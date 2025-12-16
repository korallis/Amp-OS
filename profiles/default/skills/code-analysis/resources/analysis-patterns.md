# Code Analysis Patterns

## Common Search Patterns by Language

### JavaScript/TypeScript

| Find | Grep Pattern |
|------|--------------|
| Exports | `"export (default\|const\|function\|class)"` |
| React components | `"(function\|const) [A-Z][a-zA-Z]+.*=.*=>"` |
| Hooks | `"use[A-Z][a-zA-Z]+"` |
| API routes | `"(get\|post\|put\|delete\|patch)\s*\("` |
| Type definitions | `"(interface\|type) [A-Z]"` |
| Test files | Glob: `"**/*.test.{ts,tsx}"` |

### Python

| Find | Grep Pattern |
|------|--------------|
| Class definitions | `"^class [A-Z]"` |
| Function definitions | `"^def [a-z_]+"` |
| Decorators | `"^@[a-z_]+"` |
| Imports | `"^(from\|import) "` |
| FastAPI routes | `"@(app\|router)\.(get\|post)"` |

### Go

| Find | Grep Pattern |
|------|--------------|
| Struct definitions | `"type [A-Z][a-zA-Z]+ struct"` |
| Interface definitions | `"type [A-Z][a-zA-Z]+ interface"` |
| Function definitions | `"^func [A-Z]"` (exported) |
| HTTP handlers | `"func.*http\.ResponseWriter"` |

### Rust

| Find | Grep Pattern |
|------|--------------|
| Struct definitions | `"pub struct [A-Z]"` |
| Impl blocks | `"impl [A-Z]"` |
| Trait definitions | `"trait [A-Z]"` |
| Public functions | `"pub fn [a-z_]+"` |

## Architecture Analysis Queries

### For finder (semantic search)

```
"Find where authentication/authorization is handled"
"Find database connection and query execution"
"Find error handling and logging patterns"
"Find API request validation"
"Find configuration loading and environment variables"
"Find the main business logic for [feature]"
"Find tests related to [component]"
```

### Dependency Mapping

1. **Direct imports**
   ```
   Grep: "import.*from ['\"]\.\./" (relative imports)
   Grep: "import.*from ['\"][^.]" (package imports)
   ```

2. **Circular dependency detection**
   - Map: A imports B, B imports C, C imports A
   - Use finder: "Find circular dependencies between modules"

3. **External dependency audit**
   ```
   Read: package.json → dependencies section
   Grep: Each dependency name to find usage count
   ```

## Impact Assessment Checklist

When analyzing change impact:

- [ ] **Direct callers** - What calls this function/class?
- [ ] **Interface contracts** - What interfaces does this implement?
- [ ] **Database changes** - Schema migrations needed?
- [ ] **API changes** - Breaking changes for consumers?
- [ ] **Test coverage** - Existing tests that verify behavior?
- [ ] **Configuration** - Environment/config dependencies?
- [ ] **Documentation** - Docs that reference this?

## Red Flags to Watch For

| Pattern | Concern |
|---------|---------|
| Files >500 lines | Consider splitting |
| Circular imports | Architecture smell |
| `any` type (TS) | Type safety gap |
| Hardcoded values | Configuration needed |
| No error handling | Reliability risk |
| Global state | Testing difficulty |
| Deep nesting (>4) | Complexity |

## Output Templates

### Component Summary
```markdown
## ComponentName
**Path**: `src/components/ComponentName.tsx`
**Lines**: 150
**Imports**: 5 internal, 3 external
**Exported**: ComponentName, ComponentNameProps
**Used by**: ParentA, ParentB
**Tests**: `ComponentName.test.tsx` (85% coverage)
```

### Dependency Report
```markdown
## Module Dependencies

### Internal
- `utils/` → used by 12 modules
- `services/` → used by 8 modules
- `components/` → used by 5 modules

### External (npm)
- react: 45 imports
- lodash: 23 imports (consider tree-shaking)
- axios: 8 imports (centralized in api/)
```
