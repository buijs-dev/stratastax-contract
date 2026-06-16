WITH cp AS (
    INSERT INTO canonical_player (display_name, version)
    VALUES ('Emma', 0), ('Alain', 0), ('Sara', 0), ('Ruud', 0), ('Peter', 0), ('Nora', 0)
    RETURNING id, display_name
),
u AS (
    INSERT INTO app_user (canonical_player_id, display_name, email, last_login_at)
    SELECT id, display_name, lower(display_name) || '@example.test',
           now() - (random() * interval '30 days')
    FROM cp
    RETURNING id, display_name, email
)
INSERT INTO app_user_identity (user_id, provider, provider_user_id, email, email_verified)
SELECT id, 'keycloak', 'seed-' || id, email, true
FROM u;
