# Technical Requirements

This document outlines the technical specifications for building a valid skill.

## File and Folder Naming

-   **Skill Folder:** Must be `kebab-case`.
    -   ✅ `my-cool-skill`
    -   ❌ `My Cool Skill`, `my_cool_skill`
-   **SKILL.md:** The main skill file must be named `SKILL.md` (case-sensitive).
    -   ✅ `SKILL.md`
    -   ❌ `skill.md`, `Skill.md`
-   **README.md:** Do NOT include a `README.md` file inside the skill folder. The README belongs in the root of your Git repository, for human readers.

## File Structure

```
skill-name/
├── SKILL.md          # Required: Main skill file with instructions.
├── scripts/          # Optional: Executable code (e.g., .py, .sh).
├── references/       # Optional: Supporting documents to be read by the agent.
└── templates/        # Optional: Boilerplate files for generating output.
```

## YAML Frontmatter

The frontmatter in `SKILL.md` is critical for skill discovery. It must be valid YAML enclosed in `---` delimiters.

### Required Fields

-   `name` (string): The name of the skill. Must match the folder name (kebab-case).
-   `description` (string): A description of what the skill does and when to use it. Must be under 1024 characters and must not contain XML tags (`<` or `>`).

### Optional Fields

-   `license` (string): The license for the skill (e.g., `MIT`, `Apache-2.0`).
-   `compatibility` (string): A description of any environment requirements (e.g., "Requires Node.js v18+").
-   `metadata` (object): A key-value map for custom metadata.
    -   Recommended keys: `author`, `version`, `mcp-server`.

### Security Restrictions

-   **No XML Tags:** The `<` and `>` characters are forbidden in the frontmatter to prevent prompt injection.
-   **Reserved Names:** Skill names cannot contain "claude" or "anthropic".
