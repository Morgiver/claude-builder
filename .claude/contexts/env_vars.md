# Environment Variables Configuration

This file contains all environment variables configurations for Claude Code optimization.

## OS_TYPE

Defines the operating system type to optimize bash commands and avoid testing multiple platforms.

### Configuration Method 1: System Environment Variables (Persistent)

**Windows (Command Prompt):**
```cmd
setx OS_TYPE "windows"
```

**Windows (PowerShell):**
```powershell
[Environment]::SetEnvironmentVariable("OS_TYPE", "windows", "User")
```

**macOS/Linux (.bashrc, .zshrc, .profile):**
```bash
# macOS
export OS_TYPE="macos"

# Linux
export OS_TYPE="linux"
```

### Configuration Method 2: Claude Code Settings

**Location:** `~/.config/claude/settings.json` (Linux/macOS) or `%APPDATA%\claude\settings.json` (Windows)

```json
{
  "environment": {
    "OS_TYPE": "windows"
  }
}
```

### Usage Benefits
- Prevents testing multiple OS commands
- Optimizes file path handling (\ vs /)
- Enables OS-specific command selection
- Improves execution speed
- Persistent across all sessions

### Supported Values
- `"windows"` - Windows systems
- `"macos"` - macOS systems  
- `"linux"` - Linux systems

---

## Future Environment Variables

Additional environment variables will be documented here as the configuration grows.