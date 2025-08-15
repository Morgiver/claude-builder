# Claude Code Configuration Tests

This folder contains all tests for the Claude Code configuration.

## Structure

```
tests/
├── README.md              # This file
└── yolo-protection/       # YOLO Protection hook tests
    ├── README.md          # YOLO tests documentation
    ├── test-yolo-hook.ps1 # Original automated test
    ├── test-scenarios.ps1 # Comprehensive tests
    ├── debug-yolo.ps1     # Debugging
    └── ...                # Other test files
```

## Test Types

### Hooks
- **yolo-protection/** - Tests for the protection hook against dangerous commands in YOLO mode

### Agents
_(Coming soon)_

### Commands
_(Coming soon)_

## Running Tests

### Prerequisites
- PowerShell (Windows)
- Bash (Linux/macOS/Windows)
- Environment variables configured according to tests

### Quick Commands
```bash
# Test all hooks
cd yolo-protection && bash test-all.sh

# PowerShell tests
cd yolo-protection && powershell -ExecutionPolicy Bypass -File test-scenarios.ps1
```

## Contributing

When adding new Claude Code components:
1. Create a dedicated subfolder in `tests/`
2. Add an explanatory README.md
3. Include automated tests
4. Document expected results