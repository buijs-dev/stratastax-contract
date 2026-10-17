CREATE SEQUENCE IF NOT EXISTS trusted_editor_seq INCREMENT BY 50;

CREATE TABLE trusted_editor (
    id                  BIGINT PRIMARY KEY DEFAULT nextval('trusted_editor_seq'),
    public_id           UUID NOT NULL DEFAULT gen_random_uuid(),
    grantor_user_id     BIGINT NOT NULL,
    trustee_user_id     BIGINT NOT NULL,
    revoked_at          TIMESTAMPTZ,
    revoked_by_user_id  BIGINT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ,
    version             BIGINT NOT NULL,

    CONSTRAINT uq_trusted_editor_public_id UNIQUE (public_id),
    CONSTRAINT fk_trusted_editor_grantor_user_id FOREIGN KEY (grantor_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_trusted_editor_trustee_user_id FOREIGN KEY (trustee_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_trusted_editor_revoked_by_user_id FOREIGN KEY (revoked_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_trusted_editor_not_self CHECK (grantor_user_id <> trustee_user_id),
    CONSTRAINT chk_trusted_editor_revoked CHECK (revoked_at IS NOT NULL OR revoked_by_user_id IS NULL)
);

-- At most one active grant per grantor and trustee.
CREATE UNIQUE INDEX uq_trusted_editor_grantor_user_id_trustee_user_id_active
    ON trusted_editor (grantor_user_id, trustee_user_id)
    WHERE revoked_at IS NULL;

CREATE INDEX ix_trusted_editor_trustee_user_id ON trusted_editor (trustee_user_id);
CREATE INDEX ix_trusted_editor_revoked_by_user_id ON trusted_editor (revoked_by_user_id);

COMMENT ON TABLE trusted_editor IS
    'A grant by which a match recorder (grantor) has the match edits of the trustee approved automatically.';
