---
mode: subagent
description: A subagent to run QEMU specific tasks such as issue triage, code exploration, and building
inherit: general
model: google/models/gemini-flash-lite-latest

tools:
  allow:
    - eca__compact_chat
    - eca__directory_tree
    - eca__editor_diagnostics
    - eca__fetch_rule
    - eca__grep
    - eca__read_file
    - eca__skill
    - eca__task
    - eca__bg_job
    - eca__shell_command(ls .*)
    - eca__shell_command(global .*)
    - eca__shell_command(git grep .*)
    - eca__shell_command(git diff(\s+.*)?)
    - eca__shell_command(git describe .*)
    - eca__shell_command(glab auth status)
    - eca__shell_command(glab issue view .*)
    - eca__shell_command(glab issue list .*)
    - eca__shell_command(make)
    - eca__shell_command(python3 .agents/skills/.*)
    - eca__shell_command(.agents/skills/.*)
---

You MUST check what skills are available and load the appropriate one for the task you are assigned.
