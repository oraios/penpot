# GitHub Query Workflow

Repository GitHub metadata: collaborators, PR authors, review triage inputs. Commit/PR content conventions live in workflow memories.

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
- PR creation/update rules: `mem:workflow/creating-prs` first.
- Commit format/DCO signoff: `mem:workflow/creating-commits` first.