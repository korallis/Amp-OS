# Stripe Patterns

Comprehensive patterns for Stripe payments with Next.js - checkout, subscriptions, and webhooks.

## When to Use Stripe

- SaaS subscription billing
- One-time payments and checkout
- Usage-based billing
- Marketplace payments

## Setup

### Installation

```bash
npm install stripe @stripe/stripe-js
```

### Environment Variables

```bash
# .env.local
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...

# Price IDs from Stripe Dashboard
STRIPE_PRO_MONTHLY_PRICE_ID=price_...
STRIPE_PRO_YEARLY_PRICE_ID=price_...
```

### Stripe Client

```typescript
// lib/stripe.ts
import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2024-11-20.acacia",
  typescript: true,
});
```

## Checkout Session

### Create Checkout

```typescript
// app/api/stripe/checkout/route.ts
import { stripe } from "@/lib/stripe";
import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

const PRICE_IDS = {
  pro_monthly: process.env.STRIPE_PRO_MONTHLY_PRICE_ID!,
  pro_yearly: process.env.STRIPE_PRO_YEARLY_PRICE_ID!,
} as const;

export async function POST(req: Request) {
  try {
    const { userId } = await auth();
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { priceId, successUrl, cancelUrl } = await req.json();

    if (!Object.values(PRICE_IDS).includes(priceId)) {
      return NextResponse.json({ error: "Invalid price" }, { status: 400 });
    }

    // Get or create Stripe customer
    let customer = await getOrCreateCustomer(userId);

    const session = await stripe.checkout.sessions.create({
      customer: customer.id,
      mode: "subscription",
      payment_method_types: ["card"],
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl || `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?success=true`,
      cancel_url: cancelUrl || `${process.env.NEXT_PUBLIC_APP_URL}/pricing?canceled=true`,
      subscription_data: {
        metadata: { userId },
      },
      allow_promotion_codes: true,
      billing_address_collection: "auto",
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error("Checkout error:", error);
    return NextResponse.json(
      { error: "Failed to create checkout session" },
      { status: 500 }
    );
  }
}

async function getOrCreateCustomer(userId: string) {
  // Check if customer exists in your database
  const user = await db.query.users.findFirst({
    where: eq(users.clerkId, userId),
  });

  if (user?.stripeCustomerId) {
    return await stripe.customers.retrieve(user.stripeCustomerId);
  }

  // Create new customer
  const customer = await stripe.customers.create({
    metadata: { userId },
  });

  // Save to database
  await db
    .update(users)
    .set({ stripeCustomerId: customer.id })
    .where(eq(users.clerkId, userId));

  return customer;
}
```

### Client-Side Redirect

```typescript
"use client";

export function CheckoutButton({ priceId }: { priceId: string }) {
  const [loading, setLoading] = useState(false);

  const handleCheckout = async () => {
    setLoading(true);
    try {
      const response = await fetch("/api/stripe/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ priceId }),
      });

      const { url, error } = await response.json();

      if (error) {
        console.error(error);
        return;
      }

      window.location.href = url;
    } finally {
      setLoading(false);
    }
  };

  return (
    <button onClick={handleCheckout} disabled={loading}>
      {loading ? "Loading..." : "Subscribe"}
    </button>
  );
}
```

## Webhook Handler

### Signature Verification

```typescript
// app/api/webhooks/stripe/route.ts
import { stripe } from "@/lib/stripe";
import { headers } from "next/headers";
import { NextResponse } from "next/server";
import type Stripe from "stripe";

const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET!;

// Events we handle
const ALLOWED_EVENTS = new Set([
  "checkout.session.completed",
  "customer.subscription.created",
  "customer.subscription.updated",
  "customer.subscription.deleted",
  "invoice.paid",
  "invoice.payment_failed",
]);

export async function POST(req: Request) {
  const body = await req.text();
  const headersList = await headers();
  const signature = headersList.get("stripe-signature");

  if (!signature) {
    return NextResponse.json({ error: "No signature" }, { status: 400 });
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(body, signature, WEBHOOK_SECRET);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 });
  }

  // Ignore events we don't handle
  if (!ALLOWED_EVENTS.has(event.type)) {
    return NextResponse.json({ received: true });
  }

  try {
    await handleEvent(event);
    return NextResponse.json({ received: true });
  } catch (error) {
    console.error(`Webhook handler error for ${event.type}:`, error);
    return NextResponse.json(
      { error: "Webhook handler failed" },
      { status: 500 }
    );
  }
}

async function handleEvent(event: Stripe.Event) {
  switch (event.type) {
    case "checkout.session.completed": {
      const session = event.data.object as Stripe.Checkout.Session;
      await handleCheckoutComplete(session);
      break;
    }
    case "customer.subscription.created":
    case "customer.subscription.updated": {
      const subscription = event.data.object as Stripe.Subscription;
      await handleSubscriptionChange(subscription);
      break;
    }
    case "customer.subscription.deleted": {
      const subscription = event.data.object as Stripe.Subscription;
      await handleSubscriptionCanceled(subscription);
      break;
    }
    case "invoice.payment_failed": {
      const invoice = event.data.object as Stripe.Invoice;
      await handlePaymentFailed(invoice);
      break;
    }
  }
}
```

