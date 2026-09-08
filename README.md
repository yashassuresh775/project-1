# Flask + PostgreSQL Two-Tier

Original two-tier web application: **Flask** (web) + **PostgreSQL 16** (data).

**Author:** [Yashas Suresh](https://github.com/yashassuresh775)

## Architecture

![Two-tier architecture: Client → Flask/Gunicorn → PostgreSQL 16 under Docker Compose](docs/diagrams/architecture.png)

```mermaid
flowchart LR
  Client[Client] --> Web[Web tier: Flask / Gunicorn]
  Web --> DB[(Data tier: PostgreSQL 16)]
```

## Infrastructure

![Infrastructure: published ports, Docker Engine with Flask + Postgres, GitHub Actions CI](docs/diagrams/infrastructure.png)

Same layout idea as a classic two-tier DevOps poster (host → ports → containers → CI), redrawn for **this** repo:

| Layer | Their reference idea | Ours |
| --- | --- | --- |
| Edge / ports | Security group: 22 / 8080 Jenkins / 5000 app / 3306 MySQL | Published host port **8080** → container 5000; Postgres stays **internal** on Compose network |
| Compute | Single EC2 (Ubuntu) | Local Docker Desktop / any Linux host |
| App runtime | Docker Engine + bridge network | Docker Compose network (`web` ↔ `db`) |
| Data store | MySQL | **PostgreSQL 16** |
| CI/CD | Jenkins on the same host + GitHub webhook | **GitHub Actions** (`py_compile` + `docker compose config`) |
| Actors | Developer (SSH) + end user (browser) | Developer (`git` / `compose`) + end user (`http://localhost:8080`) |

```mermaid
flowchart TB
  subgraph ports[Published / controlled ports]
    P8080[8080 host → Flask]
  end

  subgraph host[Runtime host]
    subgraph ci[GitHub Actions CI]
      Check[py_compile + compose config]
    end
    subgraph docker[Docker Engine / Compose]
      Web[web: Flask + Gunicorn]
      DB[(db: PostgreSQL 16)]
      Web <-->|bridge network| DB
    end
  end

  Dev[Developer] -->|git push / PR| GH[GitHub]
  GH --> Check
  Dev -->|docker compose up --build| docker
  User[End user] --> P8080 --> Web
```

## Local run & CI

![Workflow: git push / GitHub Actions CI and local docker compose up](docs/diagrams/workflow.png)

```mermaid
flowchart LR
  Dev[Developer] -->|push| GH[GitHub]
  GH --> Actions[GitHub Actions CI]
  Actions --> Checks[py_compile + compose config]
  Dev -->|docker compose up --build| Stack[Flask :8080 + Postgres]
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
  -d '{"text":"hello from Flask + PostgreSQL Two-Tier"}'
```

## License

MIT — see [LICENSE](LICENSE).
