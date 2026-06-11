-- Singleton table tracking the global config revision counter.
-- Every admin write that mutates persisted config bumps this value so that
-- other QueryFlux replicas can detect the change via polling or LISTEN/NOTIFY.
CREATE TABLE IF NOT EXISTS config_revision (
    id       BOOLEAN     PRIMARY KEY DEFAULT TRUE CHECK (id),
    revision BIGINT      NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO config_revision (id, revision) VALUES (TRUE, 0) ON CONFLICT DO NOTHING;

-- Trigger function: after the revision row is updated, emit a NOTIFY on the
-- 'config_revision_changed' channel with the new revision as payload.
CREATE OR REPLACE FUNCTION notify_config_revision_changed()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('config_revision_changed', NEW.revision::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER config_revision_notify
    AFTER UPDATE ON config_revision
    FOR EACH ROW
    EXECUTE FUNCTION notify_config_revision_changed();
