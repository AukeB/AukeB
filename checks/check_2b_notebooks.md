# Check: README.md, Notebooks details

Read [common.md](common.md) first. It defines the base directory, the process for running a check, and the rules for fixing failures.

## Files this check uses

- `AukeB/README.md`, the Notebooks details section. This is the ground truth. Accept it as correct; do not check it against the files in the notebooks folder.
- `repos/public/notebooks/README.md`, which must be consistent with the ground truth

Do not look at the files in `repos/public/notebooks/` (the notebook scripts and folders). Only the two README files above are used by this check. Ignore any `__marimo__` folders.

## Exclusions

- Nothing in the University Courses & Research details section of `AukeB/README.md` ever needs to change. The user is no longer attending university and all courses are finished, so do not check, edit or report on that section.

## Rules

### Notebooks

16. The Notebooks details section of `AukeB/README.md` is the ground truth, and it can be assumed safely. `repos/public/notebooks/README.md` must be consistent with it. Consistent means identical: the bullet lines of the Notebooks details section (the lines starting with `- ` and a backtick) must appear in `repos/public/notebooks/README.md` with the same text, the same order and no extra or missing entries. Each bullet is compared as a whole line, so the file name in backticks, the emoji and the description must match exactly. Where they differ, update `repos/public/notebooks/README.md` to match the Notebooks details section of `AukeB/README.md`. Never change the Notebooks details section to match `repos/public/notebooks/README.md`.
   - Exception: the content of `repos/public/notebooks/README.md` outside the bullet lines is not checked and is never changed by this rule. This includes its `# Notebooks` header, its intro sentence, its `**Notebooks**:` label and blank lines.
