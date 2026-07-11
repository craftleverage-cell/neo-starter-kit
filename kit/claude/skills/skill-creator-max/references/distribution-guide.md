# Distribution and Sharing Guide

Once your skill is tested and refined, it's time to share it with others.

## Hosting Your Skill

The best practice is to host your skill in a public Git repository (e.g., on GitHub).

-   **Repository Structure:**
    -   The root of the repository should contain a `README.md` file for human users.
    -   The skill folder itself (`your-skill-name/`) should be in the root of the repository.
-   **Clear README:** The `README.md` is your skill's storefront. It should include:
    -   A clear value proposition (focus on outcomes, not features).
    -   Usage examples, including screenshots or GIFs.
    -   Clear, step-by-step installation instructions.

## Installation Instructions

Provide a clear, copy-pasteable set of instructions in your `README.md`.

**Example:**

> ## Installing the [Your Service] Skill
>
> 1.  **Download the skill:**
>     -   Clone the repository: `git clone https://github.com/your-company/your-skill-repo.git`
>     -   Or download the ZIP file from the Releases page.
>
> 2.  **Install in the Agent:**
>     -   Open the agent interface > Settings > Skills.
>     -   Click "Upload Skill."
>     -   Select the skill folder (or the zipped skill folder).
>
> 3.  **Enable the Skill:**
>     -   Toggle the skill on in your skill library.
>     -   If it uses an MCP, ensure your MCP server is connected.
>
> 4.  **Test it:**
>     -   Ask the agent: "Help me set up a new project in [Your Service]."

## Positioning Your Skill

How you describe your skill determines whether users will understand its value and try it.

-   **Focus on Outcomes, Not Features:**
    -   **Bad:** "The ProjectHub skill is a folder containing YAML frontmatter and Markdown instructions that calls our MCP server tools."
    -   **Good:** "The ProjectHub skill enables teams to set up complete project workspaces in seconds—including pages, databases, and templates—instead of spending 30 minutes on manual setup."

-   **Highlight the MCP + Skill Story:**
    -   "Our MCP server gives the agent access to your Linear projects. Our skill teaches the agent your team's sprint planning workflow. Together, they enable AI-powered project management."
