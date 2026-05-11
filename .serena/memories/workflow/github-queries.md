# GitHub Query Workflow

Use when an agent needs repository-level GitHub metadata such as collaborators, PR authors, or review triage inputs. For commit and PR content conventions, read `workflow/creating-commits` and `workflow/creating-prs`.

## Collaborators and PR authors

To list repository collaborators:

```bash
gh api repos/:owner/:repo/collaborators --paginate --jq '.[].login'
```

To list open PRs from members/non-members, build the collaborator list with that command and filter:

```bash
gh pr list --state open --limit 200 --json author,title,number
```

Compare each PR author login against the collaborator list. Prefer JSON/JQ processing over text parsing so bots, renamed users, and missing fields are handled explicitly.

## Safety notes

- Do not create commits, branches, labels, comments, or PRs unless the user explicitly asks.
- For PR creation/update rules, read `workflow/creating-prs` first.
- For commit format and DCO signoff, read `workflow/creating-commits` first.