# Drizzle ORM Patterns

Comprehensive patterns for Drizzle ORM with PostgreSQL - the TypeScript ORM with maximum type safety.

## When to Use Drizzle

- Serverless/Edge deployments (Neon, Vercel Postgres)
- Projects requiring maximum type safety
- High-performance query requirements
- Teams preferring SQL-like syntax over abstraction

## Schema Definition

### Basic Tables with Relations

```typescript
// db/schema.ts
import {
  pgTable,
  pgEnum,
  uuid,
  text,
  timestamp,
  boolean,
  integer,
  varchar,
  jsonb,
  index,
  uniqueIndex,
} from "drizzle-orm/pg-core";
import { relations, sql } from "drizzle-orm";

// Enums
export const userRoleEnum = pgEnum("user_role", ["admin", "editor", "viewer"]);
export const postStatusEnum = pgEnum("post_status", ["draft", "published", "archived"]);

// Reusable timestamp columns
const timestamps = {
  createdAt: timestamp("created_at", { mode: "date", withTimezone: true })
    .defaultNow()
    .notNull(),
  updatedAt: timestamp("updated_at", { mode: "date", withTimezone: true })
    .defaultNow()
    .notNull()
    .$onUpdateFn(() => new Date()),
};

// Users table
export const users = pgTable(
  "users",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    email: varchar("email", { length: 320 }).notNull().unique(),
    name: varchar("name", { length: 100 }).notNull(),
    role: userRoleEnum("role").notNull().default("viewer"),
    avatarUrl: text("avatar_url"),
    stripeCustomerId: text("stripe_customer_id"),
    preferences: jsonb("preferences").$type<UserPreferences>(),
    isActive: boolean("is_active").default(true).notNull(),
    ...timestamps,
  },
  (table) => [
    uniqueIndex("users_email_unique").on(table.email),
    index("users_active_idx").on(table.isActive).where(sql`${table.isActive} = true`),
  ]
);

// Posts table
export const posts = pgTable(
  "posts",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    title: varchar("title", { length: 255 }).notNull(),
    content: text("content").notNull(),
    status: postStatusEnum("status").notNull().default("draft"),
    authorId: uuid("author_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    publishedAt: timestamp("published_at", { mode: "date", withTimezone: true }),
    ...timestamps,
  },
  (table) => [
    index("posts_author_idx").on(table.authorId),
    index("posts_published_idx")
      .on(table.publishedAt)
      .where(sql`${table.status} = 'published'`),
  ]
);

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}));

// Type inference
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type Post = typeof posts.$inferSelect;
export type NewPost = typeof posts.$inferInsert;

// Custom types
interface UserPreferences {
  theme: "light" | "dark";
  notifications: boolean;
  language: string;
}
```

### Many-to-Many Relations

```typescript
// Tags table
export const tags = pgTable("tags", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: varchar("name", { length: 50 }).notNull().unique(),
  slug: varchar("slug", { length: 50 }).notNull().unique(),
});

// Junction table
export const postsToTags = pgTable(
  "posts_to_tags",
  {
    postId: uuid("post_id")
      .notNull()
      .references(() => posts.id, { onDelete: "cascade" }),
    tagId: uuid("tag_id")
      .notNull()
      .references(() => tags.id, { onDelete: "cascade" }),
  },
  (table) => [
    primaryKey({ columns: [table.postId, table.tagId] }),
  ]
);

// Relations for many-to-many
export const postsRelations = relations(posts, ({ one, many }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
  postsToTags: many(postsToTags),
}));

export const tagsRelations = relations(tags, ({ many }) => ({
  postsToTags: many(postsToTags),
}));

export const postsToTagsRelations = relations(postsToTags, ({ one }) => ({
  post: one(posts, {
    fields: [postsToTags.postId],
    references: [posts.id],
  }),
  tag: one(tags, {
    fields: [postsToTags.tagId],
    references: [tags.id],
  }),
}));
```

## Database Client Setup

### Neon Serverless (Edge)

```typescript
// db/index.ts
import { drizzle } from "drizzle-orm/neon-http";
import { neon } from "@neondatabase/serverless";
import * as schema from "./schema";

const sql = neon(process.env.DATABASE_URL!);

export const db = drizzle(sql, { schema });
```

### Neon with Connection Pool (Node.js)

```typescript
// db/index.ts
import { drizzle } from "drizzle-orm/neon-serverless";
import { Pool } from "@neondatabase/serverless";
import * as schema from "./schema";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export const db = drizzle(pool, { schema });
```

### Node Postgres (Traditional)

```typescript
// db/index.ts
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import * as schema from "./schema";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
});

export const db = drizzle(pool, { schema });
```

## Query Patterns

### Basic Queries

```typescript
import { db } from "@/db";
import { users, posts } from "@/db/schema";
import { eq, and, or, like, desc, asc, isNull } from "drizzle-orm";

// Select all
const allUsers = await db.select().from(users);

// Select with conditions
const activeUsers = await db
  .select()
  .from(users)
  .where(eq(users.isActive, true));

// Select specific columns
const userEmails = await db
  .select({ id: users.id, email: users.email })
  .from(users);

// Complex conditions
const filteredPosts = await db
  .select()
  .from(posts)
  .where(
    and(
      eq(posts.status, "published"),
      or(
        like(posts.title, "%TypeScript%"),
        like(posts.title, "%React%")
      )
    )
  )
  .orderBy(desc(posts.publishedAt))
  .limit(10);
```

### Relational Queries

