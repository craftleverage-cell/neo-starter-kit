# Progressive Disclosure Patterns

Progressive disclosure is a core principle of skill design. It ensures that the agent has the right information at the right time without overwhelming its context window. The goal is to keep the initial context load as small as possible.

## The Three-Layer System

1.  **Layer 1: YAML Frontmatter (Always in Context)**
    -   **Content:** `name` and `description`.
    -   **Purpose:** To help the agent decide *when* to use the skill.
    -   **Size:** Should be very small (~100 words).

2.  **Layer 2: `SKILL.md` Body (Loaded on Trigger)**
    -   **Content:** The main instructions, workflow steps, and pointers to other resources.
    -   **Purpose:** To guide the agent on *how* to execute the skill.
    -   **Size:** Keep it lean. Aim for under 500 lines. If it gets longer, it's a sign you should move content to Layer 3.

3.  **Layer 3: Linked Files (`references/`, `scripts/`) (Loaded as Needed)**
    -   **Content:** Detailed documentation, long examples, schemas, helper scripts.
    -   **Purpose:** To provide deep, specialized knowledge or tools that are only needed for specific parts of the workflow.
    -   **Size:** Can be large, as they are only loaded on demand.

## Pattern 1: Moving Details to `references/`

**Problem:** Your `SKILL.md` is getting too long with detailed explanations, examples, or schemas.

**Solution:**
1.  Create a new file in the `references/` directory (e.g., `api_guide.md`, `detailed_examples.md`).
2.  Move the detailed content from `SKILL.md` into the new file.
3.  In `SKILL.md`, replace the content with a clear pointer to the reference file.

**Example:**

**Before (in `SKILL.md`):**
> ### API Schema
> The project object has the following structure:
> ```json
> {
>   "id": "string",
>   "name": "string",
>   "description": "string",
>   ...
> }
> ```

**After:**

**`SKILL.md`:**
> ### API Schema
> For the full project schema, refer to `references/project_schema.json`.

**`references/project_schema.json`:**
> ```json
> {
>   "id": "string",
>   "name": "string",
>   "description": "string",
>   ...
> }
> ```

## Pattern 2: Multi-Domain Skills

**Problem:** You have a skill that applies to multiple domains (e.g., finance, sales, product), and each has its own specific rules.

**Solution:**
1.  Keep the core, shared workflow in `SKILL.md`.
2.  Create a separate file in `references/` for each domain (e.g., `finance.md`, `sales.md`).
3.  In `SKILL.md`, create a routing instruction that tells the agent which reference file to read based on the user's context.

**Example `SKILL.md`:**
> ## Domain-Specific Rules
> Based on the user's department, apply the relevant rules:
> - If the user is in Finance, read and follow the instructions in `references/finance_rules.md`.
> - If the user is in Sales, read and follow the instructions in `references/sales_rules.md`.
