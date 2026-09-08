#!/usr/bin/env bash
# Step 3 — Install Jenkins + OpenJDK 21 on Ubuntu 22.04 EC2.
set -euo pipefail

echo "==> Installing OpenJDK 21 (required by current Jenkins LTS)"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-21-jdk curl gnupg

echo "==> Adding Jenkins apt repository (current signing key)"
sudo rm -f /etc/apt/sources.list.d/jenkins.list /usr/share/keyrings/jenkins-keyring.*
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
gpg --batch --export 7198F4B714ABFC68 | sudo tee /usr/share/keyrings/jenkins-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

echo "==> Installing Jenkins"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

echo "==> Point Jenkins at Java 21 + grant Docker access"
sudo mkdir -p /etc/systemd/system/jenkins.service.d
printf '%s\n' '[Service]' 'Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"' 'Environment="PATH=/usr/lib/jvm/java-21-openjdk-amd64/bin:/usr/sbin:/usr/bin:/sbin:/bin"' \
  | sudo tee /etc/systemd/system/jenkins.service.d/java21.conf >/dev/null
sudo usermod -aG docker jenkins
sudo systemctl daemon-reload
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
