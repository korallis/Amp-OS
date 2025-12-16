# Tech Stack

Template for defining and documenting project technology stacks.

## Principles

1. **Choose boring technology** - Proven tools over trendy ones
2. **Minimize stack diversity** - Fewer technologies to maintain
3. **Document decisions** - Record why tools were chosen
4. **Version lock dependencies** - Reproducible builds

## Stack Definition Template

### Core Technologies
```yaml
runtime: <language/runtime version>
framework: <primary framework>
database: <database type>
hosting: <deployment platform>
```

### Development Tools
```yaml
package_manager: <npm/pnpm/yarn>
bundler: <vite/webpack/etc>
linter: <eslint/biome/etc>
formatter: <prettier/biome/etc>
testing: <vitest/jest/etc>
```

### Infrastructure
```yaml
ci_cd: <github actions/etc>
monitoring: <observability tool>
logging: <logging service>
secrets: <secrets management>
```

## Stack Documentation

Each technology choice should document:
- **What**: Tool name and version
- **Why**: Reason for selection
- **Alternatives**: What was considered
- **Risks**: Known limitations

## Version Management

- Pin exact versions in lockfiles
- Document minimum supported versions
- Plan upgrade cadence (quarterly recommended)
- Test major upgrades in isolation

## Example Stack

```yaml
# Example: Full-Stack TypeScript
core:
  runtime: Node.js 20 LTS
  language: TypeScript 5.x
  framework: Next.js 14
  database: PostgreSQL 16
  orm: Prisma 5.x

tools:
  package_manager: pnpm
  linter: ESLint + typescript-eslint
  formatter: Prettier
  testing: Vitest + Playwright
```

## Detailed Patterns

For language-specific configurations, see:
- [Coding Conventions - TypeScript Config](../../skills/standards-global/resources/coding-conventions.md#typescript-configuration)

## Quick Reference

```
✅ DO                          ❌ AVOID
─────────────────────────────────────────
LTS versions                    Bleeding edge
Document decisions              Undocumented choices
Lock dependencies               Loose version ranges
Single language where possible  Polyglot complexity
```
