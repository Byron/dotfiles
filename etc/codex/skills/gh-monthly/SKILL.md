---
name: gh-monthly
description: Create Gitoxide monthly report outlines from GitHub and local git activity. Use when Byron asks for gh-monthly, a Gitoxide monthly report outline, or preparation for the report usually created around the 22nd. The skill uses `gh` to inspect all GitHub activity for the previous calendar month, reads `/Users/byron/dev/github.com/GitoxideLabs/gitoxide` for git history and `etc/reports` samples, and incorporates must-include topics with summaries of how they were covered in the prior month.
---

# GH Monthly

Create an outline for a Gitoxide monthly report. Produce a full draft only if explicitly asked.

## Defaults

- The Gitoxide checkout is `/Users/byron/dev/github.com/GitoxideLabs/gitoxide`.
- Byron usually creates the report around the 22nd of each month.
- If the target month is not specified, outline the previous calendar month.
- Target report path is `etc/reports/YY-MM.md`.
- Use `etc/reports` as the style and structure reference.

## Inputs

The user may provide must-include topics. Treat them as required sections or subsections unless they clearly belong together.

For each topic, preserve:

- topic name
- why it matters this month
- what was written about it in the prior month
- links, PRs, issues, releases, contributors, or rough notes

Do not ask for topics. If none are provided, infer topics from GitHub and git activity.

## Data Gathering

Run all commands from the local checkout unless another path is explicitly provided:

```sh
cd /Users/byron/dev/github.com/GitoxideLabs/gitoxide
```

Use exact date bounds for the previous calendar month. For a report created in May 2026, inspect `2026-04-01..2026-04-30`.

Use `gh` to inspect repository-wide GitHub activity, not only Byron's activity:

```sh
gh pr list --repo GitoxideLabs/gitoxide --state all --limit 200 --search 'updated:YYYY-MM-DD..YYYY-MM-DD'
gh issue list --repo GitoxideLabs/gitoxide --state all --limit 200 --search 'updated:YYYY-MM-DD..YYYY-MM-DD'
gh release list --repo GitoxideLabs/gitoxide --limit 20
```

For promising PRs and issues, inspect details instead of relying on titles:

```sh
gh pr view NUMBER --repo GitoxideLabs/gitoxide --comments --json title,body,state,author,mergedAt,closedAt,createdAt,updatedAt,additions,deletions,changedFiles,labels,reviews,comments,files,url
gh issue view NUMBER --repo GitoxideLabs/gitoxide --comments --json title,body,state,author,closedAt,createdAt,updatedAt,labels,comments,url
```

Use local git history to cross-check activity, find commits that did not surface clearly in PR listings, and understand touched areas:

```sh
git log --since=YYYY-MM-DD --until=YYYY-MM-DD --date=short --decorate --oneline --all
git log --since=YYYY-MM-DD --until=YYYY-MM-DD --date=short --stat --all
```

Read report samples:

1. The prior month's report, if present.
2. The same month from the previous year, if present.
3. One or two recent reports with similar themes, if needed.

## Selection Rules

Prioritize material that helps explain the month:

- releases, security work, correctness fixes, performance work, compatibility, or user-visible API/CLI changes
- continued long-running themes from prior reports
- contributor work and review-heavy community activity
- PRs/issues whose discussion explains important design decisions
- topics Byron explicitly said must be included

Avoid raw activity dumps. Group related PRs and issues into narrative sections.

Keep uncertainty visible. If GitHub or local history is incomplete, say what could not be verified.

## Outline Workflow

1. Determine target month and target report path.
2. Gather GitHub PR, issue, release, and discussion activity with `gh`.
3. Inspect local git history for the same date range.
4. Read relevant `etc/reports` samples.
5. Identify continuity from the prior report:
   - topics that continue
   - topics that disappeared and may need a short "nothing new" note
   - promises or expectations from last month
   - recurring contributor threads
6. Place must-include topics first unless the monthly narrative clearly needs another lead.
7. Add secondary sections only if they strengthen the report.
8. Produce a writable outline, not a research dump.

## Output Format

Return Markdown:

```markdown
# Outline for etc/reports/YY-MM.md

## Opening angle

- ...

## Must-include topics

### Proposed section title

Prior-month continuity:
Current-month angle:
Outline:
- ...
Facts to confirm:
- ...

## Other likely sections

### Proposed section title

Evidence:
- PR/issue/release/local commit references
Outline:
- ...

## Community

### ...

## Recurring / horizon notes

### Gix in Cargo

- Keep / omit / update because ...

## Suggested ordering

1. ...
2. ...
3. ...

## Missing inputs or verification gaps

- ...
```

## Style Notes

The report voice is personal, technical, candid, and maintainer-oriented. Prefer concrete project consequences over generic progress language. Preserve contributor credit. Avoid marketing copy.
