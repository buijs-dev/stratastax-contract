CREATE SEQUENCE IF NOT EXISTS loadout_seq INCREMENT BY 50;

CREATE TABLE loadout (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('loadout_seq'),
    public_id             UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    match_participant_id  BIGINT NOT NULL,
    attributes            JSONB NOT NULL DEFAULT '{}',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    version               BIGINT NOT NULL,
    CONSTRAINT fk_loadout_match_participant_id_ref_match_participant_id FOREIGN KEY (match_participant_id) REFERENCES match_participant (id)
);

CREATE UNIQUE INDEX uq_loadout_match_participant_id ON loadout (match_participant_id);
