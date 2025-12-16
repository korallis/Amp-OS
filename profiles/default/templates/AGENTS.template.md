# Project AGENTS.md

> **AMP-OS Standards Applied**: All code must follow AMP-OS standards. See [Standards Guide](./amp-os/docs/standards-guide.md).

## Standards (Always Apply)

**Before writing or modifying any code, you MUST consult these standards:**

| Task Type | Required Standards |
|-----------|-------------------|
| Any code | `standards-global` |
| Frontend/UI | `standards-global` + `standards-frontend` |
| Backend/API | `standards-global` + `standards-backend` |
| Tests | `standards-global` + `standards-testing` |
| Full feature | All four standards |

**To load standards** (invoke by name from SKILL.md, not folder name):
```
skill standards-global
skill standards-frontend
skill standards-backend
skill standards-testing
```

## Quick Commands

```bash
# Build
# pnpm build

# Test
# pnpm test

# Lint
# pnpm lint

# Typecheck
# pnpm check
```

## AMP-OS Workflow Triggers

Use these phrases to activate AMP-OS workflows:

| Phase | Trigger | Description |
|-------|---------|-------------|
| 1 | **"plan product"** | Start product roadmap planning |
| 2 | **"shape spec"** | Research and gather requirements |
| 3 | **"write spec"** | Create feature specification |
| 4 | **"create tasks"** | Break spec into implementation tasks |
| 5 | **"implement tasks"** | Execute task implementation workflow |
| 6 | **"verify implementation"** | Run final verification checks |

## Code Style Requirements

**Global Standards** (from `standards-global`):
- TypeScript strict mode with `noUncheckedIndexedAccess`
- `kebab-case` for files, `camelCase` for functions, `PascalCase` for types
- Maximum 300 lines per file, 50 lines per function
- Use Result pattern for error handling
- No `any` types ever
- Use Zod for validation

**Conventions**:
- Follow existing patterns in the codebase
- Prefer composition over inheritance
- Use discriminated unions for state
- Match surrounding code style

## Project Structure

```
src/
├── components/    # UI components
├── lib/           # Shared utilities
├── routes/        # Page routes
└── types/         # TypeScript types

amp-os/
├── specs/         # Feature specifications
│   └── [feature]/
│       ├── spec.md
│       ├── tasks.md
│       └── planning/
└── docs/          # AMP-OS documentation
```

## Tech Stack

<!-- Define your project's tech stack here -->

| Category | Technology |
|----------|------------|
| Framework | Next.js 15 |
| Language | TypeScript |
| Database | <!-- Convex / Supabase / Drizzle+Neon --> |
| Styling | Tailwind CSS v4 |
| Testing | Vitest + Playwright |
| Payments | <!-- Stripe if applicable --> |

## Notes

<!-- Add project-specific notes here -->
