# Flask + PostgreSQL Two-Tier

**Author:** [Yashas Suresh](https://github.com/yashassuresh775)  
**Repo:** https://github.com/yashassuresh775/flask-postgresql-two-tier

Automated CI/CD for a **two-tier** web app on **AWS EC2**: **Flask + Gunicorn** (web) and **PostgreSQL 16** (data), containerized with **Docker Compose**, deployed by **Jenkins** whenever code lands on GitHub.

> Intentional difference from common MySQL labs: this project uses **PostgreSQL** as the data tier.

---

## Table of contents

1. [Project overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Step 1 — AWS EC2 preparation](#3-step-1--aws-ec2-preparation)
4. [Step 2 — Install dependencies on EC2](#4-step-2--install-dependencies-on-ec2)
5. [Step 3 — Jenkins installation](#5-step-3--jenkins-installation)
6. [Step 4 — GitHub repository configuration](#6-step-4--github-repository-configuration)
7. [Step 5 — Jenkins pipeline job](#7-step-5--jenkins-pipeline-job)
8. [Local run (developer machine)](#8-local-run-developer-machine)
9. [Infrastructure diagram](#9-infrastructure-diagram)
10. [Workflow diagram](#10-workflow-diagram)
11. [API examples](#11-api-examples)
12. [License](#12-license)

---

## 1. Project overview

| Piece | Choice |
| --- | --- |
| Web tier | Flask + Gunicorn |
| Data tier | PostgreSQL 16 |
| Packaging | Docker + Docker Compose |
| CI/CD | Jenkins Pipeline (`Jenkinsfile`) on EC2 |
| Source | GitHub |
| Optional IaC | Terraform under `infra/terraform/` |
| Lightweight CI | GitHub Actions (syntax + `compose config`) |

Flow: **Developer → GitHub → Jenkins (EC2) → Docker Compose → Flask + Postgres**.

---

## 2. Architecture

![Architecture](docs/diagrams/architecture.png)

```text
Developer  -->  GitHub  -->  Jenkins on EC2
                                | 1) checkout
                                | 2) docker compose build
                                | 3) docker compose up -d
                                v
                         Same EC2 host
                    +---------------------+
                    | Docker Compose      |
                    |  web (Flask) :5000  |
                    |       |             |
                    |       v             |
                    |  db (Postgres)      |
                    +---------------------+
End user ----------> http://<ec2-ip>:5000
```

---

## 3. Step 1 — AWS EC2 preparation

### Option A — Console (manual)

1. Launch **Ubuntu 22.04 LTS**, type **t3.micro** (or t2.micro), attach a key pair.
2. Security group inbound rules:

| Type | Port | Source | Purpose |
| --- | --- | --- | --- |
| SSH | 22 | Your IP `/32` | Admin access |
| Custom TCP | 8080 | Your IP `/32` (prefer) | Jenkins UI |
| Custom TCP | 5000 | `0.0.0.0/0` (lab) | Flask app |

3. SSH in:

```bash
ssh -i /path/to/key.pem ubuntu@<ec2-public-ip>
```

### Option B — Terraform (recommended)

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# edit key_name, ssh_cidr, jenkins_cidr
terraform init
terraform apply
```

Requires a valid AWS session (`aws login` / configured credentials) and an existing EC2 key pair name in that region.

Outputs: public IP, Jenkins URL, app URL, SSH command.

---

## 4. Step 2 — Install dependencies on EC2

If you did **not** use Terraform `user_data` (which already installs Docker):

```bash
git clone https://github.com/yashassuresh775/flask-postgresql-two-tier.git
cd flask-postgresql-two-tier
bash scripts/01-install-docker.sh
newgrp docker   # or reconnect SSH
```

Installs: Git, Docker Engine, Docker Compose v2 plugin.

---

## 5. Step 3 — Jenkins installation

```bash
bash scripts/02-install-jenkins.sh
```

Or full bootstrap:

```bash
bash scripts/bootstrap-ec2.sh
```

Then:

1. Open `http://<ec2-public-ip>:8080`
2. Unlock with `/var/lib/jenkins/secrets/initialAdminPassword`
3. Install suggested plugins + create admin user  
4. Confirm Jenkins is in the `docker` group (script does this)

---

## 6. Step 4 — GitHub repository configuration

This repository already contains the deployable artifacts:

| File | Role |
| --- | --- |
| `app/Dockerfile` | Flask/Gunicorn image |
| `docker-compose.yml` | `web` + `db` on Compose network `two-tier` |
| `Jenkinsfile` | Checkout → validate → build → deploy → smoke test |
| `db/init.sql` | Messages table bootstrap |
| `.env.example` | `DATABASE_URL`, `APP_HOST_PORT` |

**Port convention**

- **Local (macOS):** `APP_HOST_PORT=8080` (AirPlay often owns 5000)
- **EC2 + Jenkins:** `APP_HOST_PORT=5000` (Jenkins keeps 8080)

---

## 7. Step 5 — Jenkins pipeline job

See [scripts/03-configure-jenkins-notes.md](scripts/03-configure-jenkins-notes.md).

Summary:

1. New Item → Pipeline → **Pipeline script from SCM** → this GitHub repo → Script Path `Jenkinsfile`
2. **Build Now**
3. Verify:

```bash
curl -s http://<ec2-public-ip>:5000/api/health
# expect: {"status":"ok","database":"up"}
```

Optional: GitHub webhook → `http://<ec2-public-ip>:8080/github-webhook/` so every push redeploys.

---

## 8. Local run (developer machine)

```bash
cp .env.example .env
docker compose up --build
```

Open [http://localhost:8080](http://localhost:8080).

GitHub Actions still validates `py_compile` + `docker compose config` on every push.

---

## 9. Infrastructure diagram

![Infrastructure](docs/diagrams/infrastructure.png)

Layers: published ports → runtime host → Docker Engine (Flask + Postgres) → GitHub Actions / Jenkins CI.

---

## 10. Workflow diagram

![Workflow](docs/diagrams/workflow.png)

```text
Push code → GitHub → Jenkins detects change → Pipeline starts
  → clones → builds image → docker compose up → app live
```

---

## 11. API examples

Local (`8080`) or EC2 (`5000`):

```bash
curl -s http://localhost:8080/api/health
curl -s http://localhost:8080/api/messages
curl -s -X POST http://localhost:8080/api/messages \
  -H 'Content-Type: application/json' \
  -d '{"text":"hello from Flask + PostgreSQL Two-Tier"}'
```

---

## 12. License

MIT — see [LICENSE](LICENSE).
