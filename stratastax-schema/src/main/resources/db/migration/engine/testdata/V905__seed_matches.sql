-- 520 matches over the two years before 2026-01-01, picked deterministically from the match number
-- i: the game, the recorder, the participants and their results all follow from i. One in five
-- matches is recorded in the community (by a member), every second one uses a playset of its game
-- with that playset's expansions, and three in four are finalized.
DO $$
DECLARE
    base_at            CONSTANT TIMESTAMPTZ := timestamptz '2026-01-01 12:00+00';
    factions           CONSTANT TEXT[] := ARRAY['Crimean Khanate', 'Nordic Kingdom', 'Rusviet Union', 'Polania Republic', 'Saxony Empire'];
    game_ids           BIGINT[];
    user_ids           BIGINT[];
    member_ids         BIGINT[];
    community_row_id   BIGINT;
    g                  RECORD;
    i                  INT;
    j                  INT;
    recorder_id        BIGINT;
    participant_count  INT;
    match_row_id       BIGINT;
    playset_row_id     BIGINT;
    played             TIMESTAMPTZ;
    self_ghost_id      BIGINT;
    other_ghost_ids    BIGINT[];
    ghost_id           BIGINT;
    loadout_row_id     BIGINT;
BEGIN
    SELECT array_agg(id ORDER BY public_id) INTO game_ids FROM game;
    SELECT array_agg(id ORDER BY id) INTO user_ids FROM app_user;
    SELECT id INTO community_row_id FROM community WHERE display_name = 'Board Game Cafe Utrecht';
    SELECT array_agg(user_id ORDER BY user_id) INTO member_ids FROM membership WHERE community_id = community_row_id;

    FOR i IN 1..520 LOOP
        SELECT * INTO g FROM game WHERE id = game_ids[1 + (i * 7) % array_length(game_ids, 1)];

        IF i % 5 = 0 THEN
            recorder_id := member_ids[1 + i % array_length(member_ids, 1)];
        ELSE
            recorder_id := user_ids[1 + (i * 5) % array_length(user_ids, 1)];
        END IF;

        participant_count := g.min_players + (i * 3) % (g.max_players - g.min_players + 1);
        played := base_at - i * interval '1 day' - ((i * 37) % 24) * interval '1 hour';

        playset_row_id := NULL;
        IF i % 2 = 0 THEN
            SELECT id INTO playset_row_id FROM playset WHERE game_id = g.id ORDER BY id LIMIT 1;
        END IF;

        INSERT INTO match (public_id, game_id, playset_id, community_id, recorder_user_id, played_at,
                           finalized_at, created_at, version)
        VALUES (format('0192f000-0007-7000-8000-%s', lpad(to_hex(i), 12, '0'))::uuid,
                g.id, playset_row_id,
                CASE WHEN i % 5 = 0 THEN community_row_id END,
                recorder_id, played,
                CASE WHEN i % 4 <> 0 THEN played + interval '2 hours' END,
                played + interval '1 hour', 0)
        RETURNING id INTO match_row_id;

        INSERT INTO match_expansion (match_id, expansion_id)
        SELECT match_row_id, expansion_id FROM playset_expansion WHERE playset_id = playset_row_id;

        -- The recorder plays every match (self ghost first), with a rotating window of their other ghosts.
        SELECT id INTO self_ghost_id FROM ghost_player WHERE owner_user_id = recorder_id AND is_self;
        SELECT array_agg(id ORDER BY id) INTO other_ghost_ids
        FROM ghost_player WHERE owner_user_id = recorder_id AND NOT is_self AND deleted_at IS NULL;

        FOR j IN 1..participant_count LOOP
            IF j = 1 THEN
                ghost_id := self_ghost_id;
            ELSE
                ghost_id := other_ghost_ids[1 + (i + j - 2) % array_length(other_ghost_ids, 1)];
            END IF;

            -- A faction for most participants of faction-driven games.
            loadout_row_id := NULL;
            IF g.display_name IN ('Scythe', 'Root') AND (i + j) % 5 <> 0 THEN
                INSERT INTO match_loadout (public_id, attributes, created_at, version)
                VALUES (format('0192f000-0009-7000-8000-%s', lpad(to_hex(i * 10 + j), 12, '0'))::uuid,
                        jsonb_build_object('faction', factions[1 + (i + j) % array_length(factions, 1)]),
                        played + interval '1 hour', 0)
                RETURNING id INTO loadout_row_id;
            END IF;

            INSERT INTO match_participant (public_id, match_id, ghost_player_id, loadout_id, score, outcome, created_at, version)
            VALUES (format('0192f000-0008-7000-8000-%s', lpad(to_hex(i * 10 + j), 12, '0'))::uuid,
                    match_row_id, ghost_id, loadout_row_id,
                    CASE g.score_type
                        WHEN 'SCORE' THEN 10 + (i * 31 + j * 17) % 190
                        WHEN 'TIME'  THEN 50 + (i * 13 + j * 29) % 550  -- seconds
                        WHEN 'TURNS' THEN 5 + (i * 11 + j * 7) % 40
                    END,
                    CASE WHEN g.score_type = 'WIN_LOSS'
                         THEN CASE WHEN j = 1 + i % participant_count THEN 'WIN' ELSE 'LOSS' END
                    END,
                    played + interval '1 hour', 0);
        END LOOP;
    END LOOP;
