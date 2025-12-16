# Database Migrations

Principles for safe, reversible, and production-ready database migrations.

## Core Principles

### 1. Migrations Are Immutable
- Never modify a migration after it's been applied
- Create new migrations to fix issues
- Treat migration history as an append-only log

### 2. Small, Focused Changes
- One logical change per migration
- Easier to review, test, and rollback
- Name migrations descriptively: `add_user_email_index`

### 3. Always Plan for Rollback
- Write down migrations when possible
- Consider data loss implications
- Test rollback in staging before production

### 4. Separate Schema from Data
- Schema migrations: structure changes
- Data migrations: content transformations
- Never mix them in the same migration

### 5. Zero-Downtime by Default
- Avoid locking operations on large tables
- Use progressive rollout for breaking changes
- Consider read replicas during migrations

## Migration Workflow

```
1. Generate → Create migration file from schema diff
2. Review   → Verify SQL is safe and correct
3. Test     → Apply to local/staging database
4. Apply    → Run in production with monitoring
5. Verify   → Confirm application works correctly
```

## Safe vs Unsafe Operations

| Operation | Safety | Notes |
|-----------|--------|-------|
| Add column (nullable) | ✅ Safe | No data changes needed |
| Add column (default) | ⚠️ Careful | May lock table |
| Add index | ⚠️ Careful | Use CONCURRENTLY if supported |
| Drop column | ❌ Unsafe | Requires application update first |
| Rename column | ❌ Unsafe | Use add/copy/drop pattern |
| Change type | ❌ Unsafe | Create new column, migrate data |

## Breaking Change Pattern

```
Phase 1: Add new column (nullable)
Phase 2: Backfill data, update application
Phase 3: Make column required
Phase 4: Remove old column (after verification)
```

## Technology-Specific Patterns

For implementation details, see:
- [Drizzle Migrations](../../skills/standards-backend/resources/drizzle.md)
- [Database Patterns](../../skills/standards-backend/resources/database-patterns.md)
- [Supabase Migrations](../../skills/standards-backend/resources/supabase.md)

## Quick Checklist

- [ ] Migration has descriptive name
- [ ] Rollback strategy documented
- [ ] Tested on local database
- [ ] No table-locking operations on large tables
- [ ] Application code ready for schema change
- [ ] Backup taken before production apply
