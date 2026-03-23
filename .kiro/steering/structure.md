Project structure – Python CLI tools

New Python CLI tools should follow a consistent layout similar to:project-root/

  src/
    package_name/
      __init__.py
      cli.py          # click entrypoints
      core.py         # core logic (no I/O-heavy code)
  tests/
    test_cli.py
    test_core.py
  pyproject.toml
  .mise.toml
  README.md

Guidelines:

- Put `click` commands in a dedicated `cli.py` module (or a `cli/` package for larger tools).
- Keep business logic in separate modules (`core.py`, etc.) so it can be tested independently of the CLI.
- Use `if __name__ == "__main__":` only as a thin wrapper that calls a `click` command via `click.Command` or `click.Group` entrypoint.
- Configure entrypoints via `pyproject.toml`’s `project.scripts` (or equivalent) so tools can be installed and invoked as console scripts.