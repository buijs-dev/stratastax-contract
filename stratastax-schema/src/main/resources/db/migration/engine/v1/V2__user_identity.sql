CREATE SEQUENCE IF NOT EXISTS app_user_identity_seq INCREMENT BY 50;

CREATE TABLE app_user_identity (
    id                BIGINT PRIMARY KEY DEFAULT nextval('app_user_identity_seq'),
    user_id           BIGINT NOT NULL,
    provider          VARCHAR(255) NOT NULL, -- 'keycloak', or a federated provider name
    provider_user_id  VARCHAR(255) NOT NULL, -- JWT "sub"
    email             VARCHAR(255),
    email_verified    BOOLEAN,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ,

    CONSTRAINT uq_app_user_identity_provider_provider_user_id UNIQUE (provider, provider_user_id),
    CONSTRAINT fk_app_user_identity_user_id FOREIGN KEY (user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_app_user_identity_user_id ON app_user_identity (user_id);

COMMENT ON TABLE app_user_identity IS
    'A way to sign in as a user (identity provider + subject). Invariant (application): a user cannot remove their last remaining identity.';
