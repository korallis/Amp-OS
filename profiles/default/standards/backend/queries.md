# Query Optimization

Principles for writing efficient, maintainable, and scalable database queries.

## Core Principles

### 1. Measure Before Optimizing
- Profile queries in development
- Monitor slow query logs in production
- Optimize the queries that matter (80/20 rule)

### 2. Index Strategically
- Index columns used in WHERE, JOIN, ORDER BY
- Consider composite indexes for multi-column queries
- Remove unused indexes (they slow writes)

### 3. Fetch Only What You Need
- Select specific columns, not `SELECT *`
- Use pagination for large result sets
- Limit results with appropriate defaults

### 4. Push Work to the Database
- Use aggregations instead of application-level loops
- Filter at database level, not in application
- Leverage database-specific optimizations

### 5. Understand Your Access Patterns
- Design indexes around read patterns
- Consider read replicas for heavy read loads
- Cache frequently accessed, rarely changing data

## Query Performance Checklist

| Check | Impact | How |
|-------|--------|-----|
| Index exists | High | EXPLAIN shows index scan |
| N+1 eliminated | High | Use joins or batch loading |
| Pagination used | Medium | LIMIT/OFFSET or cursor |
| Columns selected | Medium | Only needed fields |
| Results cached | Medium | For repeated identical queries |

## N+1 Query Problem

```
❌ Bad: Fetch users, then loop to fetch orders
   → 1 query + N queries = N+1 queries

✅ Good: Fetch users with orders in single query
   → 1 query with JOIN or include
```

## Pagination Patterns

```
Offset-based (simple, has issues at scale):
  SELECT * FROM items LIMIT 20 OFFSET 40

Cursor-based (consistent, scales better):
  SELECT * FROM items 
  WHERE id > :last_id 
  ORDER BY id LIMIT 20
```

## Index Guidelines

```
Single column:  High-cardinality columns (user_id)
Composite:      Frequently combined conditions (org_id, status)
Partial:        Filtered subsets (active = true)
Covering:       Include all selected columns
```

## Common Optimizations

| Problem | Solution |
|---------|----------|
| Slow COUNT | Use estimated count or cache |
| Large IN clauses | Use temporary table or ANY() |
| LIKE '%term%' | Full-text search index |
| Complex sorting | Pre-computed sort columns |
| Frequent aggregations | Materialized views |

## Technology-Specific Patterns

For implementation details, see:
- [Drizzle Queries](../../skills/standards-backend/resources/drizzle.md)
- [Convex Queries](../../skills/standards-backend/resources/convex.md)
- [Database Patterns](../../skills/standards-backend/resources/database-patterns.md)

## Quick Checklist

- [ ] Query has appropriate indexes
- [ ] No N+1 query patterns
- [ ] Pagination implemented correctly
- [ ] Only required columns selected
- [ ] EXPLAIN plan reviewed for complex queries
- [ ] Slow queries logged and monitored
