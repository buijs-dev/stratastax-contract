CREATE SEQUENCE IF NOT EXISTS match_edit_seq INCREMENT BY 50;

CREATE TABLE match_edit (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('match_edit_seq'),
    public_id             UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    match_id              BIGINT NOT NULL,
    proposed_by_user_id   BIGINT NOT NULL,
    approved_by_user_id   BIGINT,
    status                VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT fk_match_edit_match_id_ref_match_id FOREIGN KEY (match_id) REFERENCES match (id),
    CONSTRAINT fk_match_edit_proposed_by_user_id_ref_app_user_id FOREIGN KEY (proposed_by_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_match_edit_approved_by_user_id_ref_app_user_id FOREIGN KEY (approved_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_match_edit_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

CREATE INDEX ix_match_edit_match_id ON match_edit (match_id);
CREATE INDEX ix_match_edit_proposed_by ON match_edit (proposed_by_user_id);

CREATE TABLE match_edit_participant_change (
    match_edit_id         BIGINT NOT NULL,
    match_participant_id  BIGINT NOT NULL,
    score                 NUMERIC,
    rank                  INTEGER,
    outcome               VARCHAR(16),

    PRIMARY KEY (match_edit_id, match_participant_id),
    CONSTRAINT fk_participant_change_match_edit_id_ref_match_edit_id FOREIGN KEY (match_edit_id) REFERENCES match_edit (id),
    CONSTRAINT fk_participant_change_participant_id_ref_match_participant_id FOREIGN KEY (match_participant_id) REFERENCES match_participant (id),
    CONSTRAINT chk_match_edit_participant_change_outcome CHECK (outcome IS NULL OR outcome IN ('WIN', 'LOSS'))
);

CREATE TABLE match_edit_loadout_change (
    match_edit_id         BIGINT NOT NULL,
    match_participant_id  BIGINT NOT NULL,
    attributes            JSONB NOT NULL,
    CONSTRAINT fk_loadout_change_match_edit_id_ref_match_edit_id FOREIGN KEY (match_edit_id) REFERENCES match_edit (id),
    CONSTRAINT fk_loadout_change_match_participant_id_ref_match_participant_id FOREIGN KEY (match_participant_id) REFERENCES match_participant (id),
    PRIMARY KEY (match_edit_id, match_participant_id)
);

CREATE TABLE match_edit_playset_change (
    match_edit_id   BIGINT PRIMARY KEY,
    new_playset_id  BIGINT NOT NULL,
    CONSTRAINT fk_playset_change_match_edit_id_ref_match_edit_id FOREIGN KEY (match_edit_id) REFERENCES match_edit (id),
    CONSTRAINT fk_playset_change_new_playset_id_ref_playset_id FOREIGN KEY (new_playset_id) REFERENCES playset (id)
);
