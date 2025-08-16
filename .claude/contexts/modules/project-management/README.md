# Project Management Module

## Overview

This module provides structured project management methodologies to help organize and guide development work. Each methodology offers a specific framework with practices, phases, and tools adapted to different project contexts.

## Purpose

- Provide structured approaches for managing development projects
- Offer guidance on project phases, rituals, and best practices
- Help teams choose the right methodology for their context
- Standardize project workflows and communication patterns

## Available Methodologies

| Methodology | Description | Best For | Status |
|------------|-------------|----------|--------|
| [Agile Scrum](methodologies/agile-scrum.md) | Adaptive Scrum for AI agents with iteration-based development | Evolving requirements, complex features, collaborative work | ✅ Ready |
| [Waterfall](methodologies/waterfall.md) | Sequential phase-based development with comprehensive documentation | Stable requirements, regulated environments, large complex systems | ✅ Ready |

## How to Use

### Selecting a Methodology

When starting a new project, you can request a specific methodology:

```
"Let's use [methodology name] for this project"
"What project management approach would you recommend?"
"Show me available project methodologies"
```

### Methodology Structure

Each methodology document includes:

- **Overview**: Core principles and philosophy
- **Project Phases**: Structured stages of development
- **Roles & Responsibilities**: Team member functions
- **Ceremonies/Rituals**: Meetings and checkpoints
- **Artifacts**: Documents and deliverables
- **Best Practices**: Proven patterns for success
- **Tools & Techniques**: Supporting methods and tools
- **When to Use**: Context and project types

## Directory Structure

```
project-management/
├── README.md                  # This file - module overview and index
└── methodologies/             # Individual methodology documents
    ├── agile-scrum.md        # (Example - to be created)
    ├── kanban.md             # (Example - to be created)
    └── waterfall.md          # (Example - to be created)
```

## Integration with Other Modules

### With global-orchestrator
- Orchestrates project phases automatically
- Manages dependencies between project stages
- Tracks methodology-specific milestones

### With workflows
- Combines project methodology with technical workflows
- Aligns development practices with management approach

## Adding New Methodologies

To add a new methodology:

1. Create a new markdown file in `methodologies/` directory
2. Follow the standard template structure
3. Update this README's methodology table
4. Test the methodology in a sample project

## Configuration

Module settings in `settings.json`:

```json
{
  "modules": {
    "project-management": {
      "enabled": true,
      "default_methodology": null,
      "auto_suggest": true,
      "adapt_to_team_size": true
    }
  }
}
```

## Notes

- Methodologies are guides, not rigid rules
- Adapt approaches to your specific context
- Combine elements from different methodologies when appropriate
- Focus on delivering value over following process