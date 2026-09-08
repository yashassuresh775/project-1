#!/usr/bin/env bash
# Step 3 — Install Jenkins + OpenJDK 17 on Ubuntu 22.04 EC2.
set -euo pipefail

echo "==> Installing OpenJDK 17"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk curl gnupg

echo "==> Adding Jenkins apt repository"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

echo "==> Installing Jenkins"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

echo "==> Grant Jenkins Docker access"
sudo usermod -aG docker jenkins
sudo systemctl enable --now jenkins
sudo systemctl restart jenkins

echo "==> Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo

PUBLIC_IP="$(curl -fsS http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo '<ec2-public-ip>')"

cat <<EOF

Done (Step 3).
Open Jenkins: http://${PUBLIC_IP}:8080
1) Paste the admin password above
2) Install suggested plugins
3) Create your admin user
4) Create a Pipeline job → Pipeline script from SCM → this GitHub repo → Script Path: Jenkinsfile

Next: scripts/03-configure-jenkins-notes.md
EOF
