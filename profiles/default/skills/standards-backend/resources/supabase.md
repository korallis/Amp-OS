# Supabase Patterns

Comprehensive patterns for Supabase with Next.js App Router - the open source Firebase alternative.

## When to Use Supabase

- Full-stack applications needing auth + database + storage
- Projects requiring PostgreSQL with Row Level Security
- Real-time subscription features
- Rapid prototyping with instant APIs

## Client Setup

### Server Client (App Router)

```typescript
// lib/supabase/server.ts
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // Called from Server Component - handled by middleware
          }
        },
      },
    }
  );
}
```

### Browser Client

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

### Middleware (Session Refresh)

```typescript
// middleware.ts
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: { headers: request.headers },
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          response = NextResponse.next({
            request: { headers: request.headers },
          });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  // Refresh session
  await supabase.auth.getUser();

  return response;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

## Type Generation

```bash
# Generate types from your database
npx supabase gen types typescript --project-id your-project-id > lib/supabase/database.types.ts
```

```typescript
// lib/supabase/types.ts
import { Database } from "./database.types";

type Tables = Database["public"]["Tables"];

export type Post = Tables["posts"]["Row"];
export type PostInsert = Tables["posts"]["Insert"];
export type PostUpdate = Tables["posts"]["Update"];

export type User = Tables["users"]["Row"];
```

## Row Level Security (RLS)

### Enable RLS

```sql
-- Enable RLS on tables
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
```

### Common Policies

```sql
-- Users can only view their own data
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users can view their own posts
CREATE POLICY "Users can view own posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create posts
CREATE POLICY "Users can create posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = user_id);

-- Public read access for published posts
CREATE POLICY "Public can view published posts"
  ON posts FOR SELECT
  USING (published = true);
```

### Role-Based Policies

```sql
-- Admin can do everything
CREATE POLICY "Admin full access"
  ON posts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Team members can view team data
CREATE POLICY "Team members can view team data"
  ON team_data FOR SELECT
  USING (
    team_id IN (
      SELECT team_id FROM team_members
      WHERE user_id = auth.uid()
    )
  );
```

## Database Queries

### Server Component Queries

```typescript
// app/posts/page.tsx
import { createClient } from "@/lib/supabase/server";

export default async function PostsPage() {
  const supabase = await createClient();

  const { data: posts, error } = await supabase
    .from("posts")
    .select("*, author:users(name, avatar_url)")
    .order("created_at", { ascending: false })
    .limit(20);

  if (error) throw error;

  return <PostsList posts={posts} />;
}
```

### Client Component Queries

```typescript
"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { Post } from "@/lib/supabase/types";

export function PostsList() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const supabase = createClient();

  useEffect(() => {
    async function fetchPosts() {
      const { data, error } = await supabase
        .from("posts")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) {
        console.error("Error:", error);
      } else {
        setPosts(data);
      }
      setLoading(false);
    }

    fetchPosts();
  }, []);

  if (loading) return <Loading />;
  return <PostsGrid posts={posts} />;
}
```

### Complex Queries

```typescript
// Filtering
const { data } = await supabase
  .from("posts")
  .select("*")
  .eq("status", "published")
  .gte("created_at", "2024-01-01")
  .contains("tags", ["typescript"])
  .order("views", { ascending: false });

// Text search
const { data } = await supabase
  .from("posts")
  .select("*")
  .textSearch("title", "typescript react", { type: "websearch" });

// Pagination
const { data, count } = await supabase
  .from("posts")
  .select("*", { count: "exact" })
  .range(0, 9); // First 10 items

// Nested relations
const { data } = await supabase
  .from("posts")
  .select(`
    *,
    author:users(id, name, avatar_url),
    comments(
      id,
      content,
      user:users(name)
    )
  `)
  .eq("id", postId)
  .single();
```

## Real-Time Subscriptions

```typescript
"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { Post } from "@/lib/supabase/types";

export function RealtimePosts({ initialPosts }: { initialPosts: Post[] }) {
  const [posts, setPosts] = useState(initialPosts);
  const supabase = createClient();

  useEffect(() => {
    const channel = supabase
      .channel("posts-changes")
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "posts",
        },
        (payload) => {
          if (payload.eventType === "INSERT") {
            setPosts((prev) => [payload.new as Post, ...prev]);
          } else if (payload.eventType === "DELETE") {
            setPosts((prev) => prev.filter((p) => p.id !== payload.old.id));
          } else if (payload.eventType === "UPDATE") {
            setPosts((prev) =>
              prev.map((p) =>
                p.id === payload.new.id ? (payload.new as Post) : p
              )
            );
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  return <PostsList posts={posts} />;
}
```

### Filtered Subscriptions

```typescript
// Only subscribe to specific user's posts
const channel = supabase
  .channel("my-posts")
  .on(
    "postgres_changes",
    {
      event: "*",
      schema: "public",
      table: "posts",
      filter: `user_id=eq.${userId}`,
    },
    handleChange
  )
  .subscribe();
```

## Authentication

### OAuth Callback Route

```typescript
// app/auth/callback/route.ts
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      return NextResponse.redirect(new URL(next, request.url));
    }
  }

  return NextResponse.redirect(new URL("/auth/error", request.url));
}
```

### Sign In with OAuth

```typescript
"use client";

import { createClient } from "@/lib/supabase/client";

export function LoginButton() {
  const supabase = createClient();

  const handleLogin = async () => {
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
  };

  return <button onClick={handleLogin}>Sign in with Google</button>;
}
```

### Get Current User

```typescript
// Server Component
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export default async function ProtectedPage() {
  const supabase = await createClient();
  const { data: { user }, error } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  return <Dashboard user={user} />;
}
```

## Storage

### Upload Files

```typescript
"use client";

import { createClient } from "@/lib/supabase/client";

export function FileUpload() {
  const supabase = createClient();

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const fileExt = file.name.split(".").pop();
    const fileName = `${Date.now()}.${fileExt}`;
    const filePath = `uploads/${fileName}`;

    const { data, error } = await supabase.storage
      .from("avatars")
      .upload(filePath, file, {
        cacheControl: "3600",
        upsert: false,
      });

    if (error) {
      console.error("Upload error:", error);
    } else {
      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from("avatars")
        .getPublicUrl(filePath);
      
      console.log("Uploaded:", publicUrl);
    }
  };

  return <input type="file" onChange={handleUpload} />;
}
```

### Storage Policies

```sql
-- Allow authenticated users to upload to their folder
CREATE POLICY "Users can upload to own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow public read access
CREATE POLICY "Public read access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');
```

## Server Actions

```typescript
// actions/posts.ts
"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function createPost(formData: FormData) {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("Unauthorized");

  const { data, error } = await supabase
    .from("posts")
    .insert({
      title: formData.get("title") as string,
      content: formData.get("content") as string,
      user_id: user.id,
    })
    .select()
    .single();

  if (error) throw error;

  revalidatePath("/posts");
  return data;
}

export async function deletePost(postId: string) {
  const supabase = await createClient();

  const { error } = await supabase
    .from("posts")
    .delete()
    .eq("id", postId);

  if (error) throw error;

  revalidatePath("/posts");
}
```

## Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...

# Server-only (for admin operations)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIs...
```

## Best Practices

### Do's

- Always use RLS policies for data security
- Generate and use TypeScript types
- Use the middleware for session refresh
- Create indexes for frequently queried columns
- Use server client in Server Components

### Don'ts

- Never expose `SUPABASE_SERVICE_ROLE_KEY` to the client
- Don't disable RLS in production
- Don't use `service_role` key in client code
- Don't skip the auth.getUser() check in protected routes
