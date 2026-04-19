# AGENTS.md — Dotfiles Repository

## What This Repo Is
Personal dotfiles and setup scripts. No build system, no test suite.
Symlinks are managed by `setup_dotfiles.sh` (home dir) and `dotconfig/setup.sh` (~/.config/).

## "Build" / Lint / Run Commands
```bash
bash setup_dotfiles.sh          # symlink dotfiles into $HOME
bash dotconfig/setup.sh         # symlink dotconfig/* into ~/.config/
bash bootstrap.sh               # full bootstrap on a new machine
bash -n <file>.sh               # syntax-check a shell script (no test runner)
perl -wc bin/linkbin.pl         # syntax-check Perl script
python3 -m py_compile bin/rsync-recent.py  # syntax-check Python
shellcheck <file>.sh            # lint shell scripts (preferred)
```
No single-test command exists — there are no automated tests.

## Code Style

### Shell (Bash)
- Shebang: `#!/bin/bash`; `set -e` in setup scripts
- Functions: `lower_snake_case`; local vars: `lower_snake_case`
- Indent: 4 spaces (no tabs)
- Quote all variable expansions: `"$var"`, `"${var}"`
- Prefer `[[ … ]]` over `[ … ]` for conditionals

### Python
- Python 3; `#!/usr/bin/env python3`
- `argparse` for CLI, `logging` for output (no bare `print` in main logic)
- `lower_snake_case` for functions/variables; constants `UPPER_SNAKE_CASE`

### Perl
- Always `use strict; use warnings;` (or `-w` flag)
- `lower_snake_case` subs; `$lower_camel` local vars
- do not use for new scripts

### General
- Host-specific files: `<hostname>_dot<name>` convention
- User-specific files: `<username>_dot<name>` convention
- ECA skill files live in `dotconfig/eca/skills/<name>/SKILL.md`
- Commit messages: imperative mood, plain English, no emoji
