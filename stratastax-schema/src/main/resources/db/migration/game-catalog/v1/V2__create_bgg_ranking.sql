CREATE TABLE bgg_ranking (
     public_id        UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
     bgg_id           BIGINT PRIMARY KEY,
     name             VARCHAR(500) NOT NULL,
     year_published   INTEGER NOT NULL,
     rank             INTEGER NOT NULL,
     is_expansion     BOOLEAN NOT NULL,
     candidate_id     UUID REFERENCES candidate (public_id)
);

CREATE INDEX idx_bgg_ranking_rank
    ON bgg_ranking (rank);

CREATE INDEX idx_bgg_ranking_candidate_id
    ON bgg_ranking (candidate_id);
