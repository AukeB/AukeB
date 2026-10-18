#!/usr/bin/env python3
"""Writes an HTML report of the dependencies of every project in the Projects folder.

Every pyproject.toml is one column, named after its folder. Every unique package across all
projects is one row. A cell holds the version that uv.lock resolved for that project. Cells are
coloured by comparing that version with the latest version on PyPI:
- light green: the same version as the latest release
- light red: an older version than the latest release
- gray: the project does not use the package

Dependencies from [project].dependencies, [project.optional-dependencies], [dependency-groups]
and [tool.uv].dev-dependencies are all included.
"""

import html
import json
import re
import sys
import tomllib
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

# Folders that are never searched for pyproject.toml files.
_SKIPPED_FOLDERS = {".git", ".venv", "node_modules"}

# Where the HTML report is written, relative to the profile repo.
_OUTPUT_PATH = Path("docs") / "dependency_matrix.html"

_PYPI_URL = "https://pypi.org/pypi/{name}/json"
_PYPI_TIMEOUT_SECONDS = 10

# Name at the start of a PEP 508 requirement, such as "requests[socks]>=2 ; python_version<'4'".
_REQUIREMENT_NAME = re.compile(r"^\s*([A-Za-z0-9][A-Za-z0-9._-]*)")

# Background colours for the cell states.
_COLOR_SAME = "#d4f5d4"
_COLOR_LOWER = "#f8d0d0"
_COLOR_EMPTY = "#e3e3e3"

_CSS = """
body { font-family: system-ui, sans-serif; margin: 24px; color: #222; }
h1 { font-size: 1.4em; }
.legend span { display: inline-block; padding: 2px 10px; margin-right: 8px; border-radius: 4px; }
.table-wrap { overflow: auto; max-height: 85vh; border: 1px solid #ccc; }
table { border-collapse: collapse; font-size: 13px; }
th, td { border: 1px solid #ccc; padding: 4px 8px; white-space: nowrap; }
th { background: #f2f2f2; position: sticky; top: 0; z-index: 2; }
td:first-child, th:first-child { position: sticky; left: 0; background: #fff; z-index: 1; }
th:first-child { background: #f2f2f2; z-index: 3; }
td.same { background: #d4f5d4; }
td.lower { background: #f8d0d0; }
td.empty { background: #e3e3e3; }
"""


def normalize_name(name: str) -> str:
    """Lowercase a package name and replace runs of '-', '_' and '.' with a single '-'.

    Args:
        name (str): The package name as written in a requirement or lock file.

    Returns:
        normalized_name (str): The name in the form PyPI uses for comparison.
    """

    normalized_name = re.sub(r"[-_.]+", "-", name).lower()

    return normalized_name


def find_pyproject_files(base: Path) -> list[Path]:
    """Find every pyproject.toml under the base folder, skipping .git, .venv and node_modules.

    Args:
        base (Path): The folder to search.

    Returns:
        pyproject_files (list[Path]): The paths of the pyproject.toml files, sorted.
    """

    pyproject_files: list[Path] = []
    for path in base.rglob("pyproject.toml"):
        if not any(part in _SKIPPED_FOLDERS for part in path.relative_to(base).parts):
            pyproject_files.append(path)

    return sorted(pyproject_files)


def requirement_name(requirement: str) -> str | None:
    """Get the normalized package name from a requirement string.

    Args:
        requirement (str): A requirement such as "numpy>=2.0".

    Returns:
        name (str | None): The normalized package name, or None if the string has no name.
    """

    match = _REQUIREMENT_NAME.match(requirement)
    if match is None:
        return None

    name = normalize_name(match.group(1))

    return name


def direct_dependencies(pyproject: dict[str, Any]) -> set[str]:
    """Collect the names of all direct dependencies declared in a pyproject.toml.

    Args:
        pyproject (dict[str, Any]): The parsed pyproject.toml.

    Returns:
        names (set[str]): Normalized names from every dependency group.
    """

    requirements: list[str] = list(pyproject.get("project", {}).get("dependencies", []))

    optional = pyproject.get("project", {}).get("optional-dependencies", {})
    for group in optional.values():
        requirements.extend(group)

    # PEP 735 dependency groups. Entries that are {include-group = ...} tables are skipped,
    # because the group they include is already listed under its own name.
    for group in pyproject.get("dependency-groups", {}).values():
        requirements.extend(item for item in group if isinstance(item, str))

    requirements.extend(pyproject.get("tool", {}).get("uv", {}).get("dev-dependencies", []))

    names: set[str] = set()
    for requirement in requirements:
        name = requirement_name(requirement)
        if name is not None:
            names.add(name)

    return names


def locked_versions(lock_path: Path) -> dict[str, str]:
    """Read the version that uv.lock resolved for each package.

    Args:
        lock_path (Path): The path to the uv.lock file.

    Returns:
        versions (dict[str, str]): Normalized package name mapped to its locked version.
    """

    with lock_path.open("rb") as file:
        lock = tomllib.load(file)

    versions: dict[str, str] = {}
    for package in lock.get("package", []):
        version = package.get("version")
        if version is not None:
            versions[normalize_name(package["name"])] = version

    return versions


