# Check: README.md, My Repositories

Read [common.md](common.md) first. It defines the base directory, the process for running a check, and the rules for fixing failures.

## Files this check uses

- `AukeB/README.md`, section `## My Repositories`
- `AukeB/docs/repos.md`, to see which repos are public
- The folders in `repos/public/`

Changes to `AukeB/README.md` are made only in this check's section.

## Exceptions

The `AukeB` repo is the profile repo. It is an exception to rules 1 and 3, so it does not need a bullet under `## My Repositories`, and a missing bullet for it is not a failure.

## Rules

1. In `README.md`, every public repository has a bullet under the `## My Repositories` section. The bullet links to the repo at `https://github.com/AukeB/<repo-name>`, with the repo name in backticks, followed by a colon and a description of at least one sentence. A sentence ends with `.`, `!` or `?`. One bullet may cover more than one repo, as long as each repo is named and linked in it.
2. The bullets under `## My Repositories` appear in the order they have in the file now. That order is the user's preference. Do not reorder them unless the user asks. Rule 3 is the only way a new bullet is added.
3. A public repository is not yet mentioned when no bullet under `## My Repositories` links to it. When one is found, ask the user for its position in the list. Do not add it until the user answers.

Rule 12 in [check_3_repos_md.md](check_3_repos_md.md) uses rule 3 of this check to add a missing public repo. When that happens, ask the user for the position as rule 3 says.