### Event Handlers

```typescript
async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.userId;
  if (!userId) return;

  // Subscription is automatically created by Stripe
  console.log(`Checkout completed for user ${userId}`);
}

async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const userId = subscription.metadata.userId;
  if (!userId) return;

  const plan = determinePlan(subscription);
  const status = subscription.status;

  await db
    .update(users)
    .set({
      subscriptionPlan: plan,
      subscriptionStatus: status,
      subscriptionId: subscription.id,
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      updatedAt: new Date(),
    })
    .where(eq(users.clerkId, userId));

  console.log(`Subscription updated for user ${userId}: ${plan} (${status})`);
}

async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  const userId = subscription.metadata.userId;
  if (!userId) return;

  await db
    .update(users)
    .set({
      subscriptionPlan: "free",
      subscriptionStatus: "canceled",
      updatedAt: new Date(),
    })
    .where(eq(users.clerkId, userId));

  console.log(`Subscription canceled for user ${userId}`);
}

async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;
  
  // Find user and notify them
  const user = await db.query.users.findFirst({
    where: eq(users.stripeCustomerId, customerId),
  });

  if (user) {
    // Send notification email
    console.log(`Payment failed for user ${user.id}`);
  }
}

function determinePlan(subscription: Stripe.Subscription): "free" | "pro" | "team" {
  if (subscription.status !== "active") return "free";
  
  const priceId = subscription.items.data[0]?.price.id;
  
  if (priceId === process.env.STRIPE_TEAM_PRICE_ID) return "team";
  if (priceId === process.env.STRIPE_PRO_MONTHLY_PRICE_ID) return "pro";
  if (priceId === process.env.STRIPE_PRO_YEARLY_PRICE_ID) return "pro";
  
  return "free";
}
```

## Idempotent Webhook Processing

```typescript
// db/schema.ts
export const webhookEvents = pgTable("webhook_events", {
  id: varchar("id", { length: 255 }).primaryKey(),
  source: varchar("source", { length: 50 }).notNull(),
  type: varchar("type", { length: 100 }).notNull(),
  processedAt: timestamp("processed_at").defaultNow().notNull(),
  payload: jsonb("payload"),
});

// lib/webhooks.ts
export async function processIdempotent<T>(
  eventId: string,
  source: string,
  type: string,
  handler: () => Promise<T>
): Promise<{ processed: boolean; result?: T }> {
  // Check if already processed
  const existing = await db.query.webhookEvents.findFirst({
    where: and(
      eq(webhookEvents.id, eventId),
      eq(webhookEvents.source, source)
    ),
  });

  if (existing) {
    console.log(`Event ${eventId} already processed, skipping`);
    return { processed: false };
  }

  // Process atomically
  const result = await db.transaction(async (tx) => {
    await tx.insert(webhookEvents).values({ id: eventId, source, type });
    return handler();
  });

  return { processed: true, result };
}

// Usage in webhook
async function handleEvent(event: Stripe.Event) {
  const { processed } = await processIdempotent(
    event.id,
    "stripe",
    event.type,
    async () => {
      // Handle the event
    }
  );
}
```

## Customer Portal

```typescript
// app/api/stripe/portal/route.ts
import { stripe } from "@/lib/stripe";
import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

export async function POST() {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const user = await db.query.users.findFirst({
    where: eq(users.clerkId, userId),
  });

  if (!user?.stripeCustomerId) {
    return NextResponse.json(
      { error: "No billing account" },
      { status: 404 }
    );
  }

  const session = await stripe.billingPortal.sessions.create({
    customer: user.stripeCustomerId,
    return_url: `${process.env.NEXT_PUBLIC_APP_URL}/settings/billing`,
  });

  return NextResponse.json({ url: session.url });
}
```

## Cancel Subscription

```typescript
// actions/billing.ts
"use server";

import { stripe } from "@/lib/stripe";
import { auth } from "@clerk/nextjs/server";
import { revalidatePath } from "next/cache";

export async function cancelSubscription(immediate = false) {
  const { userId } = await auth();
  if (!userId) throw new Error("Unauthorized");

  const user = await db.query.users.findFirst({
    where: eq(users.clerkId, userId),
  });

  if (!user?.subscriptionId) {
    throw new Error("No active subscription");
  }

  if (immediate) {
    await stripe.subscriptions.cancel(user.subscriptionId);
  } else {
    await stripe.subscriptions.update(user.subscriptionId, {
      cancel_at_period_end: true,
    });
  }

  revalidatePath("/settings/billing");
}
```

## Testing

### Stripe CLI

```bash
# Login to Stripe
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
```

### Test Cards

| Card Number | Scenario |
|-------------|----------|
| 4242424242424242 | Successful payment |
| 4000000000000341 | Attaching fails |
| 4000000000009995 | Insufficient funds |
| 4000000000000002 | Declined |

## Best Practices

### Do's

- Always verify webhook signatures
- Use idempotent webhook processing
- Store subscription status in your database
- Use metadata to link Stripe objects to your users
- Handle all relevant webhook events

### Don'ts

- Never expose secret key to client
- Don't trust client-side data for pricing
- Don't skip webhook signature verification
- Don't ignore failed payment events
- Don't hardcode price IDs in multiple places
