#!/usr/bin/env bash
# Commits all changes in the profile repo and every repo under repos/,
# then asks before pushing anything.

set -u

BASE="$(cd "$(dirname "$0")/.." && pwd)"

repos=("$BASE/AukeB")
for dir in "$BASE"/repos/public/*/ "$BASE"/repos/private/*/; do
    repos+=("${dir%/}")
done

committed=()
for repo in "${repos[@]}"; do
    name="$(basename "$repo")"
    if [ ! -d "$repo/.git" ]; then
        echo "skip (not a git repo): $name"
        continue
    fi
    if [ -z "$(git -C "$repo" status --porcelain)" ]; then
        continue
    fi

    echo "== $name"
    git -C "$repo" status --short
    if git -C "$repo" add -A && git -C "$repo" commit -q -m "Updated"; then
        committed+=("$repo")
    else
        echo "commit failed: $name"
    fi
done

if [ ${#committed[@]} -eq 0 ]; then
    echo "No changes to commit."
    exit 0
fi

echo
echo "Committed locally:"
for repo in "${committed[@]}"; do
    echo "  $(basename "$repo")"
done

read -r -p "Push these repos? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Not pushed. The commits are local only."
    exit 0
fi

for repo in "${committed[@]}"; do
    if git -C "$repo" push; then
        echo "pushed: $(basename "$repo")"
    else
        echo "push failed: $(basename "$repo")"
    fi
done
