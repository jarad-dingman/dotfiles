### Technology stack – Python CLI tools

For any Python application created as a tool or command-line utility, follow these technology choices:

Language and runtime

- Prefer the latest stable CPython 3.x release.
- Use `mise` for Python version management.
- Each project should declare its Python version in a `.mise.toml` file.

CLI framework

- Use `click` for building command-line interfaces.
- All public entrypoints should be implemented as `click` commands and groups.
- Support `--help` on all commands with clear usage and examples.

Console output and logging

- Use `rich` for logging and console output:
 - Structured, colorized logs where appropriate.
 - Tables, progress bars, and tracebacks via `rich`.
- Do not use bare `print()` for anything other than the simplest one-off debug scenarios; prefer `rich.console.Console` and `rich.logging.RichHandler`.

Dependency management and packaging

- Use `uv` for dependency management and execution.
- Dependencies should be declared using `uv`-managed configuration (e.g., `pyproject.toml` with `uv` lock files).
- Use `uv` commands instead of `pip` or `pip-tools` for installs and upgrades.
- Avoid per-project `virtualenv`/`venv` tooling in favor of `uv` and `mise` together.

Linting and formatting

- Use `ruff` as the primary linter (and, where appropriate, for import sorting).
- Use `black` for code formatting.
- Configure `ruff` and `black` in `pyproject.toml` where possible so they share the same configuration file.
- Projects should provide standard tasks (via `Makefile`, `justfile`, or `uvx` scripts) to run linting and formatting.

Testing

- Use `pytest` as the testing framework.
- Name test files `test_*.py` and place them under a `tests/` directory at the project root.
- Prefer small, focused tests with clear names and minimal fixtures.

Use this stack consistently across all Python CLI tools unless a steering file explicitly defines an exception for a specific project.