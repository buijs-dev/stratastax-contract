CREATE SEQUENCE IF NOT EXISTS trusted_editor_seq INCREMENT BY 50;

CREATE TABLE trusted_editor (
    id               BIGINT PRIMARY KEY DEFAULT nextval('trusted_editor_seq'),
    public_id        UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    grantor_user_id  BIGINT NOT NULL,
    trustee_user_id  BIGINT NOT NULL,
    revoked_at       TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_trusted_editor_grantor_user_id_ref_app_user_id FOREIGN KEY (grantor_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_trusted_editor_trustee_user_id_ref_app_user_id FOREIGN KEY (trustee_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_trusted_editor_not_self CHECK (grantor_user_id <> trustee_user_id)
);

CREATE UNIQUE INDEX uq_trusted_editor_active_pair
    ON trusted_editor (grantor_user_id, trustee_user_id)
    WHERE revoked_at IS NULL;

CREATE INDEX ix_trusted_editor_trustee_user_id ON trusted_editor (trustee_user_id);
