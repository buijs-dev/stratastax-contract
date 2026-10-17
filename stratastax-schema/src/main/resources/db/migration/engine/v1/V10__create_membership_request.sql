CREATE SEQUENCE IF NOT EXISTS membership_request_seq INCREMENT BY 50;

CREATE TABLE membership_request (
    id                  BIGINT PRIMARY KEY DEFAULT nextval('membership_request_seq'),
    public_id           UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    community_id        BIGINT NOT NULL,
    proposed_by_user_id BIGINT NOT NULL,
    decided_by_user_id  BIGINT,
    status              VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_membership_request_community_id_ref_community_id FOREIGN KEY (community_id) REFERENCES community (id),
    CONSTRAINT fk_membership_request_proposed_by_user_id_ref_app_user_id FOREIGN KEY (proposed_by_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_membership_request_decided_by_user_id_ref_app_user_id FOREIGN KEY (decided_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_membership_request_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

CREATE INDEX ix_membership_request_community_id ON membership_request (community_id);
CREATE INDEX ix_membership_request_proposed_by ON membership_request (proposed_by_user_id);
