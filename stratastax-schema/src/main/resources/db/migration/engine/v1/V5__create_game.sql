CREATE SEQUENCE IF NOT EXISTS game_seq INCREMENT BY 50;

CREATE TABLE game (
    id              BIGINT PRIMARY KEY DEFAULT nextval('game_seq'),
    public_id       UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    description     TEXT NOT NULL,
    min_players     INTEGER NOT NULL,
    max_players     INTEGER NOT NULL,
    image_url       VARCHAR(500),
    tags            TEXT[] NOT NULL DEFAULT '{}',
    score_type      VARCHAR(16) NOT NULL,
    win_condition   VARCHAR(16),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,
    version         BIGINT NOT NULL,

    CONSTRAINT chk_game_player_range
        CHECK (min_players >= 1 AND max_players >= min_players),
    CONSTRAINT chk_game_score_type
        CHECK (score_type IN ('SCORE', 'TIME', 'TURNS', 'WIN_LOSS')),
    CONSTRAINT chk_game_win_condition
        CHECK (
            (score_type = 'WIN_LOSS' AND win_condition IS NULL)
            OR
            (score_type <> 'WIN_LOSS' AND win_condition IN ('HIGHER_WINS', 'LOWER_WINS'))
        )
);