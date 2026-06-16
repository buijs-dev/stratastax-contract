CREATE SEQUENCE IF NOT EXISTS match_seq INCREMENT BY 50;

CREATE TABLE match (
    id                      BIGINT PRIMARY KEY DEFAULT nextval('match_seq'),
    public_id               UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    game_id                 BIGINT NOT NULL,
    playset_id              BIGINT,
    community_id            BIGINT,
    recorder_user_id        BIGINT NOT NULL,
    played_at               TIMESTAMPTZ NOT NULL,
    edit_requests_enabled   BOOLEAN NOT NULL DEFAULT true,
    locked_at               TIMESTAMPTZ,
    last_edited_at          TIMESTAMPTZ,
    last_edited_by_user_id  BIGINT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    version                 BIGINT NOT NULL,
    CONSTRAINT fk_match_game_id_ref_game_id FOREIGN KEY (game_id) REFERENCES game (id),
    CONSTRAINT fk_match_playset_id_ref_playset_id FOREIGN KEY (playset_id) REFERENCES playset (id),
    CONSTRAINT fk_match_community_id_ref_community_id FOREIGN KEY (community_id) REFERENCES community (id),
    CONSTRAINT fk_match_recorder_user_id_ref_app_user_id FOREIGN KEY (recorder_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_match_last_edited_by_user_id_ref_app_user_id FOREIGN KEY (last_edited_by_user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_match_recorder_user_id ON match (recorder_user_id);
CREATE INDEX ix_match_game_id ON match (game_id);
CREATE INDEX ix_match_community_id ON match (community_id);
CREATE INDEX ix_match_playset_id ON match (playset_id);