```typescript
// Get user with all their posts
const userWithPosts = await db.query.users.findFirst({
  where: eq(users.id, userId),
  with: {
    posts: {
      where: eq(posts.status, "published"),
      orderBy: [desc(posts.createdAt)],
      limit: 10,
    },
  },
});

// Get post with author and tags
const postWithDetails = await db.query.posts.findFirst({
  where: eq(posts.id, postId),
  with: {
    author: true,
    postsToTags: {
      with: {
        tag: true,
      },
    },
  },
});
```

### Joins

```typescript
// Inner join
const postsWithAuthors = await db
  .select({
    post: posts,
    author: users,
  })
  .from(posts)
  .innerJoin(users, eq(posts.authorId, users.id));

// Left join
const usersWithPostCount = await db
  .select({
    user: users,
    postCount: sql<number>`count(${posts.id})::int`,
  })
  .from(users)
  .leftJoin(posts, eq(users.id, posts.authorId))
  .groupBy(users.id);
```

### Aggregations

```typescript
import { count, sum, avg, min, max } from "drizzle-orm";

// Count
const totalUsers = await db
  .select({ count: count() })
  .from(users);

// Group by with aggregation
const postsByStatus = await db
  .select({
    status: posts.status,
    count: count(),
  })
  .from(posts)
  .groupBy(posts.status);
```

## Mutation Patterns

### Insert

```typescript
// Insert single
const [newUser] = await db
  .insert(users)
  .values({
    email: "user@example.com",
    name: "John Doe",
  })
  .returning();

// Insert multiple
const newPosts = await db
  .insert(posts)
  .values([
    { title: "Post 1", content: "...", authorId: userId },
    { title: "Post 2", content: "...", authorId: userId },
  ])
  .returning();

// Insert with conflict handling (upsert)
await db
  .insert(users)
  .values({ email: "user@example.com", name: "Updated Name" })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: "Updated Name", updatedAt: new Date() },
  });
```

### Update

```typescript
// Update with conditions
await db
  .update(posts)
  .set({
    status: "published",
    publishedAt: new Date(),
  })
  .where(and(
    eq(posts.id, postId),
    eq(posts.authorId, userId)
  ));

// Update with returning
const [updatedPost] = await db
  .update(posts)
  .set({ title: "New Title" })
  .where(eq(posts.id, postId))
  .returning();
```

### Delete

```typescript
// Delete with conditions
await db
  .delete(posts)
  .where(eq(posts.id, postId));

// Delete with returning
const [deletedPost] = await db
  .delete(posts)
  .where(eq(posts.id, postId))
  .returning();
```

### Transactions

```typescript
// Transaction with multiple operations
const result = await db.transaction(async (tx) => {
  const [user] = await tx
    .insert(users)
    .values({ email: "new@example.com", name: "New User" })
    .returning();

  const [post] = await tx
    .insert(posts)
    .values({
      title: "Welcome Post",
      content: "Hello!",
      authorId: user.id,
    })
    .returning();

  return { user, post };
});

// Transaction with rollback on error
try {
  await db.transaction(async (tx) => {
    await tx.insert(users).values({ ... });
    await tx.insert(posts).values({ ... });
    
    // If this throws, everything rolls back
    if (someCondition) {
      throw new Error("Rollback");
    }
  });
} catch (error) {
  console.error("Transaction failed:", error);
}
```

## Migrations

### Configuration

```typescript
// drizzle.config.ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./db/schema.ts",
  out: "./db/migrations",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

### Commands

```bash
# Generate migration from schema changes
npx drizzle-kit generate

# Apply migrations to database
npx drizzle-kit migrate

# Push schema directly (development only)
npx drizzle-kit push

# Open Drizzle Studio
npx drizzle-kit studio
```

### Migration Script

```typescript
// scripts/migrate.ts
import { drizzle } from "drizzle-orm/neon-http";
import { migrate } from "drizzle-orm/neon-http/migrator";
import { neon } from "@neondatabase/serverless";

const sql = neon(process.env.DATABASE_URL!);
const db = drizzle(sql);

async function runMigrations() {
  console.log("Running migrations...");
  await migrate(db, { migrationsFolder: "./db/migrations" });
  console.log("Migrations completed!");
  process.exit(0);
}

runMigrations().catch((err) => {
  console.error("Migration failed!", err);
  process.exit(1);
});
```

## Server Actions Integration

```typescript
// actions/posts.ts
"use server";

import { db } from "@/db";
import { posts } from "@/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";
import { auth } from "@clerk/nextjs/server";

export async function createPost(formData: FormData) {
  const { userId } = await auth();
  if (!userId) throw new Error("Unauthorized");

  const title = formData.get("title") as string;
  const content = formData.get("content") as string;

  const [post] = await db
    .insert(posts)
    .values({
      title,
      content,
      authorId: userId,
    })
    .returning();

  revalidatePath("/posts");
  return post;
}

export async function deletePost(postId: string) {
  const { userId } = await auth();
  if (!userId) throw new Error("Unauthorized");

  await db
    .delete(posts)
    .where(and(
      eq(posts.id, postId),
      eq(posts.authorId, userId)
    ));

  revalidatePath("/posts");
}
```

## Best Practices

### Do's

- Define relations for complex queries
- Use typed JSON columns with `$type<T>()`
- Create indexes for frequently queried columns
- Use transactions for multi-table operations
- Infer types with `$inferSelect` and `$inferInsert`

### Don'ts

- Don't skip migrations in production (use `push` only in dev)
- Don't use `sql` template without parameterization for user input
- Don't forget to handle nullable fields in TypeScript
- Don't create circular references in relations
