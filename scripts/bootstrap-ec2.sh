#!/usr/bin/env bash
# Convenience: run Docker + Jenkins installers in order on a fresh Ubuntu 22.04 EC2.
set -euo pipefail
cd "$(dirname "$0")"
bash ./01-install-docker.sh
bash ./02-install-jenkins.sh
