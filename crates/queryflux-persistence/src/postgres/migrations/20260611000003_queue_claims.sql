-- Queue coordination: add claim columns to queued_queries so only one
-- replica processes a given queued query.

ALTER TABLE queued_queries
    ADD COLUMN IF NOT EXISTS claimed_by TEXT,
    ADD COLUMN IF NOT EXISTS claimed_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS queued_queries_unclaimed
    ON queued_queries (created_at)
    WHERE claimed_by IS NULL;
