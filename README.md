# Claude Builder 🏗️

**Complete configuration builder for Claude Code** - Develop, test, and deploy custom settings, agents, hooks, and commands safely across any platform.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green)](https://docs.anthropic.com/en/docs/claude-code)

> **Why Claude Builder?** Transform Claude Code configuration from manual file editing to professional development workflow with version control, automated testing, safe deployment, and team collaboration.

## ✨ What Makes It Special

🏗️ **Complete Builder System** - Not just configuration files, but a full development environment  
🛡️ **Production-Safe** - Automatic backups, validation, and rollback capabilities  
🌐 **Zero-Config Cross-Platform** - Works instantly on Windows, Linux, and macOS  
🤖 **Advanced Agent Management** - Meta-agent system for dynamic agent creation  
🔧 **Hooks & Commands** - Deploy custom automation and workflows  
📦 **Team-Ready** - Share configurations effortlessly across teams  

## 🚀 Quick Start

### One-Minute Setup
```bash
# Clone and enter
git clone https://github.com/Morgiver/claude-builder.git
cd claude-builder

# Customize your configuration in .claude/
# Then deploy with one command:

# Windows
.\scripts\deploy.ps1

# Linux/macOS  
./scripts/deploy.sh
```

**That's it!** Your Claude Code is now powered by your custom configuration.

### What Happens During Deployment
✅ **Auto-detects** your Claude Code configuration directory  
✅ **Creates backup** of existing configuration  
✅ **Validates** settings.json syntax  
✅ **Deploys** settings, agents, hooks, and commands  
✅ **Provides rollback** instructions if needed  

## 📁 What You Get

```
claude-builder/
├── 📋 README.md              # This guide
├── 📖 CLAUDE.md             # Detailed documentation
├── 📊 CLAUDE-build.md       # Configuration overview
├── ⚙️  .claude/              # Your development workspace
│   ├── settings.json        # Global settings & modules
│   ├── agents/              # Custom AI agents
│   │   ├── meta-agent.md    # Dynamic agent generator
│   │   └── global-orchestrator.md # Workflow coordinator
│   ├── hooks/               # Event-driven automation
│   │   ├── examples/        # Hook templates
│   │   └── README.md        # Hook documentation
│   ├── commands/            # Custom CLI commands
│   │   ├── examples/        # Command templates
│   │   └── README.md        # Command documentation
│   └── contexts/            # Documentation & configs
└── 🛠️  scripts/              # Deployment automation
    ├── config.json          # Platform path configuration
    ├── deploy.ps1/.sh       # Deploy with backup
    ├── backup.ps1/.sh       # Manual backup creation
    └── restore.ps1/.sh      # Restore from backup
```

## 🌍 Universal Platform Support

**Claude Builder automatically detects your system** and deploys to the correct location:

| Platform | Primary Path | Fallback Options |
|----------|-------------|------------------|
| 🪟 **Windows** | `%USERPROFILE%\.claude` | `%APPDATA%\claude` |
| 🐧 **Linux** | `$HOME/.config/claude` | `$HOME/.claude` |
| 🍎 **macOS** | `$HOME/.config/claude` | `$HOME/.claude`<br>`~/Library/Application Support/claude` |

### Custom Path Override
```bash
# Use any custom location
export CLAUDE_CONFIG_PATH=/your/custom/path
./scripts/deploy.sh
```

**No configuration needed** - just run the deployment script and it finds Claude Code automatically.

## 🛠️ Powerful Scripts & Commands

### 🚀 Deployment Commands
```bash
# Standard deployment (recommended)
./scripts/deploy.sh                # Auto-backup + deploy + validation

# Advanced options
./scripts/deploy.sh --force         # Skip confirmation prompts
./scripts/deploy.sh --skip-backup   # Deploy without backup (risky)
./scripts/deploy.sh --verbose       # Detailed output
```

### 💾 Backup & Recovery
```bash
# Create manual backup
./scripts/backup.sh

# List all available backups
./scripts/restore.sh --list-backups

# Restore specific backup
./scripts/restore.sh --backup-path ./backups/backup-20250115_143022

# Interactive restore (shows menu)
./scripts/restore.sh
```

### 🔍 Validation & Health Checks
```bash
# Validate configuration before deployment
python3 -m json.tool .claude/settings.json

# Check hook syntax
bash .claude/hooks/examples/validation-hook.sh

# Test custom commands
.claude/commands/examples/system-info.ps1
```

## 🎯 Core Components

### 🤖 Smart Agents
- **Meta-Agent** - Dynamically generates new agents from descriptions
- **Global Orchestrator** - Coordinates complex multi-step workflows
- **Custom Agent Templates** - Create specialized agents for any task

### ⚙️ Advanced Configuration
- **Modular Settings** - Environment-specific configurations
- **Global Orchestration** - Parallel task execution with dependencies
- **Agent Priorities** - Smart delegation and load balancing
- **Workflow Templates** - Pre-built automation patterns

### 🔗 Hooks & Commands
- **Event Hooks** - Trigger actions on prompt submission, tool usage, errors
- **Custom Commands** - Extend Claude Code with your own utilities
- **Cross-Platform Scripts** - PowerShell, Bash, and Python examples
- **Development Tools** - Testing, validation, and debugging helpers

### 📦 Easy Extension
```bash
# Add new configuration module
1. Edit .claude/settings.json
2. Add documentation to .claude/contexts/modules/
3. Test locally with: python3 -m json.tool .claude/settings.json
4. Deploy with: ./scripts/deploy.sh
```

## 🤝 Perfect for Teams

**Claude Builder makes configuration sharing effortless:**

✅ **Fork & Customize** - Start with this template, adapt to your needs  
✅ **Version Control Ready** - Track changes, collaborate with Git  
✅ **Zero Hardcoded Paths** - Works on any team member's machine  
✅ **Safe Development** - Test locally before deploying to production  
✅ **Instant Setup** - New team members: clone, deploy, done  
✅ **Rollback Safety** - Mistakes? Restore previous configuration instantly  

### Team Workflow Example
```bash
# Team lead creates configuration
# 1. Fork the repository on GitHub
# 2. Clone the fork and customize
git clone https://github.com/your-username/claude-builder.git
cd claude-builder
# Customize .claude/ for team needs
git add . && git commit -m "Team Claude configuration"
git push origin main
# 3. Create pull request to share with team

# Team members get instant setup
# 1. Fork the team's customized repository
# 2. Clone and deploy
git clone https://github.com/your-team/claude-builder.git
cd claude-builder
./scripts/deploy.sh  # Done! Claude Code now has team configuration
```

## 📖 Documentation & Resources

📋 **[CLAUDE.md](CLAUDE.md)** - Complete development and deployment guide  
📊 **[CLAUDE-build.md](CLAUDE-build.md)** - Configuration structure and modules  
⚙️ **[scripts/config.json](scripts/config.json)** - Platform path configuration  
🤖 **[.claude/agents/README.md](.claude/agents/)** - Agent development guide  
🔗 **[.claude/hooks/README.md](.claude/hooks/)** - Hook system documentation  
🛠️ **[.claude/commands/README.md](.claude/commands/)** - Custom command creation  

### External Resources
🌐 **[Claude Code Official Docs](https://docs.anthropic.com/en/docs/claude-code)** - Official documentation  
🤖 **[Sub-Agents Guide](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** - Creating custom agents  
⚙️ **[Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)** - Configuration options  

## 🆘 Troubleshooting

### 🔧 Common Issues

**Configuration not working?**
```bash
# 1. Check deployment path
./scripts/deploy.sh --verbose

# 2. Validate JSON syntax
python3 -m json.tool .claude/settings.json

# 3. Check permissions
ls -la ~/.config/claude/  # Linux/macOS
dir %USERPROFILE%\.claude\  # Windows
```

**Need to rollback?**
```bash
# List all backups
./scripts/restore.sh --list-backups

# Restore latest backup
./scripts/restore.sh

# Restore specific backup
./scripts/restore.sh --backup-path ./backups/backup-20250115_143022
```

**Custom Claude Code location?**
```bash
# Set custom path and deploy
export CLAUDE_CONFIG_PATH=/your/custom/path
./scripts/deploy.sh
```

### 🔍 Getting Help

- 📖 **Check the docs**: [CLAUDE.md](CLAUDE.md) has detailed guides
- 🐛 **Report issues**: [GitHub Issues](https://github.com/Morgiver/claude-builder/issues)
- 💬 **Need help?**: Include your platform and error messages

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

**🏗️ Build better Claude Code configurations**  
*Safe • Portable • Professional*

[⭐ Star this repo](https://github.com/Morgiver/claude-builder) • [🔀 Fork it](https://github.com/Morgiver/claude-builder/fork) • [📖 Read the docs](CLAUDE.md)

</div>