CREATE SEQUENCE IF NOT EXISTS application_seq INCREMENT BY 50;

CREATE TABLE application (
    id               BIGINT PRIMARY KEY DEFAULT nextval('application_seq'),
    public_id        UUID NOT NULL DEFAULT gen_random_uuid(),
    application_key  VARCHAR(63) NOT NULL,
    display_name     VARCHAR(100) NOT NULL,
    base_locale      VARCHAR(10) NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ,
    version          BIGINT NOT NULL,

    CONSTRAINT uq_application_public_id UNIQUE (public_id),
    CONSTRAINT uq_application_application_key UNIQUE (application_key),
    CONSTRAINT chk_application_application_key CHECK (application_key ~ '^[a-z][a-z0-9-]{1,62}$'),
    CONSTRAINT chk_application_base_locale CHECK (base_locale ~ '^[a-z]{2,3}(-[A-Z]{2})?$')
);

CREATE TABLE application_locale (
    application_id  BIGINT      NOT NULL,
    locale          VARCHAR(10) NOT NULL,
    added_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (application_id, locale),
    CONSTRAINT fk_application_locale_application_id FOREIGN KEY (application_id) REFERENCES application (id),
    CONSTRAINT chk_application_locale_locale CHECK (locale ~ '^[a-z]{2,3}(-[A-Z]{2})?$')
);

COMMENT ON TABLE application IS
    'An application whose texts are translated here, such as a Stratastax app. Its keys come from the translation files of the application; the CMS adds translations and publishes them as releases, which the application loads as bundles at startup. Invariant (application): the base locale is one of the locales of the application.';
COMMENT ON COLUMN application.application_key IS
    'The id of the application in the API and in the configuration of a consumer app (a slug such as match-tracker); never changes.';
COMMENT ON COLUMN application.base_locale IS
    'Locale of the base texts of the keys, the source of truth in the translation files of the application.';
COMMENT ON TABLE application_locale IS
    'The locales an application is translated into, the base locale included.';
