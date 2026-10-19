-- Emma's group "Cafe Admins" (with Alain) administers her community, which Emma, Alain and Sara
-- joined. Ruud's membership request is pending, Nora's was rejected by Emma.
INSERT INTO app_group (public_id, owner_user_id, display_name, created_at, version)
SELECT '0192f000-0004-7000-8000-000000000001', id, 'Cafe Admins', timestamptz '2025-11-15 12:00+00', 0
FROM app_user WHERE display_name = 'Emma';

INSERT INTO group_member (group_id, user_id, added_at)
SELECT g.id, u.id, timestamptz '2025-11-15 12:00+00'
FROM app_group g, app_user u
WHERE g.display_name = 'Cafe Admins' AND u.display_name = 'Alain';

INSERT INTO community (public_id, owner_user_id, admin_group_id, display_name, description, join_policy, created_at, version)
SELECT '0192f000-0005-7000-8000-000000000001', u.id, g.id, 'Board Game Cafe Utrecht',
       'A weekly meetup for board game enthusiasts in Utrecht.', 'REQUIRES_APPROVAL',
       timestamptz '2025-11-15 12:00+00', 0
FROM app_group g, app_user u
WHERE g.display_name = 'Cafe Admins' AND u.display_name = 'Emma';

INSERT INTO membership (public_id, community_id, user_id, joined_at, created_at)
SELECT format('0192f000-000c-7000-8000-%s', lpad(to_hex(m.n), 12, '0'))::uuid, c.id, u.id,
       timestamptz '2025-11-15 12:00+00' + m.n * interval '1 day',
       timestamptz '2025-11-15 12:00+00' + m.n * interval '1 day'
FROM community c
JOIN (VALUES (1, 'Emma'), (2, 'Alain'), (3, 'Sara')) AS m (n, display_name) ON true
JOIN app_user u ON u.display_name = m.display_name;

INSERT INTO membership_request (public_id, community_id, proposed_by_user_id, status, decided_by_user_id, decided_at, created_at, version)
SELECT r.public_id::uuid, c.id, p.id, r.status, d.id, r.decided_at::timestamptz, r.created_at::timestamptz, 0
FROM community c
JOIN (VALUES
    ('0192f000-000d-7000-8000-000000000001', 'Ruud', 'PENDING',  NULL,   NULL,                     '2025-12-20 12:00+00'),
    ('0192f000-000d-7000-8000-000000000002', 'Nora', 'REJECTED', 'Emma', '2025-12-02 12:00+00',     '2025-12-01 12:00+00')
) AS r (public_id, proposer, status, decider, decided_at, created_at) ON true
JOIN app_user p ON p.display_name = r.proposer
LEFT JOIN app_user d ON d.display_name = r.decider;

-- Emma shares her match history with her group.
UPDATE privacy_setting ps
SET level = 'PRIVILEGED_ACCESS', updated_at = timestamptz '2025-11-16 12:00+00', version = 1
FROM app_user u
WHERE u.id = ps.user_id AND u.display_name = 'Emma' AND ps.data_type = 'MATCH_HISTORY';

INSERT INTO privacy_setting_group (privacy_setting_id, group_id)
SELECT ps.id, g.id
FROM privacy_setting ps
JOIN app_user u ON u.id = ps.user_id
JOIN app_group g ON g.owner_user_id = u.id
WHERE u.display_name = 'Emma' AND ps.data_type = 'MATCH_HISTORY' AND g.display_name = 'Cafe Admins';
