---
name: pr-from-session
description: Create a GitHub draft pull request from the current branch and session context. Use when the user asks Codex to create a PR from the current session, including creating a StGit patch from intended local changes with Codex authorship, and writing a PR body that explains the goals, prompts, constraints, decisions, and validation. Always target and push to `origin`, create draft PRs by default, and disclose that the PR was created on behalf of Byron for Byron to review.
---

# PR From Session

## Operating Mode

Treat this skill as permission to turn the current session's intended local changes into a StGit patch and GitHub pull request. Use the active conversation/session plus local git state to write a PR description that explains what the PR is supposed to do and why.

Do not amend, rebase, rewrite pre-existing commits, change branches, create worktrees, or push to any remote other than `origin`.

## Resolve Context

1. Confirm tooling and repository state:

   ```bash
   gh auth status
   git status --short
   stg series
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

## StGit Patch Creation

Use StGit for the commit created by this skill.

1. Stage intended session changes explicitly. Prefer file-specific staging. Use `git add -A` only when all local changes clearly belong to the current session.
2. If there are no staged changes and no existing branch commits relative to the base, stop because there is nothing to PR.
3. Create a short lowercase hyphenated patch name from the PR title or session goal, without `/`.
4. Create the patch with explicit Codex authorship:

   ```bash
   stg new --refresh --author="$model_name $model_version <codex@openai.com>" --message "<message>" <patch-name>
   ```

5. If exact runtime model fields are unavailable, use:

   ```bash
   --author="Codex GPT-5 <codex@openai.com>"
   ```

6. Write a descriptive commit message:
   - Title: concise user-visible change.
   - If an issue number is known and this commit is related to that issue's fix, append `ISSUE_SUFFIX` to the title, where `ISSUE_SUFFIX` is `(#<issue-number>)`; for example, `fix: handle phantom submodule modifications (#2585)`.
   - Body: session goal, relevant prompt/context, implementation summary, and validation run.
   - Do not mention the StGit patch name; it is local bookkeeping and not useful commit history.
7. Include only intentional session-related files in the patch.
8. Do not add Byron as co-author for Codex-created work. Add co-author trailers only when the user explicitly contributed included code or text.
9. Never refresh, amend, squash into, or otherwise rewrite a commit or StGit patch that Codex did not create during the current task.

## Pull Request Creation

1. After the StGit patch is created, or after confirming the branch already contains all intended commits, push the current branch to `origin`:

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
- Do not mention StGit patch names in the PR title or body; they are local-only bookkeeping. Summarize the change by behavior, files, tests, issue, or commit title instead.

## Stop Conditions

Stop and report the blocker when:

- `gh` is unavailable or unauthenticated.
- The current directory is not a git repository.
- The current worktree is not usable as an StGit stack.
- `origin` is missing, inaccessible, or not a GitHub remote.
- The current branch is the selected base/default branch.
- There are no intended local changes and no commits on the current branch relative to the selected base.
- Local changes are mixed and the intended PR scope cannot be inferred from the session.
- A PR already exists for the current branch and the user did not explicitly ask for another.
- Pushing to `origin` fails.
- Creating a PR would require pushing to a fork or any remote other than `origin`.
- The next step would amend, rebase, rewrite pre-existing history, delete branches, or force-push.

## Completion Criteria

Finish when:

- Intended session changes were captured in a StGit patch with explicit Codex authorship, unless the branch already contained all intended commits.
- Branch work has been pushed to `origin`.
- A draft PR has been opened unless the user explicitly requested ready-for-review.
- The PR targets the `origin` repository and selected base branch.
- The PR body follows the documented section order.
- The final response summarizes the branch, PR URL, target base, draft/ready status, validation, and any excluded local changes.
