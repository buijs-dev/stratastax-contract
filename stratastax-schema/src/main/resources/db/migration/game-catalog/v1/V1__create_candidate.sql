CREATE SEQUENCE IF NOT EXISTS candidate_seq INCREMENT BY 50;

CREATE TABLE candidate (
    id                   BIGINT PRIMARY KEY DEFAULT nextval('candidate_seq'),
    public_id            UUID NOT NULL DEFAULT gen_random_uuid(),
    bgg_id               BIGINT NOT NULL,
    display_name         VARCHAR(255) NOT NULL,
    description          TEXT,
    min_players          INTEGER,
    max_players          INTEGER,
    playing_time         INTEGER,
    min_age              INTEGER,
    year_published       INTEGER,
    image_url            VARCHAR(500),
    tags                 TEXT[] NOT NULL DEFAULT '{}',
    is_expansion         BOOLEAN NOT NULL DEFAULT false,
    base_game_bgg_id     BIGINT,
    score_type           VARCHAR(16),
    win_condition        VARCHAR(16),
    stage                VARCHAR(32) NOT NULL DEFAULT 'PENDING_RULES',
    status               VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    reliability          VARCHAR(16) NOT NULL DEFAULT 'UNVERIFIED',
    failure_reason       TEXT,
    publish_request_id   UUID,
    engine_game_id       UUID,
    engine_expansion_id  UUID,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ,
    version              BIGINT NOT NULL,

    CONSTRAINT uq_candidate_public_id UNIQUE (public_id),
    CONSTRAINT uq_candidate_bgg_id UNIQUE (bgg_id),
    CONSTRAINT chk_candidate_stage
        CHECK (stage IN ('PENDING_RULES', 'RULES_COLLECTED', 'INTERPRETED', 'FAILED')),
    CONSTRAINT chk_candidate_status
        CHECK (status IN ('PENDING', 'APPROVED', 'PUBLISHED', 'REJECTED')),
    CONSTRAINT chk_candidate_reliability
        CHECK (reliability IN ('HIGH', 'MEDIUM', 'LOW', 'UNVERIFIED')),
    CONSTRAINT chk_candidate_score_type
        CHECK (score_type IS NULL OR score_type IN ('SCORE', 'TIME', 'TURNS', 'WIN_LOSS')),
    -- The engine's chk_game_win_condition, with room for the values that are still unknown before
    -- review: a WIN_LOSS game never has a win condition, any other game may not have one yet.
    CONSTRAINT chk_candidate_win_condition
        CHECK (
            score_type IS NULL
            OR (score_type = 'WIN_LOSS' AND win_condition IS NULL)
            OR (score_type <> 'WIN_LOSS' AND (win_condition IS NULL OR win_condition IN ('HIGHER_WINS', 'LOWER_WINS')))
        ),
    CONSTRAINT chk_candidate_player_range
        CHECK ((min_players IS NULL OR min_players >= 1)
           AND (max_players IS NULL OR min_players IS NULL OR max_players >= min_players)),
    CONSTRAINT chk_candidate_expansion_base_game
        CHECK (NOT is_expansion OR base_game_bgg_id IS NOT NULL)
);

CREATE INDEX ix_candidate_stage ON candidate (stage);
CREATE INDEX ix_candidate_status ON candidate (status);
CREATE INDEX ix_candidate_base_game_bgg_id ON candidate (base_game_bgg_id);

COMMENT ON TABLE candidate IS
    'A game or expansion on its way into the engine''s catalogue: created from BGG data, enriched with rules found on the web and interpreted by an LLM, reviewed by a human and then published to the engine. A published candidate can be approved again with new values; the pipeline then updates the engine''s game or expansion.';
COMMENT ON COLUMN candidate.engine_game_id IS
    'Public id of the game in the engine (no FK: the engine owns it). For an expansion: its base game.';
COMMENT ON COLUMN candidate.engine_expansion_id IS
    'Public id of the expansion in the engine, once published.';
COMMENT ON COLUMN candidate.publish_request_id IS
    'Idempotency-Key of the pending publication to the engine, so a retry never creates a duplicate.';

CREATE SEQUENCE IF NOT EXISTS candidate_reliability_check_seq INCREMENT BY 50;

CREATE TABLE candidate_reliability_check (
    id            BIGINT PRIMARY KEY DEFAULT nextval('candidate_reliability_check_seq'),
    public_id     UUID NOT NULL DEFAULT gen_random_uuid(),
    candidate_id  BIGINT NOT NULL,
    field         VARCHAR(32) NOT NULL,
    bgg_value     VARCHAR(255),
    llm_value     VARCHAR(255),
    matches       BOOLEAN NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ,

    CONSTRAINT uq_candidate_reliability_check_public_id UNIQUE (public_id),
    CONSTRAINT fk_candidate_reliability_check_candidate_id FOREIGN KEY (candidate_id) REFERENCES candidate (id)
);

CREATE INDEX ix_candidate_reliability_check_candidate_id ON candidate_reliability_check (candidate_id);

COMMENT ON TABLE candidate_reliability_check IS
    'One field compared between the BGG data and the LLM''s reading of the rules; together they explain the candidate''s reliability.';
