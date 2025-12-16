# AMP-OS

> Spec-driven development workflows for Amp CLI using native skills.

AMP-OS brings structured, lazy-loaded development workflows to [Amp](https://ampcode.com). Skills load on-demand, keeping context efficient while providing comprehensive guidance for planning, specification, implementation, and verification.

## Installation

**One-line install:**

```bash
curl -fsSL https://raw.githubusercontent.com/leebarry/Amp-OS/main/install.sh | bash
```

Or clone manually:

```bash
git clone https://github.com/leebarry/Amp-OS.git ~/Amp-OS
```

## Quick Start

```bash
# Install AMP-OS into a project
~/Amp-OS/scripts/amp-project-install.sh /path/to/your-project

# Or from within your project
~/Amp-OS/scripts/amp-project-install.sh .
```

## What's Included

### 14 Skills

| Category | Skills |
|----------|--------|
| **Phase** | `plan-product`, `shape-spec`, `write-spec`, `create-tasks`, `implement-tasks`, `verify-implementation` |
| **Verifier** | `spec-verifier`, `implementation-verifier` |
| **Standards** | `standards-global`, `standards-backend`, `standards-frontend`, `standards-testing` |
| **Utility** | `architecture-diagrams`, `code-analysis` |

### Workflow

```
Plan Product → Shape Spec → Write Spec → Create Tasks → Implement → Verify
```

1. **Plan Product** - Define roadmap and milestones using `oracle`
2. **Shape Spec** - Research requirements, gather user stories
3. **Write Spec** - Create detailed specification from requirements
4. **Create Tasks** - Break spec into implementable task groups
5. **Implement Tasks** - Execute with standards, test-first approach
6. **Verify Implementation** - Run tests, update roadmap, generate report

## Project Structure After Install

```
your-project/
├── AGENTS.md                    # Project context for Amp
├── amp-os/
│   ├── config.yml              # Project-specific settings
│   ├── product/
│   │   └── roadmap.md          # Product roadmap
│   ├── specs/                  # Feature specifications
│   │   └── [feature]/
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       └── planning/
│   └── templates/              # Document templates
└── .claude/
    └── skills/                 # Symlinked AMP-OS skills
        ├── amp-os-plan-product/
        ├── amp-os-write-spec/
        └── ...
```

## Usage

Skills are triggered automatically by Amp when relevant. You can also explicitly invoke them:

```
"Load the amp-os-plan-product skill to create a roadmap"
"Use amp-os-write-spec to create a specification for user authentication"
"Apply amp-os-standards-backend when implementing the API"
```

### Multi-Agent Implementation

For large features, use the Task tool with agent templates:

```
Task: "Implement Task Group 2 using the implementer agent template"
```

## Configuration

### Master Config (`~/Amp-OS/config.yml`)

```yaml
version: 1.0.0
use_symlinks: true        # Symlink skills (true) or copy (false)
profile: default          # Profile to use

# Skill categories
install_phase_skills: true
install_verifier_skills: true
install_standards_skills: true
install_utility_skills: true
```

### Project Config (`project/amp-os/config.yml`)

```yaml
version: 1.0.0
profile: default
project_name: "My Project"
tech_stack: ["node", "react", "postgres"]

standards:
  global: true
  backend: true
  frontend: true
  testing: true
```

## Updating

```bash
# Update skills in a project (for copied installs)
~/Amp-OS/scripts/amp-project-update.sh /path/to/project

# Symlinked installs update automatically
```

## Key Benefits

| Feature | Benefit |
|---------|---------|
| **Lazy Loading** | Skills load only when needed, preserving context |
| **Oracle Integration** | GPT-5 powered planning and review |
| **Native Todos** | Sync with Amp's `todo_write`/`todo_read` |
| **Semantic Search** | Use `finder` for intelligent code discovery |
| **Diagrams** | Generate mermaid diagrams with code citations |
| **Multi-Agent** | Orchestrate with `Task` tool for parallel work |

## License

MIT
