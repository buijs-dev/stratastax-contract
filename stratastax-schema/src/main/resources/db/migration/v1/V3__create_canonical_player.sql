CREATE SEQUENCE IF NOT EXISTS canonical_player_seq INCREMENT BY 50;

CREATE TABLE canonical_player (
    id            BIGINT PRIMARY KEY DEFAULT nextval('canonical_player_seq'),
    public_id     UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    display_name  VARCHAR(100) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    version       BIGINT NOT NULL
);

ALTER TABLE app_user
    ADD CONSTRAINT fk_app_user_canonical_player_ref_canonical_player_id
    FOREIGN KEY (canonical_player_id) REFERENCES canonical_player (id);