-- A self ghost player, and its claim edge, for every seeded user (see V22__self_ghost_player).
INSERT INTO ghost_player (owner_user_id, display_name, is_self, version)
SELECT u.id, u.display_name, true, 0
FROM app_user u
WHERE NOT EXISTS (
    SELECT 1 FROM ghost_player gp WHERE gp.owner_user_id = u.id AND gp.is_self
);

INSERT INTO claim_edge (canonical_player_id, ghost_player_id)
SELECT u.canonical_player_id, gp.id
FROM ghost_player gp
JOIN app_user u ON u.id = gp.owner_user_id
WHERE gp.is_self
  AND NOT EXISTS (
    SELECT 1 FROM claim_edge ce WHERE ce.ghost_player_id = gp.id AND ce.revoked_at IS NULL
);
