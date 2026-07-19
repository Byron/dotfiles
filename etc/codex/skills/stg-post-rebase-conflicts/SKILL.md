---
name: stg-post-rebase-conflicts
description: "Explicit opt-in only: resolve StGit conflicts after a rebase or patch push while preserving patch intent and completing the patch queue. Use only when the user explicitly invokes `$stg-post-rebase-conflicts`, or when another already-invoked skill explicitly directs Codex to invoke it. Do not select this skill merely because a request involves StGit conflicts, rebases, or patch pushes."
---

# StG Post-Rebase Conflicts

## Operating Mode

Treat this skill as permission to resolve StGit patch conflicts in the current worktree and continue applying the existing patch queue. Preserve the intent of each conflicting patch as readable from the current StGit patch/commit diff and commit message, adapt it to the rebased code, run `cargo fmt`, refresh the patch, and push the next patch.

Do not create new commits, reorder patches, drop patches, squash patches, change branches, or discard user work unless the user explicitly asks.

## Workflow

Repeat until `stg push` reports there are no unapplied patches left:

1. Inspect the current state:

   ```bash
   git status --short
   stg series
   stg top
   stg show
   ```

2. If there are no conflicts and no local changes from conflict resolution, push the next patch:

   ```bash
   stg push
   ```

3. If `stg push` reports there are no unapplied patches left, stop successfully.
4. If there are conflicts, identify the conflicting files with `git status --short` and inspect them directly. Also inspect the current patch with `stg show` so the intended change is clear before editing.
5. Resolve each conflict by keeping the current patch's intended behavior, API, tests, docs, and user-visible effect, while adapting to the rebased base code.
6. Prefer semantic resolution over choosing one side wholesale. Preserve unrelated upstream changes unless they directly conflict with the patch intent.
7. Run focused validation when feasible, especially tests touched by the current patch.
8. Format the fixed-up patch before refreshing it:

   ```bash
   cargo fmt
   ```

9. Refresh the resolved patch:

   ```bash
   stg refresh
   ```

10. Push the next patch:

   ```bash
   stg push
   ```

11. If `stg push` produces another conflict, repeat this workflow for the new current patch.
12. After `stg push` reports there are no unapplied patches left, run:

   ```bash
   cargo clippy --workspace --all-targets
   ```

## Interpreting Patch Intent

Use these sources, in order:

- `stg show` for the current StGit patch/commit diff and commit message.
- Nearby code and tests in the rebased worktree.
- Repository history only when the current patch is ambiguous.

When both sides changed the same area, preserve the patch's meaningful effect rather than its exact old text. If the rebased code already implements the patch intent, remove the duplicate change and refresh the patch so it becomes empty only if StGit accepts that naturally.

## Stop Conditions

Stop and report the blocker when:

- The current worktree is not an StGit stack or has no current patch.
- Local changes appear unrelated to the conflicted patch and may be user-owned.
- The current patch intent cannot be inferred from `stg show`, code, tests, or commit message.
- A resolution requires product, design, API, or compatibility judgment with multiple plausible answers.
- Validation needs unavailable services, credentials, or production access.
- Continuing would require destructive operations such as `git reset --hard`, `git checkout -- <path>`, `stg delete`, `stg squash`, dropping patches, or plain force-pushing.

## Completion Criteria

Finish when:

- `stg push` reports no unapplied patches remain, or a stop condition is reached.
- All conflicts encountered in the applied queue have been resolved.
- Each resolved patch was refreshed with `stg refresh`.
- `cargo fmt` was run after each fixed-up patch before refresh.
- `cargo clippy --workspace --all-targets` was run after the stack completed, or any inability to run it is explained.
- Relevant validation was run, or any skipped validation is explained.
- The final response summarizes resolved patches, validation, and any remaining risk.
