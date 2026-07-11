# MCP Integration Guide

This guide explains how to build skills that enhance and orchestrate MCP (Model Context Protocol) servers.

## Skills + MCPs: A Powerful Combination

-   **MCPs provide the tools:** They give the agent access to real-time data and the ability to perform actions in external services (e.g., Notion, Jira, Stripe).
-   **Skills provide the knowledge:** They teach the agent *how* to use those tools effectively. They capture your team's specific workflows, best practices, and domain expertise.

Think of it like a professional kitchen. The MCP is the set of appliances and ingredients. The skill is the recipe that turns them into a finished dish.

## Why This Matters for Your Users

| Without Skills | With Skills |
| --- | --- |
| Users don't know what to do next. | Pre-built workflows guide the user. |
| Inconsistent results from varied prompts. | Reliable and consistent tool usage. |
| Users blame the MCP for workflow issues. | Best practices are built into every interaction. |
| High learning curve for your integration. | Lower barrier to entry for your integration. |

## Common Patterns for MCP-Enhanced Skills

### 1. Sequential Workflow Orchestration

This is the most common pattern. The skill defines a step-by-step process that calls multiple MCP tools in a specific order.

**Example:** A skill that creates a new customer in Stripe, sets up their subscription, and then sends a welcome email via SendGrid.

**SKILL.md:**
```markdown
### Step 1: Create Stripe Customer
Call the `stripe.create_customer` tool.

### Step 2: Create Subscription
Use the customer ID from Step 1 to call `stripe.create_subscription`.

### Step 3: Send Welcome Email
Call the `sendgrid.send_email` tool.
```

### 2. Domain-Specific Intelligence

The skill adds a layer of expert knowledge on top of the raw tools.

**Example:** A financial compliance skill that checks a transaction against a set of internal rules before calling the payment processing MCP tool.

**SKILL.md:**
```markdown
### Before Processing (Compliance Check)
1.  Fetch transaction details via the MCP.
2.  Apply compliance rules:
    -   Check against internal sanctions lists (`references/sanctions-list.md`).
    -   Verify jurisdiction allowances.
3.  If compliance passes, proceed to the next step. Otherwise, flag for manual review.

### Processing
Call the `payment.process_transaction` MCP tool.
```

### 3. Context-Aware Tool Selection

The skill uses context to choose the right tool for the job, making the user's experience simpler.

**Example:** A skill that automatically chooses the correct storage location for a file based on its size and type.

**SKILL.md:**
```markdown
1.  **Analyze the file:** Check its type and size.
2.  **Select storage:**
    -   If it's a large video file, use the S3 MCP.
    -   If it's a collaborative document, use the Google Drive MCP.
3.  **Execute:** Call the chosen MCP tool to upload the file.
```
