CREATE SEQUENCE IF NOT EXISTS app_user_identity_seq INCREMENT BY 50;

CREATE TABLE app_user_identity
(
    id                BIGINT PRIMARY KEY DEFAULT nextval('app_user_identity_seq'),
    user_id           BIGINT NOT NULL,
    provider          VARCHAR(255) NOT NULL, -- 'keycloak', or a federated provider name
    provider_user_id  VARCHAR(255) NOT NULL, -- JWT "sub"
    email             VARCHAR(255),
    email_verified    BOOLEAN,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (provider, provider_user_id),
    CONSTRAINT fk_app_user_identity_user_id_ref_app_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
);



CREATE INDEX ix_app_user_identity_user_id ON app_user_identity (user_id);