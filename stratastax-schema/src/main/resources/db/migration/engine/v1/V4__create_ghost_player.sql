CREATE SEQUENCE IF NOT EXISTS ghost_player_seq INCREMENT BY 50;

CREATE TABLE ghost_player (
    id             BIGINT PRIMARY KEY DEFAULT nextval('ghost_player_seq'),
    public_id      UUID NOT NULL DEFAULT gen_random_uuid(),
    owner_user_id  BIGINT NOT NULL,
    display_name   VARCHAR(100) NOT NULL,
    is_self        BOOLEAN NOT NULL DEFAULT false,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ,
    deleted_at     TIMESTAMPTZ,
    version        BIGINT NOT NULL,

    CONSTRAINT uq_ghost_player_public_id UNIQUE (public_id),
    CONSTRAINT fk_ghost_player_owner_user_id FOREIGN KEY (owner_user_id) REFERENCES app_user (id),
    CONSTRAINT chk_ghost_player_self_not_deleted CHECK (NOT (is_self AND deleted_at IS NOT NULL))
);

CREATE INDEX ix_ghost_player_owner_user_id ON ghost_player (owner_user_id);

-- At most one self ghost player per user.
CREATE UNIQUE INDEX uq_ghost_player_owner_user_id_self
    ON ghost_player (owner_user_id)
    WHERE is_self;

COMMENT ON TABLE ghost_player IS
    'A player as a match recorder knows them, in the recorder''s own list. Soft-deleted: a deleted '
    'ghost player stays in the matches it played, but is no longer listed, suggested or usable in '
    'new matches and claim requests. Invariant (application): deleting a ghost player revokes its '
    'active claim edges.';
COMMENT ON COLUMN ghost_player.is_self IS
    'The ghost player that represents the owner themselves in the matches they record. Created with '
    'the user, with a claim edge to their own canonical player; never deleted and never unclaimed.';
