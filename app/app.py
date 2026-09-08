"""
Project 1 — Two-Tier Flask Application
Author: Yashas Suresh (https://github.com/yashassuresh775)
Web tier (Flask) + data tier (PostgreSQL).
"""

from __future__ import annotations

import os
from contextlib import contextmanager

import psycopg2
from dotenv import load_dotenv
from flask import Flask, jsonify, request
from psycopg2.extras import RealDictCursor

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://app:app@db:5432/appdb",
)

app = Flask(__name__)


@contextmanager
def get_conn():
    conn = psycopg2.connect(DATABASE_URL)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def init_db() -> None:
    """Create the messages table if it does not already exist."""
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    text TEXT NOT NULL,
                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                )
                """
            )


@app.before_request
def ensure_schema():
    # Lazy init on first request if startup init failed (e.g. db still warming).
    if not getattr(app, "_db_ready", False):
        try:
            init_db()
            app._db_ready = True
        except psycopg2.OperationalError:
            pass


@app.route("/")
def index():
    return (
        """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Project 1 — Two-Tier Flask</title>
  <style>
    body { font-family: Georgia, serif; max-width: 40rem; margin: 3rem auto; padding: 0 1rem; color: #1a1a1a; }
    h1 { font-weight: 400; letter-spacing: -0.02em; }
    p { color: #444; line-height: 1.5; }
    code { background: #f0f0f0; padding: 0.15em 0.35em; border-radius: 3px; }
  </style>
</head>
<body>
  <h1>Project 1 — Two-Tier Flask</h1>
  <p>Flask web tier backed by PostgreSQL. Try <code>/api/health</code> and <code>/api/messages</code>.</p>
  <p>Author: <a href="https://github.com/yashassuresh775">Yashas Suresh</a></p>
</body>
</html>
""",
        200,
        {"Content-Type": "text/html; charset=utf-8"},
    )


@app.route("/api/health")
def health():
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                cur.fetchone()
        return jsonify({"status": "ok", "database": "up"})
    except psycopg2.Error as exc:
        return jsonify({"status": "degraded", "database": "down", "detail": str(exc)}), 503


@app.route("/api/messages", methods=["GET"])
def list_messages():
    with get_conn() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT id, text, created_at FROM messages ORDER BY id ASC"
            )
            rows = cur.fetchall()
    messages = [
        {
            "id": row["id"],
            "text": row["text"],
            "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        }
        for row in rows
    ]
    return jsonify(messages)


@app.route("/api/messages", methods=["POST"])
def create_message():
    payload = request.get_json(silent=True) or {}
    text = payload.get("text")
    if not text or not isinstance(text, str) or not text.strip():
        return jsonify({"error": "JSON body must include non-empty string field 'text'"}), 400

    text = text.strip()
    with get_conn() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                INSERT INTO messages (text)
                VALUES (%s)
                RETURNING id, text, created_at
                """,
                (text,),
            )
            row = cur.fetchone()

    return (
        jsonify(
            {
                "id": row["id"],
                "text": row["text"],
                "created_at": row["created_at"].isoformat() if row["created_at"] else None,
            }
        ),
        201,
    )


# Attempt schema creation at import/worker start (gunicorn).
try:
    init_db()
    app._db_ready = True
except Exception:
    app._db_ready = False


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)
