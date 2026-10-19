-- Idempotency-Key records of the stratastax-http idempotency-reactive module (reference DDL
-- db/stratastax/idempotency/idempotency_record.sql). Holds the response of every mutating request
-- (POST, PUT, PATCH, DELETE) for replay. No public_id, version or updated_at: the table belongs to
-- the module, not to the domain.
CREATE TABLE idempotency_record (
    scope                 VARCHAR(255)  NOT NULL,
    request_id            UUID          NOT NULL,
    request_method        VARCHAR(16)   NOT NULL,
    request_path          VARCHAR(2048) NOT NULL,
    request_checksum      VARCHAR(64)   NOT NULL,
    response_code         INTEGER,
    response_content_type VARCHAR(255),
    response_body         TEXT,
    created_at            TIMESTAMPTZ   NOT NULL DEFAULT now(),

    PRIMARY KEY (scope, request_id)
);

CREATE INDEX ix_idempotency_record_created_at ON idempotency_record (created_at);
