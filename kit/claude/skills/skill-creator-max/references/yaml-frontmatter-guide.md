# YAML Frontmatter Guide

YAML frontmatter is the most important part of your skill. It's how the agent decides when to use your skill. Get this right, and you're halfway to a great skill.

## Minimum Required Format

```yaml
---
name: your-skill-name
description: What your skill does and the specific phrases a user might say to trigger it.
---
```

## Field Requirements

### `name` (Required)

-   **Format:** Must be `kebab-case`.
-   **Consistency:** Must match the skill's folder name.
-   **Uniqueness:** Should be unique and descriptive.

### `description` (Required)

This is the primary trigger for your skill. It must contain two things:

1.  **What it does:** A clear, concise summary of the skill's capability.
2.  **When to use it:** Specific trigger phrases and keywords a user might use.

**Structure:** `[What it does] + [When to use it] + [Key capabilities]`

**Good Examples:**

```yaml
# Good - specific and actionable
description: Analyzes Figma design files and generates developer handoff documentation. Use when a user uploads a .fig file or asks for "design specs", "component documentation", or "design-to-code handoff".

# Good - includes trigger phrases
description: Manages Linear project workflows, including sprint planning and task creation. Use when a user mentions "sprint", "Linear tasks", "project planning", or asks to "create tickets".

# Good - clear value proposition
description: End-to-end customer onboarding workflow for PayFlow. Handles account creation, payment setup, and subscription management. Use when a user says "onboard new customer" or "set up a subscription".
```

**Bad Examples:**

```yaml
# Too vague - What kind of help? When?
description: Helps with projects.

# Missing triggers - How does a user activate this?
description: Creates sophisticated multi-page documentation systems.

# Too technical, no user triggers - A user would never say this.
description: Implements the Project entity model with hierarchical relationships.
```

### Optional Fields

-   `license`: Specify an open-source license (e.g., `MIT`).
-   `compatibility`: Note any dependencies (e.g., "Requires Python 3.9+").
-   `metadata`: Add custom key-value pairs like `author`, `version`, or the associated `mcp-server`.

**Example with all fields:**

```yaml
---
name: my-data-analyzer
description: Performs advanced data analysis on CSV files. Use for statistical modeling and regression analysis. Do NOT use for simple plotting.
license: MIT
metadata:
  author: My Company
  version: 1.2.0
  tags: [data-analysis, statistics]
---
```
