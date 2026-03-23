Python version management – mise

For all Python projects:

- Use `mise` to manage the Python runtime version globally and per project.
- Each project should include a `.mise.toml` file specifying:
    - The preferred Python version (latest stable 3.x).
    - Any `uv`-related shims or tasks for running commands (linting, testing, formatting, etc.).

Kiro should:

- Prefer `mise`-managed Python when running commands or generating scripts.
- Use `.mise.toml` as the source of truth for Python versions, rather than relying on system Python or ad-hoc `pyenv`/`venv` setups.