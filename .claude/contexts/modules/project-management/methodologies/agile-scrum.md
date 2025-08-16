# Agile Scrum for AI Agents

## Overview

An adaptive implementation of Agile Scrum methodology specifically designed for AI agents. This approach maintains the iterative, incremental nature of Scrum while removing human-centric ceremonies and adapting to the instantaneous, parallel nature of AI agent work.

## Core Principles

1. **Iterative Development** - Work in focused iterations delivering complete features
2. **Continuous Adaptation** - Adjust approach based on findings and feedback
3. **Value-Driven** - Prioritize tasks that deliver the most user value
4. **Transparent Progress** - Real-time visibility of work status
5. **User Control** - Multiple intervention points for developer guidance

## Structure

### Iterations (Replacing Sprints)

Iterations are defined by:
- **Complexity-based sizing** rather than time-based
- **Coherent feature sets** that deliver complete functionality
- **Adaptive scope** that can adjust based on discoveries
- **Clear exit criteria** for completion

### Task Management

**Task Backlog**
- Prioritized list of all work to be done
- Automatically integrated with TodoWrite tool
- Dynamic re-prioritization based on dependencies and discoveries

**Iteration Backlog**
- Subset of tasks selected for current iteration
- Sized to be completable in a single work session
- Organized by dependencies and logical flow

## Iteration Phases

### 1. Planning Phase

**Activities:**
- Analyze user requirements and objectives
- Decompose work into atomic, testable tasks
- Identify dependencies and potential blockers
- Create iteration plan with clear deliverables
- Estimate complexity and identify risks

**User Intervention Points:**
- Approve/modify proposed plan
- Adjust task priorities
- Add technical constraints or preferences
- Specify technology choices

**Output:**
- Detailed iteration plan
- Task list with priorities
- Risk assessment

### 2. Execution Phase

**Activities:**
- Execute tasks in priority order
- Parallelize independent tasks when possible
- Continuous testing and validation
- Real-time progress updates via TodoWrite
- Automatic dependency resolution

**User Intervention Points:**
- Mid-iteration checkpoints after major tasks
- Architecture decision points
- Technology choice confirmations
- Blocker resolution requests

**Practices:**
- Test-driven development when applicable
- Incremental commits (when requested)
- Code quality checks at each step
- Documentation updates inline with code

### 3. Delivery Phase

**Activities:**
- Compile iteration results
- Run final validation tests
- Generate iteration report
- Identify remaining work
- Prepare next iteration plan

**User Intervention Points:**
- Review completed work
- Provide feedback
- Approve or request changes
- Decide on next iteration

**Outputs:**
- Working code/features
- Iteration summary report
- Updated backlog
- Recommendations for next steps

## Roles

### User (Product Owner)
- Defines requirements and acceptance criteria
- Sets priorities and makes business decisions
- Provides feedback and direction
- Approves completed work

### Primary Agent (Scrum Master + Dev Team)
- Plans and executes iterations
- Manages task progression
- Identifies and escalates blockers
- Maintains transparency of progress

### Orchestrator Agent (When Multiple Agents)
- Coordinates parallel work streams
- Manages dependencies between agents
- Aggregates progress reporting
- Resolves inter-agent conflicts

### Specialist Agents (As Needed)
- Execute specific technical tasks
- Provide domain expertise
- Report progress to orchestrator

## Intervention Modes

### Autonomous Mode (Default)
```
"Proceed with the full iteration and report results"
```
- Agent completes entire iteration independently
- User reviews at iteration end
- Best for: Well-defined tasks, experienced users

### Collaborative Mode
```
"Request validation at major checkpoints"
```
- Agent pauses after each significant task
- User validates direction before continuing
- Best for: Complex projects, learning phase

### Supervised Mode
```
"Show me each change before applying"
```
- Agent presents each modification for approval
- Maximum control over development
- Best for: Critical systems, teaching scenarios

### Custom Mode
```
"I'll tell you when I want to review"
```
- User can interrupt at any time
- Flexible intervention points
- Best for: Experienced developers

## User Commands

