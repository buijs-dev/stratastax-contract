WITH recorders AS (
    SELECT id, display_name FROM app_user
),
ghost_names AS (
    SELECT * FROM (VALUES
        ('Peter'), ('Nora'), ('Mystery Guest')
    ) AS t(ghost_name)
)
INSERT INTO ghost_player (owner_user_id, display_name, version)
SELECT r.id, gn.ghost_name || ' (' || r.display_name || '''s list)', 0
FROM recorders r
CROSS JOIN ghost_names gn;

INSERT INTO claim_edge (canonical_player_id, ghost_player_id)
SELECT cp.id, gp.id
FROM ghost_player gp
JOIN canonical_player cp ON cp.display_name = 'Peter'
WHERE gp.display_name LIKE 'Peter (%';

INSERT INTO claim_edge (canonical_player_id, ghost_player_id)
SELECT cp.id, gp.id
FROM ghost_player gp
JOIN canonical_player cp ON cp.display_name = 'Nora'
WHERE gp.display_name LIKE 'Nora (%';
