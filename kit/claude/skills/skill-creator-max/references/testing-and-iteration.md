# Testing and Iteration Guide

Testing is not a one-time step; it's a continuous cycle of refinement. A good skill is never truly "done."

## Defining Success Criteria

Before you start testing, define what success looks like. Use a mix of quantitative and qualitative metrics.

-   **Quantitative Metrics:**
    -   **Trigger Rate:** Does the skill trigger on >90% of relevant queries?
    -   **Tool Call Efficiency:** Does the skill reduce the number of tool calls compared to a manual workflow?
    -   **Error Rate:** Does the workflow complete with a 0% API call failure rate?
-   **Qualitative Metrics:**
    -   **Autonomy:** Can the workflow complete without the user needing to provide corrections or clarifications?
    -   **Consistency:** Does the skill produce consistent, high-quality results across multiple runs of the same request?
    -   **Usability:** Can a new user successfully use the skill on their first try with minimal guidance?

## The Testing Workflow

### 1. Trigger Testing

**Goal:** Ensure the skill activates when it should and stays dormant when it shouldn't.

-   **Positive Testing:** Create a list of 10-20 queries that *should* trigger the skill. Run them and track the success rate.
-   **Negative Testing:** Create a list of queries that are related but should *not* trigger the skill. Ensure the skill is not overly broad.
-   **Debugging:** If the skill doesn't trigger, ask the agent directly: "When would you use the `[skill-name]` skill?" The agent will quote the description back to you, revealing what it understands. Refine the description based on this feedback.

### 2. Functional Testing

**Goal:** Verify that the entire workflow executes correctly from start to finish.

-   **Happy Path:** Test the ideal scenario where everything works perfectly.
-   **Error Handling:** Intentionally introduce errors. Does the skill handle them gracefully? (e.g., what happens if an MCP call fails? What if a script encounters bad data?)
-   **Edge Cases:** Test with unusual but valid inputs. What happens with very large files, empty strings, or other edge cases?

### 3. Quality and Consistency Testing

**Goal:** Ensure the output is consistently high-quality.

-   **Run the same request 3-5 times.** Compare the outputs. Are they structurally consistent? Is the quality comparable?
-   **Involve Beta Testers:** Ask a colleague to try the skill. Their fresh perspective will often reveal confusing instructions or gaps in the workflow.

## The Iteration Loop

1.  **Test:** Use the skill in a real-world scenario.
2.  **Observe:** Notice any friction, inefficiencies, or errors.
3.  **Identify:** Pinpoint the exact part of the skill that needs improvement (e.g., the description, a specific instruction, a script).
4.  **Refine:** Implement the change.
5.  **Retest:** Run the same scenario again to confirm the improvement.

This loop is the core of building a robust and effective skill. Embrace the process.
