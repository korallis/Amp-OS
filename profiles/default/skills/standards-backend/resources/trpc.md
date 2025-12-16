# tRPC Patterns

Comprehensive patterns for tRPC with Next.js App Router - end-to-end type-safe APIs.

## When to Use tRPC

- Full-stack TypeScript applications
- Projects needing type-safe API calls
- Teams wanting to avoid REST/GraphQL boilerplate
- Rapid API development with automatic type inference

## Setup

### Installation

```bash
npm install @trpc/server @trpc/client @trpc/react-query @tanstack/react-query superjson zod
```

### Server Setup

```typescript
// server/trpc/init.ts
import { initTRPC, TRPCError } from "@trpc/server";
import superjson from "superjson";
import { ZodError } from "zod";
import { auth } from "@clerk/nextjs/server";
import { db } from "@/db";

export const createTRPCContext = async (opts: { headers: Headers }) => {
  const { userId } = await auth();

  return {
    db,
    userId,
    headers: opts.headers,
  };
};

const t = initTRPC.context<typeof createTRPCContext>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    };
  },
});

export const router = t.router;
export const publicProcedure = t.procedure;

// Auth middleware
const enforceAuth = t.middleware(async ({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: "UNAUTHORIZED" });
  }
  return next({
    ctx: {
      userId: ctx.userId,
    },
  });
});

export const protectedProcedure = t.procedure.use(enforceAuth);
```

### Router Definition

```typescript
// server/trpc/routers/post.ts
import { z } from "zod";
import { router, publicProcedure, protectedProcedure } from "../init";
import { posts } from "@/db/schema";
import { eq, desc } from "drizzle-orm";

export const postRouter = router({
  // Public query
  list: publicProcedure
    .input(
      z.object({
        limit: z.number().min(1).max(100).default(20),
        cursor: z.string().optional(),
      })
    )
    .query(async ({ ctx, input }) => {
      const items = await ctx.db.query.posts.findMany({
        limit: input.limit + 1,
        orderBy: [desc(posts.createdAt)],
        where: input.cursor
          ? (posts, { lt }) => lt(posts.id, input.cursor!)
          : undefined,
      });

      let nextCursor: string | undefined;
      if (items.length > input.limit) {
        const nextItem = items.pop();
        nextCursor = nextItem?.id;
      }

      return { items, nextCursor };
    }),

  // Public query by ID
  byId: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const post = await ctx.db.query.posts.findFirst({
        where: eq(posts.id, input.id),
        with: { author: true },
      });

      if (!post) {
        throw new TRPCError({ code: "NOT_FOUND" });
      }

      return post;
    }),

  // Protected mutation
  create: protectedProcedure
    .input(
      z.object({
        title: z.string().min(1).max(200),
        content: z.string().min(1),
      })
    )
    .mutation(async ({ ctx, input }) => {
      const [post] = await ctx.db
        .insert(posts)
        .values({
          ...input,
          authorId: ctx.userId,
        })
        .returning();

      return post;
    }),

  // Protected mutation with authorization
  delete: protectedProcedure
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const post = await ctx.db.query.posts.findFirst({
        where: eq(posts.id, input.id),
      });

      if (!post) {
        throw new TRPCError({ code: "NOT_FOUND" });
      }

      if (post.authorId !== ctx.userId) {
        throw new TRPCError({ code: "FORBIDDEN" });
      }

      await ctx.db.delete(posts).where(eq(posts.id, input.id));

      return { success: true };
    }),
});
```

### App Router Handler

```typescript
// server/trpc/routers/_app.ts
import { router } from "../init";
import { postRouter } from "./post";
import { userRouter } from "./user";

export const appRouter = router({
  post: postRouter,
  user: userRouter,
});

export type AppRouter = typeof appRouter;
```

```typescript
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from "@trpc/server/adapters/fetch";
import { appRouter } from "@/server/trpc/routers/_app";
import { createTRPCContext } from "@/server/trpc/init";

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: "/api/trpc",
    req,
    router: appRouter,
    createContext: () => createTRPCContext({ headers: req.headers }),
    onError: ({ path, error }) => {
      console.error(`❌ tRPC failed on ${path}:`, error);
    },
  });

export { handler as GET, handler as POST };
```

## Client Setup

### React Query Provider

```typescript
// trpc/client.tsx
"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { httpBatchLink } from "@trpc/client";
import { createTRPCReact } from "@trpc/react-query";
import { useState } from "react";
import superjson from "superjson";
import type { AppRouter } from "@/server/trpc/routers/_app";

export const trpc = createTRPCReact<AppRouter>();

function getBaseUrl() {
  if (typeof window !== "undefined") return "";
  if (process.env.VERCEL_URL) return `https://${process.env.VERCEL_URL}`;
  return "http://localhost:3000";
}

export function TRPCProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 5 * 1000,
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  const [trpcClient] = useState(() =>
    trpc.createClient({
      links: [
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
          transformer: superjson,
        }),
      ],
    })
  );

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </trpc.Provider>
  );
}
```

### Root Layout

```typescript
// app/layout.tsx
import { TRPCProvider } from "@/trpc/client";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <TRPCProvider>{children}</TRPCProvider>
      </body>
    </html>
  );
}
```

## Client Usage

### Queries

```typescript
"use client";

