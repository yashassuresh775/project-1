# Project 1 — Two-Tier Flask

Original two-tier web application: **Flask** (web) + **PostgreSQL 16** (data).

**Author:** [Yashas Suresh](https://github.com/yashassuresh775)

## Architecture

```mermaid
flowchart LR
  Client[Client] --> Web[Web tier: Flask / Gunicorn]
  Web --> DB[(Data tier: PostgreSQL 16)]
```

## Requirements

- Docker and Docker Compose

## Run with Docker Compose

```bash
cp .env.example .env
docker compose up --build
```

Open [http://localhost:8080](http://localhost:8080) for the health HTML page.
(Host port **8080** avoids macOS AirPlay often binding to 5000.)

## API examples

Health check:

```bash
curl -s http://localhost:8080/api/health
```

List messages:

```bash
curl -s http://localhost:8080/api/messages
```

Create a message:

```bash
curl -s -X POST http://localhost:8080/api/messages \
  -H 'Content-Type: application/json' \
  -d '{"text":"hello from Project 1"}'
```

## License

MIT — see [LICENSE](LICENSE).
