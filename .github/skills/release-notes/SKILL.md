---
name: release-notes
description: "Draft release notes from commits and merged pull requests since the last tag. Use when preparing a release, changelog, or deployment summary."
---

# Release notes

Write notes from repository history. Do not invent changes.

## Collect

```bash
git describe --tags --abbrev=0
git log <tag>..HEAD --pretty=format:"%h %s"
gh pr list --state merged --limit 50 --search "merged:>=YYYY-MM-DD"
```

If there is no tag, say so and use the last 30 days, or the range the user named. Put that range at the top.

Prefer merged pull request titles over raw commit subjects when both exist. Skip empty merge commits.

## Group

Use only sections that have items:

- Breaking changes, with the migration step
- Features
- Fixes
- Security and operations

Drop typo-only and chore commits unless behavior changed. Keep a dependency bump only when it fixes a vulnerability or is user-visible.

## Rules

- Link pull requests or SHAs you actually found. Do not guess numbers.
- Do not include secrets, tokens, or customer names that are not already in the repo's public changelog style.
- Match an existing `CHANGELOG` format when the repo has one.
- Plain language. No marketing filler.

## Output

Markdown ready to paste into a GitHub Release. Start with the version or range. End with anything you could not classify.
