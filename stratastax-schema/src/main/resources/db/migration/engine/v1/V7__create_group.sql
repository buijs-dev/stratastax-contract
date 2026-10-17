-- "app_" prefix: GROUP is a reserved word in PostgreSQL (see NAMING.md).
CREATE SEQUENCE IF NOT EXISTS app_group_seq INCREMENT BY 50;

CREATE TABLE app_group (
    id            BIGINT PRIMARY KEY DEFAULT nextval('app_group_seq'),
    public_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    owner_user_id BIGINT NOT NULL,
    display_name  VARCHAR(100) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    deleted_at    TIMESTAMPTZ,
    version       BIGINT NOT NULL,

    CONSTRAINT uq_app_group_public_id UNIQUE (public_id),
    CONSTRAINT fk_app_group_owner_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_app_group_owner_user_id ON app_group (owner_user_id);

CREATE TABLE group_member (
    group_id BIGINT      NOT NULL,
    user_id  BIGINT      NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (group_id, user_id),
    CONSTRAINT fk_group_member_group_id FOREIGN KEY (group_id) REFERENCES app_group (id),
    CONSTRAINT fk_group_member_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_group_member_user_id ON group_member (user_id);

COMMENT ON TABLE app_group IS
    'A named roster of users, owned by one user, used for privileged access and community admins. '
    'Soft-deleted: a deleted group grants nothing any more, although its rows still exist.';
