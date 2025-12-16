# Data Modeling

Principles for designing robust, scalable, and maintainable data models.

## Core Principles

### 1. Model the Domain, Not the UI
- Entities represent real-world concepts
- Don't let UI requirements drive schema design
- Separate read models from write models when needed

### 2. Explicit Relationships
- Define all relationships in schema
- Use foreign keys for referential integrity
- Document relationship cardinality (1:1, 1:N, N:M)

### 3. Normalize First, Denormalize Intentionally
- Start with 3NF normalization
- Denormalize only for proven performance needs
- Document every denormalization decision

### 4. Type Safety End-to-End
- Schema is the source of truth
- Generate types from schema definitions
- Validate at boundaries, trust internally

### 5. Plan for Audit and History
- Include timestamps: `created_at`, `updated_at`
- Consider soft deletes: `deleted_at`
- Track who: `created_by`, `updated_by`

## Standard Fields

| Field | Type | Purpose |
|-------|------|---------|
| `id` | UUID/CUID | Primary identifier |
| `created_at` | Timestamp | Record creation time |
| `updated_at` | Timestamp | Last modification time |
| `deleted_at` | Timestamp? | Soft delete marker |
| `version` | Integer | Optimistic locking |

## Naming Conventions

```
Tables:      snake_case, plural     → users, order_items
Columns:     snake_case             → first_name, created_at
Foreign keys: singular_table_id     → user_id, order_id
Indexes:     table_column_idx       → users_email_idx
Constraints: table_column_type      → users_email_unique
```

## Relationship Patterns

```
1:1  → Foreign key on either side, unique constraint
1:N  → Foreign key on the "many" side
N:M  → Junction table with composite key
```

## Anti-Patterns to Avoid

- **God tables**: Single table with 50+ columns
- **EAV pattern**: Entity-Attribute-Value without good reason
- **Stringly typed**: Using strings for structured data
- **Missing constraints**: Relying on application for data integrity
- **Implicit nulls**: Nullable columns without clear meaning

## Technology-Specific Patterns

For implementation details, see:
- [Drizzle Schema](../../skills/standards-backend/resources/drizzle.md)
- [Convex Data Modeling](../../skills/standards-backend/resources/convex.md)
- [Supabase Schema](../../skills/standards-backend/resources/supabase.md)
- [Database Patterns](../../skills/standards-backend/resources/database-patterns.md)

## Quick Checklist

- [ ] All entities have proper primary keys
- [ ] Relationships defined with foreign keys
- [ ] Standard timestamp fields included
- [ ] Indexes planned for query patterns
- [ ] Constraints enforce data integrity
- [ ] Types generated from schema
