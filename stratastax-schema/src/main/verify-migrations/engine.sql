-- Seed data of the engine. Every query returns one row per violation.

SELECT 'expected 6 users, found ' || count(*) FROM app_user HAVING count(*) <> 6;
SELECT 'expected 520 matches, found ' || count(*) FROM match HAVING count(*) <> 520;

SELECT 'user without exactly one self ghost player: ' || u.display_name
FROM app_user u
WHERE (SELECT count(*) FROM ghost_player gp WHERE gp.owner_user_id = u.id AND gp.is_self) <> 1;

SELECT 'self ghost player without an active claim edge to its owner: ' || gp.display_name
FROM ghost_player gp
JOIN app_user u ON u.id = gp.owner_user_id
WHERE gp.is_self
  AND NOT EXISTS (SELECT 1 FROM claim_edge ce
                  WHERE ce.ghost_player_id = gp.id AND ce.canonical_player_id = u.canonical_player_id
                    AND ce.revoked_at IS NULL);

SELECT 'user without exactly 3 privacy settings: ' || u.display_name
FROM app_user u
WHERE (SELECT count(*) FROM privacy_setting ps WHERE ps.user_id = u.id) <> 3;

SELECT 'match with a player count outside the game''s range: ' || m.public_id
FROM match m
JOIN game g ON g.id = m.game_id
WHERE (SELECT count(*) FROM match_participant mp WHERE mp.match_id = m.id) NOT BETWEEN g.min_players AND g.max_players;

SELECT 'match without its recorder''s self ghost player: ' || m.public_id
FROM match m
WHERE NOT EXISTS (SELECT 1 FROM match_participant mp
                  JOIN ghost_player gp ON gp.id = mp.ghost_player_id
                  WHERE mp.match_id = m.id AND gp.is_self AND gp.owner_user_id = m.recorder_user_id);

SELECT 'match with a playset of another game: ' || m.public_id
FROM match m JOIN playset p ON p.id = m.playset_id
WHERE p.game_id <> m.game_id;

SELECT 'match with an expansion of another game: ' || m.public_id
FROM match m
JOIN match_expansion me ON me.match_id = m.id
JOIN expansion e ON e.id = me.expansion_id
WHERE e.game_id <> m.game_id;

SELECT 'expected 1 disputed participant, found ' || count(*)
FROM match_participant WHERE dispute_reason IS NOT NULL HAVING count(*) <> 1;

SELECT 'expected 1 pending match edit with a participant and an expansion change'
WHERE NOT EXISTS (
    SELECT 1 FROM match_edit e
    WHERE e.status = 'PENDING' AND e.expansions_set
      AND EXISTS (SELECT 1 FROM match_edit_participant_change pc WHERE pc.match_edit_id = e.id)
      AND EXISTS (SELECT 1 FROM match_edit_expansion_change xc WHERE xc.match_edit_id = e.id)
);

SELECT 'expected a pending claim request, a pending membership request and a trusted editor'
WHERE NOT EXISTS (SELECT 1 FROM claim_request WHERE status = 'PENDING')
   OR NOT EXISTS (SELECT 1 FROM membership_request WHERE status = 'PENDING')
   OR NOT EXISTS (SELECT 1 FROM trusted_editor WHERE revoked_at IS NULL);
