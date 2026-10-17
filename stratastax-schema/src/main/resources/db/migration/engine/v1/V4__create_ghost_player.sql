CREATE SEQUENCE IF NOT EXISTS ghost_player_seq INCREMENT BY 50;

CREATE TABLE ghost_player (
    id             BIGINT PRIMARY KEY DEFAULT nextval('ghost_player_seq'),
    public_id      UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    owner_user_id  BIGINT NOT NULL,
    display_name   VARCHAR(100) NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ,
    version        BIGINT NOT NULL,
    CONSTRAINT fk_ghost_player_owner_user_id_ref_app_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_ghost_player_owner_user_id ON ghost_player (owner_user_id);