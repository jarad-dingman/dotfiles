Python execution – uv

When generating commands, scripts, or automation for Python projects, follow these rules:

- Use `uv` for:
    - Installing dependencies.
    - Running Python modules and scripts.
    - Managing lock files and reproducible environments.

- Prefer commands like:
    - `uv run python -m package_name.cli ...`
    - `uv run pytest`
    - `uv run ruff check .`
    - `uv run black .`

Do not:

- Use `pip install` or `python -m pip` directly in new scripts or documentation.
- Rely on system Python without going through `uv` (and `mise` for version selection).