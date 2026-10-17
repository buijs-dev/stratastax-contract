CREATE SEQUENCE IF NOT EXISTS expansion_seq INCREMENT BY 50;

CREATE TABLE expansion (
    id          BIGINT PRIMARY KEY DEFAULT nextval('expansion_seq'),
    public_id   UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    game_id     BIGINT NOT NULL,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    image_url   VARCHAR(500),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    version     BIGINT NOT NULL,
    CONSTRAINT fk_expansion_game_id_ref_game_id FOREIGN KEY (game_id) REFERENCES game (id)
);

CREATE INDEX ix_expansion_game_id ON expansion (game_id);