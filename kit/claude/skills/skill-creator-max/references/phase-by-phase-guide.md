# Phase-by-Phase Guide to Building Skills

This guide provides a detailed walkthrough of the 6 phases of skill creation.

## Phase 1: Plan and Design

**Goal:** Establish a clear vision for your skill.

1.  **Define the Use Case:** What specific problem will this skill solve? Who is the target user?
2.  **Identify the Category:**
    *   **Category 1: Document and Asset Creation:** For creating consistent, high-quality outputs like documents, presentations, or code.
    *   **Category 2: Workflow Automation:** For multi-step processes that benefit from a consistent methodology.
    *   **Category 3: MCP Enhancement:** For providing workflow guidance on top of MCP server tools.
3.  **Set Success Criteria:** How will you measure if the skill is working effectively? (e.g., triggers on 90% of relevant queries, completes workflow with 0 errors).

*Self-Correction Question: Is the use case specific enough? A vague goal like "helps with projects" is less effective than "generates a project kickoff presentation from a brief."*

## Phase 2: Technical Setup

**Goal:** Create the foundational structure of your skill.

1.  **File Structure:** Create the skill directory (e.g., `my-cool-skill/`) with `SKILL.md`, and optional `scripts/`, `references/`, and `templates/` folders.
2.  **YAML Frontmatter:** In `SKILL.md`, create the frontmatter. This is the most critical part for skill discovery.
    *   `name`: Must be kebab-case and match the folder name.
    *   `description`: Clearly state **what it does** and **when to use it**. Include specific trigger phrases.

*Self-Correction Question: Does my description include concrete examples of what a user might say to activate this skill?*

## Phase 3: Write Instructions

**Goal:** Draft the core logic of your skill in `SKILL.md`.

1.  **Structure:** Use clear headings, lists, and code blocks. Start with the main steps.
2.  **Be Specific and Actionable:** Instead of "Validate the data," write "Run `python scripts/validate.py --input {filename}` to check for missing fields."
3.  **Include Error Handling:** Document common errors, their causes, and solutions.
4.  **Provide Examples:** Show a clear example of user input and the expected agent actions and results.

*Self-Correction Question: If another developer read these instructions, could they execute the workflow without asking for clarification?*

## Phase 4: Develop Resources

**Goal:** Build the reusable components of your skill.

1.  **Scripts (`scripts/`):** Write and test any Python or shell scripts needed for automation. Ensure they are robust and have clear inputs/outputs.
2.  **Reference Documents (`references/`):** Move detailed documentation, schemas, or API guides here to keep `SKILL.md` lean. Link to them from the main instructions.
3.  **Templates (`templates/`):** Create boilerplate files, report structures, or other assets that the skill will use to generate outputs.

*Self-Correction Question: Am I repeating code or large blocks of text in my `SKILL.md`? If so, they should be moved to a script or reference file.*

## Phase 5: Test and Iterate

**Goal:** Ensure the skill is reliable, effective, and easy to use.

1.  **Trigger Testing:** Does the skill activate on the right queries? Does it ignore irrelevant ones?
2.  **Functional Testing:** Execute the entire workflow. Does it complete successfully? Does it handle errors gracefully?
3.  **Quality Testing:** Is the output high-quality and consistent across multiple runs?
4.  **Iterate:** Use the feedback from testing to refine the description, instructions, and resources.

*Self-Correction Question: Did the skill require me to manually correct its course or provide extra clarification during testing? If so, the instructions need to be improved.*

## Phase 6: Distribute and Share

**Goal:** Package and document the skill for others to use.

1.  **Create a README:** In your Git repository (but NOT inside the skill folder), create a `README.md` that explains the skill's value, shows usage examples, and provides installation instructions.
2.  **Document Installation:** Provide clear, step-by-step instructions for users to download and install the skill.
3.  **Positioning:** Frame the skill's value in terms of outcomes, not features. Instead of "This skill calls our MCP server," say "This skill automates your entire customer onboarding workflow."

*Self-Correction Question: Is it clear to a new user what this skill does and why they should use it within the first 30 seconds of reading the README?*
