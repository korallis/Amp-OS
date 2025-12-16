# Test Patterns Reference

Comprehensive testing patterns for modern TypeScript/React applications.

## Table of Contents

- [Unit Testing Patterns](#unit-testing-patterns)
- [Component Testing Patterns](#component-testing-patterns)
- [Hook Testing Patterns](#hook-testing-patterns)
- [Mocking Strategies](#mocking-strategies)
- [MSW Handler Patterns](#msw-handler-patterns)
- [Playwright E2E Patterns](#playwright-e2e-patterns)
- [Authentication Testing](#authentication-testing)
- [Database Testing](#database-testing)
- [CI/CD Integration](#cicd-integration)
- [Test Organization](#test-organization)

---

## Unit Testing Patterns

### Testing Pure Functions

```typescript
import { describe, it, expect } from 'vitest';
import { calculateTotal, formatCurrency, validateEmail } from './utils';

describe('calculateTotal', () => {
  it('should calculate total with tax', () => {
    const items = [
      { price: 100, quantity: 2 },
      { price: 50, quantity: 1 },
    ];
    expect(calculateTotal(items, 0.1)).toBe(275); // 250 + 10% tax
  });

  it('should return 0 for empty cart', () => {
    expect(calculateTotal([], 0.1)).toBe(0);
  });

  it('should handle negative quantities gracefully', () => {
    const items = [{ price: 100, quantity: -1 }];
    expect(calculateTotal(items, 0.1)).toBe(0);
  });
});

describe('validateEmail', () => {
  it.each([
    ['test@example.com', true],
    ['user.name+tag@domain.co.uk', true],
    ['invalid-email', false],
    ['@nodomain.com', false],
    ['spaces in@email.com', false],
    ['', false],
  ])('validateEmail(%s) should return %s', (email, expected) => {
    expect(validateEmail(email)).toBe(expected);
  });
});
```

### Testing Async Functions

```typescript
import { describe, it, expect, vi } from 'vitest';
import { fetchUserData, processData } from './api';

describe('fetchUserData', () => {
  it('should fetch and transform user data', async () => {
    const userData = await fetchUserData('123');
    
    expect(userData).toMatchObject({
      id: '123',
      name: expect.any(String),
      createdAt: expect.any(Date),
    });
  });

  it('should throw for non-existent user', async () => {
    await expect(fetchUserData('non-existent')).rejects.toThrow('User not found');
  });

  it('should handle timeout', async () => {
    vi.useFakeTimers();
    
    const promise = fetchUserData('123', { timeout: 5000 });
    vi.advanceTimersByTime(6000);
    
    await expect(promise).rejects.toThrow('Request timeout');
    
    vi.useRealTimers();
  });
});
```

### Testing Error Handling

```typescript
describe('error handling', () => {
  it('should throw specific error types', () => {
    expect(() => parseConfig(null)).toThrow(ValidationError);
    expect(() => parseConfig(null)).toThrow('Config cannot be null');
  });

  it('should include error context', () => {
    try {
      parseConfig({ invalid: true });
    } catch (error) {
      expect(error).toBeInstanceOf(ValidationError);
      expect(error.context).toEqual({ field: 'invalid', reason: 'unknown field' });
    }
  });
});
```

---

## Component Testing Patterns

### Basic Component Test

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('should render with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('should call onClick when clicked', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    
    render(<Button onClick={onClick}>Click me</Button>);
    await user.click(screen.getByRole('button'));
    
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('should be disabled when loading', () => {
    render(<Button loading>Submit</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('should apply variant styles', () => {
    render(<Button variant="destructive">Delete</Button>);
    expect(screen.getByRole('button')).toHaveClass('bg-destructive');
  });
});
```

### Form Testing

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  const setup = (props = {}) => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    const utils = render(<LoginForm onSubmit={onSubmit} {...props} />);
    
    return {
      user,
      onSubmit,
      emailInput: screen.getByLabelText(/email/i),
      passwordInput: screen.getByLabelText(/password/i),
      submitButton: screen.getByRole('button', { name: /sign in/i }),
      ...utils,
    };
  };

  it('should submit valid form data', async () => {
    const { user, onSubmit, emailInput, passwordInput, submitButton } = setup();
    
    await user.type(emailInput, 'test@example.com');
    await user.type(passwordInput, 'password123');
    await user.click(submitButton);
    
    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });

  it('should show validation errors for invalid input', async () => {
    const { user, submitButton } = setup();
    
    await user.click(submitButton);
    
    expect(await screen.findByText(/email is required/i)).toBeInTheDocument();
    expect(await screen.findByText(/password is required/i)).toBeInTheDocument();
  });

  it('should disable submit button while loading', async () => {
    const { submitButton } = setup({ isLoading: true });
    expect(submitButton).toBeDisabled();
  });
});
```

### Testing Conditional Rendering

```typescript
describe('UserProfile', () => {
  it('should show loading state', () => {
    render(<UserProfile isLoading />);
    expect(screen.getByTestId('loading-skeleton')).toBeInTheDocument();
  });

  it('should show error state', () => {
    render(<UserProfile error="Failed to load user" />);
    expect(screen.getByRole('alert')).toHaveTextContent(/failed to load user/i);
  });

  it('should show user data when loaded', () => {
    render(<UserProfile user={{ name: 'Alice', email: 'alice@example.com' }} />);
    
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('alice@example.com')).toBeInTheDocument();
  });

  it('should show empty state when no user', () => {
    render(<UserProfile user={null} />);
    expect(screen.getByText(/no user found/i)).toBeInTheDocument();
  });
});
```

### Testing Lists and Iterations

```typescript
describe('TodoList', () => {
  const todos = [
    { id: '1', text: 'Buy groceries', completed: false },
    { id: '2', text: 'Walk the dog', completed: true },
    { id: '3', text: 'Read a book', completed: false },
  ];

  it('should render all todos', () => {
    render(<TodoList todos={todos} />);
    
    const items = screen.getAllByRole('listitem');
    expect(items).toHaveLength(3);
  });

  it('should filter completed todos', async () => {
    const user = userEvent.setup();
    render(<TodoList todos={todos} />);
    
    await user.click(screen.getByRole('button', { name: /hide completed/i }));
    
    const items = screen.getAllByRole('listitem');
    expect(items).toHaveLength(2);
    expect(screen.queryByText('Walk the dog')).not.toBeInTheDocument();
  });

  it('should toggle todo completion', async () => {
    const user = userEvent.setup();
    const onToggle = vi.fn();
    
    render(<TodoList todos={todos} onToggle={onToggle} />);
    
    await user.click(screen.getByRole('checkbox', { name: /buy groceries/i }));
    
    expect(onToggle).toHaveBeenCalledWith('1');
  });
});
```

---

## Hook Testing Patterns

### Basic Hook Test

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('should initialize with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('should initialize with provided value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('should increment counter', () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });

  it('should decrement counter', () => {
    const { result } = renderHook(() => useCounter(5));
    
    act(() => {
      result.current.decrement();
    });
    
    expect(result.current.count).toBe(4);
  });

  it('should reset counter', () => {
    const { result } = renderHook(() => useCounter(0));
    
    act(() => {
      result.current.increment();
      result.current.increment();
      result.current.reset();
    });
    
    expect(result.current.count).toBe(0);
  });
});
```

### Async Hook with React Query

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useUser } from './useUser';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });

  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('useUser', () => {
  it('should fetch user data', async () => {
    const { result } = renderHook(() => useUser('123'), {
      wrapper: createWrapper(),
    });

    expect(result.current.isLoading).toBe(true);

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toEqual({
      id: '123',
      name: 'Alice',
      email: 'alice@example.com',
    });
  });

  it('should handle error state', async () => {
    const { result } = renderHook(() => useUser('non-existent'), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(result.current.isError).toBe(true);
    });

    expect(result.current.error?.message).toBe('User not found');
  });
});
```

### Hook with Context

```typescript
import { renderHook, act } from '@testing-library/react';
import { AuthProvider, useAuth } from './AuthContext';

describe('useAuth', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <AuthProvider>{children}</AuthProvider>
  );

  it('should start with unauthenticated state', () => {
    const { result } = renderHook(() => useAuth(), { wrapper });
    
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });

  it('should authenticate user on login', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    await act(async () => {
      await result.current.login('test@example.com', 'password');
    });

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user?.email).toBe('test@example.com');
  });

  it('should clear user on logout', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    await act(async () => {
      await result.current.login('test@example.com', 'password');
    });

    act(() => {
      result.current.logout();
    });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
  });
});
```

---

## Mocking Strategies

### vi.mock - Module Mocking

```typescript
import { vi, describe, it, expect } from 'vitest';
import { sendEmail } from './email';
import { createUser } from './users';

// Mock entire module
vi.mock('./email', () => ({
  sendEmail: vi.fn().mockResolvedValue({ success: true }),
}));

describe('createUser', () => {
  it('should send welcome email after creating user', async () => {
    await createUser({ name: 'Alice', email: 'alice@example.com' });
    
    expect(sendEmail).toHaveBeenCalledWith({
      to: 'alice@example.com',
      template: 'welcome',
    });
  });
});
```

### vi.spyOn - Method Spying

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as api from './api';

describe('data fetching', () => {
  let fetchSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    fetchSpy = vi.spyOn(api, 'fetchData').mockResolvedValue({ data: 'mocked' });
  });

  afterEach(() => {
    fetchSpy.mockRestore();
  });

  it('should call fetchData with correct params', async () => {
    await loadUserData('123');
    
    expect(fetchSpy).toHaveBeenCalledWith('/users/123');
  });

  it('should handle different responses', async () => {
    fetchSpy.mockResolvedValueOnce({ data: 'first' });
    fetchSpy.mockResolvedValueOnce({ data: 'second' });
    
    const first = await api.fetchData('/test');
    const second = await api.fetchData('/test');
    
    expect(first.data).toBe('first');
    expect(second.data).toBe('second');
  });
});
```

### Mocking Environment Variables

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('config', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    vi.resetModules();
    process.env = { ...originalEnv };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('should use production API URL', async () => {
    process.env.NODE_ENV = 'production';
    process.env.API_URL = 'https://api.example.com';
    
    const { getApiUrl } = await import('./config');
    expect(getApiUrl()).toBe('https://api.example.com');
  });

  it('should use local API URL in development', async () => {
    process.env.NODE_ENV = 'development';
    
    const { getApiUrl } = await import('./config');
    expect(getApiUrl()).toBe('http://localhost:3000/api');
  });
});
```

### Mocking Timers

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';
import { debounce } from './utils';

describe('debounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should debounce function calls', () => {
    const fn = vi.fn();
    const debouncedFn = debounce(fn, 300);

    debouncedFn();
    debouncedFn();
    debouncedFn();

    expect(fn).not.toHaveBeenCalled();

    vi.advanceTimersByTime(300);

    expect(fn).toHaveBeenCalledTimes(1);
  });

  it('should use latest arguments', () => {
    const fn = vi.fn();
    const debouncedFn = debounce(fn, 300);

    debouncedFn('first');
    debouncedFn('second');
    debouncedFn('third');

    vi.advanceTimersByTime(300);

    expect(fn).toHaveBeenCalledWith('third');
  });
});
```

---

## MSW Handler Patterns

### Basic REST Handlers

```typescript
// mocks/handlers.ts
import { http, HttpResponse, delay } from 'msw';

export const handlers = [
  // GET with query params
  http.get('/api/users', ({ request }) => {
    const url = new URL(request.url);
    const page = url.searchParams.get('page') || '1';
    const limit = url.searchParams.get('limit') || '10';
    
    return HttpResponse.json({
      users: mockUsers.slice((+page - 1) * +limit, +page * +limit),
      total: mockUsers.length,
      page: +page,
      limit: +limit,
    });
  }),

  // GET with path params
  http.get('/api/users/:id', ({ params }) => {
    const user = mockUsers.find((u) => u.id === params.id);
    
    if (!user) {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }
    
    return HttpResponse.json(user);
  }),

  // POST with body parsing
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    
    const newUser = {
      id: crypto.randomUUID(),
      ...body,
      createdAt: new Date().toISOString(),
    };
    
    return HttpResponse.json(newUser, { status: 201 });
  }),

  // PUT/PATCH
  http.patch('/api/users/:id', async ({ params, request }) => {
    const body = await request.json();
    const user = mockUsers.find((u) => u.id === params.id);
    
    if (!user) {
      return HttpResponse.json({ error: 'User not found' }, { status: 404 });
    }
    
    return HttpResponse.json({ ...user, ...body });
  }),

  // DELETE
  http.delete('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ deleted: params.id });
  }),
];
```

### Simulating Network Conditions

```typescript
import { http, HttpResponse, delay } from 'msw';

export const networkHandlers = [
  // Slow response
  http.get('/api/slow', async () => {
    await delay(3000);
    return HttpResponse.json({ data: 'slow response' });
  }),

  // Random delay
  http.get('/api/variable', async () => {
    await delay(Math.random() * 2000);
    return HttpResponse.json({ data: 'variable delay' });
  }),

  // Network error
  http.get('/api/network-error', () => {
    return HttpResponse.error();
  }),

  // Timeout simulation
  http.get('/api/timeout', async () => {
    await delay('infinite');
    return HttpResponse.json({ data: 'never reached' });
  }),
];
```

### GraphQL Handlers

```typescript
import { graphql, HttpResponse } from 'msw';

export const graphqlHandlers = [
  graphql.query('GetUser', ({ variables }) => {
    const { id } = variables;
    
    return HttpResponse.json({
      data: {
        user: {
          id,
          name: 'Alice',
          email: 'alice@example.com',
        },
      },
    });
  }),

  graphql.mutation('CreateUser', ({ variables }) => {
    const { input } = variables;
    
    return HttpResponse.json({
      data: {
        createUser: {
          id: '123',
          ...input,
        },
      },
    });
  }),

  graphql.query('GetUser', ({ variables }) => {
    if (variables.id === 'error') {
      return HttpResponse.json({
        errors: [{ message: 'User not found' }],
      });
    }
    
    return HttpResponse.json({
      data: { user: mockUser },
    });
  }),
];
```

### Handler Composition

```typescript
// mocks/handlers/users.ts
export const userHandlers = [
  http.get('/api/users', handleGetUsers),
  http.get('/api/users/:id', handleGetUser),
  http.post('/api/users', handleCreateUser),
];

// mocks/handlers/posts.ts
export const postHandlers = [
  http.get('/api/posts', handleGetPosts),
  http.post('/api/posts', handleCreatePost),
];

// mocks/handlers/index.ts
import { userHandlers } from './users';
import { postHandlers } from './posts';

export const handlers = [...userHandlers, ...postHandlers];
```

---

## Playwright E2E Patterns

### Page Object Model

```typescript
// e2e/pages/base.page.ts
import { Page, Locator, expect } from '@playwright/test';

export class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle');
  }

  async takeScreenshot(name: string) {
    await this.page.screenshot({ path: `screenshots/${name}.png`, fullPage: true });
  }

  async getByTestId(testId: string): Promise<Locator> {
    return this.page.getByTestId(testId);
  }
}

// e2e/pages/dashboard.page.ts
import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './base.page';

export class DashboardPage extends BasePage {
  readonly welcomeMessage: Locator;
  readonly userMenu: Locator;
  readonly logoutButton: Locator;
  readonly statsCards: Locator;

  constructor(page: Page) {
    super(page);
    this.welcomeMessage = page.getByRole('heading', { name: /welcome/i });
    this.userMenu = page.getByTestId('user-menu');
    this.logoutButton = page.getByRole('button', { name: /logout/i });
    this.statsCards = page.getByTestId('stats-card');
  }

  async goto() {
    await this.page.goto('/dashboard');
    await this.waitForPageLoad();
  }

  async logout() {
    await this.userMenu.click();
    await this.logoutButton.click();
    await expect(this.page).toHaveURL('/login');
  }

  async expectStatsCount(count: number) {
    await expect(this.statsCards).toHaveCount(count);
  }
}
```

### Fixtures

```typescript
// e2e/fixtures.ts
import { test as base } from '@playwright/test';
import { LoginPage } from './pages/login.page';
import { DashboardPage } from './pages/dashboard.page';

type Pages = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
};

