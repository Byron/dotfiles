---
name: pr-full-auto
description: Monitor and fix a GitHub pull request in full-auto mode until CI passes, then inspect and address non-nit review feedback. Use when the user asks Codex to watch a PR, fix failing checks, push StGit commits, respond to reviews on Byron's behalf, or keep iterating until the PR is green.
---

# PR Full Auto

## Operating Mode

Treat this skill as permission to operate the PR end to end: inspect CI, make fixes, create StGit commits, push updates, monitor checks, inspect reviews, address non-nit feedback, and repeat until the PR is green or a real blocker is reached.

Use existing GitHub skills for specialized mechanics:

- Use `github:gh-fix-ci` for GitHub Actions check and log inspection.
- Use `github:gh-address-comments` for unresolved review threads and inline review context.
- Use GitHub app tools for PR metadata, diffs, comments, reviews, and GitHub writes when available.
- Use `gh` for Actions logs, review-thread GraphQL details, and operations not exposed by the GitHub app.

## Resolve Context

1. Expect the current branch and worktree where the skill was invoked to already match the mentioned PR.
2. Resolve the repository and PR number from the user's URL/number or the current branch, then verify that the current branch/worktree corresponds to that PR.
3. Do not change branches, create branches, create worktrees, or move to a different checkout. Work only in the current worktree.
4. Run `gh auth status` before relying on `gh`.
5. Inspect PR metadata: head branch, base branch, author, mergeability if available, current checks, review status, unresolved threads, and recent comments.
6. Inspect local state with `git status --short`.
7. Treat uncommitted local changes as user-owned unless they were created in the current task. Do not revert or overwrite them.

## PR Description Format

If this skill creates or rewrites a PR description, prefix it with `PR_HEADER`:

```markdown
## Tasks

- [ ] refackiew

----
Created by Codex on behalf of Byron. Byron will review before this is ready to merge.
```

Then append the PR-specific content.

Do not mention StGit patch names in PR descriptions. They are local-only bookkeeping. Summarize changes by behavior, files, tests, issue, commit title, or short SHA instead.

## CI Loop

Repeat until all required and relevant CI checks pass, or until a blocker is reached:

1. Inspect failing checks before editing.
2. Read the relevant logs and identify the smallest likely root cause.
3. Reproduce locally when feasible with targeted commands.
4. Implement the smallest coherent fix.
5. Validate locally with the most relevant test, lint, build, or formatter check.
6. Create a StGit commit for the fix, or update a StGit commit only if Codex created it during the current task.
7. Push the PR branch.
8. Monitor checks again.

Treat non-GitHub Actions checks as report-only unless logs are available through the check URL or the user has provided the provider-specific access path.

If a check is flaky, rerun it only when logs strongly support flakiness. Prefer fixing deterministic failures.

## StGit Commit Rules

Use StGit for all PR fixes.

- For a new independent fix, use `stg new`.
- For follow-up edits to a fix commit that Codex created during the current task, use `stg refresh`.
- Never refresh, amend, squash into, or otherwise rewrite a commit or StGit patch that Codex did not create during the current task. If a fix logically belongs near an existing user-authored or pre-existing patch, create a new follow-up StGit patch instead.
- Use other `stg` commands as appropriate for stack management, but do not discard user work.
- Make patch names short, lowercase, and descriptive, such as `fix-ci-clippy`, `fix-review-docs`, or `address-null-case`.
- Use concise commit messages that explain the user-visible reason for the fix.
- Do not mention StGit patch names in commit messages; they are local bookkeeping only.
- If an issue number is known and the first commit Codex creates during this skill is related to that issue's fix, append `ISSUE_SUFFIX` to the title, where `ISSUE_SUFFIX` is `(#<issue-number>)`; for example, `fix: handle phantom submodule modifications (#2585)`.
- For commits created to fix CI, include a detailed commit body that explains how the failure was originally surfacing, names the failing check or command when known, summarizes the relevant error, and explains why the change fixes that failure.
- When addressing review comments, make the commit title say it addresses review feedback, such as `Address review comment about <topic>`.
- In review-fix commit bodies, repeat the relevant review comment and explain how the commit addresses it.
- Include only intentional task-related files in each patch.
- Do not add Byron as a co-author on commits created by Codex itself.
- Add `Co-authored-by` trailers only when the user explicitly contributed specific code or text that is included in that commit.

Set authorship explicitly on every new or refreshed StGit patch:

```bash
stg new --author="$model_name $model_version <codex@openai.com>" --message "<message>" <patch-name>
stg refresh --author="$model_name $model_version <codex@openai.com>"
```

If exact runtime identity fields are unavailable, use:

```bash
--author="Codex GPT-5 <codex@openai.com>"
```

When `stg refresh` rewrites commits already pushed to the PR branch, push with the safest required mode, normally:

```bash
git push --force-with-lease
```

Do not use plain `--force`.

## Review Handling

After CI passes, inspect unresolved review threads and requested changes.

Address actionable non-nit feedback automatically. Skip low-value nits at discretion when they are subjective, stylistic, optional, preference-only, or not tied to a bug, correctness issue, maintainability issue, project convention, or explicit reviewer request.

For review feedback:

- Prefer thread-aware review data over flat comment lists.
- Group related comments into one fix when sensible.
- Feel free to create one StGit commit per review comment when that improves traceability.
- Implement code/docs/test changes for actionable comments.
- Leave ambiguous product/design choices open and ask the user only if the PR cannot proceed without the decision.
- Do not resolve a thread until the requested state is achieved.
- Mention the fixing commit in the GitHub reply whenever a commit has been created for the review comment.
- After review fixes, push and return to the CI loop.

When replying to review comments or PR comments, make the authorship clear:

```text
Codex on behalf of Byron: ...
```

If the runtime exposes a concrete agent name, use it instead:

```text
$agent_name on behalf of Byron: ...
```

Keep replies concise: what changed, why it addresses the comment, and what validation ran.
For review-fix replies, include the commit title or short SHA if available.

## Stop Conditions

Stop and ask or report a blocker when:

- GitHub authentication or repository permissions are missing.
- CI logs are unavailable and the failure cannot be inferred safely.
- A required external CI provider needs credentials or access not already available.
- Fixing the issue requires product/design judgment with multiple plausible outcomes.
- The work would touch secrets, production systems, deployments, billing, permissions, or security posture beyond the PR scope.
- The next step would merge, close, mark ready, convert draft state, request changes, enable auto-merge, bypass checks, or override branch protection.
- Local changes conflict with user-owned work.
- The current branch/worktree does not match the mentioned PR.
- Continuing would require destructive git operations such as `git reset --hard`, `git checkout -- <path>`, deleting branches, or plain force-pushing.

When stopped, state the blocker, what was already done, and the smallest user decision or credential needed to continue.

## Completion Criteria

Finish when:

- PR CI is passing, or remaining failures are clearly external/unactionable and summarized.
- Non-nit actionable review feedback has been addressed or explicitly blocked.
- StGit patches are pushed to the PR branch.
- The final response summarizes commits or fixes created by title or SHA, checks observed, review threads addressed/skipped, and any residual risk.

Do not merge the PR unless the user explicitly asks for merge/land/ship.
