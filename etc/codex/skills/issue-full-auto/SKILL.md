---
name: issue-full-auto
description: "Work a GitHub issue URL, GitHub security advisory URL, or plain-text issue report end to end in full-auto mode from a user-prepared pristine non-base worktree: verify the local clone and remote, refuse if the starting worktree is not set or is not clean, write a regression test, fix the issue, create StGit commits with Codex authorship, run one Codex review per commit, push the current branch explicitly, open a GitHub PR as Byron with disclosure, then invoke pr-full-auto for CI and review follow-up. Use when the user asks Codex to fix, implement, or work on a GitHub issue, advisory, or issue-like report automatically."
---

# Issue Full Auto

## Operating Mode

Treat this skill as permission to take a GitHub issue URL, GitHub security advisory URL, or plain-text issue report from report to pull request only from a user-prepared pristine worktree: inspect the issue context, verify the starting worktree, reproduce the problem with a test, implement the fix, validate it, create StGit commits, push the current branch explicitly, open a PR, and then use `pr-full-auto` to drive the PR through CI and review.

Do not merge the PR, close the issue manually, bypass branch protection, create or switch worktrees, change directories away from the starting worktree, or perform destructive git operations unless the user explicitly asks.

## Resolve Context

1. Classify the user's input:
   - If it contains a GitHub repository security advisory URL like `https://github.com/<owner>/<repo>/security/advisories/GHSA-...`, use advisory-backed mode.
   - If it contains a GitHub issue URL, use URL-backed mode.
   - Otherwise, use plain-text report mode and treat the user's issue text as the complete issue report.
2. Run `gh auth status` before relying on `gh`.
3. In URL-backed mode, resolve repository, issue number, title, body, labels, and recent comments with `gh issue view`.
4. In advisory-backed mode:
   - Parse the owner, repo, and GHSA ID from the advisory URL.
   - Resolve advisory details with:

     ```bash
     gh api repos/<owner>/<repo>/security-advisories/<GHSA-ID>
     ```

   - Capture the advisory URL, GHSA ID, summary/title, description, severity, affected package/ecosystem, vulnerable version range, patched versions, CVE ID if present, and identifiers if available.
   - Treat the advisory as security-sensitive. If the advisory is private, embargoed, or contains exploit details that should not be disclosed in a public PR, keep the PR body sanitized and link or reference the advisory only as appropriate for repository policy.
   - Do not invent a GitHub issue number, labels, or issue comments.
5. In plain-text report mode:
   - Use the current local clone as the target repository.
   - Derive a concise working title from the report text.
   - Preserve the exact user-provided report text for the PR body.
   - Do not invent a GitHub issue number, issue URL, labels, or comments.
6. Verify the current local clone's remote:
   - In URL-backed mode, verify that the remote matches the issue repository. Prefer the remote whose URL corresponds to the issue repo; use that remote for push and PR creation.
   - In advisory-backed mode, verify that the remote matches the advisory repository. Prefer the remote whose URL corresponds to the advisory repo; use that remote for push and PR creation.
   - In plain-text report mode, verify that a pushable GitHub remote exists and use that remote for push and PR creation.
7. Inspect local state with `git status --short`. Treat existing local changes as user-owned. Stop if they conflict with the issue work.
8. Confirm the clone is sufficiently current for the target base branch. Fetch remote metadata if needed, but do not rebase, reset, or discard local work without explicit user approval.

## Starting Worktree

The starting directory is the only allowed worktree for this skill. Do not run `cd`, `pushd`, `git -C`, `git worktree add`, `git worktree remove`, `git switch`, or `git checkout` to move the work elsewhere. Record the starting path with `pwd`, use that exact path as `workdir` for every later command, and refuse to continue if the starting path is not set, not a Git worktree, not pristine, or on a base/release branch. The current branch is the work branch for the run; do not require it to match a derived `fix/...` name.

1. Treat the current branch name as the prepared work branch. A `fix/<slug>-<issue-number>` or `fix/<slug>-<ghsa-id>` branch name is recommended when the user is preparing a worktree, but it is not required and must not be used as a reason to stop.
2. Verify the starting worktree before editing or committing:

   ```bash
   pwd
   git rev-parse --show-toplevel
   git branch --show-current
   git status --short
   stg series
   git rev-parse --abbrev-ref --symbolic-full-name @{u}
   ```

   If `@{u}` is unset, that is acceptable. If it is set, it must not resolve to `origin/main`, `origin/master`, or any other base branch.
