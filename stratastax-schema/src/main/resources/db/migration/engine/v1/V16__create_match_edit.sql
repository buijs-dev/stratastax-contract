-- A proposed change to a finalized match. The change set is a closed set, stored in normalized
-- form: result changes per participant, loadout changes per participant, and the replacement of
-- the playset and of the expansions on match_edit itself. A field that is left out (keep the
-- current value) is told apart from a field that is cleared by the *_set flags: only flagged
-- fields are written when the edit is approved.
CREATE SEQUENCE IF NOT EXISTS match_edit_seq INCREMENT BY 50;

CREATE TABLE match_edit (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('match_edit_seq'),
    public_id             UUID NOT NULL DEFAULT gen_random_uuid(),
    match_id              BIGINT NOT NULL,
    proposed_by_user_id   BIGINT NOT NULL,
    playset_set           BOOLEAN NOT NULL DEFAULT false,
    new_playset_id        BIGINT,
    expansions_set        BOOLEAN NOT NULL DEFAULT false,
    status                VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    decided_by_user_id    BIGINT,
    decided_at            TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ,
    version               BIGINT NOT NULL,

    CONSTRAINT uq_match_edit_public_id UNIQUE (public_id),
    CONSTRAINT fk_match_edit_match_id FOREIGN KEY (match_id) REFERENCES match (id),
    CONSTRAINT fk_match_edit_proposed_by_user_id FOREIGN KEY (proposed_by_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_match_edit_new_playset_id FOREIGN KEY (new_playset_id) REFERENCES playset (id),
    CONSTRAINT fk_match_edit_decided_by_user_id FOREIGN KEY (decided_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_match_edit_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_match_edit_playset CHECK (playset_set OR new_playset_id IS NULL),
    CONSTRAINT chk_match_edit_decided
        CHECK ((status = 'PENDING' AND decided_at IS NULL) OR (status <> 'PENDING' AND decided_at IS NOT NULL))
);

CREATE INDEX ix_match_edit_match_id ON match_edit (match_id);
CREATE INDEX ix_match_edit_proposed_by_user_id ON match_edit (proposed_by_user_id);
CREATE INDEX ix_match_edit_new_playset_id ON match_edit (new_playset_id);
CREATE INDEX ix_match_edit_decided_by_user_id ON match_edit (decided_by_user_id);

COMMENT ON TABLE match_edit IS
    'A proposed change to a finalized match. Invariants (application): the decider is the match''s '
    'recorder; an edit only changes participants of its own match; a new playset is for the match''s '
    'game and new expansions belong to it; only the flagged (*_set) fields are written on approval.';
COMMENT ON COLUMN match_edit.playset_set IS
    'The edit replaces the playset with new_playset_id; NULL there clears the playset.';
COMMENT ON COLUMN match_edit.expansions_set IS
    'The edit replaces the expansions with the rows in match_edit_expansion_change; none clears them.';

CREATE TABLE match_edit_expansion_change (
    match_edit_id BIGINT NOT NULL,
    expansion_id  BIGINT NOT NULL,

    PRIMARY KEY (match_edit_id, expansion_id),
    CONSTRAINT fk_match_edit_expansion_change_match_edit_id FOREIGN KEY (match_edit_id) REFERENCES match_edit (id),
    CONSTRAINT fk_match_edit_expansion_change_expansion_id FOREIGN KEY (expansion_id) REFERENCES expansion (id)
);

CREATE INDEX ix_match_edit_expansion_change_expansion_id ON match_edit_expansion_change (expansion_id);

CREATE SEQUENCE IF NOT EXISTS match_edit_participant_change_seq INCREMENT BY 50;

CREATE TABLE match_edit_participant_change (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('match_edit_participant_change_seq'),
    public_id             UUID NOT NULL DEFAULT gen_random_uuid(),
    match_edit_id         BIGINT NOT NULL,
    match_participant_id  BIGINT NOT NULL,
    score                 NUMERIC(10,2),
    score_set             BOOLEAN NOT NULL DEFAULT false,
    rank                  INTEGER,
    rank_set              BOOLEAN NOT NULL DEFAULT false,
    outcome               VARCHAR(16),
    outcome_set           BOOLEAN NOT NULL DEFAULT false,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ,

    CONSTRAINT uq_match_edit_participant_change_public_id UNIQUE (public_id),
    CONSTRAINT uq_match_edit_participant_change_match_edit_participant
        UNIQUE (match_edit_id, match_participant_id),
    CONSTRAINT fk_match_edit_participant_change_match_edit_id FOREIGN KEY (match_edit_id) REFERENCES match_edit (id),
    CONSTRAINT fk_match_edit_participant_change_match_participant_id FOREIGN KEY (match_participant_id) REFERENCES match_participant (id),
    CONSTRAINT chk_match_edit_participant_change_outcome CHECK (outcome IS NULL OR outcome IN ('WIN', 'LOSS')),
    CONSTRAINT chk_match_edit_participant_change_rank CHECK (rank IS NULL OR rank >= 1),
    CONSTRAINT chk_match_edit_participant_change_set
        CHECK ((score_set OR score IS NULL) AND (rank_set OR rank IS NULL) AND (outcome_set OR outcome IS NULL))
);

CREATE INDEX ix_match_edit_participant_change_match_participant_id
    ON match_edit_participant_change (match_participant_id);

COMMENT ON TABLE match_edit_participant_change IS 'The new result of one participant, proposed by a match edit.';
COMMENT ON COLUMN match_edit_participant_change.score_set IS
    'The edit sets the score: written on approval, NULL clears it. Same for rank_set and outcome_set.';

CREATE SEQUENCE IF NOT EXISTS match_edit_loadout_change_seq INCREMENT BY 50;

CREATE TABLE match_edit_loadout_change (
    id                    BIGINT PRIMARY KEY DEFAULT nextval('match_edit_loadout_change_seq'),
    public_id             UUID NOT NULL DEFAULT gen_random_uuid(),
    match_edit_id         BIGINT NOT NULL,
    match_participant_id  BIGINT NOT NULL,
    attributes            JSONB NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ,

    CONSTRAINT uq_match_edit_loadout_change_public_id UNIQUE (public_id),
    CONSTRAINT uq_match_edit_loadout_change_match_edit_participant
        UNIQUE (match_edit_id, match_participant_id),
    CONSTRAINT fk_match_edit_loadout_change_match_edit_id FOREIGN KEY (match_edit_id) REFERENCES match_edit (id),
    CONSTRAINT fk_match_edit_loadout_change_match_participant_id FOREIGN KEY (match_participant_id) REFERENCES match_participant (id)
);

CREATE INDEX ix_match_edit_loadout_change_match_participant_id
    ON match_edit_loadout_change (match_participant_id);

COMMENT ON TABLE match_edit_loadout_change IS
    'The new loadout attributes of one participant, proposed by a match edit; they replace the current ones.';
