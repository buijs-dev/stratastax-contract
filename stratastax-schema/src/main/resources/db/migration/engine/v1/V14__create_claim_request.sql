CREATE SEQUENCE IF NOT EXISTS claim_request_seq INCREMENT BY 50;

CREATE TABLE claim_request (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('claim_request_seq'),
    public_id             UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    canonical_player_id   BIGINT NOT NULL,
    validated_by_user_id  BIGINT,
    status                VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_claim_request_canonical_player_id_ref_canonical_player_id FOREIGN KEY (canonical_player_id) REFERENCES canonical_player (id),
    CONSTRAINT fk_claim_request_validated_by_user_id_ref_app_user_id FOREIGN KEY (validated_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_claim_request_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

CREATE INDEX ix_claim_request_canonical_player_id ON claim_request (canonical_player_id);

CREATE TABLE claim_request_target (
    claim_request_id BIGINT NOT NULL REFERENCES claim_request (id),
    ghost_player_id  BIGINT NOT NULL REFERENCES ghost_player (id),
    CONSTRAINT fk_claim_request_target_claim_request_id_ref_claim_request_id FOREIGN KEY (claim_request_id) REFERENCES claim_request (id),
    CONSTRAINT fk_claim_request_target_ghost_player_id_ref_ghost_player_id FOREIGN KEY (ghost_player_id) REFERENCES ghost_player (id),
    PRIMARY KEY (claim_request_id, ghost_player_id)
);
