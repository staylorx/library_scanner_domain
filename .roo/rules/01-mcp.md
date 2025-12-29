You must use MCPs where needed

I have a specific MCP flow:

Use context7 to find any relevant documentation pieces you will need for this process, ensure to feed any relevant knoweldege to any relevant subtasks - use context7 at all times to do research on important documentation if you're unsure of something.

Utilize the roo-code-memory-bank-mcp server to maintain project context:

At the start of a task or significant subtask, use `check_memory_bank_status`.
If the memory bank exists (exists: true), use `read_memory_bank_file` for relevant files (e.g., productContext.md, activeContext.md) to load the current project context.
Incorporate this loaded context into your planning and execution.
When making significant decisions, progress updates, or architectural changes, use `append_memory_bank_entry` to record the information in the appropriate file (decisionLog.md, progress.md, etc.), ensuring context persistence.
If the memory bank doesn't exist, consider using `initialize_memory_bank` if appropriate for the project.

Use the sequential-thinking mcp server:

* Breaking down complex problems into steps
* Planning and design with room for revision
* Analysis that might need course correction
* Problems where the full scope might not be clear initially
* Tasks that need to maintain context over multiple steps
* Situations where irrelevant information needs to be filtered out
