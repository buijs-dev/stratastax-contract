CREATE SEQUENCE raw_artifact_seq
    START WITH 1
    INCREMENT BY 50;

CREATE TABLE raw_artifact (
      id           BIGINT PRIMARY KEY DEFAULT nextval('raw_artifact_seq'),
      public_id    UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
      candidate_id UUID NOT NULL REFERENCES candidate (public_id),
      source       VARCHAR(50) NOT NULL,
      content      JSONB NOT NULL,
      created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_raw_artifact_candidate_id
    ON raw_artifact (candidate_id);