3. The current branch must not be `main`, `master`, a release branch, or any branch whose upstream is a base branch. If the branch fails one of those checks, stop and ask the user to start Codex in a pristine worktree on a non-base work branch.
4. The starting worktree must be pristine: `git status --short` and `stg series` must both be empty. Treat any existing file changes, untracked files, or StGit patches as user-owned and stop.
5. Do all test, fix, review, commit, push, and PR work from the starting worktree only. Before the first StGit command and before the first push, re-run:

   ```bash
   pwd
   git branch --show-current
   git status --short
   stg series
   ```

   The `pwd` output must match the recorded starting path every time.

## Fix Workflow

1. Read the issue and relevant code before editing. Search with `rg` first.
2. Write a failing regression test that reproduces the issue before implementing the fix.
3. In advisory-backed mode, think beyond the single scenario named in the advisory: identify similar attack vectors, adjacent inputs, variant encodings, alternate call paths, and shared helpers that express the same exploit class. Prefer a general prevention that closes the broader class when it is coherent and proportional, and add regression coverage for the representative variants without disclosing sensitive exploit details unnecessarily.
4. If the issue is related to git behavior, inspect `/Users/byron/dev/github.com/git/git` as the desired-behavior reference rather than relying only on the issue report. Record the relevant Git baseline, command behavior, test, commit, or source reference for the eventual commit message.
5. Implement the smallest coherent fix that satisfies the regression test and fits the repo's existing patterns.
6. Run the focused test first, then the nearest repo-standard validation that is proportional to the change.
7. Do not run `codex review --uncommitted` in this workflow. Codex review happens only after a StGit commit exists, and only once per commit hash.
8. If you notice an issue yourself before committing, fix it directly; do not invoke Codex review as a pre-commit check.

## StGit Commit Rules

Use StGit for all commits created by this skill.

Before creating or refreshing any StGit patch, run `pwd` and `git branch --show-current`. The path must be the recorded starting worktree, and the branch must be the same current branch recorded during starting-worktree verification. If either check fails, stop immediately.

1. Create the first patch with the fixed worktree content:

   ```bash
   stg new --refresh --author="$model_name $model_version <codex@openai.com>" --message "<message>" <patch-name>
   ```

2. If exact runtime model fields are unavailable, use:

   ```bash
   --author="Codex GPT-5 <codex@openai.com>"
   ```

3. Make the patch name short, lowercase, and hyphenated, without `/`.
4. Write a descriptive commit message:
   - Title: concise user-visible fix.
   - In URL-backed mode, if this first patch is related to the issue fix, append `ISSUE_SUFFIX` to the title, where `ISSUE_SUFFIX` is `(#<issue-number>)`; for example, `fix: handle phantom submodule modifications (#2585)`.
   - Body: issue summary, failing test/reproduction, fix rationale, validation run.
   - In advisory-backed mode, reference the GHSA ID and include only the advisory details needed to understand the fix. Avoid reproducing sensitive exploit details unless they are already public and necessary.
   - In plain-text report mode, include a concise summary of the user-provided report rather than a GitHub issue reference.
   - For git-related issues: include the Git baseline/reference details found during research.
   - Do not mention the StGit patch name; it is local bookkeeping and not useful commit history.
5. Get the new commit hash, then run exactly once for that hash:

   ```bash
   codex review --commit <hash>
   ```

   Do not also run `codex review --uncommitted`, and do not rerun review for the same commit hash.
6. Address substantive review findings. Ignore only findings that are clearly false positives or unrelated to the task, and mention that judgment in the final summary.
7. For small follow-up edits from commit review, update the same patch:

   ```bash
   stg refresh --author="$model_name $model_version <codex@openai.com>"
   ```

   Use the fallback author if needed.
8. If `stg refresh` changes the commit hash, run `codex review --commit <new-hash>` exactly once for the new hash. This is a review for the new commit, not a repeat review of the old hash.
9. For substantial independent review findings, create another StGit patch with `stg new --refresh --author=...`, then run one Codex review for that new commit hash.
10. Include only intentional issue-related files in each patch.
11. Do not add Byron as co-author for Codex-created work. Add co-author trailers only when the user explicitly contributed included code or text.

