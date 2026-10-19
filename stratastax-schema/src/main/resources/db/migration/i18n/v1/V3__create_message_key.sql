CREATE SEQUENCE IF NOT EXISTS message_key_seq INCREMENT BY 50;

CREATE TABLE message_key (
    id              BIGINT PRIMARY KEY DEFAULT nextval('message_key_seq'),
    public_id       UUID NOT NULL DEFAULT gen_random_uuid(),
    application_id  BIGINT NOT NULL,
    message_key     VARCHAR(200) NOT NULL,
    base_text       VARCHAR(4000) NOT NULL,
    description     VARCHAR(1000),
    obsoleted_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,

    CONSTRAINT uq_message_key_public_id UNIQUE (public_id),
    CONSTRAINT uq_message_key_application_id_message_key UNIQUE (application_id, message_key),
    CONSTRAINT fk_message_key_application_id FOREIGN KEY (application_id) REFERENCES application (id),
    CONSTRAINT chk_message_key_message_key CHECK (message_key ~ '^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)*$')
);

CREATE TABLE message_argument (
    message_key_id  BIGINT      NOT NULL,
    position        INTEGER     NOT NULL,
    name            VARCHAR(64) NOT NULL,
    argument_type   VARCHAR(16) NOT NULL,

    PRIMARY KEY (message_key_id, position),
    CONSTRAINT uq_message_argument_message_key_id_name UNIQUE (message_key_id, name),
    CONSTRAINT fk_message_argument_message_key_id FOREIGN KEY (message_key_id) REFERENCES message_key (id),
    CONSTRAINT chk_message_argument_position CHECK (position >= 0),
    CONSTRAINT chk_message_argument_name CHECK (name ~ '^[A-Za-z][A-Za-z0-9_]*$'),
    CONSTRAINT chk_message_argument_argument_type CHECK (argument_type IN ('ANY', 'NUMBER', 'DATE', 'STRING'))
);

COMMENT ON TABLE message_key IS
    'A message of an application, with its text in the base locale, as imported from the translation files of the application. An import replaces the base text, description and arguments of every key it contains and marks every other key obsolete; a later import that contains the key again revives it. Invariant (application): an obsolete key is not published and is left out of every bundle. The version is the ETag of the key with its translations, so it goes up with every change of one of its translations as well.';
COMMENT ON COLUMN message_key.message_key IS
    'Dotted key, as in the translation files of the application (matchCreateCommand.gameId.label).';
COMMENT ON COLUMN message_key.obsoleted_at IS
    'When the last import no longer contained the key; null while the key is in use.';
COMMENT ON TABLE message_argument IS
    'An argument of a message key, which every translation of the key may use, in the order in which the generated code passes them.';
COMMENT ON COLUMN message_argument.argument_type IS
    'The ICU type of the argument: NUMBER (number and plural), DATE, STRING (select) or ANY (plain placeholder).';
