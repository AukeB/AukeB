# Check: docs/repos.md

Read [common.md](common.md) first. It defines the base directory, the process for running a check, and the rules for fixing failures.

## Files this check uses

- `AukeB/docs/repos.md`, the counts above the table and the table
- The folders in `repos/public/` and `repos/private/`
- `AukeB/README.md`, to see which public repos are mentioned
- [check_1_readme_my_repositories.md](check_1_readme_my_repositories.md), for rule 3 when a repo is missing from the README

## Rules

### Counts

9. The three counts above the table in `docs/repos.md` must match the table. The total equals the number of rows. The public count equals the number of rows marked ✅ in the Public column. The private count equals the number of rows marked ❌ in the Public column.
10. Every folder in `repos/public/` and `repos/private/` has a row in the table. Every row names a folder in one of those two directories, except the `AukeB` row, which is the profile repo itself and is not in `repos/`.
11. The Public column of each row matches the folder the repo is in. A repo in `repos/public/` is ✅ and a repo in `repos/private/` is ❌. The folder is the ground truth, so the table is changed to match the folder, never the other way round.
12. Every public repo in `repos/public/` is mentioned in `README.md`, as rule 1 of [check_1_readme_my_repositories.md](check_1_readme_my_repositories.md) requires. If one is missing, it is added in the way rule 3 of that check says. If the repo has no readme, the user will have added one with a level 1 header and a description, so copy the description from that readme.
