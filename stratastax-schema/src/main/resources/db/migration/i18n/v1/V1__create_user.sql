-- "app_" prefix: USER is a reserved word in PostgreSQL (see NAMING.md).
CREATE SEQUENCE IF NOT EXISTS app_user_seq INCREMENT BY 50;

CREATE TABLE app_user (
    id            BIGINT PRIMARY KEY DEFAULT nextval('app_user_seq'),
    public_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    subject       VARCHAR(255) NOT NULL, -- JWT "sub"
    display_name  VARCHAR(100) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,
    version       BIGINT NOT NULL,

    CONSTRAINT uq_app_user_public_id UNIQUE (public_id),
    CONSTRAINT uq_app_user_subject UNIQUE (subject)
);

COMMENT ON TABLE app_user IS
    'A user of the translation CMS (an admin who writes and publishes translations), as known from the identity provider. Created on the first change the user makes and updated from the claims of the access token on every later change; the public_id is the id of a user reference in the API. Consumer applications read bundles through a service account and never appear here.';
COMMENT ON COLUMN app_user.subject IS
    'Subject ("sub" claim) of the user at the identity provider.';