## Pull Request

1. Before pushing, confirm again that `pwd` is the recorded starting worktree and `git branch --show-current` is the same current branch recorded during starting-worktree verification. Never push from `main`, `master`, or any branch whose upstream is a base branch.
2. Push explicitly to the selected target remote and current branch name:

   ```bash
   git push <remote> HEAD:refs/heads/<current-branch>
   ```

   Do not run bare `git push`, do not rely on upstream tracking, and do not set upstream with `-u`.
3. Create the PR with `gh pr create --head <current-branch> --base <base-branch>` against the selected target repository. Do not rely on `gh` inferring the head from upstream tracking.
4. Title the PR for the fix only. Do not disclose Codex or Byron impersonation in the title.
5. Prefix the PR body with `PR_HEADER`, then append the issue, advisory, report, and validation details:

   ```markdown
   ## Tasks

   - [ ] refackiew

   ----
   Created by Codex on behalf of Byron. Byron will review before this is ready to merge.
   ```

6. In URL-backed mode, link the issue:
   - Use `Fixes #<issue-number>` or equivalent only when the PR fully resolves the issue.
   - Use `Refs #<issue-number>` when the PR is partial, investigative, or intentionally not closing the issue.
7. In advisory-backed mode:
   - Include the advisory URL and GHSA ID in the PR body.
   - Include a concise `Advisory summary` section with severity, affected package/range, patched version details, and CVE ID when available.
   - Do not use `Fixes #...` or `Refs #...` unless there is also a real GitHub issue.
   - Keep the PR body sanitized if the advisory is private, embargoed, or includes details that should not be publicly disclosed.
8. In plain-text report mode, include the exact user-provided issue text in the PR body under a `Reported issue` section instead of an issue URL or `Fixes`/`Refs` line.
9. Include a concise test summary and any notable Git reference/baseline details. Do not mention StGit patch names in the PR title or body; summarize changes by issue, behavior, files, tests, commit title, or short SHA instead.
10. After the PR exists, invoke the `pr-full-auto` skill on the PR URL to monitor CI, inspect reviews, address non-nit feedback, push StGit follow-up commits, and continue until green or blocked.

## Stop Conditions

Stop and report the blocker when:

- GitHub authentication or repository permissions are missing.
- In URL-backed mode, the local clone's remote cannot be matched to the issue repository.
- In advisory-backed mode, the advisory cannot be read, or the local clone's remote cannot be matched to the advisory repository.
- In plain-text report mode, the current local clone has no pushable GitHub remote.
- The starting worktree path is not set, cannot be confirmed, is not a Git worktree, or later commands cannot be run from that same path.
- The starting branch is `main`, `master`, a release branch, or has upstream tracking to a base branch such as `origin/main` or `origin/master`.
- The starting worktree is not pristine: `git status --short` or `stg series` is non-empty.
- A regression test cannot be written without unavailable services, credentials, production access, or product decisions.
- The issue requires product, design, security, billing, deployment, or permission judgment outside the issue's clear scope.
- A git-related issue needs `/Users/byron/dev/github.com/git/git`, but that reference checkout is unavailable.
- Continuing would require destructive git operations such as `git reset --hard`, `git checkout -- <path>`, deleting branches, or plain force-pushing.

## Completion Criteria

Finish when:

- A PR has been opened for the issue or report.
- For advisory-backed mode, the PR body references the advisory URL and GHSA ID, and sensitive advisory details are handled according to disclosure needs.
- For plain-text report mode, the PR body reproduces the user-provided issue text instead of linking a GitHub issue.
- StGit patch authorship is explicit.
- The branch was pushed with an explicit `HEAD:refs/heads/<current-branch>` refspec, not via upstream tracking.
- Codex review was run only after commits existed, exactly once per commit hash, or any inability to run it is explained.
- Relevant tests and validation were run, or unavailable validation is explained.
- `pr-full-auto` has taken over the PR, or a blocker prevents handoff.
- The final response summarizes the branch, PR URL, commits, validation, and any residual risk.
