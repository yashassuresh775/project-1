# Step 5 — Jenkins pipeline job (manual UI checklist)

After Jenkins is up on `http://<ec2-public-ip>:8080`:

## Create the job

1. **New Item** → name: `flask-postgresql-two-tier` → type **Pipeline** → OK  
2. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/yashassuresh775/flask-postgresql-two-tier.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
3. Save → **Build Now**

## Optional: auto-trigger on push

1. In Jenkins job → **Build Triggers** → check **GitHub hook trigger for GITScm polling** (or generic webhook)  
2. In GitHub repo → **Settings → Webhooks → Add webhook**  
   - Payload URL: `http://<ec2-public-ip>:8080/github-webhook/`  
   - Content type: `application/json`  
   - Events: Just the push event  

## Verify deployment

```bash
curl -s http://<ec2-public-ip>:5000/api/health
docker ps
```

App UI: `http://<ec2-public-ip>:5000`