import { trpc } from "@/trpc/client";

export function PostList() {
  const { data, isLoading, error } = trpc.post.list.useQuery({
    limit: 20,
  });

  if (isLoading) return <Loading />;
  if (error) return <Error message={error.message} />;

  return (
    <ul>
      {data?.items.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

### Mutations with Optimistic Updates

```typescript
"use client";

import { trpc } from "@/trpc/client";

export function CreatePostForm() {
  const utils = trpc.useUtils();
  
  const createPost = trpc.post.create.useMutation({
    onMutate: async (newPost) => {
      await utils.post.list.cancel();
      
      const previous = utils.post.list.getData();
      
      utils.post.list.setData({ limit: 20 }, (old) => ({
        ...old,
        items: [
          { id: "temp", ...newPost, createdAt: new Date() },
          ...(old?.items ?? []),
        ],
      }));
      
      return { previous };
    },
    onError: (err, newPost, context) => {
      utils.post.list.setData({ limit: 20 }, context?.previous);
    },
    onSettled: () => {
      utils.post.list.invalidate();
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    
    createPost.mutate({
      title: formData.get("title") as string,
      content: formData.get("content") as string,
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit" disabled={createPost.isPending}>
        {createPost.isPending ? "Creating..." : "Create Post"}
      </button>
    </form>
  );
}
```

### Infinite Queries

```typescript
"use client";

import { trpc } from "@/trpc/client";

export function InfinitePostList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = trpc.post.list.useInfiniteQuery(
    { limit: 20 },
    {
      getNextPageParam: (lastPage) => lastPage.nextCursor,
    }
  );

  return (
    <div>
      {data?.pages.map((page) =>
        page.items.map((post) => <PostCard key={post.id} post={post} />)
      )}
      
      {hasNextPage && (
        <button
          onClick={() => fetchNextPage()}
          disabled={isFetchingNextPage}
        >
          {isFetchingNextPage ? "Loading..." : "Load More"}
        </button>
      )}
    </div>
  );
}
```

## Server-Side Usage

### Server Components

```typescript
// trpc/server.ts
import { appRouter } from "@/server/trpc/routers/_app";
import { createTRPCContext } from "@/server/trpc/init";
import { headers } from "next/headers";

export const createCaller = async () => {
  const context = await createTRPCContext({
    headers: await headers(),
  });
  return appRouter.createCaller(context);
};
```

```typescript
// app/posts/page.tsx
import { createCaller } from "@/trpc/server";

export default async function PostsPage() {
  const trpc = await createCaller();
  
  const { items } = await trpc.post.list({ limit: 20 });

  return (
    <ul>
      {items.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

### Server Actions with tRPC

```typescript
// actions/posts.ts
"use server";

import { createCaller } from "@/trpc/server";
import { revalidatePath } from "next/cache";

export async function createPost(formData: FormData) {
  const trpc = await createCaller();

  await trpc.post.create({
    title: formData.get("title") as string,
    content: formData.get("content") as string,
  });

  revalidatePath("/posts");
}
```

## Error Handling

### Custom Error Codes

```typescript
import { TRPCError } from "@trpc/server";

// In procedure
if (!post) {
  throw new TRPCError({
    code: "NOT_FOUND",
    message: "Post not found",
  });
}

if (post.authorId !== ctx.userId) {
  throw new TRPCError({
    code: "FORBIDDEN",
    message: "You can only edit your own posts",
  });
}
```

### Client Error Handling

```typescript
const createPost = trpc.post.create.useMutation({
  onError: (error) => {
    if (error.data?.zodError) {
      // Handle validation errors
      const fieldErrors = error.data.zodError.fieldErrors;
      console.log(fieldErrors);
    } else {
      // Handle other errors
      toast.error(error.message);
    }
  },
});
```

## Middleware

### Rate Limiting

```typescript
// server/trpc/middleware/rateLimit.ts
import { TRPCError } from "@trpc/server";
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "10 s"),
});

export const rateLimitMiddleware = t.middleware(async ({ ctx, next }) => {
  const identifier = ctx.userId ?? ctx.headers.get("x-forwarded-for") ?? "anonymous";
  
  const { success } = await ratelimit.limit(identifier);
  
  if (!success) {
    throw new TRPCError({
      code: "TOO_MANY_REQUESTS",
      message: "Rate limit exceeded",
    });
  }
  
  return next();
});

export const rateLimitedProcedure = t.procedure.use(rateLimitMiddleware);
```

### Logging

```typescript
const loggerMiddleware = t.middleware(async ({ path, type, next }) => {
  const start = Date.now();
  const result = await next();
  const duration = Date.now() - start;
  
  console.log(`${type} ${path} - ${duration}ms`);
  
  return result;
});
```

## Best Practices

### Do's

- Use Zod for input validation
- Create separate routers per domain
- Use superjson for Date/Map/Set serialization
- Implement proper error handling
- Use optimistic updates for better UX

### Don'ts

- Don't expose sensitive data through procedures
- Don't skip input validation
- Don't use tRPC for public APIs (use REST/GraphQL)
- Don't forget to handle loading/error states
- Don't mutate cache directly without invalidation
