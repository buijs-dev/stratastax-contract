CREATE SEQUENCE IF NOT EXISTS community_seq INCREMENT BY 50;

CREATE TABLE community (
    id              BIGINT PRIMARY KEY DEFAULT nextval('community_seq'),
    public_id       UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    owner_user_id   BIGINT NOT NULL,
    admin_group_id  BIGINT,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    join_policy     VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,
    CONSTRAINT fk_community_owner_user_id_ref_app_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_community_admin_group_id_ref_app_group_id FOREIGN KEY (admin_group_id) REFERENCES app_group (id),
    CONSTRAINT chk_community_join_policy CHECK (join_policy IN ('OPEN', 'REQUIRES_APPROVAL'))
);

CREATE INDEX ix_community_owner_user_id ON community (owner_user_id);
CREATE INDEX ix_community_admin_group_id ON community (admin_group_id);

CREATE SEQUENCE IF NOT EXISTS membership_seq INCREMENT BY 50;

CREATE TABLE membership (
    id              BIGINT PRIMARY KEY DEFAULT nextval('membership_seq'),
    public_id       UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    community_id    BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (community_id, user_id),
    CONSTRAINT fk_membership_community_id_ref_community_id FOREIGN KEY (community_id) REFERENCES community (id),
    CONSTRAINT fk_membership_user_id_ref_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_membership_user_id ON membership (user_id);
