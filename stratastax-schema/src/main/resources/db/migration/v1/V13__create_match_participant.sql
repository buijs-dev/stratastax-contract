CREATE SEQUENCE IF NOT EXISTS match_participant_seq INCREMENT BY 50;

CREATE TABLE match_participant (
    id              BIGINT PRIMARY KEY DEFAULT nextval('match_participant_seq'),
    public_id       UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    match_id        BIGINT NOT NULL,
    ghost_player_id BIGINT NOT NULL,
    loadout_id      BIGINT,
    score           NUMERIC(10,2),
    rank            INTEGER,
    outcome         VARCHAR(16),
    dispute_reason  TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,
    UNIQUE (match_id, ghost_player_id),
    CONSTRAINT fk_match_participant_match_id_ref_match_id FOREIGN KEY (match_id) REFERENCES match (id),
    CONSTRAINT fk_match_participant_ghost_player_id_ref_ghost_player_id FOREIGN KEY (ghost_player_id) REFERENCES ghost_player (id),
    CONSTRAINT fk_match_participant_loadout_id_ref_loadout_id FOREIGN KEY (loadout_id) REFERENCES loadout (id),
    CONSTRAINT chk_match_participant_outcome CHECK (outcome IS NULL OR outcome IN ('WIN', 'LOSS'))
);

CREATE INDEX ix_match_participant_match_id ON match_participant (match_id);
CREATE INDEX ix_match_participant_ghost_player_id ON match_participant (ghost_player_id);