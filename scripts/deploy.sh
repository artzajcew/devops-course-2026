#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--dry-run" ) ]]; then
    echo "Usage: scripts/deploy.sh [--dry-run]" >&2
    exit 1
fi

DRY_RUN=()
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=(--dry-run)
fi

if [[ ! -f site/index.html ]]; then
    echo "Error: site/index.html not found" >&2
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: commit changes before deployment" >&2
    exit 1
fi

SSH="/mnt/c/Windows/System32/OpenSSH/ssh.exe"

if [[ ! -x "$SSH" ]]; then
    echo "Error: Windows SSH client not found" >&2
    exit 1
fi

rsync -avz "${DRY_RUN[@]}" --delete --chmod=D755,F644 \
    -e "$SSH" site/ devops:/var/www/devops-site/

if [[ ${#DRY_RUN[@]} -eq 0 ]]; then
    if ! curl --fail --silent --show-error --max-time 10 \
        --cacert "$HOME/devops.crt" https://devops.local/ -o /dev/null; then
        echo "Error: HTTPS health check failed" >&2
        exit 1
    fi
    echo "Deployment successful: $(git rev-parse --short HEAD)"
fi
