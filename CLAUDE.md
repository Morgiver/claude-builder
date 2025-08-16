# Claude Code Configuration Development Project

This project develops and maintains the global Claude Code configuration that will be deployed to your system's Claude Code configuration directory.

## Project Structure

```
e:\dev\claude\                    # Development workspace
├── CLAUDE.md                     # This file - project documentation
├── CLAUDE-build.md               # Configuration documentation (build mode)
├── .claude/                      # Configuration being developed
│   ├── settings.json            # Global settings (to deploy)
│   ├── agents/                  # Custom agents (to deploy)
│   │   ├── meta-agent.md
│   │   └── global-orchestrator.md
│   ├── contexts/                # Extended context (to deploy)
│   ├── hooks/                   # Custom hooks (to deploy)
│   │   ├── pre-prompt/
│   │   ├── post-tool/
│   │   ├── user-prompt-submit/
│   │   └── examples/
│   └── commands/                # Custom commands (to deploy)
│       ├── development/
│       ├── utilities/
│       ├── git/
│       └── examples/
└── scripts/                     # Cross-platform deployment utilities
    ├── deploy.ps1               # Windows PowerShell deployment
    ├── backup.ps1               # Windows PowerShell backup
    ├── restore.ps1              # Windows PowerShell restore
    ├── deploy.sh                # Linux/macOS bash deployment
    ├── backup.sh                # Linux/macOS bash backup
    └── restore.sh               # Linux/macOS bash restore
```

## Deployment Target

**Auto-detected paths** (in order of preference):

**Windows**:
1. `%USERPROFILE%\.claude\` (default)
2. `%APPDATA%\claude\` (fallback)

**Linux**:
1. `$HOME/.config/claude/` (default)
2. `$HOME/.claude/` (fallback)

**macOS**:
1. `$HOME/.config/claude/` (default)
2. `$HOME/.claude/` (fallback)
3. `$HOME/Library/Application Support/claude/` (macOS-specific)

**Custom Path Override**:
Set `CLAUDE_CONFIG_PATH` environment variable to use a custom location:
```bash
export CLAUDE_CONFIG_PATH=/path/to/your/custom/claude/config
```

The scripts automatically detect your platform and find the best available path.

## Development Workflow

### 1. Development Phase
- Work in this directory (your development workspace)
- Modify `.claude/settings.json` and agents
- Test configurations locally
- Document changes in `CLAUDE-build.md`

### 2. Testing Phase
- Validate configuration structure
- Test agents functionality
- Check settings.json syntax
- Verify integrations

### 3. Deployment Phase
- Run `scripts/deploy.ps1` to copy to global config
- Backup existing configuration first
- Verify deployment success

## Configuration Components

### Core Files (Deploy to Global)
- `.claude/settings.json` → Auto-detected Claude Code config directory
- `.claude/agents/*.md` → Auto-detected Claude Code agents directory
- `.claude/contexts/` → Auto-detected Claude Code contexts directory
- `.claude/hooks/` → Auto-detected Claude Code hooks directory
- `.claude/commands/` → Auto-detected Claude Code commands directory

**Note**: Deployment paths are automatically detected based on your platform and user.

### Development Only (Keep Local)
- `CLAUDE-build.md` - Build-time configuration documentation
- `scripts/` - Deployment utilities

## Commands

### Test Configuration
```bash
# Validate settings.json syntax (cross-platform)
python3 -m json.tool .claude/settings.json
# OR
jq empty .claude/settings.json

# List agents
ls .claude/agents/
```

### Deploy to Global

**Windows (PowerShell)**:
```powershell
# Deploy configuration (creates backup first)
.\scripts\deploy.ps1

# Manual backup
.\scripts\backup.ps1

# Restore from backup
.\scripts\restore.ps1
```

**Linux/macOS (Bash)**:
```bash
# Deploy configuration (creates backup first)
./scripts/deploy.sh

# Manual backup
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh --list-backups
./scripts/restore.sh --backup-path /path/to/backup
```

## Hooks & Commands

### Hooks
Hooks allow executing scripts at specific moments:

```bash
# View available hooks
ls .claude/hooks/

# Test a hook
.claude/hooks/examples/validation-hook.sh "test prompt"
```

**Hook types**:
- `pre-prompt/` - Before prompt processing
- `post-tool/` - After tool usage  
- `user-prompt-submit/` - On prompt submission

### Commands
Custom commands extend Claude Code:

```bash
# List commands
ls .claude/commands/

# Execute example command
.claude/commands/examples/hello-world.sh "Your Name"
.claude/commands/development/quick-test.sh
```

**Command categories**:
- `development/` - Development and testing
- `utilities/` - General utilities
- `git/` - Git workflows
- `examples/` - Examples and templates

## Development Guidelines

1. **Always test locally first** before deployment
2. **Document changes** in CLAUDE-build.md during development
3. **Version control** this development workspace
4. **Backup global config** before each deployment
5. **Test agents** work correctly after deployment

## Module Update Rules

When adding or modifying modules, **ALWAYS** update the following files in this order:

### When Adding a New Module

1. **Create Module Files**:
   - `.claude/contexts/modules/<module-name>/README.md` - Module documentation
   - `.claude/contexts/modules/<module-name>/` - Module directory structure

2. **Update Configuration**:
   - `.claude/settings.json` - Add module in `modules` section with configuration

3. **Update Documentation** (ALL required):
   - `.claude/contexts/modules/README.md` - Add module to the index table
   - `CLAUDE-build.md` - Add module to the "Available modules" list
   - `CLAUDE.md` (if needed) - Update project structure or guidelines

### When Adding a Methodology/Component to a Module

1. **Create Component**:
   - `.claude/contexts/modules/<module-name>/<component-type>/<component>.md`

2. **Update Module Documentation**:
   - `.claude/contexts/modules/<module-name>/README.md` - Update index/table

3. **Update Global Documentation**:
   - `CLAUDE-build.md` - Update module description if significant

### When Adding a Custom Agent

1. **Create Agent**:
   - `.claude/agents/<agent-name>.md` - Agent configuration

2. **Update Configuration**:
   - `.claude/settings.json` - Add agent in `custom_agents` section

3. **Update Documentation**:
   - `CLAUDE-build.md` - Add agent to "Available agents" list
   - `.claude/contexts/agents.md` (if exists) - Update agent registry

### When Modifying Existing Components

1. **Make the Change** in the component file
2. **Update Version/Status** if significant change
3. **Update Documentation** if behavior changes

### Validation Checklist

Before completing any module/agent addition:
- [ ] Component files created
- [ ] settings.json updated
- [ ] Module README.md updated
- [ ] Global modules/README.md updated
- [ ] CLAUDE-build.md updated
- [ ] Integration points documented

**Note**: Use TodoWrite to track these updates and ensure none are missed.

---

*This workspace separates development from the live Claude Code configuration, allowing safe iteration and testing.*