# Testing Standards

Standards for test writing, coverage, and quality assurance.

## Testing Philosophy

1. **Tests come BEFORE implementation** (TDD when possible)
2. **Test behavior, not implementation**
3. **Each test should test ONE thing**
4. **Tests are documentation**

## Test Structure

### AAA Pattern (Arrange, Act, Assert)

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid input', async () => {
      // Arrange
      const input = { email: 'test@example.com', name: 'Test User' };
      
      // Act
      const result = await userService.createUser(input);
      
      // Assert
      expect(result.email).toBe(input.email);
      expect(result.id).toBeDefined();
    });

    it('should throw ValidationError for invalid email', async () => {
      // Arrange
      const input = { email: 'invalid', name: 'Test' };
      
      // Act & Assert
      await expect(userService.createUser(input))
        .rejects.toThrow(ValidationError);
    });
  });
});
```

### Naming Conventions

```typescript
// Pattern: should [expected behavior] when [condition]
it('should return empty array when no users exist')
it('should throw NotFoundError when user does not exist')
it('should update lastLoginAt when user logs in')
```

## Coverage Requirements

| Type | Minimum | Target |
|------|---------|--------|
| Statements | 70% | 85% |
| Branches | 70% | 80% |
| Functions | 70% | 85% |
| Lines | 70% | 85% |

### What to Test

**Always test:**
- Happy path (expected inputs)
- Edge cases (empty, null, boundary values)
- Error conditions
- Business logic and validation

**Don't test:**
- Framework/library code
- Simple getters/setters
- Third-party integrations (mock them)

## Unit Tests

### Testing Pure Functions

```typescript
describe('calculateTotal', () => {
  it('should sum all item prices', () => {
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 3 },
    ];
    
    expect(calculateTotal(items)).toBe(35);
  });

  it('should return 0 for empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });
});
```

### Testing with Mocks

```typescript
describe('OrderService', () => {
  let orderService: OrderService;
  let mockPaymentService: jest.Mocked<PaymentService>;

  beforeEach(() => {
    mockPaymentService = {
      charge: jest.fn(),
      refund: jest.fn(),
    };
    orderService = new OrderService(mockPaymentService);
  });

  it('should charge payment when creating order', async () => {
    mockPaymentService.charge.mockResolvedValue({ success: true });
    
    await orderService.createOrder(orderData);
    
    expect(mockPaymentService.charge).toHaveBeenCalledWith(
      expect.objectContaining({ amount: orderData.total })
    );
  });
});
```

## Integration Tests

### API Testing

```typescript
describe('POST /api/users', () => {
  it('should create user and return 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test' })
      .expect(201);
    
    expect(response.body.data).toMatchObject({
      email: 'test@example.com',
      name: 'Test',
    });
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Test' })
      .expect(400);
    
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

### Database Testing

```typescript
describe('UserRepository', () => {
  beforeEach(async () => {
    await db.delete(users); // Clean slate
  });

  afterAll(async () => {
    await db.end();
  });

  it('should persist user to database', async () => {
    const user = await userRepo.create({ email: 'test@example.com' });
    
    const found = await userRepo.findById(user.id);
    expect(found).toMatchObject({ email: 'test@example.com' });
  });
});
```

## E2E Tests (Playwright)

### Page Object Model

```typescript
// pages/login.page.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email"]', email);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="submit"]');
  }

  async getErrorMessage() {
    return this.page.textContent('[data-testid="error"]');
  }
}

// tests/login.spec.ts
test('should login with valid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  
  await expect(page).toHaveURL('/dashboard');
});
```

## Mocking

### MSW for API Mocking

```typescript
// mocks/handlers.ts
export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      data: { id: params.id, name: 'Test User' }
    });
  }),
  
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { data: { id: '123', ...body } },
      { status: 201 }
    );
  }),
];

// Setup
const server = setupServer(...handlers);
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Test Data

### Factories

```typescript
// factories/user.factory.ts
export const userFactory = {
  build: (overrides?: Partial<User>): User => ({
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    createdAt: new Date(),
    ...overrides,
  }),
  
  buildMany: (count: number, overrides?: Partial<User>): User[] =>
    Array.from({ length: count }, () => userFactory.build(overrides)),
};

// Usage
const user = userFactory.build({ role: 'admin' });
const users = userFactory.buildMany(5);
```

## Test Checklist

Before PR:

- [ ] All tests pass locally
- [ ] New code has tests
- [ ] Edge cases covered
- [ ] No skipped tests without reason
- [ ] Tests are not flaky
- [ ] Coverage meets minimum thresholds
