CREATE SEQUENCE IF NOT EXISTS loadout_seq INCREMENT BY 50;

CREATE TABLE loadout (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('loadout_seq'),
    public_id             UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    attributes            JSONB NOT NULL DEFAULT '{}',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    version               BIGINT NOT NULL
);

