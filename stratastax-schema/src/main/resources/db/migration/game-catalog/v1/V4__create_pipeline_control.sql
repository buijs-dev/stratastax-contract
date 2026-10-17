-- Run state of each automatic pipeline step. A step runs only when it is not paused (through the
-- API) and not suspended (an external service answered 5xx/429; suspended_until is when it may
-- try again).
CREATE TABLE pipeline_control (
    step             VARCHAR(32) PRIMARY KEY,
    paused           BOOLEAN NOT NULL DEFAULT false,
    suspended_until  TIMESTAMPTZ,
    suspend_reason   TEXT,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_pipeline_control_step
        CHECK (step IN ('ENRICH_FROM_BGG', 'COLLECT_RULES', 'INTERPRET_RULES', 'PUBLISH'))
);

INSERT INTO pipeline_control (step) VALUES
    ('ENRICH_FROM_BGG'),
    ('COLLECT_RULES'),
    ('INTERPRET_RULES'),
    ('PUBLISH');