### Flow Control
- `pause` - Stop current work and await instructions
- `continue` - Resume after pause
- `skip [task]` - Skip specified task
- `abort iteration` - Cancel current iteration

### Visibility
- `status` - Show current progress and task list
- `show plan` - Display iteration plan
- `show changes` - Review modifications made
- `explain [decision]` - Get rationale for agent choices

### Modification
- `prioritize [task]` - Move task to top priority
- `add task [description]` - Insert new task
- `remove task [id]` - Delete task from backlog
- `modify approach` - Change implementation strategy

### Review
- `review code` - Show all code changes
- `test status` - Display test results
- `show blockers` - List current obstacles
- `summarize` - Get iteration summary

## Artifacts

### Iteration Plan
```yaml
iteration:
  number: 1
  objective: "Implement user authentication"
  tasks:
    - id: 1
      description: "Create user model"
      priority: high
      complexity: medium
      dependencies: []
    - id: 2
      description: "Implement login endpoint"
      priority: high
      complexity: high
      dependencies: [1]
```

### Progress Status
Real-time task status via TodoWrite:
- `pending` - Not started
- `in_progress` - Currently working
- `completed` - Finished successfully
- `blocked` - Waiting for user input

### Iteration Report
```markdown
## Iteration 1 Summary
**Objective**: Implement user authentication
**Completion**: 100%

### Completed Tasks
- ✅ Created user model
- ✅ Implemented login endpoint
- ✅ Added password hashing
- ✅ Created JWT token generation

### Challenges Encountered
- Database connection timeout (resolved)

### Next Iteration Recommendations
- Add password reset functionality
- Implement session management
```

## Metrics

### Iteration Metrics
- **Completion Rate**: Percentage of planned tasks completed
- **Velocity**: Complexity points completed per iteration
- **Block Time**: Time waiting for user input
- **Error Rate**: Number of errors requiring correction

### Project Metrics
- **Total Iterations**: Number of iterations completed
- **Average Velocity**: Mean complexity per iteration
- **Scope Creep**: Tasks added mid-iteration
- **Technical Debt**: Identified improvements needed

## Best Practices

### For Users
1. Provide clear acceptance criteria upfront
2. Choose appropriate intervention mode for project criticality
3. Review iteration plans before execution
4. Give feedback promptly when blocked
5. Batch related changes into single iterations

### For Agents
1. Break work into small, testable increments
2. Validate assumptions early and often
3. Escalate blockers immediately
4. Maintain clear progress visibility
5. Document decisions and rationale

## When to Use This Methodology

**Ideal for:**
- Projects with evolving requirements
- Complex features requiring iteration
- Learning and exploration projects
- Collaborative development sessions
- Projects needing frequent user feedback

**Less suitable for:**
- Simple, one-off tasks
- Purely research activities
- Emergency fixes
- Highly regulated environments requiring waterfall

## Configuration Example

```json
{
  "methodology": "agile-scrum",
  "settings": {
    "intervention_mode": "collaborative",
    "max_iteration_complexity": 20,
    "auto_test": true,
    "progress_updates": "after_major_tasks",
    "require_plan_approval": true
  }
}
```

## Recommended Project Structure

### Directory Hierarchy

When using Agile Scrum methodology, organize your project with this structure:

