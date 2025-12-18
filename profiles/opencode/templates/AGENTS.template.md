# [PROJECT_NAME]

> Powered by OpenCode-OS + oh-my-opencode

## Overview

This project uses **OpenCode-OS** for spec-driven development workflows, built on the **oh-my-opencode** plugin.

## Quick Start

```bash
# Start with product planning
/plan-product [describe your goals]

# For a specific feature:
/shape-spec feature-name      # Research & requirements
/write-spec feature-name      # Technical specification  
/create-tasks feature-name    # Break into tasks
/implement feature-name       # Build it (TDD)
/verify feature-name          # Verify & ship
```

## Workflow Commands

| Command | Purpose | Agent Used |
|---------|---------|------------|
| `/plan-product` | Strategic roadmap planning | oracle |
| `/shape-spec <feature>` | Research & gather requirements | librarian |
| `/write-spec <feature>` | Write technical specification | document-writer |
| `/create-tasks <feature>` | Break spec into implementable tasks | (default) |
| `/implement <feature>` | TDD implementation | (default) |
| `/verify <feature>` | Final verification & report | oracle |
| `/verify-spec <feature>` | Verify spec quality before tasks | oracle |
| `/task-status <feature>` | Check/update task progress | (default) |

## Available Agents

Your agents depend on your oh-my-opencode configuration:

| Agent | Purpose | Use With |
|-------|---------|----------|
| **OmO** | Main orchestrator | Complex tasks, delegation |
| **oracle** | Architecture, debugging, review | `@oracle [question]` |
| **librarian** | Documentation, OSS examples | `@librarian [lookup]` |
| **explore** | Fast codebase search | `@explore [pattern]` |
| **frontend-ui-ux-engineer** | UI/UX development | `@frontend-ui-ux-engineer [task]` |
| **document-writer** | Technical writing | `@document-writer [task]` |

## Project Structure

```
[PROJECT_NAME]/
├── AGENTS.md                      # This file
├── opencode-os/
│   ├── config.yml                 # Project config
│   ├── product/
│   │   └── roadmap.md            # Product roadmap
│   ├── specs/
│   │   └── [feature]/            # Per-feature specs
│   │       ├── planning/
│   │       │   └── requirements.md
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       └── verification.md
│   ├── standards/                 # Coding standards
│   │   ├── global.md
│   │   ├── backend.md
│   │   ├── frontend.md
│   │   └── testing.md
│   └── templates/                 # Document templates
└── .opencode/
    ├── opencode.json             # OpenCode config
    └── command/                  # Workflow commands
```

## Standards

Standards are automatically loaded. They cover:

- **Global** - TypeScript, naming, error handling, file organization
- **Backend** - API design, database patterns, security
- **Frontend** - React patterns, state management, accessibility
- **Testing** - Test structure, coverage, mocking

## Workflow Example

```bash
# 1. Planning phase
/plan-product "Build a user authentication system with OAuth support"

# 2. Shape the auth feature
/shape-spec auth

# 3. Write detailed spec
/write-spec auth

# 4. Verify spec is ready
/verify-spec auth

# 5. Break into tasks
/create-tasks auth

# 6. Implement (TDD)
/implement auth

# 7. Verify implementation
/verify auth
```

## Tips

- Use `@agent-name` to directly invoke any agent
- Run background tasks for parallel work
- Check `/task-status` to track progress
- Standards are enforced automatically

## Resources

- [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)
- [OpenCode Docs](https://opencode.ai/docs)
- [AGENT-OS Concepts](https://buildermethods.com/agent-os)
