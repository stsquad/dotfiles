---
name: git-query
description: Summarize and query git commit history efficiently. Use this skill when the user wants to understand recent changes, summarize a range of commits (e.g., since origin/master), or get specific details (message, tags, date, diffstat, or patches) for individual commits. This skill provides optimized git commands and patterns for history analysis.
---

# Git Query

A general-purpose skill for querying and summarizing git project history. This skill helps you navigate commit logs and extract specific information efficiently without over-fetching data.

## Workflows

### 1. Summarizing a Range of Commits
When you need to see what has changed between two points (e.g., from `origin/master` to the current state).

- **Quick Overview**: `git log origin/master..HEAD --oneline`
- **Grouped by Author**: `git shortlog origin/master..HEAD`
- **Visual History**: `git log origin/master..HEAD --graph --oneline --decorate`

### 2. Extracting Specific Commit Details
To get details for a list of commit hashes efficiently.

- **Metadata Only (No Diff)**:
  - Commit Message: `git show -s --format=%B <commit>`
  - Tags/Refs: `git show -s --format=%D <commit>`
  - Date: `git show -s --format=%ad --date=short <commit>`
  - Custom Block: `git show -s --format="Hash: %h%nDate: %ad%nTags: %D%nSubject: %s"`

- **Impact Analysis**:
  - File List and Changes: `git show --stat --oneline <commit>`

- **Full Diff (Patch)**:
  - Actual Changes: `git show -p <commit>`
  - Merge Commit Changes: `git show <commit>^!`

## Examples

**Example 1: Summarize work since master**
User: "What have I done since master?"
Action: 
1. Run `git log origin/master..HEAD --oneline` to get a list.
2. For important commits, run `git show --stat <commit>` to see impact.
3. Summarize the findings for the user.

**Example 2: Detailed query for a specific commit**
User: "Tell me more about commit a1b2c3d."
Action:
1. Run `git show -s --format="Author: %an%nDate: %ad%nTags: %D%n%n%B" --date=short a1b2c3d` to get metadata and message.
2. Run `git show --stat a1b2c3d` to see which files were affected.
3. Present a clear summary.

## Best Practices
- **Use `-s`**: Always use the `-s` flag with `git show` if you don't need the patch content. This is much faster for large commits.
- **Custom Formats**: Use `--format` to specify exactly what you need. Avoid parsing default `git show` output if possible.
- **Range Queries**: Use `..<branch>` to limit searches to relevant history.
