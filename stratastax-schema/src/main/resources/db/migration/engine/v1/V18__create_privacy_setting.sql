CREATE SEQUENCE IF NOT EXISTS privacy_setting_seq INCREMENT BY 50;

CREATE TABLE privacy_setting (
    id          BIGINT PRIMARY KEY DEFAULT nextval('privacy_setting_seq'),
    public_id   UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id     BIGINT NOT NULL,
    data_type   VARCHAR(20) NOT NULL,
    level       VARCHAR(20) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    version     BIGINT NOT NULL,

    CONSTRAINT fk_privacy_setting_user_id_ref_app_user_id FOREIGN KEY (user_id) REFERENCES app_user (id),

    UNIQUE (user_id, data_type)
    -- [no-codegen start]
    ,
    CONSTRAINT chk_privacy_setting_data_type
        CHECK (data_type = 'PROFILE' or data_type = 'MATCH_HISTORY' or data_type = 'MATCH_DETAILS'),
    CONSTRAINT chk_privacy_setting_level
        CHECK (level = 'PRIVATE' or level = 'PRIVILEGED_ACCESS' or level = 'PUBLIC')
    -- [no-codegen stop]
);

CREATE TABLE privacy_setting_group (
    privacy_setting_id BIGINT NOT NULL,
    group_id           BIGINT NOT NULL,

    PRIMARY KEY (privacy_setting_id, group_id),
    CONSTRAINT fk_privacy_setting_group_group_id_ref_app_group_id FOREIGN KEY (group_id) REFERENCES app_group (id),
    CONSTRAINT fk_privacy_setting_group_setting_id_ref_privacy_setting_id FOREIGN KEY (privacy_setting_id) REFERENCES privacy_setting (id)
);