export const test = base.extend<Pages>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },
  dashboardPage: async ({ page }, use) => {
    const dashboardPage = new DashboardPage(page);
    await use(dashboardPage);
  },
});

export { expect } from '@playwright/test';

// Usage in tests
import { test, expect } from './fixtures';

test('should login successfully', async ({ loginPage, dashboardPage }) => {
  await loginPage.goto();
  await loginPage.login('test@example.com', 'password123');
  await expect(dashboardPage.welcomeMessage).toBeVisible();
});
```

### Visual Regression Testing

```typescript
import { test, expect } from '@playwright/test';

test.describe('visual regression', () => {
  test('homepage matches snapshot', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage.png', {
      maxDiffPixels: 100,
    });
  });

  test('component matches snapshot', async ({ page }) => {
    await page.goto('/components/button');
    
    const button = page.getByRole('button', { name: /primary/i });
    await expect(button).toHaveScreenshot('primary-button.png');
  });

  test('responsive layout', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage-mobile.png');
    
    await page.setViewportSize({ width: 1920, height: 1080 });
    await expect(page).toHaveScreenshot('homepage-desktop.png');
  });
});
```

### API Testing with Playwright

```typescript
import { test, expect } from '@playwright/test';

test.describe('API tests', () => {
  test('should create and fetch user', async ({ request }) => {
    // Create user
    const createResponse = await request.post('/api/users', {
      data: { name: 'Test User', email: 'test@example.com' },
    });
    
    expect(createResponse.ok()).toBeTruthy();
    const user = await createResponse.json();
    expect(user.id).toBeDefined();
    
    // Fetch user
    const getResponse = await request.get(`/api/users/${user.id}`);
    expect(getResponse.ok()).toBeTruthy();
    
    const fetchedUser = await getResponse.json();
    expect(fetchedUser.name).toBe('Test User');
  });

  test('should handle validation errors', async ({ request }) => {
    const response = await request.post('/api/users', {
      data: { name: '' }, // Missing email
    });
    
    expect(response.status()).toBe(400);
    const error = await response.json();
    expect(error.message).toContain('email');
  });
});
```

---

## Authentication Testing

### Setup Authentication State

```typescript
// e2e/auth.setup.ts
import { test as setup, expect } from '@playwright/test';
import path from 'path';