```
project-root/
├── .scrum/                      # Scrum methodology artifacts (FIXED STRUCTURE)
│   ├── project-structure.md    # Documents chosen code structure
│   ├── conventions.md          # Project-specific conventions
│   ├── backlog/                # Product and iteration backlogs
│   │   ├── product-backlog.md  # Feature index and prioritization
│   │   ├── features/           # Detailed feature specifications
│   │   │   ├── FEAT-001-user-auth.md
│   │   │   ├── FEAT-002-data-persistence.md
│   │   │   └── FEAT-003-api-structure.md
│   │   └── iteration-001.md    # Current iteration tasks
│   ├── iterations/             # Iteration history and reports
│   │   ├── current/            # Active iteration workspace
│   │   │   ├── plan.md         # Iteration plan
│   │   │   ├── tasks.todo     # TodoWrite compatible task list
│   │   │   └── progress.md     # Real-time progress updates
│   │   └── archive/            # Completed iterations
│   │       ├── iteration-001/  # Archived iteration 1
│   │       │   ├── plan.md
│   │       │   ├── report.md   # Final iteration report
│   │       │   └── metrics.json
│   │       └── iteration-002/
│   ├── decisions/              # Architecture Decision Records (ADRs)
│   │   ├── ADR-001-database-choice.md
│   │   └── ADR-002-api-structure.md
│   ├── metrics/                # Project metrics and analytics
│   │   ├── velocity.json       # Iteration velocity tracking
│   │   ├── burndown.json       # Progress tracking data
│   │   └── quality.json        # Code quality metrics
│   └── templates/              # Optional structure templates
│       └── structures/         # Common project structures
│           ├── web-fullstack.md
│           ├── python-api.md
│           └── go-microservice.md
│
└── [PROJECT CODE]              # FLEXIBLE STRUCTURE - Adapt to project type
    │                           # Examples:
    │                           # - Python: app/, tests/, scripts/
    │                           # - Node.js: src/, dist/, public/
    │                           # - Go: cmd/, pkg/, internal/
    │                           # - Java: src/main/java/, src/test/
    │                           # - Mobile: app/, components/, screens/
    │                           # - Microservices: services/, packages/
    └── (structure documented in .scrum/project-structure.md)

```

### File Naming Conventions

#### Iteration Files
- `iteration-XXX.md` - Sequential numbering (001, 002, 003)
- `plan-YYYY-MM-DD.md` - Date-based for planning documents
- `report-iteration-XXX.md` - Iteration completion reports

#### Task Files
- `tasks.todo` - TodoWrite compatible format
- `blocked-tasks.md` - Tasks awaiting user input
- `completed-tasks.md` - Archive of done tasks

#### Decision Records
- `ADR-XXX-brief-description.md` - Architecture decisions
- `DECISION-XXX-topic.md` - General project decisions

## Document Templates

Standard templates for consistent project documentation.

### Feature Specification Template

```markdown
# {{FEATURE_ID}}: {{FEATURE_NAME}}

**Status**: 💡 Proposed
**Priority**: {{PRIORITY}}
**Complexity**: {{COMPLEXITY}}
**Target Iteration**: {{ITERATION}}
**Created**: {{CREATED_DATE}}
**Updated**: {{UPDATED_DATE}}

## Overview
[Provide a clear, concise description of what this feature does and why it's needed]

## User Stories
1. **As a [user type]**, I want to [action] so that [benefit]
2. **As a [user type]**, I want to [action] so that [benefit]
3. **As a [user type]**, I want to [action] so that [benefit]

## Acceptance Criteria
- [ ] [Specific, testable criteria for completion]
- [ ] [Another criteria]
- [ ] [Performance/security requirements if applicable]

## Technical Requirements

### Database Schema (if applicable)
```sql
-- Define any new tables, columns, or indexes needed
```

### API Endpoints (if applicable)
- `[HTTP_METHOD] /api/[endpoint]` - [Description]

### Dependencies
- [Library/service name] - [Why needed]

## Tasks Breakdown
1. [ ] [Specific, actionable task]
2. [ ] [Another task]
3. [ ] [Write unit tests]
4. [ ] [Update documentation]

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk description] | [High/Medium/Low] | [How to mitigate] |

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Tests written and passing
- [ ] Documentation updated

## Notes
- [Any additional considerations]
- [Future enhancements to consider]
```

### Iteration Plan Template

```markdown
# Iteration {{ITERATION_NUMBER}} Plan

**Objective**: {{OBJECTIVE}}
**Complexity Points**: {{COMPLEXITY_POINTS}}
**Started**: {{START_DATE}}

## Goals
- [Primary goal of this iteration]
- [Secondary goal]

## Selected Features
| Feature ID | Name | Priority | Complexity | Dependencies |
|------------|------|----------|------------|--------------|
| [FEAT-XXX] | [Feature name] | [High/Med/Low] | [Points] | [Dependencies] |

## Tasks
1. [Task description] ([complexity] pts)
2. [Task description] ([complexity] pts)

## Success Criteria
- [Specific, measurable criteria for iteration success]
- [Another criteria]

## Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| [Risk] | [High/Med/Low] | [High/Med/Low] | [Action] |

## Notes
- [Any additional context or considerations]
```

