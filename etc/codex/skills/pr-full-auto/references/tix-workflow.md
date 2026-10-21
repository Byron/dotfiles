# Tix in issue and PR workflows

Use this guidance during the active GitHub workflow only. Read and follow the available `tix` skill before editing files, including regression tests and review fixes. Tix governs target selection, travel, amendments, fixups, commit placement, messages, and replay. The calling skill still controls task scope, repository, remote, validation, and when GitHub work ends.

## Local History

Record the starting worktree, local work branch, head hash/change ID, and the verified push remote and remote branch. Before the first travel or history mutation in an edit/push cycle, capture the remote baseline described below; retain it through all fixes until that cycle's push.

Before each fix, locate the commit responsible for the failure or review feedback. Limit history edits to task-related commits on the work branch beyond the selected base. If the introducing commit is already in the base, add a new fix on the work branch instead of rewriting shared base history. In-scope Tix amendments, fixup insertion, and descendant replay are permitted even when the affected commits predate this run.

Use Tix to reach the target before editing and refresh `tix show` there. Follow its selection rules: amend an existing commit without `✨`, insert a `fixup!` immediately above one with `✨`, and create a new commit for independent work. Do not assume every CI fix is independent work. Preserve existing local changes according to the Tix skill before any required travel.

Keep the exact `fixup! <original subject>` and create the note required by Tix. Issue suffixes and ordinary review-fix titles apply only to new non-fixup commits. Put failure details, review feedback, and validation in the commit body. Use explicit Codex authorship for new independent commits and fixups; follow Tix's authorship rules for amendments and replay.

## Restore and Validate

Temporary detachment during Tix travel is expected. After editing an ancestor, follow Tix's replay and conflict recovery procedure, then restore the recorded local work branch:

```bash
tix travel <recorded-work-branch>
```

Verify the worktree path, branch attachment, intended changes, and fresh `tix show`. Resolve final commit hashes from the saved change IDs after replay, before Codex review, GitHub replies, or reporting. Run the relevant validation on the resulting branch as needed; do not push from an ancestor or with pending replay/conflicts.

## Push the Restored Branch

Before each edit/push cycle, read the exact remote ref:

```bash
git ls-remote --heads <remote> refs/heads/<remote-branch>
```

Save its object ID as `<expected-oid>` until that cycle's push. A successful empty result means the branch does not exist; an error is not an absent branch. Verify that existing remote changes are present in the starting local history, or accounted for by an authorized Tix rewrite already performed in this session. Stop on unexplained divergence or unaccounted remote work.

For a new branch or fast-forward update, push explicitly:

```bash
git push <remote> HEAD:refs/heads/<remote-branch>
```

When the authorized Tix work rewrote existing remote history, use the saved expected object ID as an explicit lease:

```bash
git push --force-with-lease=refs/heads/<remote-branch>:<expected-oid> <remote> HEAD:refs/heads/<remote-branch>
```

Use this only for the verified work/PR branch, never a base branch. Never use plain `--force`, a `+` refspec, or a lease inferred from a tracking ref. If the lease is rejected, stop and inspect the concurrent change; do not refresh the expected ID merely to retry. After success, verify the remote ref matches the restored local head. If the calling workflow includes CI monitoring, observe checks for that head. For a later cycle, capture a new baseline only after verifying the remote work is accounted for.
