---
name: gb-weekly
description: Create a Discord-ready weekly GitHub activity report for Byron. Use when asked for gb-weekly, a GitButler/Gitoxide weekly report, or last week's GitHub work summary. The report covers the previous Monday through Sunday, highlights only GitButler and Gitoxide PR work in the public team section, incorporates user-provided topics when they match work, and adds a broader personal complete summary of noteworthy GitHub activity.
---

# GB Weekly

## Purpose

Create a plain-language weekly report that Byron can paste into Discord. The report has two sections:

```markdown
**Last Week**
- ...

**Complete Summary**
- ...
```

## Inputs

- The user will usually ask on Monday. Use the previous complete Monday-Sunday week unless the user specifies a different range.
- If the user passes topics, use them as labels or parenthetical context behind matching `Last Week` activities. Example: `- multi-hash support for gix-index crate (SHA-256)`.
- The user may mention local paths to repository clones. Use those paths as optional context for inspecting commits, diffs, code, or local history when it helps explain the work accurately.
- Do not ask for topics. If none are provided, write the report without them.

## Date Range

1. Determine today's date from the environment.
2. Compute the previous Monday through Sunday in the user's current timezone.
3. Use exact dates internally when querying GitHub. Mention dates only if helpful for disambiguation; the final report should normally stay clean and copy-ready.

## Data Gathering

Use the GitHub app tools when available, with `gh` CLI as a fallback for activity not exposed by the connector.

1. Get the authenticated GitHub login.
2. Gather GitHub activity during the week:
   - PRs authored, reviewed, commented on, merged, closed, or otherwise involved.
   - Issues opened, triaged, labeled, commented on, closed, or otherwise involved.
   - Review comments and issue comments that explain meaningful work.
3. Prefer precise repository queries over broad feeds when possible:
   - For `Last Week`, focus on repositories whose owner/name or repo name matches GitButler or Gitoxide, commonly including `gitbutlerapp/gitbutler` and `GitoxideLabs/gitoxide`.
   - For `Complete Summary`, do not filter by project.
4. Exclude `Byron/small` from all summaries and searches where practical. It is a testing repository and should not appear in `Last Week` or `Complete Summary`.
5. Inspect PR titles, descriptions, diffs, comments, reviews, and issue discussion as needed to understand the work. Do not rely on titles alone when they are vague.
6. If the user provides local repository clone paths, use ordinary local Git and code-search tools inside those clones to clarify commit intent, touched code, or terminology. Treat local clones as supporting evidence; GitHub activity still determines whether an item belongs in the weekly report.
7. Keep only activity that happened inside the computed week. If an item was created earlier but Byron did meaningful work on it during the week, include the work that happened during the week.

Useful query patterns:

```text
repo:OWNER/REPO is:pr involves:LOGIN updated:YYYY-MM-DD..YYYY-MM-DD
repo:OWNER/REPO is:issue involves:LOGIN updated:YYYY-MM-DD..YYYY-MM-DD
is:pr involves:LOGIN updated:YYYY-MM-DD..YYYY-MM-DD
is:issue involves:LOGIN updated:YYYY-MM-DD..YYYY-MM-DD
```

## Last Week Section

This section is for other engineers on the team.

Rules:

- Start with exactly `**Last Week**`.
- Include only GitButler and Gitoxide work.
- Include PRs only. Exclude issues unless they directly explain a PR that is listed.
- Do not report counts, stats, or "I made N PRs".
- Group related PRs into work themes when that reads better than one bullet per PR.
- Treat new feature PRs as strong `Last Week` candidates even when the feature is small, contributed by someone else, or Byron's role was review/coordination. Include them when Byron was meaningfully involved and the result matters to engineers or users.
- Write in plain language about what changed and why it matters: new features, fixes, design decisions, migration work, reliability improvements, developer experience, review work, or unblockers.
- Mention repository names only when needed for clarity.
- Attach user-provided topics to matching bullets in parentheses. Use exact topic wording when it fits.
- Avoid empty status language like "worked on", "continued", or "made progress" unless followed by the concrete outcome.

Tone and shape:

```markdown
**Last Week**
- Added multi-hash support in the index path so SHA-1 and SHA-256 repositories can share the same code path. (SHA-256)
- Fixed checkout edge cases around sparse paths and conflict cleanup, which should make repository state transitions less surprising.
- Reviewed the virtual branches sync changes and helped narrow the API boundary before merge.
```

## Complete Summary Section

This section is for Byron's own memory.

Rules:

- Start with exactly `**Complete Summary**`.
- Do not filter to GitButler or Gitoxide.
- Exclude `Byron/small`; it is only for testing.
- Include noteworthy PRs, issues, triage, review discussions, comments, decisions, debugging, releases, CI fixes, and coordination.
- Be more detailed than `Last Week`, but still summarize. Do not dump raw event logs.
- Organize by project or theme if there is enough activity; otherwise use a simple bullet list.
- Include links only when they add value. Discord should remain readable without opening every link.
- Preserve uncertainty explicitly when the GitHub data does not show enough context.

## Output Contract

- Return only the report text unless the user asks for notes or methodology.
- Use Markdown that is safe to paste into Discord.
- Use first person sparingly. Prefer team-facing, outcome-focused phrasing.
- Keep `Last Week` concise and high-signal.
- Make `Complete Summary` useful for recall, not performance reporting.
- Do not fabricate activity. If GitHub data is incomplete or unavailable, say what could not be verified.
