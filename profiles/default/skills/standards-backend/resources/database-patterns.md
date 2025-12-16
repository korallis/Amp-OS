# Database Patterns

## Schema Design

### Naming Conventions
- Tables: plural, snake_case (`users`, `order_items`)
- Columns: singular, snake_case (`created_at`, `user_id`)
- Primary keys: `id` (prefer UUID for distributed systems)
- Foreign keys: `<singular_table>_id` (`user_id`, `order_id`)
- Indexes: `idx_<table>_<columns>` (`idx_users_email`)

### Required Columns
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- ... other columns ...
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Query Patterns

### Pagination
```sql
-- Cursor-based (preferred for large datasets)
SELECT * FROM orders
WHERE created_at < :cursor
ORDER BY created_at DESC
LIMIT 20;

-- Offset-based (simpler, fine for small datasets)
SELECT * FROM users
ORDER BY id
LIMIT 20 OFFSET 40;
```

### Avoiding N+1 Queries
```sql
-- Bad: Query per user
SELECT * FROM users;
-- Then for each user: SELECT * FROM orders WHERE user_id = ?

-- Good: Single query with join
SELECT u.*, o.*
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.id IN (:user_ids);
```

### Soft Deletes
```sql
-- Add column
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP WITH TIME ZONE;

-- Query active records
SELECT * FROM users WHERE deleted_at IS NULL;

-- "Delete" record
UPDATE users SET deleted_at = NOW() WHERE id = :id;
```

## Indexing Guidelines

**Index when**:
- Column used in WHERE clauses frequently
- Column used in JOIN conditions
- Column used in ORDER BY
- Foreign key columns

**Composite indexes**:
```sql
-- Order matters: leftmost columns used first
CREATE INDEX idx_orders_user_status 
ON orders (user_id, status);

-- Supports: WHERE user_id = ? AND status = ?
-- Supports: WHERE user_id = ?
-- Does NOT support: WHERE status = ?
```

## Transactions

```javascript
// Use transactions for multi-step operations
async function transferFunds(fromId, toId, amount) {
  return await db.transaction(async (trx) => {
    await trx('accounts')
      .where('id', fromId)
      .decrement('balance', amount);
    
    await trx('accounts')
      .where('id', toId)
      .increment('balance', amount);
    
    await trx('transfers').insert({
      from_account_id: fromId,
      to_account_id: toId,
      amount,
    });
  });
}
```

## Migrations

```javascript
// Up: Apply change
exports.up = async (knex) => {
  await knex.schema.createTable('users', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.string('email').notNullable().unique();
    t.timestamps(true, true);
  });
};

// Down: Reverse change (must be reversible)
exports.down = async (knex) => {
  await knex.schema.dropTable('users');
};
```

## Connection Management

```javascript
const pool = {
  min: 2,
  max: 10,
  acquireTimeoutMillis: 30000,
  idleTimeoutMillis: 30000,
};

// Always release connections
const client = await pool.connect();
try {
  return await client.query(sql);
} finally {
  client.release();
}
```
