CREATE SEQUENCE IF NOT EXISTS match_loadout_seq INCREMENT BY 50;

CREATE TABLE match_loadout (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('match_loadout_seq'),
    public_id             UUID NOT NULL DEFAULT gen_random_uuid(),
    match_participant_id  BIGINT NOT NULL,
    attributes            JSONB NOT NULL DEFAULT '{}',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ,
    version               BIGINT NOT NULL,

    CONSTRAINT uq_match_loadout_public_id UNIQUE (public_id),
    CONSTRAINT uq_match_loadout_match_participant_id UNIQUE (match_participant_id),
    CONSTRAINT fk_match_loadout_match_participant_id
        FOREIGN KEY (match_participant_id) REFERENCES match_participant (id) ON DELETE CASCADE
);

COMMENT ON TABLE match_loadout IS
    'Per-participant configuration of a match (faction, character, ...). Belongs to its participant '
    'and is deleted with it.';
