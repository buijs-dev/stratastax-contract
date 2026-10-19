CREATE SEQUENCE IF NOT EXISTS release_seq INCREMENT BY 50;

CREATE TABLE release (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('release_seq'),
    public_id             UUID NOT NULL DEFAULT gen_random_uuid(),
    application_id        BIGINT NOT NULL,
    release_number        INTEGER NOT NULL,
    note                  VARCHAR(500),
    message_count         INTEGER NOT NULL,
    published_at          TIMESTAMPTZ NOT NULL,
    published_by_user_id  BIGINT NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ,

    CONSTRAINT uq_release_public_id UNIQUE (public_id),
    CONSTRAINT uq_release_application_id_release_number UNIQUE (application_id, release_number),
    CONSTRAINT fk_release_application_id FOREIGN KEY (application_id) REFERENCES application (id),
    CONSTRAINT fk_release_published_by_user_id FOREIGN KEY (published_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_release_release_number CHECK (release_number >= 1),
    CONSTRAINT chk_release_message_count CHECK (message_count >= 0)
);

CREATE INDEX ix_release_published_by_user_id ON release (published_by_user_id);

CREATE TABLE release_locale (
    release_id  BIGINT      NOT NULL,
    locale      VARCHAR(10) NOT NULL,

    PRIMARY KEY (release_id, locale),
    CONSTRAINT fk_release_locale_release_id FOREIGN KEY (release_id) REFERENCES release (id),
    CONSTRAINT chk_release_locale_locale CHECK (locale ~ '^[a-z]{2,3}(-[A-Z]{2})?$')
);

COMMENT ON TABLE release IS
    'A publication of the draft translations of an application, numbered from 1 per application. A release never changes: the bundle of a locale is the published text of every key in it, with the number of the latest release of that locale as its version. Invariant (application): a release publishes only locales of its application, and no translation whose arguments no longer match its key.';
COMMENT ON COLUMN release.release_number IS
    'Sequence number of the release within its application, the version of a release and of a bundle in the API.';
COMMENT ON COLUMN release.message_count IS
    'Number of translations whose draft this release published.';
COMMENT ON TABLE release_locale IS
    'The locales whose drafts a release published.';