### Iteration Report Template

```markdown
# Iteration {{ITERATION_NUMBER}} Summary

**Completion**: {{COMPLETION_RATE}}%
**Duration**: [Start date] - [End date]
**Velocity**: [Complexity points completed]

## Objective Achievement
**Target**: {{OBJECTIVE}}
**Result**: [Did we achieve the objective? What was delivered?]

## Completed Tasks
- ✅ [Task description] ([complexity] pts)
- ✅ [Task description] ([complexity] pts)

## Incomplete Tasks
- ❌ [Task description] - [Reason not completed]
- 🔄 [Task description] - [Moved to next iteration]

## Key Achievements
{{ACHIEVEMENTS}}

## Challenges Encountered
{{CHALLENGES}}

## Metrics
- **Planned complexity**: [X] points
- **Completed complexity**: [Y] points
- **Completion rate**: {{COMPLETION_RATE}}%

## What Went Well
- [Positive aspect 1]
- [Positive aspect 2]

## What Could Be Improved
- [Area for improvement 1]
- [Area for improvement 2]

## Actions for Next Iteration
- [Action item 1]
- [Action item 2]
```

### Architecture Decision Record Template

```markdown
# ADR-{{ADR_NUMBER}}: {{TITLE}}

**Status**: {{STATUS}}
**Date**: {{DECISION_DATE}}
**Iteration**: {{ITERATION}}

## Context
{{CONTEXT}}

[Describe the situation that requires a decision. What is the architectural problem we're trying to solve?]

## Decision
{{DECISION}}

[Describe the architectural decision we've made. Be specific about what we're choosing to do.]

## Rationale
[Explain why this decision was made. What alternatives were considered? What are the trade-offs?]

### Alternatives Considered
1. **[Alternative 1]**: [Description and why it was rejected]
2. **[Alternative 2]**: [Description and why it was rejected]

### Decision Factors
- [Factor 1]: [How it influenced the decision]
- [Factor 2]: [How it influenced the decision]

## Consequences
{{CONSEQUENCES}}

### Positive Consequences
- [Benefit 1]
- [Benefit 2]

### Negative Consequences
- [Drawback 1]
- [Drawback 2]

## Implementation Notes
- [How will this decision be implemented?]
- [What needs to be changed?]

## Related Decisions
- [Link to related ADRs]

## Follow-up Actions
- [ ] [Action item 1]
- [ ] [Action item 2]

## Review Date
[When should this decision be reviewed?]
```

### Key Files Description

#### `.scrum/backlog/product-backlog.md`
Feature index with prioritized list linking to detailed feature specifications.
Template: `{{template:project-management/agile-scrum/feature-template}}`

#### `.scrum/backlog/features/FEAT-001-user-auth.md`
```markdown
# FEAT-001: User Authentication System

**Status**: 🔄 In Progress
**Priority**: High
**Complexity**: High (15 points)
**Target Iteration**: 1
**Created**: 2024-01-10
**Updated**: 2024-01-15

## Overview
Implement a complete user authentication system with registration, login, and session management using JWT tokens.

## User Stories
1. **As a user**, I want to register with email and password so that I can create an account
2. **As a user**, I want to log in with my credentials so that I can access protected features
3. **As a user**, I want my session to persist so that I don't have to log in repeatedly
4. **As a developer**, I want to protect API endpoints so that only authenticated users can access them

## Acceptance Criteria
- [ ] Users can register with email, password, and optional profile info
- [ ] Email validation and uniqueness check
- [ ] Password strength requirements (min 8 chars, 1 uppercase, 1 number)
- [ ] Passwords are hashed using bcrypt
- [ ] Login returns JWT token valid for 24 hours
- [ ] Refresh token mechanism for extended sessions
- [ ] Middleware to protect routes
- [ ] Password reset via email functionality

## Technical Requirements

### Database Schema
```sql
users {
  id: UUID
  email: string (unique)
  password_hash: string
  created_at: timestamp
  updated_at: timestamp
  last_login: timestamp
}

