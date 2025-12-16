# AMP-OS Development Agent Instructions

> **CRITICAL**: Always use RAG tools (exa, perplexity, ref) before implementing ANY code. Your knowledge is outdated.

## Project Overview

AMP-OS provides spec-driven development workflows for Amp CLI, using native skills for context-efficient, lazy-loaded guidance through planning, specification, implementation, and verification phases.

## RAG-First Development Protocol

Before writing ANY code:
1. **exa** (`mcp__exa__get_code_context_exa`) - For API/library code examples
2. **perplexity** (`mcp__perplexity__perplexity_ask/research`) - For current best practices
3. **ref** (`mcp__ref__ref_search_documentation`) - For official documentation

## Implementation Plan Reference

See: `docs/implementation-plan.md` for complete specification.

## Master Folder Structure

```
~/Amp-OS/
├── config.yml                    # Master configuration
├── README.md                     # Documentation
├── AGENTS.md                     # This file
├── scripts/
│   ├── amp-project-install.sh    # Main install script
│   ├── amp-project-update.sh     # Update existing installs
│   ├── create-profile.sh         # Create new profiles
│   └── common-functions.sh       # Shared bash utilities
└── profiles/
    └── default/
        ├── skills/               # 14 SKILL directories
        ├── agents/               # Task tool prompt templates
        └── templates/            # Document templates
```

## Skills to Implement (14 total)

### Phase Skills (6)
1. `plan-product` - Product roadmap planning
2. `shape-spec` - Research & requirements gathering
3. `write-spec` - Specification writing
4. `create-tasks` - Task breakdown
5. `implement-tasks` - Implementation workflow
6. `verify-implementation` - Final verification

### Verifier Skills (2)
7. `spec-verifier` - Spec quality verification
8. `implementation-verifier` - Implementation verification

### Standards Skills (4)
9. `standards-global` - Global coding standards
10. `standards-backend` - Backend standards
11. `standards-frontend` - Frontend standards
12. `standards-testing` - Testing standards

### Utility Skills (2)
13. `architecture-diagrams` - Mermaid diagram generation
14. `code-analysis` - Codebase analysis helper

## Agent Prompt Templates (7)

1. `product-planner.md`
2. `spec-shaper.md`
3. `spec-writer.md`
4. `tasks-creator.md`
5. `implementer.md`
6. `spec-verifier.md`
7. `implementation-verifier.md`

## Document Templates (4)

1. `AGENTS.template.md` - Minimal AGENTS.md for projects
2. `spec.md` - Feature specification template
3. `requirements.md` - Requirements template
4. `tasks.md` - Task breakdown template
5. `final-verification.md` - Verification report template

## Commands

```bash
# No build/test commands yet - this is a template/script project
# Validation will be manual testing of install scripts
```

## Key Amp Tools to Leverage

- `skill` - Load skills on demand (lazy loading)
- `oracle` - Planning and review (o3 model)
- `todo_write`/`todo_read` - Native task tracking
- `finder` - Semantic code search
- `mermaid` - Architecture diagrams
- `Task` - Sub-agent orchestration

## Code Style

- Shell scripts: POSIX-compatible bash
- YAML: 2-space indentation
- Markdown: Standard GFM with YAML frontmatter for skills
