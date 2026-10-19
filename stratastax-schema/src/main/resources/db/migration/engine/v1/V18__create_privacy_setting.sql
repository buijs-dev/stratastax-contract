CREATE SEQUENCE IF NOT EXISTS privacy_setting_seq INCREMENT BY 50;

CREATE TABLE privacy_setting (
    id          BIGINT PRIMARY KEY DEFAULT nextval('privacy_setting_seq'),
    public_id   UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id     BIGINT NOT NULL,
    data_type   VARCHAR(20) NOT NULL,
    level       VARCHAR(20) NOT NULL DEFAULT 'PRIVATE',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    version     BIGINT NOT NULL,

    CONSTRAINT uq_privacy_setting_public_id UNIQUE (public_id),
    CONSTRAINT uq_privacy_setting_user_id_data_type UNIQUE (user_id, data_type),
    CONSTRAINT fk_privacy_setting_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
    -- [no-codegen start]
    ,
    CONSTRAINT chk_privacy_setting_data_type
        CHECK (data_type IN ('PROFILE', 'MATCH_HISTORY', 'MATCH_DETAILS')),
    CONSTRAINT chk_privacy_setting_level
        CHECK (level IN ('PRIVATE', 'PRIVILEGED_ACCESS', 'PUBLIC'))
    -- [no-codegen stop]
);

COMMENT ON TABLE privacy_setting IS
    'Who may see a kind of data of a user. Invariants (application): every user has exactly one setting per data type, created PRIVATE together with the user, and settings are never deleted; the groups of a setting are owned by its user.';

CREATE TABLE privacy_setting_group (
    privacy_setting_id BIGINT NOT NULL,
    group_id           BIGINT NOT NULL,

    PRIMARY KEY (privacy_setting_id, group_id),
    CONSTRAINT fk_privacy_setting_group_privacy_setting_id FOREIGN KEY (privacy_setting_id) REFERENCES privacy_setting (id),
    CONSTRAINT fk_privacy_setting_group_group_id FOREIGN KEY (group_id) REFERENCES app_group (id)
);

CREATE INDEX ix_privacy_setting_group_group_id ON privacy_setting_group (group_id);
