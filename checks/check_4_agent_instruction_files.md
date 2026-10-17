# Check: agent instruction files (all repos)

Read [common.md](common.md) first. It defines the base directory, the process for running a check, and the rules for fixing failures.

## Files this check uses

- `AGENTS.md` and `CLAUDE.md` in the repos under `repos/public/` and `repos/private/`
- `AukeB/docs/repos.md`, the Python column, to find the Python-based repos
- [check_2_readme_details.md](check_2_readme_details.md), rules 4 and 5, for the application folders of `algorithms-from-scratch`

These rules cover `AGENTS.md` and `CLAUDE.md` in the repos. They are applied as overwrites, without asking, because the user asked for that behaviour.

## Rules

13. **Source.** Find every `AGENTS.md` under `repos/public/` and `repos/private/`, skipping `.venv`, `node_modules` and `.git` folders. The file with the latest modification time is the source. Its folder's `AGENTS.md` and `CLAUDE.md` are the source pair. If the newest `AGENTS.md` ties on modification time with another one, ask the user which to use. Report the source path and its modification time.
14. **Targets.** Overwrite `AGENTS.md` and `CLAUDE.md` with the source pair in every Python-based repo. The Python-based repos are the ones marked ✅ in the Python column of `AukeB/docs/repos.md`, and the ones marked ❌ there are not targets. Apply these exceptions:
   - The source repo itself is skipped, since it already has the pair.
   - `Tetris` and `university-courses-and-research` are skipped, since they no longer get edits. Do not add or change files in them.
   - `algorithms-from-scratch` gets the pair in each application folder listed in its tree (the leaves of the tree in `repos/public/algorithms-from-scratch/readme.md`), not at the repo root. Use the same application folders as in rules 4 and 5 of [check_2_readme_details.md](check_2_readme_details.md).
   - Repos marked ❌ in the Python column of `AukeB/docs/repos.md` are not targets. This covers private repos that are not Python-based.
   If a target already has the files, replace them. If it does not, create them.
15. **Verify.** After copying, each target's `AGENTS.md` and `CLAUDE.md` must match the source byte for byte. Report each target as pass or fail, and list which targets had their files replaced, created, or left unchanged. Do not commit or push.
