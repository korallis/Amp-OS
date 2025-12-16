# Frontend Component Patterns

Comprehensive patterns for modern React/Next.js frontend development.

## React 19 Patterns

### use() Hook for Async Data

```tsx
import { use, Suspense } from 'react';

// Promise that can be passed to use()
const userPromise = fetch('/api/user').then(res => res.json());

function UserProfile() {
  const user = use(userPromise);
  return <div>{user.name}</div>;
}

export function Page() {
  return (
    <Suspense fallback={<UserSkeleton />}>
      <UserProfile />
    </Suspense>
  );
}
```

### useOptimistic for Instant UI

```tsx
'use client';

import { useOptimistic } from 'react';
import { updateTodo } from '@/actions/todos';

interface Todo {
  id: string;
  text: string;
  completed: boolean;
}

export function TodoItem({ todo }: { todo: Todo }) {
  const [optimisticTodo, setOptimisticTodo] = useOptimistic(
    todo,
    (current, completed: boolean) => ({ ...current, completed })
  );
  
  const toggleTodo = async () => {
    setOptimisticTodo(!optimisticTodo.completed);
    await updateTodo(todo.id, !todo.completed);
  };
  
  return (
    <div className={optimisticTodo.completed ? 'line-through opacity-50' : ''}>
      <input
        type="checkbox"
        checked={optimisticTodo.completed}
        onChange={toggleTodo}
      />
      {optimisticTodo.text}
    </div>
  );
}
```

### useTransition for Non-Blocking Updates

```tsx
'use client';

import { useState, useTransition } from 'react';

export function SearchResults() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<string[]>([]);
  const [isPending, startTransition] = useTransition();
  
  const handleSearch = (value: string) => {
    setQuery(value);
    
    startTransition(async () => {
      const data = await searchAPI(value);
      setResults(data);
    });
  };
  
  return (
    <div>
      <input 
        value={query} 
        onChange={(e) => handleSearch(e.target.value)} 
      />
      {isPending && <Spinner />}
      <ul>
        {results.map((result) => (
          <li key={result}>{result}</li>
        ))}
      </ul>
    </div>
  );
}
```

## Data Fetching Patterns

### Parallel Data Fetching

```tsx
// app/dashboard/page.tsx
async function DashboardPage() {
  // Parallel fetching - all start at the same time
  const [user, stats, notifications] = await Promise.all([
    getUser(),
    getStats(),
    getNotifications(),
  ]);
  
  return (
    <Dashboard 
      user={user} 
      stats={stats} 
      notifications={notifications} 
    />
  );
}
```

### Streaming with Suspense

```tsx
// app/product/[id]/page.tsx
import { Suspense } from 'react';

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id);
  
  return (
    <div>
      <ProductHeader product={product} />
      
      {/* Stream in reviews as they load */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews productId={params.id} />
      </Suspense>
      
      {/* Stream in recommendations */}
      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations productId={params.id} />
      </Suspense>
    </div>
  );
}

async function ProductReviews({ productId }: { productId: string }) {
  const reviews = await getReviews(productId); // Can be slow
  return <ReviewsList reviews={reviews} />;
}
```

### Error Boundaries

```tsx
// app/dashboard/error.tsx
'use client';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[400px]">
      <h2 className="text-2xl font-bold text-destructive">
        Something went wrong!
      </h2>
      <p className="text-muted-foreground mt-2">
        {error.message || 'An unexpected error occurred'}
      </p>
      <button
        onClick={reset}
        className="mt-4 px-4 py-2 bg-primary text-primary-foreground rounded-md"
      >
        Try again
      </button>
    </div>
  );
}
```

## Form Patterns

### Form with Zod Validation

```tsx
// schemas/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email('Invalid email address'),
  name: z.string().min(2, 'Name must be at least 2 characters'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain an uppercase letter')
    .regex(/[0-9]/, 'Password must contain a number'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;

// actions/user.ts
'use server';

import { CreateUserSchema } from '@/schemas/user';

export async function createUser(prevState: any, formData: FormData) {
  const raw = {
    email: formData.get('email'),
    name: formData.get('name'),
    password: formData.get('password'),
    confirmPassword: formData.get('confirmPassword'),
  };
  
  const result = CreateUserSchema.safeParse(raw);
  
  if (!result.success) {
    return {
      success: false,
      errors: result.error.flatten().fieldErrors,
    };
  }
  
  // Create user
  await db.user.create({ data: result.data });
  
  return { success: true, errors: null };
}

// components/create-user-form.tsx
'use client';

import { useActionState } from 'react';
import { createUser } from '@/actions/user';

export function CreateUserForm() {
  const [state, action, pending] = useActionState(createUser, {
    success: false,
    errors: null,
  });
  
  return (
    <form action={action} className="space-y-4">
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          aria-invalid={!!state.errors?.email}
          aria-describedby={state.errors?.email ? 'email-error' : undefined}
        />
        {state.errors?.email && (
          <p id="email-error" className="text-destructive text-sm">
            {state.errors.email[0]}
          </p>
        )}
      </div>
      
      {/* More fields... */}
      
      <button type="submit" disabled={pending}>
        {pending ? 'Creating...' : 'Create User'}
      </button>
    </form>
  );
}
```

