---
name: command-permissions
description: >-
  Guidelines and protocol for handling terminal command execution and permissions. Use always when considering running terminal commands or needing user approvals.
---

# Command Execution & Permission Protocol

## Core Rule
**Never trigger frequent, repeated permission prompts by running terminal commands one by one.**

The user should not be prompted to approve terminal commands every few seconds.

## Guidelines
1. **Prefer Non-Terminal Tools for Read/Write**:
   - Always prefer `view_file`, `replace_file_content`, and `write_to_file` over shell commands like `cat`, `grep`, `dir`, `Select-String`, or `git grep`.
   - File inspection and code editing tools do not interrupt the user with terminal execution prompts.

2. **Pre-Plan and Batch Terminal Commands**:
   - If terminal commands are genuinely needed (e.g., `flutter build`, `flutter test`, `git` actions, package installations):
   - First analyze and plan all commands that will be required.
   - List and explain the commands to the user in chat before or alongside execution, so the user knows what is being run and why.
   - Combine operations or execute them in a single cohesive step where possible, rather than issuing multiple scattered commands.
