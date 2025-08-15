# Claude Code Commands

This directory contains custom commands for Claude Code.

## Structure

```
commands/
├── README.md                    # This file
├── development/                 # Development commands
│   ├── quick-test.sh
│   ├── deploy-local.ps1
│   └── format-code.py
├── utilities/                   # General utilities
│   ├── backup-project.sh
│   ├── clean-workspace.ps1
│   └── project-stats.py
├── git/                        # Custom Git commands
│   ├── smart-commit.sh
│   ├── branch-cleanup.sh
│   └── sync-fork.sh
└── examples/                   # Command examples
    ├── hello-world.sh
    ├── system-info.ps1
    └── file-processor.py
```

## Command Types

### Development
Commands related to development and project building.

### Utilities
General utilities for workspace and project management.

### Git
Custom Git commands for workflow automation.

### Examples
Basic examples for creating your own commands.

## Configuration

Commands are available via Claude Code using:
- `/run command-name` - Execute a command
- `/commands` - List available commands

## Command Format

Commands can be:
- Scripts Shell (.sh) for Linux/macOS
- Scripts PowerShell (.ps1) for Windows  
- Python scripts (.py) cross-platform
- Compiled executables

### Metadata

Add metadata at the beginning of the file:

```bash
#!/bin/bash
# CLAUDE_COMMAND_NAME: test-project
# CLAUDE_COMMAND_DESC: Run project tests
# CLAUDE_COMMAND_ARGS: [test-type] [coverage]
```