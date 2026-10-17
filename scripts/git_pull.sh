#!/usr/bin/env bash
# Pulls the profile repo and every repo under repos/ (fast-forward only).
# Repos with local changes or diverged history are reported and left alone.

set -u

BASE="$(cd "$(dirname "$0")/../.." && pwd)"

repos=("$BASE/AukeB")
for dir in "$BASE"/repos/public/*/ "$BASE"/repos/private/*/; do
    repos+=("${dir%/}")
done

failed=()
for repo in "${repos[@]}"; do
    name="$(basename "$repo")"
    if [ ! -d "$repo/.git" ]; then
        printf '\033[33mskip (not a git repo):\033[0m %s\n' "$name"
        continue
    fi
    if ! git -C "$repo" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        printf '\033[33mskip (no upstream):\033[0m %s\n' "$name"
        continue
    fi

    printf '\033[1;36m== %s\033[0m\n' "$name"
    if ! git -C "$repo" pull --ff-only; then
        printf '\033[31mpull failed:\033[0m %s\n' "$name"
        failed+=("$name")
    fi
done

echo
if [ ${#failed[@]} -eq 0 ]; then
    printf '\033[32mAll repos pulled.\033[0m\n'
else
    printf '\033[31mFailed: %s\033[0m\n' "${failed[*]}"
    exit 1
fi
