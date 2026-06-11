-- Capacity leases: each row represents a running query holding a capacity slot.
-- Used by CapacityStore to enforce global max_running_queries across replicas.

CREATE TABLE IF NOT EXISTS cluster_capacity_leases (
    query_id      TEXT        PRIMARY KEY,
    cluster_name  TEXT        NOT NULL,
    instance_id   TEXT        NOT NULL,
    acquired_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    heartbeat_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX cluster_capacity_leases_cluster
    ON cluster_capacity_leases (cluster_name);

CREATE INDEX cluster_capacity_leases_heartbeat
    ON cluster_capacity_leases (heartbeat_at);