### React Hook Form with Zod

```tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateUserSchema, type CreateUserInput } from '@/schemas/user';

export function CreateUserForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<CreateUserInput>({
    resolver: zodResolver(CreateUserSchema),
  });
  
  const onSubmit = async (data: CreateUserInput) => {
    const result = await createUser(data);
    if (result.success) {
      // Handle success
    }
  };
  
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="email">Email</label>
        <input {...register('email')} />
        {errors.email && <p className="text-destructive">{errors.email.message}</p>}
      </div>
      
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create'}
      </button>
    </form>
  );
}
```

## State Management Patterns

### Context + Reducer Pattern

```tsx
// context/cart-context.tsx
'use client';

import { createContext, useContext, useReducer, type ReactNode } from 'react';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  total: number;
}

type CartAction =
  | { type: 'ADD_ITEM'; payload: CartItem }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'UPDATE_QUANTITY'; payload: { id: string; quantity: number } }
  | { type: 'CLEAR_CART' };

const CartContext = createContext<{
  state: CartState;
  dispatch: React.Dispatch<CartAction>;
} | null>(null);

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find((i) => i.id === action.payload.id);
      if (existingItem) {
        return {
          ...state,
          items: state.items.map((i) =>
            i.id === action.payload.id
              ? { ...i, quantity: i.quantity + action.payload.quantity }
              : i
          ),
        };
      }
      return {
        ...state,
        items: [...state.items, action.payload],
      };
    }
    case 'REMOVE_ITEM':
      return {
        ...state,
        items: state.items.filter((i) => i.id !== action.payload),
      };
    case 'UPDATE_QUANTITY':
      return {
        ...state,
        items: state.items.map((i) =>
          i.id === action.payload.id
            ? { ...i, quantity: action.payload.quantity }
            : i
        ),
      };
    case 'CLEAR_CART':
      return { items: [], total: 0 };
  }
}

export function CartProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(cartReducer, { items: [], total: 0 });
  
  return (
    <CartContext.Provider value={{ state, dispatch }}>
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}
```

### Zustand Store

```tsx
// stores/user-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface User {
  id: string;
  email: string;
  name: string;
}

interface UserStore {
  user: User | null;
  setUser: (user: User | null) => void;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useUserStore = create<UserStore>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      
      login: async (email, password) => {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          body: JSON.stringify({ email, password }),
        });
        const user = await response.json();
        set({ user, isAuthenticated: true });
      },
      
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    {
      name: 'user-storage',
      partialize: (state) => ({ user: state.user }),
    }
  )
);
```

## Animation Patterns

### CSS Animations

```css
/* Staggered reveal animation */
.fade-in-stagger > * {
  opacity: 0;
  animation: fade-in 0.5s ease-out forwards;
}

.fade-in-stagger > *:nth-child(1) { animation-delay: 0ms; }
.fade-in-stagger > *:nth-child(2) { animation-delay: 100ms; }
.fade-in-stagger > *:nth-child(3) { animation-delay: 200ms; }
.fade-in-stagger > *:nth-child(4) { animation-delay: 300ms; }

@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

### Framer Motion

```tsx
'use client';

import { motion, AnimatePresence } from 'framer-motion';

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

export function AnimatedList({ items }: { items: Item[] }) {
  return (
    <motion.ul
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      <AnimatePresence>
        {items.map((item) => (
          <motion.li
            key={item.id}
            variants={itemVariants}
            exit={{ opacity: 0, x: -100 }}
            layout
          >
            {item.name}
          </motion.li>
        ))}
      </AnimatePresence>
    </motion.ul>
  );
}
```

## Testing Patterns

### Component Testing with Testing Library

```tsx
// components/__tests__/button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../button';

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });
  
  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledOnce();
  });
  
  it('shows loading state', () => {
    render(<Button isLoading>Submit</Button>);
    
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByRole('button')).toHaveTextContent(/loading/i);
  });
  
  it('applies variant classes', () => {
    render(<Button variant="destructive">Delete</Button>);
    
    expect(screen.getByRole('button')).toHaveClass('bg-destructive');
  });
});
```

## Responsive Design Patterns

### Mobile-First with Tailwind

```tsx
export function ResponsiveLayout({ children }: { children: ReactNode }) {
  return (
    <div className="
      /* Mobile first (default) */
      flex flex-col gap-4 p-4
      
      /* Tablet */
      md:flex-row md:gap-6 md:p-6
      
      /* Desktop */
      lg:gap-8 lg:p-8 lg:max-w-7xl lg:mx-auto
      
      /* Large desktop */
      xl:gap-10 xl:p-10
    ">
      {children}
    </div>
  );
}
```

### Container Queries

```tsx
export function Card({ children }: { children: ReactNode }) {
  return (
    <div className="@container">
      <div className="
        flex flex-col gap-2
        @md:flex-row @md:gap-4
        @lg:gap-6
      ">
        {children}
      </div>
    </div>
  );
}
```
