CREATE SEQUENCE IF NOT EXISTS claim_edge_seq INCREMENT BY 50;

CREATE TABLE claim_edge (
    id                            BIGINT PRIMARY KEY DEFAULT nextval('claim_edge_seq'),
    public_id                     UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    canonical_player_id           BIGINT NOT NULL,
    ghost_player_id               BIGINT NOT NULL,
    created_via_claim_request_id  BIGINT,
    revoked_at                    TIMESTAMPTZ,
    revoked_by_user_id            BIGINT,
    created_at                    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_claim_edge_canonical_player_id_ref_canonical_player_id FOREIGN KEY (canonical_player_id) REFERENCES canonical_player (id),
    CONSTRAINT fk_claim_edge_ghost_player_id_ref_ghost_player_id FOREIGN KEY (ghost_player_id) REFERENCES ghost_player (id),
    CONSTRAINT fk_claim_edge_request_id_ref_created_via_claim_request_id FOREIGN KEY (created_via_claim_request_id) REFERENCES claim_request (id),
    CONSTRAINT fk_claim_edge_revoked_by_ref_app_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES app_user (id)
);

CREATE UNIQUE INDEX uq_claim_edge_active_ghost_player
    ON claim_edge (ghost_player_id)
    WHERE revoked_at IS NULL;

CREATE INDEX ix_claim_edge_canonical_player_id ON claim_edge (canonical_player_id);