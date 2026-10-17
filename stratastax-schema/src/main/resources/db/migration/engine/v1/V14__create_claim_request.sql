CREATE SEQUENCE IF NOT EXISTS claim_request_seq INCREMENT BY 50;

CREATE TABLE claim_request (
    id                   BIGINT PRIMARY KEY DEFAULT nextval('claim_request_seq'),
    public_id            UUID NOT NULL DEFAULT gen_random_uuid(),
    canonical_player_id  BIGINT NOT NULL,
    status               VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    decided_by_user_id   BIGINT,
    decided_at           TIMESTAMPTZ,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ,
    version              BIGINT NOT NULL,

    CONSTRAINT uq_claim_request_public_id UNIQUE (public_id),
    CONSTRAINT fk_claim_request_canonical_player_id FOREIGN KEY (canonical_player_id) REFERENCES canonical_player (id),
    CONSTRAINT fk_claim_request_decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_claim_request_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_claim_request_decided
        CHECK ((status = 'PENDING' AND decided_at IS NULL) OR (status <> 'PENDING' AND decided_at IS NOT NULL))
);

CREATE INDEX ix_claim_request_canonical_player_id ON claim_request (canonical_player_id);
CREATE INDEX ix_claim_request_decided_by_user_id ON claim_request (decided_by_user_id);

COMMENT ON TABLE claim_request IS
    'A proposal to link ghost players to a canonical player. Approval creates a claim edge per ghost '
    'player. Invariant (application): deleted ghost players cannot be claimed.';

CREATE TABLE claim_request_target (
    claim_request_id BIGINT NOT NULL,
    ghost_player_id  BIGINT NOT NULL,

    PRIMARY KEY (claim_request_id, ghost_player_id),
    CONSTRAINT fk_claim_request_target_claim_request_id FOREIGN KEY (claim_request_id) REFERENCES claim_request (id),
    CONSTRAINT fk_claim_request_target_ghost_player_id FOREIGN KEY (ghost_player_id) REFERENCES ghost_player (id)
);

CREATE INDEX ix_claim_request_target_ghost_player_id ON claim_request_target (ghost_player_id);
