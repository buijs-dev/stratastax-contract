CREATE SEQUENCE IF NOT EXISTS match_seq INCREMENT BY 50;

CREATE TABLE match (
    id                      BIGINT PRIMARY KEY DEFAULT nextval('match_seq'),
    public_id               UUID NOT NULL DEFAULT gen_random_uuid(),
    game_id                 BIGINT NOT NULL,
    playset_id              BIGINT,
    community_id            BIGINT,
    recorder_user_id        BIGINT NOT NULL,
    played_at               TIMESTAMPTZ NOT NULL,
    edit_requests_enabled   BOOLEAN NOT NULL DEFAULT true,
    finalized_at            TIMESTAMPTZ,
    last_edited_at          TIMESTAMPTZ,
    last_edited_by_user_id  BIGINT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ,
    deleted_at              TIMESTAMPTZ,
    version                 BIGINT NOT NULL,

    CONSTRAINT uq_match_public_id UNIQUE (public_id),
    CONSTRAINT fk_match_game_id FOREIGN KEY (game_id) REFERENCES game (id),
    CONSTRAINT fk_match_playset_id FOREIGN KEY (playset_id) REFERENCES playset (id),
    CONSTRAINT fk_match_community_id FOREIGN KEY (community_id) REFERENCES community (id),
    CONSTRAINT fk_match_recorder_user_id FOREIGN KEY (recorder_user_id) REFERENCES app_user (id),
    CONSTRAINT fk_match_last_edited_by_user_id FOREIGN KEY (last_edited_by_user_id) REFERENCES app_user (id)
);

CREATE INDEX ix_match_game_id ON match (game_id);
CREATE INDEX ix_match_playset_id ON match (playset_id);
CREATE INDEX ix_match_community_id ON match (community_id);
CREATE INDEX ix_match_recorder_user_id ON match (recorder_user_id);
CREATE INDEX ix_match_last_edited_by_user_id ON match (last_edited_by_user_id);

COMMENT ON TABLE match IS
    'The aggregate root of gaming history. DRAFT while finalized_at is NULL: freely editable, and '
    'participants that are removed are deleted. FINALIZED afterwards: changed only through match '
    'edits. Deleting a match (only while DRAFT) soft-deletes it together with its participants. '
    'Invariants (application): the playset, if set, is for the same game; the expansions belong to the game.';
COMMENT ON COLUMN match.finalized_at IS 'When the match was finalized; NULL while it is a DRAFT.';

CREATE TABLE match_expansion (
    match_id     BIGINT NOT NULL,
    expansion_id BIGINT NOT NULL,

    PRIMARY KEY (match_id, expansion_id),
    CONSTRAINT fk_match_expansion_match_id FOREIGN KEY (match_id) REFERENCES match (id),
    CONSTRAINT fk_match_expansion_expansion_id FOREIGN KEY (expansion_id) REFERENCES expansion (id)
);

CREATE INDEX ix_match_expansion_expansion_id ON match_expansion (expansion_id);
