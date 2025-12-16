# Convex Patterns

Comprehensive patterns for Convex - the reactive backend platform with real-time sync.

## When to Use Convex

- Real-time collaborative applications
- Apps requiring automatic sync across clients
- Projects needing type-safe backend with zero boilerplate
- Serverless applications with complex data relationships

## Schema Definition

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    imageUrl: v.optional(v.string()),
    subscription: v.optional(v.object({
      plan: v.union(v.literal("free"), v.literal("pro"), v.literal("team")),
      stripeCustomerId: v.optional(v.string()),
      expiresAt: v.optional(v.number()),
    })),
  })
    .index("by_clerk_id", ["clerkId"])
    .index("by_email", ["email"]),

  projects: defineTable({
    userId: v.id("users"),
    name: v.string(),
    description: v.optional(v.string()),
    status: v.union(
      v.literal("draft"),
      v.literal("active"),
      v.literal("archived")
    ),
    settings: v.object({
      isPublic: v.boolean(),
      allowComments: v.boolean(),
    }),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_user", ["userId"])
    .index("by_status", ["status"]),

  documents: defineTable({
    projectId: v.id("projects"),
    title: v.string(),
    content: v.string(),
    embedding: v.optional(v.array(v.float64())),
  })
    .index("by_project", ["projectId"])
    .vectorIndex("by_embedding", {
      vectorField: "embedding",
      dimensions: 1536,
      filterFields: ["projectId"],
    }),
});
```

## Validators Reference

| Convex Type | TypeScript Type | Validator | Notes |
|-------------|-----------------|-----------|-------|
| Id | string | `v.id(tableName)` | Document reference |
| Null | null | `v.null()` | Use instead of undefined |
| Int64 | bigint | `v.int64()` | Signed 64-bit integers |
| Float64 | number | `v.number()` | IEEE-754 doubles |
| Boolean | boolean | `v.boolean()` | |
| String | string | `v.string()` | UTF-8, max 1MB |
| Bytes | ArrayBuffer | `v.bytes()` | Max 1MB |
| Array | Array | `v.array(values)` | Max 8192 items |
| Object | Object | `v.object({...})` | Max 1024 fields |
| Record | Record | `v.record(keys, values)` | Dynamic keys |

## Query Patterns

### Basic Query with Index

```typescript
// convex/projects.ts
import { query } from "./_generated/server";
import { v } from "convex/values";

export const list = query({
  args: {
    status: v.optional(v.union(
      v.literal("draft"),
      v.literal("active"),
      v.literal("archived")
    )),
  },
  returns: v.array(v.object({
    _id: v.id("projects"),
    name: v.string(),
    status: v.string(),
  })),
  handler: async (ctx, args) => {
    let query = ctx.db.query("projects");
    
    if (args.status) {
      query = query.withIndex("by_status", (q) => q.eq("status", args.status));
    }
    
    return await query.order("desc").take(50);
  },
});
```

### Paginated Query

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";
import { paginationOptsValidator } from "convex/server";

export const listPaginated = query({
  args: {
    paginationOpts: paginationOptsValidator,
    author: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("messages");
    
    if (args.author) {
      query = query.filter((q) => q.eq(q.field("author"), args.author));
    }
    
    return await query.order("desc").paginate(args.paginationOpts);
  },
});
```

### Query with Relations

```typescript
export const getWithRelations = query({
  args: { projectId: v.id("projects") },
  handler: async (ctx, args) => {
    const project = await ctx.db.get(args.projectId);
    if (!project) return null;
    
    const documents = await ctx.db
      .query("documents")
      .withIndex("by_project", (q) => q.eq("projectId", args.projectId))
      .collect();
    
    const user = await ctx.db.get(project.userId);
    
    return { ...project, documents, user };
  },
});
```

## Mutation Patterns

### Basic Mutation with Validation

```typescript
// convex/projects.ts
import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const create = mutation({
  args: {
    name: v.string(),
    description: v.optional(v.string()),
    isPublic: v.optional(v.boolean()),
  },
  returns: v.id("projects"),
  handler: async (ctx, args) => {
    // Validate name length
    if (args.name.length < 1 || args.name.length > 100) {
      throw new Error("Name must be 1-100 characters");
    }

    const now = Date.now();
    
    return await ctx.db.insert("projects", {
      userId: "placeholder", // Replace with auth
      name: args.name,
      description: args.description,
      status: "draft",
      settings: {
        isPublic: args.isPublic ?? false,
        allowComments: true,
      },
      createdAt: now,
      updatedAt: now,
    });
  },
});
```

