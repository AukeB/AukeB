#!/usr/bin/env bash
# Prints the requires-python specification of every pyproject.toml under the Projects folder.
# Folders named .git, .venv and node_modules are skipped. A project without requires-python is reported as such.

# Stop on unset variables so typos are caught early.
set -u

# Resolve the workspace root: this script lives in AukeB/scripts/, so two levels up is the Projects folder.
BASE="$(cd "$(dirname "$0")/../.." && pwd)"

# Collect every pyproject.toml under the workspace, skipping .git, .venv and node_modules.
# -print0 and read -d '' keep paths with spaces intact.
files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find "$BASE" \( -name .git -o -name .venv -o -name node_modules \) -prune -o -name pyproject.toml -print0)

# Print each project's folder as a heading, followed by its requires-python line.
for file in "${files[@]}"; do
    # Display name: the project folder relative to the workspace root.
    project="$(dirname "$file")"
    label="${project#"$BASE"/}"
    printf '\033[1;36m== %s\033[0m\n' "$label"

    # Take the first requires-python line in the file and keep only its value.
    spec="$(grep -m1 '^requires-python' "$file" | sed -E 's/^requires-python[[:space:]]*=[[:space:]]*//')"
    if [ -z "$spec" ]; then
        printf '\033[33mnot set\033[0m\n'
    else
        printf '%s\n' "$spec"
    fi
    echo
done

printf '\033[32mChecked %d project(s).\033[0m\n' "${#files[@]}"
