CREATE SEQUENCE IF NOT EXISTS match_loadout_seq INCREMENT BY 50;

CREATE TABLE match_loadout (
    id          BIGINT PRIMARY KEY DEFAULT nextval('match_loadout_seq'),
    public_id   UUID NOT NULL DEFAULT gen_random_uuid(),
    attributes  JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    version     BIGINT NOT NULL,

    CONSTRAINT uq_match_loadout_public_id UNIQUE (public_id)
);

COMMENT ON TABLE match_loadout IS
    'Per-participant configuration of a match (faction, character, ...). Owned by the participant that refers to it (match_participant.loadout_id) and deleted together with it.';
