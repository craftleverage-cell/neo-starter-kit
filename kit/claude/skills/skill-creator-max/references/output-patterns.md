# Output Patterns

This guide provides patterns for generating consistent, high-quality outputs.

## Pattern 1: Template-Based Generation

**Use Case:** Creating structured documents like reports, presentations, or code files.

**How it Works:**
1.  Create a template file in the `templates/` directory (e.g., `report_template.md`).
2.  The template should contain placeholders for dynamic content (e.g., `{{title}}`, `{{data_table}}`).
3.  The skill instructions should direct the agent to:
    a.  Read the template file.
    b.  Gather the necessary data.
    c.  Replace the placeholders with the data.
    d.  Write the final output to a new file.

**Example `SKILL.md` instruction:**
> "Generate the weekly report by populating `templates/weekly_report.md` with the latest sales data."

## Pattern 2: Quality Checklist

**Use Case:** Ensuring that all outputs meet a certain quality standard before being finalized.

**How it Works:**
-   Include a `### Quality Checklist` section in your `SKILL.md`.
-   This checklist should contain a series of verifiable points that the agent must confirm before finishing the task.

**Example Checklist:**
> ### Quality Checklist
> Before delivering the final document, verify the following:
> - [ ] All sections from the template are included.
> - [ ] The document has been spell-checked.
> - [ ] All data tables are correctly formatted.
> - [ ] The summary accurately reflects the content.

## Pattern 3: Structured Data Output (JSON/YAML)

**Use Case:** When the skill's output is intended to be consumed by another program or script.

**How it Works:**
-   Instruct the agent to format its output as a JSON or YAML object.
-   Provide a clear schema or example of the desired structure in the instructions.

**Example `SKILL.md` instruction:**
> "Analyze the user request and output a JSON object with the following structure:
> ```json
> {
>   "intent": "<user_intent>",
>   "entities": {
>     "project_name": "<project_name>",
>     "due_date": "<due_date_iso_8601>"
>   }
> }
> ```"