const authFile = path.join(__dirname, '../playwright/.auth/user.json');

setup('authenticate', async ({ page }) => {
  // Navigate to login
  await page.goto('/login');
  
  // Fill credentials
  await page.getByLabel(/email/i).fill(process.env.TEST_USER_EMAIL!);
  await page.getByLabel(/password/i).fill(process.env.TEST_USER_PASSWORD!);
  
  // Submit
  await page.getByRole('button', { name: /sign in/i }).click();
  
  // Wait for successful login
  await expect(page).toHaveURL('/dashboard');
  
  // Save authentication state
  await page.context().storageState({ path: authFile });
});
```

### Multiple User Roles

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    
    // Admin tests
    {
      name: 'admin',
      use: {
        storageState: 'playwright/.auth/admin.json',
      },
      dependencies: ['setup'],
      testMatch: '**/admin/**/*.spec.ts',
    },
    
    // Regular user tests
    {
      name: 'user',
      use: {
        storageState: 'playwright/.auth/user.json',
      },
      dependencies: ['setup'],
      testMatch: '**/user/**/*.spec.ts',
    },
    
    // Unauthenticated tests
    {
      name: 'unauthenticated',
      testMatch: '**/public/**/*.spec.ts',
    },
  ],
});
```

### Testing Protected Routes

