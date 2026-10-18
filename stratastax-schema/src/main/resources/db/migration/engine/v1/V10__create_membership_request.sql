CREATE SEQUENCE IF NOT EXISTS membership_request_seq INCREMENT BY 50;

CREATE TABLE membership_request (
    id                  BIGINT PRIMARY KEY DEFAULT nextval('membership_request_seq'),
    public_id           UUID NOT NULL DEFAULT gen_random_uuid(),
    community_id        BIGINT NOT NULL,
    proposed_by_user_id BIGINT NOT NULL,
    status              VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    decided_by_user_id  BIGINT,
    decided_at          TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ,
    version             BIGINT NOT NULL,

    CONSTRAINT uq_membership_request_public_id UNIQUE (public_id),
    CONSTRAINT fk_membership_request_community_id FOREIGN KEY (community_id) REFERENCES community (id),
    CONSTRAINT fk_membership_request_proposed_by_user_id FOREIGN KEY (proposed_by_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_membership_request_decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_membership_request_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_membership_request_decided
        CHECK ((status = 'PENDING' AND decided_at IS NULL) OR (status <> 'PENDING' AND decided_at IS NOT NULL))
);

CREATE INDEX ix_membership_request_community_id ON membership_request (community_id);
CREATE INDEX ix_membership_request_proposed_by_user_id ON membership_request (proposed_by_user_id);
CREATE INDEX ix_membership_request_decided_by_user_id ON membership_request (decided_by_user_id);

-- At most one pending request per user and community.
CREATE UNIQUE INDEX uq_membership_request_community_id_proposed_by_user_id_pending
    ON membership_request (community_id, proposed_by_user_id)
    WHERE status = 'PENDING';

COMMENT ON TABLE membership_request IS
    'A request to join a community with the REQUIRES_APPROVAL join policy. Invariant (application): the decider is the community''s owner or a member of its admin group.';
