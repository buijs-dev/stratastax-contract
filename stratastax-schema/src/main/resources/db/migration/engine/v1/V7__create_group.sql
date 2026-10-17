CREATE SEQUENCE IF NOT EXISTS app_group_seq INCREMENT BY 50;


CREATE TABLE app_group
(
    id            BIGINT PRIMARY KEY           DEFAULT nextval('app_group_seq'),
    public_id     UUID         NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    owner_user_id BIGINT       NOT NULL,
    display_name  VARCHAR(100) NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL        DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    deleted_at    TIMESTAMPTZ,
    version       BIGINT NOT NULL,
    CONSTRAINT fk_app_group_owner_user_id_ref_app_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id)
);



CREATE INDEX ix_app_group_owner_user_id ON app_group (owner_user_id);

CREATE TABLE group_member
(
    group_id BIGINT      NOT NULL,
    user_id  BIGINT      NOT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (group_id, user_id),
    CONSTRAINT fk_group_member_group_id_ref_app_group_id FOREIGN KEY (group_id) REFERENCES app_group (id),
    CONSTRAINT fk_group_member_user_id_ref_app_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
);