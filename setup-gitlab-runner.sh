#!/bin/bash
# ============================================================
# Setup GitLab Runner (self-hosted) for qscanner-demo
# Run this on an internal Qualys Linux machine with Docker.
#
# Usage:
#   chmod +x setup-gitlab-runner.sh
#   ./setup-gitlab-runner.sh <RUNNER_TOKEN>
#
# Get RUNNER_TOKEN from:
#   https://gitlab.com/surkadam/qscanner-demo/-/settings/ci_cd
#   → Runners → New project runner → tag: qualys-internal → copy token
# ============================================================

set -e

RUNNER_TOKEN="${1:?Usage: $0 <RUNNER_TOKEN>}"
GITLAB_URL="https://gitlab.com"
RUNNER_NAME="qualys-internal-runner"
RUNNER_TAG="qualys-internal"
RUNNER_VOLUME="gitlab-runner-config"

echo "=== Pulling GitLab Runner image ==="
docker pull gitlab/gitlab-runner:latest

echo "=== Creating config volume ==="
docker volume create "$RUNNER_VOLUME" || true

echo "=== Starting GitLab Runner container ==="
docker rm -f gitlab-runner 2>/dev/null || true
docker run -d \
  --name gitlab-runner \
  --restart always \
  -v "$RUNNER_VOLUME":/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest

echo "=== Registering runner with GitLab ==="
docker exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "$GITLAB_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --executor docker \
  --docker-image docker:24.0.2 \
  --docker-privileged \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --tag-list "$RUNNER_TAG" \
  --run-untagged false

echo ""
echo "=== Runner registered successfully! ==="
echo "Verify at: https://gitlab.com/surkadam/qscanner-demo/-/settings/ci_cd#js-runners-settings"
echo ""
echo "Next: trigger a pipeline at https://gitlab.com/surkadam/qscanner-demo/-/pipelines/new"
