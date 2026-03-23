Code conventions – Python CLI tools

General style

- Follow PEP 8 as enforced by `ruff` and `black`.
- Use type hints throughout the codebase; treat type annotations as required for public functions and classes.
- Prefer small, composable functions over large monolithic ones.

CLI design

- Provide a top-level `--version` flag where appropriate.
- Ensure `--help` output is clear, with:
    - A concise description.
    - Examples for common usage.
    - Helpful parameter descriptions, especially for flags with non-obvious behavior.

Logging and console output

- Use `rich` for all user-facing console output.
- Use `rich` logging handler for structured logs:
    - Configure a single application logger (e.g., `logger = logging.getLogger("app_name")`) with `RichHandler`.
    - Avoid writing your own raw ANSI color codes; let `rich` handle styles and theming.
- Separate human-readable output (for interactive users) from machine-readable output (e.g., JSON) where necessary, and document the behavior.

Error handling

- Fail with clear error messages printed via `rich` (e.g., styled panels or formatted tracebacks where appropriate).
- Exit with non-zero status codes for error conditions.
- Avoid exposing raw stack traces unless running in a debug or verbose mode.

Imports and layout

- Use `ruff` to manage import ordering.
- Avoid unused imports; treat `ruff` warnings as errors that must be fixed.
- Keep modules focused; if a file grows too large or mixes responsibilities, split it into smaller modules.
