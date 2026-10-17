WITH grp AS (
    INSERT INTO app_group (owner_user_id, display_name, version)
    SELECT id, 'Cafe Admins', 0 FROM app_user WHERE display_name = 'Emma'
    RETURNING id
),
grp_member AS (
    INSERT INTO group_member (group_id, user_id)
    SELECT grp.id, u.id FROM grp, app_user u WHERE u.display_name = 'Alain'
),
comm AS (
    INSERT INTO community (owner_user_id, admin_group_id, name, description, join_policy, version)
    SELECT u.id, grp.id, 'Board Game Cafe Utrecht',
           'A weekly meetup for board game enthusiasts in Utrecht.', 'REQUIRES_APPROVAL', 0
    FROM grp, app_user u WHERE u.display_name = 'Emma'
    RETURNING id
)
INSERT INTO membership (community_id, user_id)
SELECT comm.id, u.id
FROM comm, app_user u
WHERE u.display_name IN ('Emma', 'Alain', 'Sara');
