CREATE SEQUENCE IF NOT EXISTS bgg_ranking_seq INCREMENT BY 50;

CREATE TABLE bgg_ranking (
    id              BIGINT PRIMARY KEY DEFAULT nextval('bgg_ranking_seq'),
    public_id       UUID NOT NULL DEFAULT gen_random_uuid(),
    bgg_id          BIGINT NOT NULL,
    display_name    VARCHAR(500) NOT NULL,
    year_published  INTEGER NOT NULL,
    rank            INTEGER NOT NULL,
    is_expansion    BOOLEAN NOT NULL,
    candidate_id    BIGINT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ,

    CONSTRAINT uq_bgg_ranking_public_id UNIQUE (public_id),
    CONSTRAINT uq_bgg_ranking_bgg_id UNIQUE (bgg_id),
    CONSTRAINT fk_bgg_ranking_candidate_id FOREIGN KEY (candidate_id) REFERENCES candidate (id)
);

CREATE INDEX ix_bgg_ranking_rank ON bgg_ranking (rank);
CREATE INDEX ix_bgg_ranking_candidate_id ON bgg_ranking (candidate_id);

COMMENT ON TABLE bgg_ranking IS
    'A row of the imported BGG ranking CSV. The pipeline creates a candidate for it, best ranked first; candidate_id is NULL until then.';
COMMENT ON COLUMN bgg_ranking.rank IS
    'BGG rank; 0 for an entry that BGG does not rank, such as most expansions.';
