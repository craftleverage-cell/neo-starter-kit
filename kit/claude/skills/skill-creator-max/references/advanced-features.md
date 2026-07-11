# Advanced Features and Best Practices

This document covers advanced techniques for building more sophisticated and robust skills.

## Programmatic Validation

Instead of relying on natural language instructions for critical checks, use scripts for deterministic validation.

**Why:** Language can be ambiguous. Code is precise. For critical validation steps (e.g., checking for required fields before an API call), a script is more reliable than an instruction like "Make sure the project name is not empty."

**Example:**

Instead of:
> CRITICAL: Before calling `create_project`, verify:
> - Project name is non-empty
> - At least one team member assigned

Use a script:

**SKILL.md:**
> ### Step 2: Validate Project Data
> Run the validation script to ensure data integrity before creating the project.
> ```bash
> python scripts/validate_project.py --file {project_data.json}
> ```
> If the script returns errors, address them and re-run.

**`scripts/validate_project.py`:**
```python
import json
import sys

def validate(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)
    errors = []
    if not data.get('project_name'):
        errors.append("Project name is missing.")
    if not data.get('team_members'):
        errors.append("At least one team member must be assigned.")
    if errors:
        print("Validation Failed:", '\n'.join(errors), file=sys.stderr)
        sys.exit(1)
    print("Validation successful.")

if __name__ == "__main__":
    validate(sys.argv[2])
```

## Modeling Deliberate Action

If a task requires careful, thorough work, explicitly instruct the agent to take its time. This can counteract the model's tendency to rush to a solution.

**Example:**

> # Performance Notes
> - Take your time to do this thoroughly. Quality is more important than speed.
> - Do not skip any validation steps.
> - Think step-by-step and double-check your work before finalizing the output.

**Note:** This is often more effective when included in the user's prompt rather than just in the `SKILL.md`, as it becomes part of the immediate task context.

## Negative Triggering

To prevent a skill from activating on irrelevant queries, add negative constraints to the `description` in the YAML frontmatter.

**Example:**

```yaml
description: Advanced data analysis for CSV files. Use for statistical modeling, regression, and clustering. Do NOT use for simple data exploration (use the data-viz skill instead).
```

This helps the agent disambiguate between similar but distinct skills, improving accuracy and reducing incorrect activations.
