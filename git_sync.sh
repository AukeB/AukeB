#!/usr/bin/env bash
# Commits all changes in the profile repo and every repo under repos/,
# then asks before pushing anything, including commits that were made earlier and are not pushed yet.

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
    git -C "$repo" status --porcelain | while IFS= read -r line; do
        code="${line:0:2}"
        path="${line:3}"
        case "$code" in
            "??"|A*) printf '\033[32mA\033[0m %s\n' "$path" ;;
            *D*) printf '\033[31mD\033[0m %s\n' "$path" ;;
            *M*) printf '\033[33mM\033[0m %s\n' "$path" ;;
            *) printf '%s %s\n' "$code" "$path" ;;
        esac
    done
    if git -C "$repo" add -A && git -C "$repo" commit -q -m "Updated"; then
        committed+=("$repo")
    else
        echo "commit failed: $name"
    fi
done

if [ ${#committed[@]} -eq 0 ]; then
    echo "No changes to commit."
fi

# Repos with commits that are not on their remote yet (new or from earlier runs)
to_push=()
for repo in "${repos[@]}"; do
    [ -d "$repo/.git" ] || continue
    ahead="$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)"
    if [ "$ahead" -gt 0 ]; then
        to_push+=("$repo")
    fi
done

if [ ${#to_push[@]} -eq 0 ]; then
    echo "Nothing to push."
    exit 0
fi

echo
echo "Not pushed yet:"
for repo in "${to_push[@]}"; do
    echo "  $(basename "$repo") ($(git -C "$repo" rev-list --count '@{u}..HEAD') commit(s))"
done

read -r -p "Push these repos? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Not pushed. The commits are local only."
    exit 0
fi

for repo in "${to_push[@]}"; do
    if git -C "$repo" push; then
        echo "pushed: $(basename "$repo")"
    else
        echo "push failed: $(basename "$repo")"
    fi
done
