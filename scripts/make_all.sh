#!/usr/bin/env bash
# Runs `make all` in every project that has both a makefile and a pyproject.toml.
# Searches the profile repo and every repo under repos/, including nested projects.
# A failure is reported and the script moves on to the next project.

# Stop on unset variables so typos are caught early. Failing commands are handled below.
set -u

# Resolve the workspace root: this script lives in AukeB/scripts/, so two levels up is the Projects folder.
BASE="$(cd "$(dirname "$0")/../.." && pwd)"

# Make sure make is available before doing any work.
if ! command -v make >/dev/null 2>&1; then
    printf '\033[31mmake is not installed or not on PATH.\033[0m\n'
    exit 1
fi

# Collect the folder of every makefile that has a pyproject.toml next to it.
# .git, .venv and node_modules are pruned so they are not searched.
# -print0 and read -d '' keep paths with spaces intact.
projects=()
while IFS= read -r -d '' makefile; do
    project="$(dirname "$makefile")"
    if [ -f "$project/pyproject.toml" ]; then
        projects+=("$project")
    fi
done < <(find "$BASE" \( -name .git -o -name .venv -o -name node_modules \) -prune -o -name makefile -print0)

for project in "${projects[@]}"; do
    # Label for output: the project path relative to the workspace root.
    label="${project#"$BASE"/}"
    printf '\033[1;36m== %s\033[0m\n' "$label"

    # The subshell changes into the project so make finds its makefile.
    # Output is kept in a log so a failure can be traced to its target.
    log="$(mktemp)"
    (cd "$project" && set -o pipefail && make all 2>&1 | tee "$log")
    status=$?

    if [ "$status" -ne 0 ]; then
        # make git fails when there is nothing to commit. If that is the only failing target and the tree is clean, carry on.
        if grep -q ': git\] Error' "$log" && [ -z "$(git -C "$project" status --porcelain)" ]; then
            printf '\033[33mnothing to commit:\033[0m %s\n' "$label"
        else
            rm -f "$log"
            printf '\033[31mmake all failed, stopping:\033[0m %s\n' "$label"
            exit 1
        fi
    fi
    rm -f "$log"
done

printf '\033[32mmake all succeeded in %d project(s).\033[0m\n' "${#projects[@]}"
