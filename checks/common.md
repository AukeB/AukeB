# Common definitions and process for the consistency checks

This file is shared by all the check files in this folder:

- [check_1_readme_my_repositories.md](check_1_readme_my_repositories.md): rules 1 to 3
- [check_2_readme_details.md](check_2_readme_details.md): rules 4 to 8, plus the notebooks and university notices
- [check_3_repos_md.md](check_3_repos_md.md): rules 9 to 12
- [check_4_agent_instruction_files.md](check_4_agent_instruction_files.md): rules 13 to 15

To run a check, read this file first, then the check file the user named. Each check file says which other files it depends on.

No file in this folder may be changed without explicit instructions from the user. Do not edit one as part of a check, a fix, or any other task.

## Paths and sources

- The base directory is `/home/auke_b/Projects`. Every path in these checks is relative to it, unless a rule gives another base.
- `AukeB/` is the profile repo, with `AukeB/README.md` and `AukeB/docs/repos.md`. `repos/` is a sibling of `AukeB/`, not inside it. It holds `repos/public/` and `repos/private/`.
- "The order they have in the file now" (rule 2) means the order in the working-tree file at the time of the check, not the order in git.

## Definitions

- **Application**: a leaf of the tree in `repos/public/algorithms-from-scratch/readme.md`, meaning an entry with no entries nested under it. The tokenization exception in rule 4 still applies.
- **Application description**: the first non-empty line after the level 1 header of the application's readme, copied exactly, including any markdown links.
- **Bullet text**: in a bullet such as `- **Decision Tree**: <text>`, the part after the bold label and the colon. Bullet text must equal the application description exactly.

## Source of truth for descriptions

- The application readme is the source of truth for its description.
- If a bullet's text differs from the application description, update the bullet in `repos/public/algorithms-from-scratch/readme.md` and in `AukeB/README.md` to match the application readme. Never change an application readme to match a bullet.
- A description mismatch is not a rule conflict. Apply this section and do not ask.

## How to run a check

When the user asks for a check:

1. Go through each numbered rule in the check file, in order.
2. For each rule, check the files it names and decide whether the rule holds.
3. Report each rule as pass or fail, with the evidence (file, line, or text).
4. For each failing rule, fix the files directly so the rule passes, as long as the rule settles the fix. Do not wait for the user to decide.
5. Ask the user only when the rules do not settle the fix, such as the placement of a new repo under rule 3, or when two rules give different required results. A description mismatch is settled by "Source of truth for descriptions".
6. After fixing, report what you changed, per rule, with the files touched. Do not commit or push anything.

If a check depends on another check's files (for example, rule 14 uses the tree from the algorithms-from-scratch rules), read those files as well, but only fix the rules of the check the user asked for.