refresh_tokens {
  id: UUID
  user_id: UUID (FK)
  token: string
  expires_at: timestamp
}
```

### API Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout and invalidate tokens
- `POST /api/auth/reset-password` - Request password reset
- `POST /api/auth/confirm-reset` - Confirm password reset

### Dependencies
- bcrypt for password hashing
- jsonwebtoken for JWT handling
- email service for notifications
- validation library (zod/joi)

## Tasks Breakdown
1. [x] Set up database schema
2. [x] Create user model
3. [>] Implement password hashing service
4. [ ] Build registration endpoint
5. [ ] Build login endpoint
6. [ ] Implement JWT service
7. [ ] Create auth middleware
8. [ ] Add refresh token logic
9. [ ] Implement password reset
10. [ ] Write unit tests
11. [ ] Write integration tests
12. [ ] Update API documentation

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| JWT secret exposure | High | Use environment variables, rotate regularly |
| Brute force attacks | Medium | Implement rate limiting |
| Session hijacking | Medium | Use HTTPS, secure cookies |

## Notes
- Consider OAuth integration in future iteration
- May need to add 2FA in subsequent release
- Monitor failed login attempts for security
```

#### `.scrum/iterations/current/plan.md`
```markdown
# Iteration 3 Plan

**Objective**: Implement user authentication
**Complexity Points**: 15
**Started**: 2024-01-15

## Tasks
1. Create user model (3 pts)
2. Implement password hashing (2 pts)
3. Build login endpoint (5 pts)
4. Add JWT token generation (3 pts)
5. Create middleware for auth (2 pts)

## Success Criteria
- Users can register with email/password
- Users can log in and receive JWT
- Protected routes require valid token
```

#### `.scrum/iterations/current/tasks.todo`
```
[ ] Create user model schema
[x] Set up database connection
[>] Implement password hashing service
[ ] Build registration endpoint
[ ] Build login endpoint
[ ] Add JWT token generation
[ ] Create auth middleware
[ ] Write unit tests for auth
[ ] Update API documentation
```

#### `.scrum/project-structure.md`
```markdown
# Project Structure Documentation

**Project Type**: REST API with React Frontend
**Primary Language**: TypeScript/Node.js
**Last Updated**: 2024-01-15

## Directory Structure

```
project-root/
├── .scrum/                 # Agile Scrum methodology
├── backend/               # API server (Node.js/Express)
│   ├── src/
│   │   ├── controllers/  # Request handlers
│   │   ├── models/       # Database models
│   │   ├── services/     # Business logic
│   │   ├── middleware/   # Express middleware
│   │   └── utils/        # Helper functions
│   ├── tests/
│   └── package.json
├── frontend/              # React application
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── pages/        # Page components
│   │   ├── hooks/        # Custom hooks
│   │   ├── services/     # API client
│   │   └── utils/        # Helpers
│   ├── public/
│   └── package.json
├── shared/                # Shared types/utilities
│   └── types/            # TypeScript interfaces
└── docker-compose.yml     # Container orchestration
```

## Rationale

- **Monorepo structure**: Frontend and backend in same repository for easier coordination
- **Separation of concerns**: Clear boundaries between API and UI
- **Shared types**: Common TypeScript definitions prevent drift
- **Standard conventions**: Following Node.js and React best practices

## Key Conventions

- **File naming**: kebab-case for files, PascalCase for components
- **Imports**: Absolute imports using path aliases (@backend/, @frontend/, @shared/)
- **Testing**: Tests colocated with source files (*.test.ts)
- **Environment**: .env files for configuration (never committed)
```

