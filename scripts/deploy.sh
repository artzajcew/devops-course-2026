#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DRY_RUN=()
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=(--dry-run)
elif [[ $# -ne 0 ]]; then
    echo "Usage: scripts/deploy.sh [--dry-run]" >&2
    exit 1
fi

if [[ ! -f site/index.html ]]; then
    echo "Error: site/index.html not found" >&2
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: commit all changes before deployment" >&2
    exit 1
fi

SSH=(ssh -p 2222 -i "$HOME/.ssh/devops_vm"
     -o BatchMode=yes -o ConnectTimeout=5)

rsync -avz "${DRY_RUN[@]}" --delete --chmod=D755,F644 \
    -e "${SSH[*]}" site/ devops@devops.local:/var/www/devops-site/

if [[ ${#DRY_RUN[@]} -eq 0 ]]; then
    curl --fail --silent --show-error \
        --max-time 10 --cacert "$HOME/devops.crt" \
        https://devops.local/ -o /dev/null
    echo "Deployment successful: $(git rev-parse --short HEAD)"
fi
