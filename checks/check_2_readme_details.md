# Check: README.md, Details

Read [common.md](common.md) first. It defines the base directory, the definitions of application and application description, the source of truth for descriptions, and the process for running a check.

## Files this check uses

- `repos/public/algorithms-from-scratch/readme.md`, which holds the tree and the bullets
- Each application readme in `repos/public/algorithms-from-scratch/`
- `AukeB/README.md`, the Algorithms from Scratch details section

Changes to `AukeB/README.md` are made only in the sections named in this check. The Notebooks and University Courses & Research sections are excluded (see below).

## Exclusions

- The Notebooks details section in `AukeB/README.md` is ignored by all checks, since the `notebooks` repository will be reworked somewhere in the near future by the user. As long as this notice is present in that section, you can ignore it: "The notebooks repository will be reworked, so this section is out of date for now."
- Nothing in the University Courses & Research details section of `AukeB/README.md` ever needs to change. The user is no longer attending university and all courses are finished, so do not check, edit or report on that section.

## Rules

### `algorithms-from-scratch`

4. Each application in `repos/public/algorithms-from-scratch/` has a readme file named `readme.md` (case-insensitive). An application is a leaf of the tree (see Definitions in [common.md](common.md)), and it is a folder that holds code, or a notebook file. In its readme, the first line is a level 1 markdown header (a line starting with `# `), and the first non-empty line after it is the application description.
   - Exception: `machine_learning/tokenization/` has no application folder for the GPT Tokenizer. Its readme in that folder is the description for the GPT Tokenizer, and that is intended.
5. The per-application bullets are listed in `repos/public/algorithms-from-scratch/readme.md` below the file and directory structure tree. Each bullet's text equals the application description. The same bullets, with the same text, appear in the Algorithms from Scratch details section of `AukeB/README.md`.
6. The directory tree in the Algorithms from Scratch details section of `AukeB/README.md` matches the tree in `repos/public/algorithms-from-scratch/readme.md`. A match means the same entries with the same names and nesting. The `AukeB/README.md` version may start with an `algorithms-from-scratch/` line, which the repo readme does not have.
7. Every application in that tree has exactly one bullet in the Algorithms from Scratch details section of `AukeB/README.md`. The bullets appear in the same order as the tree, and each bullet's text is the application description from rule 4.
8. The user edits the Algorithms from Scratch content only in `repos/public/algorithms-from-scratch/`, meaning its `readme.md` and the application readmes. Those files are the source of truth, and any difference from `README.md` means the repo is newer. Update `README.md` to match them. Never edit files in `repos/public/algorithms-from-scratch/` to match `README.md`. If a bullet differs from its application description, the "Source of truth for descriptions" section in [common.md](common.md) decides the fix.

## Other checks that use this one

[check_4_agent_instruction_files.md](check_4_agent_instruction_files.md) rule 14 uses the leaves of the tree from rules 4 and 5 of this check to find the application folders. Those folders are the ones it uses, so changing the tree here changes that check too.
