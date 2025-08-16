# Claude Code Configuration Modules

This directory contains modular configuration components for Claude Code. Each module is self-contained and can be loaded independently for optimal performance.

## Available Modules

| Module | Description | Use Cases | Tools Required |
|--------|-------------|-----------|----------------|
| [project-management](./project-management/) | Structured project management methodologies adapted for AI agents | Iterative development, complex features, collaborative coding | TodoWrite, Task |
| [global-orchestration](./global-orchestration/) | Orchestrates complex multi-step workflows and coordinates task execution across different domains | Project management, CI/CD coordination, complex deployments | Task, TodoWrite, MultiEdit |

## Module Structure

Each module follows this structure:
```
module-name/
├── README.md          # Module documentation
├── config.json        # Module configuration
├── prompts/           # Custom prompts (optional)
├── hooks/             # Event hooks (optional)
└── examples/          # Usage examples (optional)
```

## How to Use Modules

1. **Discovery**: Browse this index to find relevant modules
2. **Selection**: Choose modules based on your use case
3. **Loading**: Reference the module in your workflow
4. **Configuration**: Customize module settings as needed

## Module Guidelines

- **Self-contained**: Each module should work independently
- **Well-documented**: Clear README with examples
- **Focused**: Single responsibility principle
- **Reusable**: Generic enough for multiple scenarios

---

*Modules are loaded on-demand for optimal performance*