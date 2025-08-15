# YOLO Protection Hook Tests

This folder contains all tests for the YOLO protection hook.

## Test Files

### Main Scripts
- `test-yolo-hook.ps1` - Original automated test script
- `test-scenarios.ps1` - Comprehensive tests with different scenarios
- `yolo-protection-test.ps1` - Modified version of the hook for testing

### Debug Scripts
- `debug-yolo.ps1` - Environment variables debugging script
- `test-yolo-manual.ps1` - Manual tests with variable management

## How to Run Tests

### Automated Tests (Bash - recommended)
```bash
# Test dangerous command in YOLO mode
export CLAUDE_YOLO_MODE=true
bash ../.claude/hooks/user-prompt-submit/yolo-protection.sh "rm -rf /test"

# Test safe command in YOLO mode  
export CLAUDE_YOLO_MODE=true
bash ../.claude/hooks/user-prompt-submit/yolo-protection.sh "list files"

# Test with bypass
export CLAUDE_YOLO_MODE=true
export CLAUDE_YOLO_BYPASS=true
bash ../.claude/hooks/user-prompt-submit/yolo-protection.sh "rm -rf /test"
```

### PowerShell Tests
```powershell
# Comprehensive tests
.\test-scenarios.ps1

# Original test
.\test-yolo-hook.ps1

# Debug
.\debug-yolo.ps1
```

## Expected Results

1. **Normal mode**: Protection inactive ✅
2. **YOLO mode + safe command**: Protection active, command allowed ✅
3. **YOLO mode + dangerous command**: Protection active, command blocked ❌
4. **YOLO mode + bypass**: Protection active, command allowed with bypass ⚠️

## Detected Dangerous Patterns

- `rm -rf`, `rm -r`
- `Remove-Item -Recurse`
- `DROP DATABASE`, `TRUNCATE TABLE`
- `docker system prune -a`
- `kubectl delete`
- And more...