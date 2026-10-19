CREATE SEQUENCE IF NOT EXISTS expansion_seq INCREMENT BY 50;

CREATE TABLE expansion (
    id            BIGINT PRIMARY KEY DEFAULT nextval('expansion_seq'),
    public_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    game_id       BIGINT NOT NULL,
    display_name  VARCHAR(255) NOT NULL,
    description   TEXT,
    image_url     VARCHAR(500),
    source_ref    VARCHAR(64),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    version       BIGINT NOT NULL,

    CONSTRAINT uq_expansion_public_id UNIQUE (public_id),
    CONSTRAINT uq_expansion_source_ref UNIQUE (source_ref),
    CONSTRAINT fk_expansion_game_id FOREIGN KEY (game_id) REFERENCES game (id)
);

CREATE INDEX ix_expansion_game_id ON expansion (game_id);

COMMENT ON TABLE expansion IS
    'An expansion of a game; it has no meaning on its own.';
COMMENT ON COLUMN expansion.source_ref IS
    'Where the expansion came from, e.g. ''bgg:199727''; unique like game.source_ref. NULL for one entered by hand.';
