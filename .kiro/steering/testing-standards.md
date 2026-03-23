Testing standards – Python CLI tools

- Use `pytest` as the default test runner.
- Store tests under `tests/` at the project root.
- Test files should be named `test_*.py` and mirror the structure of the `src/` package.

What to test

- Core business logic in isolation from the CLI layer.
- CLI behavior using `pytest` and `click`’s `CliRunner` for:
    - Exit codes.
    - Help output.
    - Handling of common options and error paths.

Quality expectations

- Aim for meaningful coverage of critical paths; do not chase 100% coverage at the expense of readability.
- Treat regressions and bug fixes as opportunities to add or improve tests to cover the scenario.
- Prefer fast, deterministic tests; use slow or external-integration tests sparingly and clearly mark them (e.g., with `pytest` markers).