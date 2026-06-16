CREATE SEQUENCE IF NOT EXISTS app_user_seq INCREMENT BY 50;

CREATE TABLE app_user (
    id                  BIGINT PRIMARY KEY DEFAULT nextval('app_user_seq'),
    public_id           UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    canonical_player_id BIGINT NOT NULL, -- FK added in V3, after canonical_player exists
    display_name        VARCHAR(100) NOT NULL,
    email               VARCHAR(255),
    last_login_at       TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ
);

CREATE UNIQUE INDEX uq_app_user_canonical_player_id ON app_user (canonical_player_id);
CREATE INDEX ix_app_user_email ON app_user (email);