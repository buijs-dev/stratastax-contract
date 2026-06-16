DO $$
DECLARE
    all_user_ids            BIGINT[];
    community_row_id        BIGINT;
    community_member_ids    BIGINT[];
    faction_game_ids        BIGINT[];
    factions                TEXT[] := ARRAY['Crimean Khanate', 'Nordic Kingdom', 'Rusviet Union', 'Polania Republic', 'Saxony Empire'];

    i                       INT;
    j                       INT;
    chosen_game_id          BIGINT;
    chosen_min_players      INT;
    chosen_max_players      INT;
    chosen_score_type       VARCHAR;
    participant_count       INT;
    recorder_id             BIGINT;
    match_row_id            BIGINT;
    playset_row_id          BIGINT;
    use_community           BOOLEAN;
    recorder_ghost_ids      BIGINT[];
    selected_ghost_ids      BIGINT[];
    win_index                INT;
    raw_score                NUMERIC;
BEGIN
    SELECT array_agg(id) INTO all_user_ids FROM app_user;
    SELECT id INTO community_row_id FROM community WHERE name = 'Board Game Cafe Utrecht';
    SELECT array_agg(user_id) INTO community_member_ids FROM membership WHERE community_id = community_row_id;
    SELECT array_agg(id) INTO faction_game_ids FROM game WHERE name IN ('Scythe', 'Root');

    FOR i IN 1..520 LOOP
        SELECT id, min_players, max_players, score_type
          INTO chosen_game_id, chosen_min_players, chosen_max_players, chosen_score_type
          FROM game
          ORDER BY random()
          LIMIT 1;

        participant_count := chosen_min_players
            + floor(random() * (chosen_max_players - chosen_min_players + 1))::INT;

        use_community := community_row_id IS NOT NULL AND random() < 0.2;

        IF use_community THEN
            recorder_id := community_member_ids[1 + floor(random() * array_length(community_member_ids, 1))::INT];
        ELSE
            recorder_id := all_user_ids[1 + floor(random() * array_length(all_user_ids, 1))::INT];
        END IF;

        -- A matching Playset, used about half the time when one exists.
        playset_row_id := NULL;
        IF random() < 0.5 THEN
            SELECT id INTO playset_row_id
              FROM playset
              WHERE game_id = chosen_game_id
              ORDER BY random()
              LIMIT 1;
        END IF;

        INSERT INTO match (game_id, playset_id, community_id, recorder_user_id, played_at, version)
        VALUES (
            chosen_game_id,
            playset_row_id,
            CASE WHEN use_community THEN community_row_id ELSE NULL END,
            recorder_id,
            now() - (random() * interval '730 days'),
            0
        )
        RETURNING id INTO match_row_id;

        SELECT array_agg(id) INTO recorder_ghost_ids FROM ghost_player WHERE owner_user_id = recorder_id;
        participant_count := LEAST(participant_count, COALESCE(array_length(recorder_ghost_ids, 1), 0));

        SELECT array_agg(gid) INTO selected_ghost_ids
        FROM (
            SELECT unnest(recorder_ghost_ids) AS gid ORDER BY random() LIMIT participant_count
        ) shuffled;

        win_index := 1 + floor(random() * GREATEST(participant_count, 1))::INT;

        FOR j IN 1..COALESCE(array_length(selected_ghost_ids, 1), 0) LOOP
            IF chosen_score_type = 'WIN_LOSS' THEN
                INSERT INTO match_participant (match_id, ghost_player_id, outcome, version)
                VALUES (match_row_id, selected_ghost_ids[j], CASE WHEN j = win_index THEN 'WIN' ELSE 'LOSS' END, 0);
            ELSIF chosen_score_type = 'SCORE' THEN
                raw_score := round((random() * 190 + 10)::NUMERIC, 0);
                INSERT INTO match_participant (match_id, ghost_player_id, score, version)
                VALUES (match_row_id, selected_ghost_ids[j], raw_score, 0);
            ELSIF chosen_score_type = 'TIME' THEN
                raw_score := round((random() * 550 + 50)::NUMERIC, 0); -- seconds
                INSERT INTO match_participant (match_id, ghost_player_id, score, version)
                VALUES (match_row_id, selected_ghost_ids[j], raw_score, 0);
            ELSE -- TURNS
                raw_score := round((random() * 40 + 5)::NUMERIC, 0);
                INSERT INTO match_participant (match_id, ghost_player_id, score, version)
                VALUES (match_row_id, selected_ghost_ids[j], raw_score, 0);
            END IF;

            -- Occasional Loadout for faction-driven games.
            IF chosen_game_id = ANY(faction_game_ids) AND random() < 0.8 THEN
                INSERT INTO loadout (match_participant_id, attributes, version)
                SELECT mp.id, jsonb_build_object('faction', factions[1 + floor(random() * array_length(factions, 1))::INT]), 0
                FROM match_participant mp
                WHERE mp.match_id = match_row_id AND mp.ghost_player_id = selected_ghost_ids[j];
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- Second pass: backfill rank for SCORE/TIME/TURNS participants, based on relative score
-- within each match. Sign is flipped for LOWER_WINS games so RANK() can uniformly order
-- descending regardless of win direction.
WITH ranked AS (
    SELECT
        mp.id,
        RANK() OVER (
            PARTITION BY mp.match_id
            ORDER BY mp.score * (CASE WHEN g.win_condition = 'LOWER_WINS' THEN -1 ELSE 1 END) DESC
        ) AS computed_rank
    FROM match_participant mp
    JOIN match m ON m.id = mp.match_id
    JOIN game g ON g.id = m.game_id
    WHERE g.score_type IN ('SCORE', 'TIME', 'TURNS')
)
UPDATE match_participant mp
SET rank = ranked.computed_rank
FROM ranked
WHERE mp.id = ranked.id;
