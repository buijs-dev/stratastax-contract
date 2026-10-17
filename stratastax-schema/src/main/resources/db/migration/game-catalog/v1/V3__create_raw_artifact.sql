CREATE SEQUENCE IF NOT EXISTS raw_artifact_seq INCREMENT BY 50;

CREATE TABLE raw_artifact (
    id            BIGINT PRIMARY KEY DEFAULT nextval('raw_artifact_seq'),
    public_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    candidate_id  BIGINT NOT NULL,
    source        VARCHAR(50) NOT NULL,
    content       JSONB NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,

    CONSTRAINT uq_raw_artifact_public_id UNIQUE (public_id),
    CONSTRAINT fk_raw_artifact_candidate_id FOREIGN KEY (candidate_id) REFERENCES candidate (id)
);

CREATE INDEX ix_raw_artifact_candidate_id ON raw_artifact (candidate_id);

COMMENT ON TABLE raw_artifact IS
    'Source material behind a candidate, as received: the BGG API response, the web search result and '
    'the LLM extraction.';
