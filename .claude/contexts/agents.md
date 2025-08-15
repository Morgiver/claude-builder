# Custom Agents Configuration

This document describes the custom agents configuration and how they integrate with the global orchestration system.

## Meta-Agent

The `meta-agent` is the core agent generator that creates new specialized agents based on user descriptions.

### Configuration

Location: `settings.json` > `custom_agents.meta-agent`

- **Priority**: 10 (highest)
- **Model**: Opus (for best generation quality)
- **Tools**: Write, WebFetch, MultiEdit
- **Auto-integration**: Enabled

### Features

- **Dynamic Agent Generation**: Creates new agents from natural language descriptions
- **Smart Path Detection**: Automatically determines correct output directory (development vs. global)
- **Auto-registration**: Automatically adds new agents to orchestration priorities
- **Consistent Structure**: Enforces standard agent format and naming conventions
- **Template System**: Uses predefined templates for consistent output
- **Environment Aware**: Respects `CLAUDE_CONFIG_PATH` and platform-specific paths

## Agent Generation Process

1. **User Request**: User describes desired agent functionality
2. **Path Detection**: Determines appropriate output directory (development or global)
3. **Analysis**: Meta-agent analyzes requirements and selects appropriate tools
4. **Generation**: Creates complete agent configuration file
5. **Registration**: Automatically adds to `agent_priorities` with default priority
6. **Integration**: Makes agent available for orchestration workflows

## Agent Structure Template

All generated agents follow this structure:

```markdown
---
name: agent-name
description: Action-oriented description for delegation
tools: Tool1, Tool2, Tool3
model: sonnet | haiku | opus
color: color-name
---

# Purpose
Agent role definition

## Instructions
Step-by-step process

## Report / Response
Output format specification
```

## Configuration Settings

### Agent Generation Templates
- **Default Model**: Sonnet (balanced performance/cost)
- **Naming Convention**: kebab-case
- **Available Colors**: red, blue, green, yellow, purple, orange, pink, cyan
- **Output Directory**: Auto-detected (development or global)

### Auto-Registration
- **Priority Assignment**: Default priority 5 (customizable)
- **Orchestration Integration**: Automatic workflow template integration
- **Configuration Updates**: Automatic settings.json updates

### Smart Path Detection
The meta-agent intelligently determines where to write new agents:

**Development Context**:
- Detects local `.claude/` directory
- Writes to `.claude/agents/` for development workflow
- Perfect for testing and iterative development

**Global Context**:
- Uses `CLAUDE_CONFIG_PATH` environment variable if set
- Auto-detects platform-specific global Claude Code directory
- Ensures agents are immediately available system-wide

**Path Priority**:
1. `CLAUDE_CONFIG_PATH` environment variable (if set)
2. Local `.claude/agents/` (if `.claude/` directory exists)
3. Auto-detected global Claude Code agents directory

---

*Custom agents enhance the orchestration capabilities by providing specialized, domain-specific expertise.*