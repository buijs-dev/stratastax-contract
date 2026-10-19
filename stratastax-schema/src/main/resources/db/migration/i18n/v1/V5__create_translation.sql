CREATE SEQUENCE IF NOT EXISTS translation_seq INCREMENT BY 50;

CREATE TABLE translation (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('translation_seq'),
    public_id             UUID NOT NULL DEFAULT gen_random_uuid(),
    message_key_id        BIGINT NOT NULL,
    locale                VARCHAR(10) NOT NULL,
    draft_text            VARCHAR(4000),
    published_text        VARCHAR(4000),
    published_release_id  BIGINT,
    invalidated_at        TIMESTAMPTZ,
    updated_by_user_id    BIGINT NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ,
    version               BIGINT NOT NULL,

    CONSTRAINT uq_translation_public_id UNIQUE (public_id),
    CONSTRAINT uq_translation_message_key_id_locale UNIQUE (message_key_id, locale),
    CONSTRAINT fk_translation_message_key_id FOREIGN KEY (message_key_id) REFERENCES message_key (id),
    CONSTRAINT fk_translation_published_release_id FOREIGN KEY (published_release_id) REFERENCES release (id),
    CONSTRAINT fk_translation_updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_translation_locale CHECK (locale ~ '^[a-z]{2,3}(-[A-Z]{2})?$'),
    CONSTRAINT chk_translation_text CHECK (draft_text IS NOT NULL OR published_text IS NOT NULL),
    CONSTRAINT chk_translation_published_release
        CHECK ((published_text IS NULL) = (published_release_id IS NULL))
);

CREATE INDEX ix_translation_published_release_id ON translation (published_release_id);
CREATE INDEX ix_translation_updated_by_user_id ON translation (updated_by_user_id);
-- The bundle of a locale: every published text of the application in that locale.
CREATE INDEX ix_translation_locale_message_key_id_published
    ON translation (locale, message_key_id) WHERE published_text IS NOT NULL;

COMMENT ON TABLE translation IS
    'The text of a message key in one locale: the draft that the next release publishes and the text of the latest release that published it. The status in the API follows from the texts: no row is MISSING, only a draft is DRAFT, only a published text is PUBLISHED, both is CHANGED. Discarding a draft that was never published deletes the row. Invariant (application): the locale is one of the locales of the application of the key, and the text only uses the arguments of the key.';
COMMENT ON COLUMN translation.published_release_id IS
    'The release that published the current published text; set together with published_text.';
COMMENT ON COLUMN translation.invalidated_at IS
    'When an import changed the arguments of the key so that the draft no longer matches them; such a draft is kept but not published until it is fixed. Null otherwise.';
