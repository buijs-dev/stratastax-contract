-- Seed data is deterministic: fixed public ids and fixed timestamps, no random() or now(), so every
-- database built from these scripts holds exactly the same data. Public ids follow
-- 0192f000-<kind>-7000-8000-<n>, with one <kind> per table:
--   0000 game/expansion (V901)   0001 app_user          0002 canonical_player   0003 ghost_player
--   0004 app_group               0005 community         0006 playset            0007 match
--   0008 match_participant       0009 match_loadout     000a claim_edge         000b privacy_setting
--   000c membership              000d membership_request 000e claim_request     000f match_edit
--   0010 trusted_editor
-- Every timestamp is relative to 2026-01-01 12:00 UTC.

-- Six users, each with a canonical player and an identity.
WITH person (n, display_name) AS (
    VALUES (1, 'Emma'), (2, 'Alain'), (3, 'Sara'), (4, 'Ruud'), (5, 'Peter'), (6, 'Nora')
),
cp AS (
    INSERT INTO canonical_player (public_id, display_name, created_at, version)
    SELECT format('0192f000-0002-7000-8000-%s', lpad(to_hex(n), 12, '0'))::uuid, display_name,
           timestamptz '2026-01-01 12:00+00' - (60 - n) * interval '1 day', 0
    FROM person
    RETURNING id, display_name, created_at
),
u AS (
    INSERT INTO app_user (public_id, canonical_player_id, display_name, email, last_login_at, created_at, version)
    SELECT format('0192f000-0001-7000-8000-%s', lpad(to_hex(p.n), 12, '0'))::uuid, cp.id, cp.display_name,
           lower(cp.display_name) || '@example.test',
           timestamptz '2026-01-01 12:00+00' - p.n * interval '1 hour', cp.created_at, 0
    FROM cp
    JOIN person p ON p.display_name = cp.display_name
    RETURNING id, email, created_at
)
INSERT INTO app_user_identity (user_id, provider, provider_user_id, email, email_verified, created_at)
SELECT id, 'keycloak', 'seed-' || split_part(email, '@', 1), email, true, created_at
FROM u;

-- Every user has a self ghost player, claimed by their own canonical player.
INSERT INTO ghost_player (public_id, owner_user_id, display_name, is_self, created_at, version)
SELECT format('0192f000-0003-7000-8000-%s', lpad(to_hex(row_number() OVER (ORDER BY u.id)), 12, '0'))::uuid,
       u.id, u.display_name, true, u.created_at, 0
FROM app_user u;

INSERT INTO claim_edge (public_id, canonical_player_id, ghost_player_id, created_at, version)
SELECT format('0192f000-000a-7000-8000-%s', lpad(to_hex(row_number() OVER (ORDER BY gp.id)), 12, '0'))::uuid,
       u.canonical_player_id, gp.id, gp.created_at, 0
FROM ghost_player gp
JOIN app_user u ON u.id = gp.owner_user_id
WHERE gp.is_self;

-- Every user has exactly one privacy setting per data type; Sara's profile is public. Emma's
-- MATCH_HISTORY is made PRIVILEGED_ACCESS in V902, once her group exists.
INSERT INTO privacy_setting (public_id, user_id, data_type, level, created_at, version)
SELECT format('0192f000-000b-7000-8000-%s', lpad(to_hex(row_number() OVER (ORDER BY u.id, dt.ord)), 12, '0'))::uuid,
       u.id, dt.data_type,
       CASE WHEN u.display_name = 'Sara' AND dt.data_type = 'PROFILE' THEN 'PUBLIC' ELSE 'PRIVATE' END,
       u.created_at, 0
FROM app_user u
CROSS JOIN (VALUES (1, 'PROFILE'), (2, 'MATCH_HISTORY'), (3, 'MATCH_DETAILS')) AS dt (ord, data_type);