```typescript
import { test, expect } from '@playwright/test';

test.describe('protected routes', () => {
  test('should redirect unauthenticated users to login', async ({ browser }) => {
    // Create a new context without auth state
    const context = await browser.newContext();
    const page = await context.newPage();
    
    await page.goto('/dashboard');
    await expect(page).toHaveURL(/\/login/);
    
    await context.close();
  });

  test('should allow authenticated access', async ({ page }) => {
    // Uses the authenticated context from storageState
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible();
  });
});
```

---

## Database Testing

### Test Database Setup

```typescript
// test/setup-db.ts
import { PrismaClient } from '@prisma/client';
import { execSync } from 'child_process';

const prisma = new PrismaClient();

export async function setupTestDatabase() {
  // Use a test database URL
  process.env.DATABASE_URL = process.env.TEST_DATABASE_URL;
  
  // Reset database
  execSync('npx prisma migrate reset --force --skip-seed', {
    env: process.env,
  });
}

export async function cleanupTestDatabase() {
  // Clean up all tables
  await prisma.$transaction([
    prisma.post.deleteMany(),
    prisma.user.deleteMany(),
  ]);
}

export async function seedTestData() {
  const user = await prisma.user.create({
    data: {
      email: 'test@example.com',
      name: 'Test User',
      posts: {
        create: [
          { title: 'Post 1', content: 'Content 1' },
          { title: 'Post 2', content: 'Content 2' },
        ],
      },
    },
    include: { posts: true },
  });
  
  return { user };
}
```

