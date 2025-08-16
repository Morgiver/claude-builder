# Claude Code Global Configuration

This file contains the global configuration for Claude Code, built progressively according to your needs.

## Configuration Structure

### Main Configuration

All configuration is centralized in a single optimized file for better performance.

⚙️ **[Main Settings File](.claude/settings.json)**

### Environment Variables

Environment variables are configured in `settings.json` under the `environment` section.

📄 **[Environment Variables Documentation](.claude/contexts/env_vars.md)**

Current variables:
- `OS_TYPE` - Operating system optimization

### Configuration Modules

Module configurations are stored in `settings.json` under the `modules` section. Documentation is maintained separately for discoverability.

📁 **[Module Documentation](.claude/contexts/modules/)**

Available modules:
- `project-management` - Structured project management methodologies for AI agents
  - **Agile Scrum** - Adaptive Scrum with iterations, user intervention modes, and developer control points
  - **Waterfall** - Sequential phase-based development with comprehensive documentation and validation gates
- `global-orchestration` - Advanced workflow orchestration and task coordination

### Custom Agents

Custom agents are configured in `settings.json` under the `custom_agents` section with automated generation capabilities.

🤖 **[Agents Configuration](.claude/contexts/agents.md)**

Available agents:
- `meta-agent` - Dynamic agent generation and auto-registration system
- `global-orchestrator` - Master orchestration agent for complex multi-step workflows and multi-agent coordination

---

*Configuration in progress...*