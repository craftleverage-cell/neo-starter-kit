# Workflow Patterns

These patterns represent common, effective approaches to structuring skill instructions. Adapt them to your specific use case.

## Pattern 1: Sequential Workflow Orchestration

**Use Case:** A process with multiple steps that must be executed in a specific order.

**Example:** Onboarding a new customer.

```markdown
# Workflow: Onboard New Customer

### Step 1: Create Account
Call the `create_customer` MCP tool with the customer's name, email, and company.

### Step 2: Set Up Payment
Call the `setup_payment_method` MCP tool and wait for verification.

### Step 3: Create Subscription
Using the `customer_id` from Step 1, call the `create_subscription` MCP tool with the chosen `plan_id`.

### Step 4: Send Welcome Email
Call the `send_email` MCP tool using the `welcome_email_template`.
```

**Key Techniques:**
- Explicit step-by-step instructions.
- Clear dependencies between steps (e.g., using an ID from a previous step).
- Validation points after each critical action.

## Pattern 2: Multi-MCP Coordination

**Use Case:** A workflow that spans multiple services or tools (e.g., Figma, Google Drive, and Linear).

**Example:** Design-to-development handoff.

```markdown
### Phase 1: Export from Figma (Figma MCP)
1.  Export design assets and specifications from the Figma file.
2.  Create an asset manifest file.

### Phase 2: Store Assets (Drive MCP)
1.  Create a new project folder in Google Drive.
2.  Upload all assets from Phase 1.
3.  Generate shareable links for the assets.

### Phase 3: Create Tasks (Linear MCP)
1.  Create development tasks in the appropriate Linear project.
2.  Attach the asset links from Phase 2 to each task.
```

**Key Techniques:**
- Clear separation of phases by tool/service.
- Instructions on how to pass data between MCPs.
- Validation before moving to the next phase.

## Pattern 3: Iterative Refinement

**Use Case:** When the quality of the output improves with iteration and feedback.

**Example:** Generating a complex report.

```markdown
### 1. Initial Draft
- Fetch the raw data via the MCP.
- Generate the first draft of the report and save it to a temporary file.

### 2. Quality Check
- Run the validation script: `scripts/check_report.py`.
- The script will identify issues like missing sections, inconsistent formatting, or data anomalies.

### 3. Refinement Loop
- Address each issue identified in the quality check.
- Regenerate the affected sections of the report.
- Re-run the validation script.
- **Repeat this loop until the quality threshold is met and the script passes with no errors.**

### 4. Finalization
- Apply final formatting and generate a summary.
- Save the final version.
```

**Key Techniques:**
- An explicit quality checklist or validation script.
- A clear loop structure (e.g., "Repeat until...").
- A defined exit criterion for the loop.

## Pattern 4: Context-Aware Tool Selection

**Use Case:** When the right tool for the job depends on the context (e.g., file size, type).

**Example:** Smart file storage.

```markdown
### Decision Tree for File Storage

1.  **Analyze the file:** Check its type, size, and purpose.
2.  **Select the best tool based on these rules:**
    -   **Large files (>100MB):** Use the cloud storage MCP (e.g., S3).
    -   **Collaborative documents:** Use the Notion or Google Docs MCP.
    -   **Code files:** Use the GitHub MCP.
    -   **Temporary files:** Use local sandbox storage.
3.  **Execute:** Call the appropriate MCP tool and apply service-specific metadata.
4.  **Inform the User:** Explain which tool was chosen and why.
```

**Key Techniques:**
- A clear decision tree or set of rules.
- Fallback options.
- Transparency with the user about the choices made.
```