### Database Test Patterns

```typescript
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import { prisma } from '@/lib/db';
import { setupTestDatabase, cleanupTestDatabase, seedTestData } from './setup-db';

describe('User Repository', () => {
  beforeAll(async () => {
    await setupTestDatabase();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();
  });

  it('should create user', async () => {
    const user = await prisma.user.create({
      data: { email: 'new@example.com', name: 'New User' },
    });

    expect(user.id).toBeDefined();
    expect(user.email).toBe('new@example.com');
  });

  it('should enforce unique email constraint', async () => {
    await prisma.user.create({
      data: { email: 'unique@example.com', name: 'User 1' },
    });

    await expect(
      prisma.user.create({
        data: { email: 'unique@example.com', name: 'User 2' },
      })
    ).rejects.toThrow(/unique constraint/i);
  });

  it('should cascade delete posts', async () => {
    const { user } = await seedTestData();
    
    await prisma.user.delete({ where: { id: user.id } });
    
    const posts = await prisma.post.findMany({
      where: { authorId: user.id },
    });
    
    expect(posts).toHaveLength(0);
  });
});
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: true

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium
      
      - name: Build application
        run: npm run build
      
      - name: Run E2E tests
        run: npm run test:e2e
        env:
          BASE_URL: http://localhost:3000
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### Pre-commit Hooks

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "vitest related --run"
    ]
  }
}
```

