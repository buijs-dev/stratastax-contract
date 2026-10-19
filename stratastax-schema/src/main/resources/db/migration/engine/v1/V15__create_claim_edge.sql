CREATE SEQUENCE IF NOT EXISTS claim_edge_seq INCREMENT BY 50;

CREATE TABLE claim_edge (
    id                            BIGINT PRIMARY KEY DEFAULT nextval('claim_edge_seq'),
    public_id                     UUID NOT NULL DEFAULT gen_random_uuid(),
    canonical_player_id           BIGINT NOT NULL,
    ghost_player_id               BIGINT NOT NULL,
    created_via_claim_request_id  BIGINT,
    revoked_at                    TIMESTAMPTZ,
    revoked_by_user_id            BIGINT,
    created_at                    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                    TIMESTAMPTZ,
    version                       BIGINT NOT NULL,

    CONSTRAINT uq_claim_edge_public_id UNIQUE (public_id),
    CONSTRAINT fk_claim_edge_canonical_player_id FOREIGN KEY (canonical_player_id) REFERENCES canonical_player (id),
    CONSTRAINT fk_claim_edge_ghost_player_id FOREIGN KEY (ghost_player_id) REFERENCES ghost_player (id),
    CONSTRAINT fk_claim_edge_created_via_claim_request_id FOREIGN KEY (created_via_claim_request_id) REFERENCES claim_request (id),
    CONSTRAINT fk_claim_edge_revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_claim_edge_revoked CHECK (revoked_at IS NOT NULL OR revoked_by_user_id IS NULL)
);

-- At most one active claim edge per ghost player.
CREATE UNIQUE INDEX uq_claim_edge_ghost_player_id_active
    ON claim_edge (ghost_player_id)
    WHERE revoked_at IS NULL;

CREATE INDEX ix_claim_edge_canonical_player_id ON claim_edge (canonical_player_id);
CREATE INDEX ix_claim_edge_created_via_claim_request_id ON claim_edge (created_via_claim_request_id);
CREATE INDEX ix_claim_edge_revoked_by_user_id ON claim_edge (revoked_by_user_id);

COMMENT ON TABLE claim_edge IS
    'The approved, revocable link between a canonical player and a ghost player. Invariant (application): the claim edge of a user''s self ghost player is never revoked.';
