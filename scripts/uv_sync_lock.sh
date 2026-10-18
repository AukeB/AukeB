#!/usr/bin/env bash
# Runs `uv sync` and then `uv lock` in every uv project in the profile repo and every repo under repos/.
# A project is any directory with a pyproject.toml, including nested ones.
# Repos without a pyproject.toml are skipped. A failure is reported and the script moves on to the next project.

# Stop on unset variables so typos are caught early. Failing commands do not stop the script; they are handled below.
set -u

# Resolve the workspace root: this script lives in AukeB/scripts/, so two levels up is the Projects folder.
BASE="$(cd "$(dirname "$0")/../.." && pwd)"

# Build the list of repos to check: the profile repo first, then every folder under repos/public and repos/private.
repos=("$BASE/AukeB")
for dir in "$BASE"/repos/public/*/ "$BASE"/repos/private/*/; do
    # Strip the trailing slash so basename and path joins work cleanly.
    repos+=("${dir%/}")
done

# Make sure uv is available before doing any work; otherwise every project would fail with the same error.
if ! command -v uv >/dev/null 2>&1; then
    printf '\033[31muv is not installed or not on PATH.\033[0m\n'
    exit 1
fi

# Names of projects whose uv sync or uv lock failed, reported at the end.
failed=()
for repo in "${repos[@]}"; do
    # Short display name for the repo: its folder name.
    name="$(basename "$repo")"

    # Collect the directory of every pyproject.toml in the repo, including nested projects.
    # Folders named .git, .venv and node_modules are pruned so they are not searched.
    # -print0 and read -d '' keep paths with spaces intact.
    projects=()
    while IFS= read -r -d '' file; do
        projects+=("$(dirname "$file")")
    done < <(find "$repo" \( -name .git -o -name .venv -o -name node_modules \) -prune -o -name pyproject.toml -print0)

    # No pyproject.toml anywhere in this repo, so there is nothing for uv to do; note it and move on.
    if [ ${#projects[@]} -eq 0 ]; then
        printf '\033[33mskip (no pyproject.toml):\033[0m %s\n' "$name"
        continue
    fi

    # Run uv sync and then uv lock in each project folder.
    for project in "${projects[@]}"; do
        # Label for output: the repo name, plus the sub-path for nested projects.
        label="$name${project#"$repo"}"
        printf '\033[1;36m== %s\033[0m\n' "$label"
        # The subshell changes into the project so uv finds its pyproject.toml; the && means lock only runs if sync succeeded.
        if ! (cd "$project" && uv sync && uv lock); then
            printf '\033[31muv sync/lock failed:\033[0m %s\n' "$label"
            failed+=("$label")
        fi
    done
done

# Final summary: exit 0 if every project succeeded, otherwise list the failures and exit 1.
echo
if [ ${#failed[@]} -eq 0 ]; then
    printf '\033[32mAll repos synced and locked.\033[0m\n'
else
    printf '\033[31mFailed: %s\033[0m\n' "${failed[*]}"
    exit 1
fi