END $$;

-- Rank SCORE/TIME/TURNS participants on their score within the match; the sign is flipped for
-- LOWER_WINS games so RANK() can order descending regardless of the win direction.
WITH ranked AS (
    SELECT mp.id,
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

-- Nora disputes her result in the first finalized SCORE match she played in.
UPDATE match_participant mp
SET dispute_reason      = 'I scored 12 points more: the end-game bonus was not counted.',
    disputed_at         = m.finalized_at + interval '1 day',
    disputed_by_user_id = u.id,
    updated_at          = m.finalized_at + interval '1 day',
    version             = mp.version + 1
FROM match m, game g, app_user u
WHERE mp.id = (
        SELECT mp2.id
        FROM match_participant mp2
        JOIN match m2 ON m2.id = mp2.match_id
        JOIN game g2 ON g2.id = m2.game_id
        JOIN claim_edge ce ON ce.ghost_player_id = mp2.ghost_player_id AND ce.revoked_at IS NULL
        JOIN canonical_player cp ON cp.id = ce.canonical_player_id
        WHERE cp.display_name = 'Nora' AND g2.score_type = 'SCORE' AND m2.finalized_at IS NOT NULL
        ORDER BY m2.id, mp2.id
        LIMIT 1)
  AND m.id = mp.match_id AND g.id = m.game_id AND u.display_name = 'Nora';

-- Peter proposes a change to the first finalized match he played in that was played without the
-- expansions of its game: 5 more points for himself, and the game's expansions. The recorder has
-- not decided yet.
WITH target AS (
    SELECT m.id AS match_id, m.game_id, m.finalized_at, mp.id AS participant_id, mp.score
    FROM match m
    JOIN match_participant mp ON mp.match_id = m.id
    JOIN claim_edge ce ON ce.ghost_player_id = mp.ghost_player_id AND ce.revoked_at IS NULL
    JOIN canonical_player cp ON cp.id = ce.canonical_player_id
    WHERE cp.display_name = 'Peter' AND m.finalized_at IS NOT NULL
      AND EXISTS (SELECT 1 FROM expansion e WHERE e.game_id = m.game_id)
      AND NOT EXISTS (SELECT 1 FROM match_expansion me WHERE me.match_id = m.id)
    ORDER BY m.id, mp.id
    LIMIT 1
),
edit AS (
    INSERT INTO match_edit (public_id, match_id, proposed_by_user_id, expansions_set, created_at, version)
    SELECT '0192f000-000f-7000-8000-000000000001', t.match_id, u.id, true, t.finalized_at + interval '2 days', 0
    FROM target t, app_user u
    WHERE u.display_name = 'Peter'
    RETURNING id
),
participant_change AS (
    INSERT INTO match_edit_participant_change (public_id, match_edit_id, match_participant_id, score, score_set, created_at)
    SELECT '0192f000-000f-7000-8000-000000000101', e.id, t.participant_id, t.score + 5, true, t.finalized_at + interval '2 days'
    FROM edit e, target t
)
INSERT INTO match_edit_expansion_change (match_edit_id, expansion_id)
SELECT e.id, x.id
FROM edit e, target t
JOIN expansion x ON x.game_id = t.game_id;
