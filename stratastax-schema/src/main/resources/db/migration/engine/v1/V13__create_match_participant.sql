CREATE SEQUENCE IF NOT EXISTS match_participant_seq INCREMENT BY 50;

CREATE TABLE match_participant (
    id                   BIGINT PRIMARY KEY DEFAULT nextval('match_participant_seq'),
    public_id            UUID NOT NULL DEFAULT gen_random_uuid(),
    match_id             BIGINT NOT NULL,
    ghost_player_id      BIGINT NOT NULL,
    loadout_id           BIGINT,
    score                NUMERIC(10,2),
    rank                 INTEGER,
    outcome              VARCHAR(16),
    dispute_reason       VARCHAR(1000),
    disputed_at          TIMESTAMPTZ,
    disputed_by_user_id  BIGINT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ,
    deleted_at           TIMESTAMPTZ,
    version              BIGINT NOT NULL,

    CONSTRAINT uq_match_participant_public_id UNIQUE (public_id),
    CONSTRAINT uq_match_participant_match_id_ghost_player_id UNIQUE (match_id, ghost_player_id),
    CONSTRAINT fk_match_participant_match_id FOREIGN KEY (match_id) REFERENCES match (id),
    CONSTRAINT uq_match_participant_loadout_id UNIQUE (loadout_id),
    CONSTRAINT fk_match_participant_ghost_player_id FOREIGN KEY (ghost_player_id) REFERENCES ghost_player (id),
    CONSTRAINT fk_match_participant_loadout_id FOREIGN KEY (loadout_id) REFERENCES match_loadout (id),
    CONSTRAINT fk_match_participant_disputed_by_user_id FOREIGN KEY (disputed_by_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_match_participant_outcome CHECK (outcome IS NULL OR outcome IN ('WIN', 'LOSS')),
    CONSTRAINT chk_match_participant_rank CHECK (rank IS NULL OR rank >= 1),
    CONSTRAINT chk_match_participant_dispute
        CHECK (
            (dispute_reason IS NULL AND disputed_at IS NULL AND disputed_by_user_id IS NULL)
            OR
            (dispute_reason IS NOT NULL AND disputed_at IS NOT NULL AND disputed_by_user_id IS NOT NULL)
        )
);

CREATE INDEX ix_match_participant_ghost_player_id ON match_participant (ghost_player_id);
CREATE INDEX ix_match_participant_disputed_by_user_id ON match_participant (disputed_by_user_id);

COMMENT ON TABLE match_participant IS
    'A player''s result in a match. Removed from a DRAFT match by deleting the row (and its loadout); soft-deleted only together with its match. Invariant (application): a dispute is raised by a user whose canonical player has an active claim edge to the participant''s ghost player.';
COMMENT ON COLUMN match_participant.dispute_reason IS
    'Why the claimed player disagrees with this result. Cleared when the dispute is withdrawn or when an approved match edit changes this participant.';