def latest_pypi_version(name: str) -> str:
    """Look up the latest release of a package on PyPI.

    Args:
        name (str): The normalized package name.

    Returns:
        version (str): The latest version, or "?" if PyPI cannot be reached.
    """

    try:
        with urllib.request.urlopen(
            _PYPI_URL.format(name=name), timeout=_PYPI_TIMEOUT_SECONDS
        ) as response:
            data = json.load(response)
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
        return "?"

    version = data["info"]["version"]

    return version


def version_numbers(version: str) -> tuple[int, ...]:
    """Turn a version string into its numbers, so versions can be compared.

    Args:
        version (str): A version such as "1.1.414" or "0.25.1rc1".

    Returns:
        numbers (tuple[int, ...]): The numbers in order, such as (1, 1, 414).
    """

    numbers = tuple(int(part) for part in re.findall(r"\d+", version))

    return numbers


def cell_class(version: str, latest: str) -> str:
    """Pick the colour class for a cell by comparing its version with the latest PyPI version.

    Args:
        version (str): The locked version, or an empty string if the project does not use the package.
        latest (str): The latest version on PyPI, or "?" if it could not be read.

    Returns:
        css_class (str): "same", "lower", "empty", or "" when the cell gets no colour.
    """

    if not version:
        css_class = "empty"
    elif version == latest:
        css_class = "same"
    elif latest == "?":
        css_class = ""
    else:
        locked = version_numbers(version)
        newest = version_numbers(latest)
        width = max(len(locked), len(newest))
        padded_locked = locked + (0,) * (width - len(locked))
        padded_newest = newest + (0,) * (width - len(newest))
        css_class = "lower" if padded_locked < padded_newest else ""

    return css_class


def build_matrix(base: Path) -> tuple[list[str], dict[str, dict[str, str]]]:
    """Build the dependency matrix for every project.

    Args:
        base (Path): The folder to search for projects.

    Returns:
        result (tuple[list[str], dict[str, dict[str, str]]]): The project names, in order,
            and a mapping of package name to its locked version per project.
    """

    pyproject_files = find_pyproject_files(base)

    project_names: list[str] = []
    cells: dict[str, dict[str, str]] = {}

    for pyproject_path in pyproject_files:
        name = pyproject_path.parent.name
        project_names.append(name)

        with pyproject_path.open("rb") as file:
            pyproject = tomllib.load(file)

        lock_path = pyproject_path.parent / "uv.lock"
        if not lock_path.exists():
            print(f"skip (no uv.lock): {name}", file=sys.stderr)
            continue

        locked = locked_versions(lock_path=lock_path)
        for dependency in direct_dependencies(pyproject=pyproject):
            version = locked.get(dependency, "")
            cells.setdefault(dependency, {})[name] = version

    return project_names, cells


def render_html(project_names: list[str], cells: dict[str, dict[str, str]]) -> str:
    """Render the matrix as a standalone HTML page.

    Args:
        project_names (list[str]): The project column names, in order.
        cells (dict[str, dict[str, str]]): Package name mapped to its version per project.

    Returns:
        page (str): The complete HTML document.
    """

    # Count how many projects use each package, then list the most used packages first.
    usage: dict[str, int] = {package: len(cells[package]) for package in cells}
    packages = sorted(cells, key=lambda package: (-usage[package], package))

    header_cells = "".join(f"<th>{html.escape(name)}</th>" for name in project_names)
    header = f"<tr><th>Package</th><th>Latest on PyPI</th><th>Used by</th>{header_cells}</tr>"

    rows: list[str] = []
    for package in packages:
        latest = latest_pypi_version(name=package)
        version_cells: list[str] = []
        for project in project_names:
            version = cells[package].get(project, "")
            css_class = cell_class(version=version, latest=latest)
            class_attr = f' class="{css_class}"' if css_class else ""
            version_cells.append(f"<td{class_attr}>{html.escape(version)}</td>")

        rows.append(
            f"<tr><td>{html.escape(package)}</td><td>{html.escape(latest)}</td>"
            f"<td>{usage[package]}</td>{''.join(version_cells)}</tr>"
        )

    legend = (
        f'<span style="background:{_COLOR_SAME}">same as latest on PyPI</span>'
        f'<span style="background:{_COLOR_LOWER}">older than latest on PyPI</span>'
        f'<span style="background:{_COLOR_EMPTY}">not used</span>'
    )

    page = (
        "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n"
        "<title>Dependency matrix</title>\n"
        f"<style>{_CSS}</style>\n</head>\n<body>\n"
        "<h1>Dependency matrix</h1>\n"
        f"<p>{len(project_names)} projects, {len(packages)} unique packages.</p>\n"
        f'<p class="legend">{legend}</p>\n'
        f'<div class="table-wrap"><table>\n<thead>{header}</thead>\n'
        f"<tbody>\n{chr(10).join(rows)}\n</tbody>\n</table></div>\n"
        "</body>\n</html>\n"
    )

    return page


def main() -> None:
    """Build the dependency matrix and write it to docs/dependency_matrix.html."""

    # This script lives in AukeB/scripts/, so two levels up is the Projects folder.
    base = Path(__file__).resolve().parents[2]

    project_names, cells = build_matrix(base=base)
    page = render_html(project_names=project_names, cells=cells)

    output_path = Path(__file__).resolve().parents[1] / _OUTPUT_PATH
    output_path.write_text(page, encoding="utf-8")
    print(f"Wrote {output_path}")


if __name__ == "__main__":
    main()
