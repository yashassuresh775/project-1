-- Schema bootstrap for Flask + PostgreSQL Two-Tier.
-- The Flask app also creates this table if missing (idempotent).

CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
