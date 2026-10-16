# Profile README and repo consistency checks

This file must never be changed without explicit instructions from the user. Do not edit it as part of a check, a fix, or any other task.

## Paths and sources

- The base directory is `/home/auke_b/Projects`. Every path in these rules is relative to it, unless a rule gives another base.
- `AukeB/` is the profile repo, with `AukeB/README.md` and `AukeB/rules.md`. `repos/` is a sibling of `AukeB/`, not inside it. It holds `repos/public/` and `repos/private/`.
- "The order they have in the file now" (rule 2) means the order in the working-tree file at the time of the check, not the order in git.

## Definitions

- **Application**: a leaf of the tree in `repos/public/algorithms-from-scratch/readme.md`, meaning an entry with no entries nested under it. The tokenization exception in rule 4 still applies.
- **Application description**: the first non-empty line after the level 1 header of the application's readme, copied exactly, including any markdown links.
- **Bullet text**: in a bullet such as `- **Decision Tree**: <text>`, the part after the bold label and the colon. Bullet text must equal the application description exactly.

## Source of truth for descriptions

- The application readme is the source of truth for its description.
- If a bullet's text differs from the application description, update the bullet in `repos/public/algorithms-from-scratch/readme.md` and in `AukeB/README.md` to match the application readme. Never change an application readme to match a bullet.
- A description mismatch is not a rule conflict. Apply this section and do not ask.

## How to check these rules

When the user asks you to check this file:

1. Go through each numbered rule in order.
2. For each rule, check the files it names and decide whether the rule holds.
3. Report each rule as pass or fail, with the evidence (file, line, or text).
4. For each failing rule, fix the files directly so the rule passes, as long as the rule settles the fix. Do not wait for the user to decide.
5. Ask the user only when the rules do not settle the fix, such as the placement of a new repo under rule 3, or when two rules give different required results. A description mismatch is settled by "Source of truth for descriptions".
6. After fixing, report what you changed, per rule, with the files touched. Then ask the user whether to run `AukeB/git_sync.sh`. Do not run it, and do not commit or push anything, unless the user confirms.
7. When the user confirms, run `AukeB/git_sync.sh` from the base directory. It commits the changes in every repo that has them, then asks the user before pushing. Do not answer that push prompt yourself.

## README.md: My Repositories

The `AukeB` repo is the profile repo. It is an exception to rules 1 and 3, so it does not need a bullet under `## My Repositories`, and a missing bullet for it is not a failure.

1. In `README.md`, every public repository has a bullet under the `## My Repositories` section. The bullet links to the repo at `https://github.com/AukeB/<repo-name>`, with the repo name in backticks, followed by a colon and a description of at least one sentence. A sentence ends with `.`, `!` or `?`. One bullet may cover more than one repo, as long as each repo is named and linked in it.
2. The bullets under `## My Repositories` appear in the order they have in the file now. That order is the user's preference. Do not reorder them unless the user asks. Rule 3 is the only way a new bullet is added.
3. A public repository is not yet mentioned when no bullet under `## My Repositories` links to it. When one is found, ask the user for its position in the list. Do not add it until the user answers.

## README.md: Details

### `algorithms-from-scratch`

4. Each application in `repos/public/algorithms-from-scratch/` has a readme file named `readme.md` (case-insensitive). An application is a leaf of the tree (see Definitions), and it is a folder that holds code, or a notebook file. In its readme, the first line is a level 1 markdown header (a line starting with `# `), and the first non-empty line after it is the application description.
   - Exception: `machine_learning/tokenization/` has no application folder for the GPT Tokenizer. Its readme in that folder is the description for the GPT Tokenizer, and that is intended.
5. The per-application bullets are listed in `repos/public/algorithms-from-scratch/readme.md` below the file and directory structure tree. Each bullet's text equals the application description. The same bullets, with the same text, appear in the Algorithms from Scratch details section of `AukeB/README.md`.
6. The directory tree in the Algorithms from Scratch details section of `AukeB/README.md` matches the tree in `repos/public/algorithms-from-scratch/readme.md`. A match means the same entries with the same names and nesting. The `AukeB/README.md` version may start with an `algorithms-from-scratch/` line, which the repo readme does not have.
7. Every application in that tree has exactly one bullet in the Algorithms from Scratch details section of `AukeB/README.md`. The bullets appear in the same order as the tree, and each bullet's text is the application description from rule 4.
8. The user edits the Algorithms from Scratch content only in `repos/public/algorithms-from-scratch/`, meaning its `readme.md` and the application readmes. Those files are the source of truth, and any difference from `README.md` means the repo is newer. Update `README.md` to match them. Never edit files in `repos/public/algorithms-from-scratch/` to match `README.md`. If a bullet differs from its application description, the "Source of truth for descriptions" section decides the fix.

### `notebooks`

- The Notebooks details section in `AukeB/README.md` is ignored by all checks, since the `notebooks` repository will be reworked somewhere in the near future by the user. As long as this notice is present in that section, you can ignore it: "The notebooks repository will be reworked, so this section is out of date for now."

### `university-courses-and-research`

- Nothing in the University Courses & Research details section of `AukeB/README.md` ever needs to change. The user is no longer attending university and all courses are finished, so do not check, edit or report on that section.

## repos.md

### Counts

9. The three counts above the table in `repos.md` must match the table. The total equals the number of rows. The public count equals the number of rows marked ✅ in the Public column. The private count equals the number of rows marked ❌ in the Public column.
10. Every folder in `repos/public/` and `repos/private/` has a row in the table. Every row names a folder in one of those two directories, except the `AukeB` row, which is the profile repo itself and is not in `repos/`.
11. The Public column of each row matches the folder the repo is in. A repo in `repos/public/` is ✅ and a repo in `repos/private/` is ❌. The folder is the ground truth, so the table is changed to match the folder, never the other way round.
12. Every public repo in `repos/public/` is mentioned in `README.md`, as rule 1 requires. If one is missing, it is added in the way rule 3 says. If the repo has no readme, the user will have added one with a level 1 header and a description, so copy the description from that readme.

## Agent instruction files (all repos)

These rules cover `AGENTS.md` and `CLAUDE.md` in the repos. They are applied as overwrites, without asking, because the user asked for that behaviour.

13. **Source.** Find every `AGENTS.md` under `repos/public/` and `repos/private/`, skipping `.venv`, `node_modules` and `.git` folders. The file with the latest modification time is the source. Its folder's `AGENTS.md` and `CLAUDE.md` are the source pair. If the newest `AGENTS.md` ties on modification time with another one, ask the user which to use. Report the source path and its modification time.
14. **Targets.** Overwrite `AGENTS.md` and `CLAUDE.md` with the source pair in every public repo, with these exceptions:
   - The source repo itself is skipped, since it already has the pair.
   - `Tetris` and `university-courses-and-research` are skipped, since they no longer get edits. Do not add or change files in them.
   - `algorithms-from-scratch` gets the pair in each application folder listed in its tree (the leaves of the tree in `repos/public/algorithms-from-scratch/readme.md`), not at the repo root. Use the same application folders as in rules 4 and 5.
   - Private repos are not targets.
   If a target already has the files, replace them. If it does not, create them.
15. **Verify.** After copying, each target's `AGENTS.md` and `CLAUDE.md` must match the source byte for byte. Report each target as pass or fail, and list which targets had their files replaced, created, or left unchanged. Do not commit or push. Leave that to `AukeB/git_sync.sh`, which the user runs.
