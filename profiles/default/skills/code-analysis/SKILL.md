---
name: code-analysis
description: Structured codebase analysis for understanding architecture, patterns, and dependencies. Use when onboarding to a codebase, planning changes, or assessing impact.
---

# Code Analysis

Systematic approach to understanding codebases using Amp's search tools.

## Analysis Workflow

### 1. Entry Point Discovery
```
finder: "Find main entry points, bootstrap files, and initialization code"
```
- Locate `main`, `index`, `app`, `server` files
- Identify configuration loading
- Map startup sequence

### 2. Architecture Mapping
```
finder: "Find service/module boundaries and how they connect"
Grep: Pattern for imports/exports between modules
```
- Identify layers (API, service, data)
- Map module dependencies
- Note shared utilities

### 3. Pattern Discovery
```
Grep: "interface|abstract class|extends|implements"
finder: "Find design patterns used in this codebase"
```
- Authentication/authorization patterns
- Data access patterns
- Error handling conventions
- State management approach

### 4. Dependency Analysis
```
Read: package.json, go.mod, Cargo.toml, requirements.txt
Grep: Import statements for external packages
```
- External dependencies and versions
- Internal module dependencies
- Circular dependency detection

### 5. Impact Assessment
```
Grep: Function/class name across codebase
finder: "Find all usages and callers of [component]"
```
- Direct consumers
- Transitive dependencies
- Test coverage for affected areas

## Output Format

Structure findings as:

```markdown
## [Component/Area Name]

**Purpose**: One-line description
**Location**: [link to main file]
**Dependencies**: List of imports
**Dependents**: What uses this
**Patterns**: Notable patterns used
**Risks**: Potential issues or tech debt
```

## Quick Commands

| Goal | Tool | Pattern |
|------|------|---------|
| Find definitions | `Grep` | `"(class|function|const)\s+Name"` |
| Find usages | `Grep` | `"Name\("` or `"import.*Name"` |
| Semantic search | `finder` | Natural language query |
| Read context | `Read` | File path with line range |

See [analysis-patterns.md](resources/analysis-patterns.md) for common patterns.

## When to Use

- Onboarding to an unfamiliar codebase
- Planning refactoring or major changes
- Assessing impact of proposed modifications
- Understanding dependencies before updates
