# Troubleshooting Guide

This guide helps resolve common issues when building and using skills.

## Skill Fails to Upload

-   **Error: "Could not find SKILL.md in the uploaded folder."**
    -   **Cause:** The main skill file is not named exactly `SKILL.md` (it's case-sensitive).
    -   **Solution:** Rename the file to `SKILL.md`.

-   **Error: "Invalid frontmatter."**
    -   **Cause:** The YAML frontmatter has a syntax error (e.g., missing `---` delimiters, unclosed quotes).
    -   **Solution:** Validate the YAML syntax. Ensure it starts and ends with `---`.

-   **Error: "Invalid skill name."**
    -   **Cause:** The `name` in the frontmatter contains spaces or uppercase letters.
    -   **Solution:** The name must be `kebab-case` and match the folder name.

## Skill Fails to Trigger

-   **Symptom:** The skill does not activate when you expect it to.
-   **Solution:** Your `description` is not specific enough.
    -   **Checklist:**
        -   Is it too generic (e.g., "Helps with projects")?
        -   Does it include the specific trigger phrases a user would say?
        -   Does it mention relevant file types if applicable?
    -   **Debug:** Ask the agent, "When do you use the `[skill-name]` skill?" It will quote the description, revealing its understanding. Adjust accordingly.

## Skill Triggers Too Often

-   **Symptom:** The skill activates for irrelevant queries.
-   **Solution:** Make the `description` more specific.
    1.  **Add Negative Triggers:** `description: Advanced data analysis for CSV files. Do NOT use for simple data exploration.`
    2.  **Be More Specific:** Change "Processes documents" to "Processes PDF legal documents for contract review."
    3.  **Clarify Scope:** Add a clarifying phrase, like "Use specifically for online payment workflows, not for general financial queries."

## Instructions Are Not Followed

-   **Symptom:** The skill triggers, but the agent doesn't follow the instructions correctly.
-   **Causes & Solutions:**
    -   **Instructions are too verbose:** Keep instructions concise. Use bullet points and numbered lists. Move long paragraphs to `references/`.
    -   **Instructions are buried:** Place critical instructions at the top. Use headings like `## CRITICAL` to draw attention.
    -   **Ambiguous language:** Be explicit. Instead of "Validate things properly," provide a concrete command: `CRITICAL: Before calling create_project, run scripts/validate.py.`
    -   **Use programmatic checks:** For critical validation, don't rely on language. A script that exits with an error code is more reliable than an instruction.
