---
name: pr-from-session
description: Create a GitHub draft pull request from the current branch and session context. Use when the user asks Codex to create a PR from the current session, including creating a Git commit from intended local changes with Codex authorship, and writing a PR body that explains the goals, prompts, constraints, decisions, and validation. Always target and push to `origin`, create draft PRs by default, and disclose that the PR was created on behalf of Byron for Byron to review. After completion, follow-up prompts stay local unless the user explicitly requests new GitHub work.
---

# PR From Session

## Operating Mode

Treat this skill as permission to turn the current session's intended local changes into a Git commit and GitHub pull request. Use the active conversation/session plus local git state to write a PR description that explains what the PR is supposed to do and why.

Work only in the current worktree and push only to `origin`. Tix travel, amendments, fixups, and replay within the work branch follow the shared workflow below. Otherwise, do not amend, rebase, rewrite pre-existing commits, or change branches. Do not create worktrees.

## Workflow Lifetime

GitHub authorization applies to the current run, including any explicitly requested CI or review handoff. Once all requested PR work is complete, state that the PR workflow is finished and later prompts default to local work; preserve that state in any continuation summary. A handoff or temporary blocker is not completion.

After completion, follow the new prompt and the repository's local workflow, including the `tix` skill for Tix-managed history work. Do not read or write GitHub, poll CI or reviews, or fetch, pull, or push GitHub remotes unless the user explicitly requests new GitHub work. Local edits, tests, commits, or a generic "continue" do not reactivate this workflow. A new GitHub request authorizes only the requested scope.

## Resolve Context

1. Confirm tooling and repository state:

   ```bash
   gh auth status
   git status --short
   git branch --show-current
   git remote get-url origin
   gh repo view --json nameWithOwner,defaultBranchRef
   ```

2. Verify `origin` is a GitHub remote and use it as both the push remote and PR target repository.
3. Determine the PR base:
   - Use the user-specified base branch if provided.
   - Otherwise use `origin`'s default branch from `gh repo view`.
4. Inspect committed branch content relative to the base:

   ```bash
   git log --oneline --decorate origin/<base>..HEAD
   git diff --stat origin/<base>...HEAD
   git diff --name-only origin/<base>...HEAD
   ```

5. Inspect uncommitted changes before staging:

   ```bash
   git diff --stat
   git diff --name-only
   git diff --cached --stat
   git diff --cached --name-only
   ```

6. If local changes are mixed or include files unrelated to the current session, stage only the files that clearly belong to the session. If ownership is unclear, stop and ask the user which files belong in the PR.
7. If a PR already exists for the current branch, report the existing PR instead of creating a duplicate unless the user explicitly asks for another PR.
8. In Tix-managed checkouts, read the available `tix` skill and the shared [Tix workflow](../pr-full-auto/references/tix-workflow.md) before further editing or commit operations. Use session intent to select the target and operation; preserve intended local changes according to Tix before any required travel.

## Commit Creation

For Tix, use the selected amendment, fixup, or new commit with its required placement, exact fixup subject, and note. The `git commit` examples and append-only rules below apply only to non-Tix checkouts. Use explicit Codex authorship for new independent commits and fixups; amendments and replay follow Tix's authorship rules.

1. Stage intended session changes explicitly. Prefer file-specific staging. Use `git add -A` only when all local changes clearly belong to the current session.
2. If there are no staged changes and no existing branch commits relative to the base, stop because there is nothing to PR.
3. Apply the selected Tix operation. In a non-Tix checkout, create the commit with explicit Codex authorship:

   ```bash
   git commit --author="$model_name $model_version <codex@openai.com>" -m "<message>"
   ```

4. If exact runtime model fields are unavailable, use:

   ```bash
   git commit --author="Codex GPT-5 <codex@openai.com>" -m "<message>"
   ```

5. Write a descriptive commit message:
   - For a new non-fixup commit, use a concise user-visible change title. Tix fixups retain their exact `fixup!` subject.
   - If an issue number is known and the new non-fixup commit is related to that issue's fix, append `ISSUE_SUFFIX` to the title, where `ISSUE_SUFFIX` is `(#<issue-number>)`; for example, `fix: handle phantom submodule modifications (#2585)`.
   - Body: session goal, relevant prompt/context, implementation summary, and validation run.
6. Include only intentional session-related files in the commit.
7. Do not add Byron as co-author for Codex-created work. Add co-author trailers only when the user explicitly contributed included code or text.
8. In non-Tix checkouts, never amend, squash into, or otherwise rewrite a commit that Codex did not create during the current task.

## Pull Request Creation

1. After recording the changes, or confirming the branch already contains all intended commits, push to `origin`. For Tix, restore the recorded work branch and follow the shared [push procedure](../pr-full-auto/references/tix-workflow.md#push-the-restored-branch) with `origin` and that branch as the target. For non-Tix checkouts:

   ```bash
   git push -u origin "$(git branch --show-current)"
   ```

2. Create a draft PR by default:

   ```bash
   gh pr create --draft --repo <origin-owner/repo> --base <base> --head <branch> --title "<title>" --body-file <body-file>
   ```

3. If the user explicitly asked for a ready-for-review PR, omit `--draft`.
4. Never let `gh pr create` choose a fork or non-`origin` push target. Use explicit `--repo`, `--base`, and `--head`.

## PR Title

Write a concise title that summarizes the user-visible change and any existing committed branch content. Do not disclose Codex or Byron impersonation in the title.

Prefer a direct user-visible change title, for example:

```text
Handle missing fixture archives safely
```

## PR Body

Write the PR body with real Markdown and these sections, in this order. The opening block is `PR_HEADER`:

```markdown
## Tasks

- [ ] refackiew

----
Created by Codex on behalf of Byron. Byron will review before this is ready to merge.

## Summary

<Concise narrative of what the PR is supposed to do.>

## Context

<Session-derived goals, constraints, decisions, assumptions, and relevant background needed to understand the PR.>

## Validation

<Commands/checks run, or "Not run" with the reason.>

## User Prompts

> <Quote the relevant user prompts last.>
```

Guidelines:

- Summarize session context; do not dump the full transcript.
- Include prompts and contextual information that help reviewers understand the purpose of the PR.
- Put quoted user prompts last, each line prefixed with `> `.
- Include only prompts relevant to the PR's scope.
- Never imply Byron personally authored or reviewed the Codex-created work.
- Summarize the change by behavior, files, tests, issue, or commit title.

## Stop Conditions

Stop and report the blocker when:

- `gh` is unavailable or unauthenticated.
- The current directory is not a git repository.
- `origin` is missing, inaccessible, or not a GitHub remote.
- The current branch is the selected base/default branch.
- There are no intended local changes and no commits on the current branch relative to the selected base.
- Local changes are mixed and the intended PR scope cannot be inferred from the session.
- A PR already exists for the current branch and the user did not explicitly ask for another.
- Pushing to `origin` fails.
- Creating a PR would require pushing to a fork or any remote other than `origin`.
- The next step would delete branches, use an unguarded force-push, or rewrite history outside the shared Tix workflow. In non-Tix checkouts, amendments, rebases, and rewriting pre-existing history remain out of scope.

## Completion Criteria

Finish when:

- Intended session changes were captured in a Git commit with explicit Codex authorship, unless the branch already contained all intended commits.
- Branch work has been pushed to `origin`.
- A draft PR has been opened unless the user explicitly requested ready-for-review.
- The PR targets the `origin` repository and selected base branch.
- The PR body follows the documented section order.
- The final response summarizes the branch, PR URL, target base, draft/ready status, validation, and any excluded local changes.
