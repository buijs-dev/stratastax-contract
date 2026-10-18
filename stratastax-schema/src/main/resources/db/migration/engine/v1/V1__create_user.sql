-- "app_" prefix: USER is a reserved word in PostgreSQL (see NAMING.md).
CREATE SEQUENCE IF NOT EXISTS app_user_seq INCREMENT BY 50;

CREATE TABLE app_user (
    id                  BIGINT PRIMARY KEY DEFAULT nextval('app_user_seq'),
    public_id           UUID NOT NULL DEFAULT gen_random_uuid(),
    canonical_player_id BIGINT NOT NULL, -- FK added in V3, after canonical_player exists
    display_name        VARCHAR(100) NOT NULL,
    email               VARCHAR(255),
    last_login_at       TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ,
    version             BIGINT NOT NULL,

    CONSTRAINT uq_app_user_public_id UNIQUE (public_id),
    CONSTRAINT uq_app_user_canonical_player_id UNIQUE (canonical_player_id)
);

CREATE INDEX ix_app_user_email ON app_user (email);

COMMENT ON TABLE app_user IS
    'A person with an account. Created together with their canonical player, their self ghost player and their three privacy settings (PROFILE, MATCH_HISTORY, MATCH_DETAILS, all PRIVATE).';
