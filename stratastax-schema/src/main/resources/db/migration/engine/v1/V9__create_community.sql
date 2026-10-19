CREATE SEQUENCE IF NOT EXISTS community_seq INCREMENT BY 50;

CREATE TABLE community (
    id              BIGINT PRIMARY KEY DEFAULT nextval('community_seq'),
    public_id       UUID NOT NULL DEFAULT gen_random_uuid(),
    owner_user_id   BIGINT NOT NULL,
    admin_group_id  BIGINT,
    display_name    VARCHAR(100) NOT NULL,
    description     TEXT,
    join_policy     VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,

    CONSTRAINT uq_community_public_id UNIQUE (public_id),
    CONSTRAINT fk_community_owner_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_community_admin_group_id FOREIGN KEY (admin_group_id) REFERENCES app_group (id),
    CONSTRAINT chk_community_join_policy CHECK (join_policy IN ('OPEN', 'REQUIRES_APPROVAL'))
);

CREATE INDEX ix_community_owner_user_id ON community (owner_user_id);
CREATE INDEX ix_community_admin_group_id ON community (admin_group_id);

COMMENT ON TABLE community IS
    'A set of users with a shared match history. Soft-deleted. Invariants (application): the admin group, if set, is owned by the community''s owner and is cleared when ownership is transferred; only the owner may remove an admin, any admin may remove a non-admin member; an admin who leaves or is removed is also removed from the admin group.';

CREATE SEQUENCE IF NOT EXISTS membership_seq INCREMENT BY 50;

CREATE TABLE membership (
    id              BIGINT PRIMARY KEY DEFAULT nextval('membership_seq'),
    public_id       UUID NOT NULL DEFAULT gen_random_uuid(),
    community_id    BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,

    CONSTRAINT uq_membership_public_id UNIQUE (public_id),
    CONSTRAINT uq_membership_community_id_user_id UNIQUE (community_id, user_id),
    CONSTRAINT fk_membership_community_id FOREIGN KEY (community_id) REFERENCES community (id),
    CONSTRAINT fk_membership_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_membership_user_id ON membership (user_id);

COMMENT ON TABLE membership IS
    'A user''s membership of a community; joined_at is when they joined.';
