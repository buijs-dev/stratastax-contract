-- Besides their self ghost player, every user keeps 7 ghost players: one per other user and two
-- guests, so a recorder always has enough players for every seeded game (at most 8). Emma also
-- has a deleted ghost player.
INSERT INTO ghost_player (public_id, owner_user_id, display_name, created_at, deleted_at, version)
SELECT format('0192f000-0003-7000-8000-%s', lpad(to_hex(100 + row_number() OVER (ORDER BY r.id, gn.ord, gn.ghost_name)), 12, '0'))::uuid,
       r.id, gn.ghost_name || ' (' || r.display_name || '''s list)', r.created_at, NULL::timestamptz, 0
FROM app_user r
CROSS JOIN LATERAL (
    SELECT 1 AS ord, o.display_name AS ghost_name FROM app_user o WHERE o.id <> r.id
    UNION ALL SELECT 2, 'Mystery Guest'
    UNION ALL SELECT 3, 'Second Guest'
) gn;

INSERT INTO ghost_player (public_id, owner_user_id, display_name, created_at, updated_at, deleted_at, version)
SELECT '0192f000-0003-7000-8000-000000000999', id, 'Former Roommate (Emma''s list)',
       timestamptz '2025-11-01 12:00+00', timestamptz '2025-12-01 12:00+00', timestamptz '2025-12-01 12:00+00', 1
FROM app_user WHERE display_name = 'Emma';

-- Peter and Nora claimed the ghost players named after them in every list.
INSERT INTO claim_edge (public_id, canonical_player_id, ghost_player_id, created_at, version)
SELECT format('0192f000-000a-7000-8000-%s', lpad(to_hex(100 + row_number() OVER (ORDER BY gp.id)), 12, '0'))::uuid,
       cp.id, gp.id, timestamptz '2025-12-10 12:00+00', 0
FROM ghost_player gp
JOIN canonical_player cp ON gp.display_name LIKE cp.display_name || ' (%'
WHERE cp.display_name IN ('Peter', 'Nora');

-- Ruud has a pending claim request for the ghost players named after him in Emma's and Sara's lists.
INSERT INTO claim_request (public_id, canonical_player_id, created_at, version)
SELECT '0192f000-000e-7000-8000-000000000001', id, timestamptz '2025-12-28 12:00+00', 0
FROM canonical_player WHERE display_name = 'Ruud';

INSERT INTO claim_request_target (claim_request_id, ghost_player_id)
SELECT cr.id, gp.id
FROM claim_request cr, ghost_player gp
WHERE cr.public_id = '0192f000-000e-7000-8000-000000000001'
  AND gp.display_name IN ('Ruud (Emma''s list)', 'Ruud (Sara''s list)');

-- Emma trusts Alain's match edits.
INSERT INTO trusted_editor (public_id, grantor_user_id, trustee_user_id, created_at, version)
SELECT '0192f000-0010-7000-8000-000000000001', g.id, t.id, timestamptz '2025-12-05 12:00+00', 0
FROM app_user g, app_user t
WHERE g.display_name = 'Emma' AND t.display_name = 'Alain';
