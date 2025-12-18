# Amp-OS

> Spec-driven development workflows for AI coding assistants.

A structured framework for planning, specification, implementation, and verification.

**Supports:**
- **Amp CLI** (Sourcegraph) — uses skills-based lazy loading
- **OpenCode** (SST) — uses slash commands + oh-my-opencode

## Installation

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Amp-OS/main/install.sh | bash
```

You'll be prompted to choose your platform (Amp CLI or OpenCode).

### Manual install

```bash
git clone https://github.com/korallis/Amp-OS.git ~/Amp-OS
chmod +x ~/Amp-OS/scripts/*.sh
```

---

## Quick Start

### For Amp CLI

```bash
# Install into a project
~/Amp-OS/scripts/amp-project-install.sh /path/to/your-project

# Then in Amp, load skills:
"Load amp-os-plan-product to create a roadmap"
```

### For OpenCode

```bash
# Requires oh-my-opencode plugin first (see below)
~/Amp-OS/scripts/opencode-project-install.sh /path/to/your-project

# Then in OpenCode, use slash commands:
/plan-product
```

---

## Platform Comparison

| Feature | Amp CLI | OpenCode |
|---------|---------|----------|
| **Context Loading** | Skills (lazy-loaded) | Slash commands |
| **Standards** | Symlinked to `.claude/skills/` | Loaded via `instructions[]` |
| **Agent Orchestration** | Native `Task` tool | oh-my-opencode agents |
| **Planning/Review** | `oracle` skill | `@oracle` agent |
| **Todo Management** | `todo_write`/`todo_read` | oh-my-opencode todos |
| **Semantic Search** | `finder` tool | `mgrep` tool |

---

## Workflow

Both platforms follow the same spec-driven workflow:

```
Plan Product → Shape Spec → Write Spec → Create Tasks → Implement → Verify
```

| Phase | Purpose | Amp CLI Skill | OpenCode Command |
|-------|---------|---------------|------------------|
| **Plan** | Define roadmap and milestones | `amp-os-plan-product` | `/plan-product` |
| **Shape** | Research requirements | `amp-os-shape-spec` | `/shape-spec` |
| **Write** | Create specification | `amp-os-write-spec` | `/write-spec` |
| **Tasks** | Break into task groups | `amp-os-create-tasks` | `/create-tasks` |
| **Implement** | TDD implementation | `amp-os-implement-tasks` | `/implement` |
| **Verify** | Final verification | `amp-os-verify-implementation` | `/verify` |

---

## Workflow Examples

### Greenfield Project (Starting Fresh)

When building a new product from scratch, follow the full workflow.

**Example: Building a SaaS invoicing app**

<details>
<summary><strong>Amp CLI Version</strong></summary>

```bash
# 1. Install Amp-OS
~/Amp-OS/scripts/amp-project-install.sh ~/projects/invoice-app
cd ~/projects/invoice-app && amp
```

```
# 2. Plan the product (creates roadmap.md)
"Load amp-os-plan-product skill. Build a SaaS invoicing application with:
- User authentication (email + OAuth)
- Invoice creation and management  
- Stripe payment integration
- PDF export
- Client portal"

# 3. Shape the first feature
"Load amp-os-shape-spec skill for user-auth feature"
# → Researches auth patterns, creates requirements.md

# 4. Write the specification
"Load amp-os-write-spec skill for user-auth"
# → Creates detailed spec.md with API contracts, data models

# 5. Verify spec quality before implementation
"Load amp-os-spec-verifier skill for user-auth"
# → Oracle reviews for completeness, flags gaps

# 6. Break into tasks
"Load amp-os-create-tasks skill for user-auth"
# → Creates tasks.md with task groups

# 7. Implement (TDD approach)
"Load amp-os-implement-tasks skill for user-auth"
# → Implements each task group with tests first

# 8. Final verification
"Load amp-os-verify-implementation skill for user-auth"
# → Runs tests, updates roadmap, generates report
```

</details>

<details>
<summary><strong>OpenCode Version</strong></summary>

```bash
# 1. Install Amp-OS
~/Amp-OS/scripts/opencode-project-install.sh ~/projects/invoice-app
cd ~/projects/invoice-app && opencode
```

```
# 2. Plan the product (creates roadmap.md)
/plan-product Build a SaaS invoicing application with:
- User authentication (email + OAuth)
- Invoice creation and management
- Stripe payment integration
- PDF export
- Client portal

# 3. Shape the first feature
/shape-spec user-auth
# → Researches auth patterns, creates requirements.md

# 4. Write the specification
/write-spec user-auth
# → Creates detailed spec.md with API contracts, data models

# 5. Verify spec quality before implementation
/verify-spec user-auth
# → Oracle reviews for completeness, flags gaps

# 6. Break into tasks
/create-tasks user-auth
# → Creates tasks.md with task groups

# 7. Implement (TDD approach)
/implement user-auth
# → Implements each task group with tests first

# 8. Final verification
/verify user-auth
# → Runs tests, updates roadmap, generates report
```

</details>

**Greenfield Tips:**
- Start with product planning to establish vision and milestones
- Tackle features in dependency order (auth → core → integrations)
- Each feature gets its own spec directory
- Verify specs before writing code

---

### Brownfield Project (Existing Codebase)

When adding features to an existing project, adapt the workflow.

**Example: Adding Stripe billing to an existing app**

<details>
<summary><strong>Amp CLI Version</strong></summary>

```bash
# 1. Install Amp-OS into existing project
~/Amp-OS/scripts/amp-project-install.sh ~/projects/my-existing-app
cd ~/projects/my-existing-app && amp
```

```
# 2. Skip product planning, go straight to feature shaping
"Load amp-os-shape-spec skill for stripe-billing feature"
# → Analyzes existing code patterns, identifies integration points

# 3. Write spec with existing code context
"Load amp-os-write-spec skill for stripe-billing"
# → References existing models, follows established patterns

# 4. Create tasks respecting current architecture
"Load amp-os-create-tasks skill for stripe-billing"
# → Breaks work into incremental, non-breaking changes

# 5. Implement incrementally
"Load amp-os-implement-tasks skill for stripe-billing"
# → Follows existing conventions, adds tests

# 6. Verify integration
"Load amp-os-verify-implementation skill for stripe-billing"
# → Ensures no regressions, all tests pass
```

</details>

<details>
<summary><strong>OpenCode Version</strong></summary>

```bash
# 1. Install Amp-OS into existing project
~/Amp-OS/scripts/opencode-project-install.sh ~/projects/my-existing-app
cd ~/projects/my-existing-app && opencode
```

```
# 2. Skip product planning, go straight to feature shaping
/shape-spec stripe-billing
# → Analyzes existing code patterns, identifies integration points

# 3. Write spec with existing code context
/write-spec stripe-billing
# → References existing models, follows established patterns

# 4. Create tasks respecting current architecture  
/create-tasks stripe-billing
# → Breaks work into incremental, non-breaking changes

# 5. Implement incrementally
/implement stripe-billing
# → Follows existing conventions, adds tests

# 6. Verify integration
/verify stripe-billing
# → Ensures no regressions, all tests pass
```

</details>

**Brownfield Tips:**
- Skip product planning unless restructuring the whole project
- Use shape-spec to analyze existing patterns first
- Reference existing code in your spec prompts
- Implement in smaller increments to avoid breaking changes
- Run existing tests frequently during implementation

---

### Quick Reference

| Scenario | Amp CLI Skills | OpenCode Commands |
|----------|----------------|-------------------|
| **New product** | `plan-product` → `shape-spec` → `write-spec` → `create-tasks` → `implement-tasks` → `verify-implementation` | `/plan-product` → `/shape-spec` → `/write-spec` → `/create-tasks` → `/implement` → `/verify` |
| **New feature** | `shape-spec` → `write-spec` → `create-tasks` → `implement-tasks` → `verify-implementation` | `/shape-spec` → `/write-spec` → `/create-tasks` → `/implement` → `/verify` |
| **Bug fix** | Load `standards-*` skills, fix directly | Fix directly (standards auto-loaded) |
| **Refactoring** | `shape-spec` → `create-tasks` → `implement-tasks` → `verify-implementation` | `/shape-spec` → `/create-tasks` → `/implement` → `/verify` |
| **Spike/research** | `shape-spec` only | `/shape-spec` only |

---

## Amp CLI Setup

### Project Structure After Install

```
your-project/
├── AGENTS.md                    # Project context
├── amp-os/
│   ├── config.yml              # Project settings
│   ├── product/
│   │   └── roadmap.md          # Product roadmap
│   ├── specs/                  # Feature specifications
│   │   └── [feature]/
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       └── planning/
│   └── templates/              # Document templates
└── .claude/
    └── skills/                 # Symlinked skills
        ├── amp-os-plan-product/
        ├── amp-os-write-spec/
        └── ...
```

### Available Skills (14)

| Category | Skills |
|----------|--------|
| **Phase** | `plan-product`, `shape-spec`, `write-spec`, `create-tasks`, `implement-tasks`, `verify-implementation` |
| **Verifier** | `spec-verifier`, `implementation-verifier` |
| **Standards** | `standards-global`, `standards-backend`, `standards-frontend`, `standards-testing` |
| **Utility** | `architecture-diagrams`, `code-analysis` |

### Usage

```
"Load the amp-os-plan-product skill to create a roadmap"
"Use amp-os-write-spec to create a specification for user authentication"
"Apply amp-os-standards-backend when implementing the API"
```

For large features, use the Task tool with agent templates:
```
Task: "Implement Task Group 2 using the implementer agent template"
```

---

## OpenCode Setup

### Prerequisites

**oh-my-opencode is REQUIRED** for the OpenCode version. It provides:
- Async background agents (oracle, librarian, explore)
- Claude Code compatibility layer
- LSP/AST tools
- Todo management and enforcement
- Curated MCPs (context7, exa, grep.app)

Install oh-my-opencode:

```bash
# Add to ~/.config/opencode/opencode.json:
{ "plugin": ["oh-my-opencode"] }

# Then run opencode to initialize
opencode
```

See: [oh-my-opencode documentation](https://github.com/code-yeongyu/oh-my-opencode)

### Project Structure After Install

```
your-project/
├── AGENTS.md                    # Project context
├── .opencode/
│   ├── opencode.json           # OpenCode config
│   └── command/                # Workflow commands
│       ├── plan-product.md
│       ├── shape-spec.md
│       ├── write-spec.md
│       └── ...
├── .claude/
│   └── rules/                  # Conditional rules (optional)
└── opencode-os/
    ├── config.yml              # Project settings
    ├── product/
    │   └── roadmap.md          # Product roadmap
    ├── specs/                  # Feature specifications
    ├── standards/              # Coding standards
    │   ├── global.md
    │   ├── backend.md
    │   ├── frontend.md
    │   └── testing.md
    └── templates/              # Document templates
```

### Available Commands

| Command | Purpose | Agent Used |
|---------|---------|------------|
| `/plan-product` | Strategic planning | oracle |
| `/shape-spec` | Research requirements | librarian |
| `/write-spec` | Write specification | document-writer |
| `/create-tasks` | Break spec into tasks | - |
| `/implement` | TDD implementation | - |
| `/verify` | Final verification | oracle |
| `/verify-spec` | Spec quality check | oracle |
| `/task-status` | Task progress | - |

### Usage

```bash
# In your project
cd /path/to/your-project
opencode

# Use slash commands
/plan-product
/shape-spec user-authentication
/implement
```

### Invoking Agents Directly

oh-my-opencode provides several agents you can invoke:

```
@oracle      - Deep reasoning, architecture decisions
@librarian   - External documentation, OSS examples
@explore     - Internal codebase search
@frontend-ui-ux-engineer - UI/UX implementation
@document-writer - Documentation tasks
```

---

## Configuration

### Master Config (`~/Amp-OS/config.yml`)

```yaml
version: 1.0.0
use_symlinks: true        # Symlink skills (true) or copy (false)
profile: default          # Profile for Amp CLI

# Skill categories (Amp only)
install_phase_skills: true
install_verifier_skills: true
install_standards_skills: true
install_utility_skills: true
```

### Project Config

**Amp CLI** (`project/amp-os/config.yml`):
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

**OpenCode** (`project/opencode-os/config.yml`):
```yaml
version: 1.0.0
profile: opencode
project_name: "My Project"
platform: opencode
standards:
  global: true
  backend: true
  frontend: true
  testing: true
features:
  oh_my_opencode: true
```

---

## Updating

### Amp CLI
```bash
# Symlinked installs update automatically when you pull
cd ~/Amp-OS && git pull

# For copied installs:
~/Amp-OS/scripts/amp-project-update.sh /path/to/project
```

### OpenCode
```bash
# Pull latest
cd ~/Amp-OS && git pull

# Re-run installer to update commands (--copy mode only)
~/Amp-OS/scripts/opencode-project-install.sh /path/to/project
```

---

## Key Benefits

| Feature | Description |
|---------|-------------|
| **Spec-Driven** | Plan before code, verify after |
| **Platform Agnostic** | Same workflow on Amp CLI or OpenCode |
| **Lazy Loading** | Context loads only when needed |
| **Standards Enforced** | Consistent coding across features |
| **Multi-Agent** | Orchestrate specialized agents |
| **Templates** | Reusable spec/task/verification templates |

---

## Repository Structure

```
~/Amp-OS/
├── install.sh                    # Unified installer
├── config.yml                    # Master config
├── README.md                     # This file
├── AGENTS.md                     # Development instructions
├── scripts/
│   ├── amp-project-install.sh    # Amp CLI project installer
│   ├── amp-project-update.sh     # Amp CLI updater
│   ├── opencode-project-install.sh # OpenCode project installer
│   ├── create-profile.sh         # Create new profiles
│   └── common-functions.sh       # Shared utilities
└── profiles/
    ├── default/                  # Amp CLI profile
    │   ├── skills/               # 14 SKILL directories
    │   ├── agents/               # Agent templates
    │   ├── standards/            # Standards files
    │   └── templates/            # Document templates
    └── opencode/                 # OpenCode profile
        ├── commands/             # 8 workflow commands
        ├── standards/            # 4 standards files
        ├── templates/            # Document templates
        └── rules/                # Conditional rules
```

---

## Credits

- [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) by code-yeongyu
- [Amp CLI](https://ampcode.com) by Sourcegraph
- [OpenCode](https://opencode.ai) by SST

## License

MIT
