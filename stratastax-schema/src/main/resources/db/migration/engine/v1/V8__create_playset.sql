CREATE SEQUENCE IF NOT EXISTS playset_seq INCREMENT BY 50;

CREATE TABLE playset (
    id              BIGINT PRIMARY KEY DEFAULT nextval('playset_seq'),
    public_id       UUID NOT NULL DEFAULT gen_random_uuid(),
    owner_user_id   BIGINT NOT NULL,
    game_id         BIGINT NOT NULL,
    display_name    VARCHAR(100),
    variants        TEXT[] NOT NULL DEFAULT '{}',
    scenario        VARCHAR(200),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,

    CONSTRAINT uq_playset_public_id UNIQUE (public_id),
    CONSTRAINT fk_playset_owner_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_playset_game_id FOREIGN KEY (game_id) REFERENCES game (id)
);

CREATE INDEX ix_playset_owner_user_id ON playset (owner_user_id);
CREATE INDEX ix_playset_game_id ON playset (game_id);

CREATE TABLE playset_expansion (
    playset_id   BIGINT NOT NULL,
    expansion_id BIGINT NOT NULL,

    PRIMARY KEY (playset_id, expansion_id),
    CONSTRAINT fk_playset_expansion_playset_id FOREIGN KEY (playset_id) REFERENCES playset (id),
    CONSTRAINT fk_playset_expansion_expansion_id FOREIGN KEY (expansion_id) REFERENCES expansion (id)
);

CREATE INDEX ix_playset_expansion_expansion_id ON playset_expansion (expansion_id);

COMMENT ON TABLE playset IS
    'A reusable match configuration (variants, scenario, expansions) for one game. Soft-deleted: '
    'matches keep referring to a deleted playset, but it can no longer be chosen. '
    'Invariant (application): its expansions belong to its game.';