### Mutation with Authentication

```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";
import { getAuthUserId } from "@convex-dev/auth/server";

export const update = mutation({
  args: {
    id: v.id("projects"),
    name: v.optional(v.string()),
    status: v.optional(v.union(
      v.literal("draft"),
      v.literal("active"),
      v.literal("archived")
    )),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthorized");

    const project = await ctx.db.get(args.id);
    if (!project) throw new Error("Not found");

    // Authorization check
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", userId))
      .unique();
    
    if (project.userId !== user?._id) {
      throw new Error("Forbidden");
    }

    const { id, ...updates } = args;
    
    await ctx.db.patch(id, {
      ...updates,
      updatedAt: Date.now(),
    });
    
    return null;
  },
});
```

### Transaction with Rollback

```typescript
export const trySendMessage = mutation({
  args: {
    body: v.string(),
    author: v.string(),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    try {
      await ctx.runMutation(internal.messages.sendMessage, args);
    } catch (e) {
      // Record the failure, but rollback any writes from `sendMessage`
      await ctx.db.insert("failures", {
        kind: "MessageFailed",
        body: args.body,
        author: args.author,
        error: `Error: ${e}`,
      });
    }
    return null;
  },
});
```

## Internal Functions

```typescript
// convex/internal/users.ts
import { internalMutation, internalQuery } from "../_generated/server";
import { v } from "convex/values";

// Called from webhooks or scheduled jobs - not exposed to clients
export const syncFromClerk = internalMutation({
  args: {
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
  },
  returns: v.id("users"),
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", args.clerkId))
      .unique();
    
    if (existing) {
      await ctx.db.patch(existing._id, {
        email: args.email,
        name: args.name,
      });
      return existing._id;
    }
    
    return await ctx.db.insert("users", args);
  },
});
```

## HTTP Actions

```typescript
// convex/http.ts
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";

const http = httpRouter();

http.route({
  path: "/webhooks/clerk",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    
    // Verify webhook signature here
    
    await ctx.runMutation(internal.users.syncFromClerk, {
      clerkId: body.data.id,
      email: body.data.email_addresses[0].email_address,
      name: `${body.data.first_name} ${body.data.last_name}`,
    });
    
    return new Response(null, { status: 200 });
  }),
});

export default http;
```

## Client-Side Usage

### React Hooks

```tsx
'use client';

import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function ProjectList() {
  const projects = useQuery(api.projects.list, { status: "active" });
  const createProject = useMutation(api.projects.create);
  
  if (!projects) return <Loading />;
  
  const handleCreate = async () => {
    await createProject({ name: "New Project" });
  };
  
  return (
    <div>
      <button onClick={handleCreate}>Create Project</button>
      {projects.map((project) => (
        <ProjectCard key={project._id} project={project} />
      ))}
    </div>
  );
}
```

### Paginated Data

```tsx
'use client';

import { usePaginatedQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function MessageList() {
  const { results, status, loadMore } = usePaginatedQuery(
    api.messages.listPaginated,
    {},
    { initialNumItems: 20 }
  );
  
  return (
    <div>
      {results.map((message) => (
        <Message key={message._id} message={message} />
      ))}
      {status === "CanLoadMore" && (
        <button onClick={() => loadMore(20)}>Load More</button>
      )}
      {status === "LoadingMore" && <Loading />}
    </div>
  );
}
```

## TypeScript Helpers

```typescript
import { FunctionReturnType } from "convex/server";
import { UsePaginatedQueryReturnType } from "convex/react";
import { api } from "../convex/_generated/api";
import { Doc, Id } from "../convex/_generated/dataModel";

// Type for document
type Project = Doc<"projects">;

// Type for ID
type ProjectId = Id<"projects">;

// Type for function return
type ProjectListResult = FunctionReturnType<typeof api.projects.list>;

// Component props using inferred types
function ProjectCard({ project }: { project: Doc<"projects"> }) {
  return <div>{project.name}</div>;
}
```

## Best Practices

### Do's

- Always include `returns` validator for all functions
- Use indexes for filtered queries
- Use `internalMutation`/`internalQuery` for server-to-server calls
- Keep functions focused and composable
- Use `ctx.runQuery`/`ctx.runMutation` for function composition

### Don'ts

- Don't use `.filter()` without an index (use `withIndex` instead)
- Don't return `undefined` (use `null` instead)
- Don't expose sensitive operations via `mutation` (use `internalMutation`)
- Don't chain many `ctx.run*` calls (each is a transaction)