```bash
# .husky/pre-commit
#!/bin/sh
npx lint-staged
```

---

## Test Organization

### File Structure

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx      # Component tests
│   │   └── index.ts
│   └── Form/
│       ├── Form.tsx
│       ├── Form.test.tsx
│       └── index.ts
├── hooks/
│   ├── useAuth/
│   │   ├── useAuth.ts
│   │   ├── useAuth.test.ts      # Hook tests
│   │   └── index.ts
│   └── useApi/
│       ├── useApi.ts
│       ├── useApi.test.ts
│       └── index.ts
├── lib/
│   ├── utils.ts
│   └── utils.test.ts            # Utility tests
├── test/
│   ├── mocks/
│   │   ├── handlers.ts          # MSW handlers
│   │   ├── server.ts            # MSW server setup
│   │   └── data.ts              # Mock data
│   ├── fixtures/
│   │   └── users.ts             # Test fixtures
│   └── test-utils.tsx           # Custom render
├── vitest.config.ts
└── vitest.setup.ts

e2e/
├── fixtures/
│   ├── index.ts                 # Playwright fixtures
│   └── auth.fixture.ts
├── pages/
│   ├── base.page.ts
│   ├── login.page.ts
│   └── dashboard.page.ts
├── tests/
│   ├── auth.spec.ts
│   ├── dashboard.spec.ts
│   └── settings.spec.ts
├── auth.setup.ts
└── playwright.config.ts
```

### Test Utilities Organization

```typescript
// test/test-utils.tsx
export * from '@testing-library/react';
export { default as userEvent } from '@testing-library/user-event';
export { renderWithProviders as render } from './render';
export { createMockUser, createMockPost } from './factories';
export { server } from './mocks/server';

// test/factories.ts
import { faker } from '@faker-js/faker';

export function createMockUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    avatar: faker.image.avatar(),
    createdAt: faker.date.past().toISOString(),
    ...overrides,
  };
}

export function createMockPost(overrides = {}) {
  return {
    id: faker.string.uuid(),
    title: faker.lorem.sentence(),
    content: faker.lorem.paragraphs(3),
    authorId: faker.string.uuid(),
    createdAt: faker.date.past().toISOString(),
    ...overrides,
  };
}
```

### Test Tagging and Filtering

```typescript
// Using test.describe for grouping
test.describe('critical', () => {
  test('user can login', async () => {});
  test('user can checkout', async () => {});
});

test.describe('smoke', () => {
  test('homepage loads', async () => {});
  test('navigation works', async () => {});
});

// Run specific groups
// npx playwright test --grep @critical
// npx vitest run --grep "critical"
```

---

## Best Practices Summary

1. **Write tests that test behavior, not implementation**
2. **Use the testing trophy: more integration tests, fewer unit/e2e**
3. **Keep tests isolated and independent**
4. **Use meaningful test descriptions**
5. **Avoid test interdependence**
6. **Mock at the right level (prefer MSW over vi.mock for HTTP)**
7. **Use data-testid sparingly; prefer accessible queries**
8. **Run tests in CI with every PR**
9. **Maintain test coverage thresholds**
10. **Delete tests that don't add value**
