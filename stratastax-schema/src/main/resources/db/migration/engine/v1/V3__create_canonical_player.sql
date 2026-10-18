CREATE SEQUENCE IF NOT EXISTS canonical_player_seq INCREMENT BY 50;

CREATE TABLE canonical_player (
    id            BIGINT PRIMARY KEY DEFAULT nextval('canonical_player_seq'),
    public_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    display_name  VARCHAR(100) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    version       BIGINT NOT NULL,

    CONSTRAINT uq_canonical_player_public_id UNIQUE (public_id)
);

ALTER TABLE app_user
    ADD CONSTRAINT fk_app_user_canonical_player_id
    FOREIGN KEY (canonical_player_id) REFERENCES canonical_player (id);

COMMENT ON TABLE canonical_player IS
    'The authoritative identity of a person in gaming history, created when the user registers. Ghost players are linked to it through claim edges.';
