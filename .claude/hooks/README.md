# Claude Code Hooks

This directory contains custom hooks for Claude Code.

## Structure

```
hooks/
├── README.md                    # This file
├── pre-prompt/                  # Hooks executed before prompt
│   └── example-pre-prompt.sh
├── post-tool/                   # Hooks executed after tools
│   └── example-post-tool.sh
├── user-prompt-submit/          # Hooks on prompt submission
│   └── example-submit.sh
└── examples/                    # Hooks examples
    ├── validation-hook.sh
    ├── logging-hook.ps1
    └── notification-hook.py
```

## Hook Types

### Pre-Prompt Hooks
Executed before user prompt processing.
Useful for validation, environment preparation.

### Post-Tool Hooks  
Executed after tool usage.
Useful for validation, logging, cleanup.

### User-Prompt-Submit Hooks
Executed on prompt submission.
Useful for analysis, content transformation.

## Configuration

Hooks are configured in `settings.json`:

```json
{
  "hooks": {
    "user-prompt-submit": ["hooks/user-prompt-submit/my-hook.sh"],
    "pre-prompt": ["hooks/pre-prompt/validation.py"],
    "post-tool": ["hooks/post-tool/cleanup.ps1"]
  }
}
```