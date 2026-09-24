#!/bin/bash
# ============================================================
# run_demo_containers.sh — spin up ONE running container per app
# image so each image gets an associated container instance that
# the Qualys CS sensor can see on this host.
#
# Usage:
#   ./run_demo_containers.sh            # uses :latest
#   TAG=<sha> ./run_demo_containers.sh  # specific tag
#   ./run_demo_containers.sh --stop     # tear the containers down
#
# Run this on a host where the Qualys sensor/agent is installed
# (e.g. the qualys-internal GitLab runner host).
# ============================================================

set -u

REGISTRY="${REGISTRY:-registry.gitlab.com/surkadam/qscanner-demo}"
TAG="${TAG:-latest}"
APPS="python-app node-app rails-app"

if [ "${1:-}" = "--stop" ]; then
  for app in $APPS; do
    echo ">> removing container qscan-${app}"
    docker rm -f "qscan-${app}" 2>/dev/null || true
  done
  exit 0
fi

for app in $APPS; do
  img="${REGISTRY}/${app}:${TAG}"
  name="qscan-${app}"

  echo ">> ${img}"
  docker rm -f "${name}" 2>/dev/null || true

  if ! docker pull "${img}"; then
    echo "   !! pull failed for ${img} — skipping"
    continue
  fi

  # Keep-alive override: demo apps have no reliable long-running CMD
  # (rails-app has none at all). A sleeping container still counts as a
  # running instance of the image for association purposes.
  docker run -d \
    --name "${name}" \
    --restart unless-stopped \
    --label "qualys.demo=image-association" \
    "${img}" tail -f /dev/null

  echo "   started ${name}"
done

echo
echo "=== running demo containers ==="
docker ps --filter "name=qscan-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
