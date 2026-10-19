CREATE SEQUENCE IF NOT EXISTS game_seq INCREMENT BY 50;

CREATE TABLE game (
    id              BIGINT PRIMARY KEY DEFAULT nextval('game_seq'),
    public_id       UUID NOT NULL DEFAULT gen_random_uuid(),
    display_name    VARCHAR(255) NOT NULL,
    description     TEXT NOT NULL,
    min_players     INTEGER NOT NULL,
    max_players     INTEGER NOT NULL,
    image_url       VARCHAR(500),
    tags            TEXT[] NOT NULL DEFAULT '{}',
    score_type      VARCHAR(16) NOT NULL,
    win_condition   VARCHAR(16),
    source_ref      VARCHAR(64),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,

    CONSTRAINT uq_game_public_id UNIQUE (public_id),
    CONSTRAINT uq_game_source_ref UNIQUE (source_ref),
    CONSTRAINT chk_game_player_range
        CHECK (min_players >= 1 AND max_players >= min_players),
    CONSTRAINT chk_game_score_type
        CHECK (score_type IN ('SCORE', 'TIME', 'TURNS', 'WIN_LOSS')),
    -- Same rule as chk_candidate_win_condition in the game catalog, which publishes into this table.
    CONSTRAINT chk_game_win_condition
        CHECK (
            (score_type = 'WIN_LOSS' AND win_condition IS NULL)
            OR
            (score_type <> 'WIN_LOSS' AND win_condition IN ('HIGHER_WINS', 'LOWER_WINS'))
        )
);

COMMENT ON TABLE game IS
    'The catalogue of games. Games are created and updated by the game catalog service, which publishes reviewed candidates.';
COMMENT ON COLUMN game.source_ref IS
    'Where the game came from, e.g. ''bgg:199792''. Unique, so publishing the same source twice is refused (409) and the catalog links its candidate to the existing game. NULL for a game entered by hand.';