#### `.scrum/conventions.md`
```markdown
# Project Conventions

## Code Style

### TypeScript/JavaScript
- ESLint configuration: airbnb-typescript
- Prettier for formatting
- Strict TypeScript settings enabled
- No any types without explicit justification

### File Organization
- One component/class per file
- Index files for clean exports
- Barrel exports for features

## Git Conventions

### Branch Naming
- feature/FEAT-XXX-description
- bugfix/BUG-XXX-description
- hotfix/ISSUE-description

### Commit Messages
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Tests
- chore: Maintenance

## API Conventions

### Endpoints
- RESTful naming: /api/v1/resources
- Plural for collections
- Consistent status codes
- JSON responses

### Authentication
- JWT in Authorization header
- Bearer token format
- Refresh token rotation

## Database

### Naming
- Tables: snake_case, plural
- Columns: snake_case
- Indexes: idx_table_columns
- Foreign keys: fk_source_target

### Migrations
- Sequential numbering
- Descriptive names
- Always reversible

## Testing

### Coverage Requirements
- Unit tests: 80% minimum
- Critical paths: 100%
- E2E for user journeys

### Naming
- describe blocks for components/functions
- it/test for specific behaviors
- Clear, descriptive test names

## Documentation

### Code Comments
- JSDoc for public APIs
- Inline comments for complex logic
- TODO with ticket reference

### README Files
- Purpose and setup
- Development workflow
- Deployment instructions
```

#### `.scrum/decisions/ADR-001-database-choice.md`
```markdown
# ADR-001: Database Choice

**Status**: Accepted
**Date**: 2024-01-15
**Iteration**: 1

## Context
Need to choose a database for the application.

## Decision
Use PostgreSQL for primary data storage.

## Rationale
- Strong consistency requirements
- Complex relational data
- Team expertise

## Consequences
- Need to set up PostgreSQL
- Will use Prisma as ORM
- Requires connection pooling for scale
```

### Automation Features

#### Auto-Generated Files
When starting a new iteration, these files are automatically created:
- Iteration plan from backlog selection
- Empty tasks.todo file
- Progress tracking file
- Metrics baseline

#### File Updates
During iteration execution:
- `tasks.todo` - Updated in real-time via TodoWrite
- `progress.md` - Auto-generated from task status
- `metrics.json` - Calculated from completion data

#### Archival Process
When completing an iteration:
1. Generate final report
2. Calculate metrics
3. Move to `archive/` with timestamp
4. Create new `current/` structure

### Flexible Project Structure

The methodology supports any project structure. When starting a new project:

1. **Agent analyzes**: Existing project structure or asks about project type
2. **Documents choice**: Creates `.scrum/project-structure.md` with rationale
3. **Maintains flexibility**: Adapts as project evolves
4. **Respects conventions**: Follows language and framework standards

### Benefits of This Structure

1. **Clear Separation** - Methodology artifacts separate from code
2. **Historical Tracking** - Complete iteration history preserved
3. **Easy Navigation** - Predictable file locations
4. **Tool Integration** - Compatible with TodoWrite and other tools
5. **Scalability** - Structure grows naturally with project
6. **Transparency** - All decisions and progress visible
7. **Flexibility** - Adapts to any project type or language
8. **Documentation** - Structure choices are documented and justified

### Usage Examples

#### Starting New Iteration
```bash
# Agent automatically creates:
.scrum/iterations/current/plan.md
.scrum/iterations/current/tasks.todo
.scrum/iterations/current/progress.md
```

#### During Development
```bash
# Agent updates:
- tasks.todo (via TodoWrite)
- progress.md (auto-generated)
- Creates ADRs for major decisions
```

#### Completing Iteration
```bash
# Agent automatically:
1. Generates iteration report
2. Archives to .scrum/iterations/archive/iteration-XXX/
3. Updates metrics
4. Prepares next iteration structure
```

## Integration with Other Modules

### With global-orchestrator
- Automatic iteration planning and execution
- Multi-agent coordination for large iterations
- Dependency management across work streams

### With workflows
- Combine with technical workflows for implementation
- Use workflow templates within iterations

## Example Usage

```
User: "Let's build a REST API using agile-scrum methodology"

Agent: "I'll use Agile Scrum for AI Agents. Here's my iteration plan:

**Iteration 1: Foundation**
1. Set up project structure
2. Configure database connection
3. Create base models
4. Implement basic CRUD endpoints

Would you like to proceed in Collaborative Mode (I'll check with you after major tasks) or Autonomous Mode (I'll complete the iteration and report back)?"

User: "Collaborative mode please"

Agent: "Starting Iteration 1 in Collaborative Mode. I'll pause after each major component for your review..."
```