# CLAUDE.md

## Project

A real-time political and policy simulator: the player leads a country and makes policy and other decisions while game time runs.

This file covers how to work in the repo. What to build lives in `docs/` (see Docs).

## Stack

- Godot 4.7.2, GDScript only (no C#, no GDExtension)
- Statically typed GDScript; `project.godot` treats untyped declarations as errors. Never disable that warning to make code compile.
- Content data: Godot `Resource` scripts with `.tres` instances
- Tests: GUT, committed under `addons/gut/`
- Lint/format: `gdtoolkit` (`gdlint`, `gdformat`), installed with `pip install "gdtoolkit==4.*"`
- Ask before adding any addon, tool or dependency not listed here.

## Structure

Dependencies flow downward only: `core/` never references `ui/`, `scenes/` or `autoload/`.

- `core/` — game logic as plain `RefCounted`/`Resource` classes; no `Node`, no SceneTree
- `data/` — `.tres` content instances; their `Resource` scripts live in `core/`
- `scenes/` — gameplay scenes; each scene sits next to its script (`scenes/main_menu/main_menu.tscn` + `main_menu.gd`)
- `ui/` — reusable UI scenes and components, same pairing rule
- `autoload/` — singletons; keep these few and thin
- `addons/` — third-party plugins; never edit
- `tests/` — GUT tests, mirroring the source path (`core/foo/bar.gd` → `tests/core/foo/test_bar.gd`)
- `docs/` — design docs

## Commands

Godot is invoked as `godot` on PATH.

- Run: `godot --path .`
- Import / check scripts: `godot --headless --path . --import`
- Test: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
- Single test file: add `-gselect=test_bar.gd`
- Lint: `gdlint core scenes ui autoload tests`
- Format: `gdformat core scenes ui autoload tests`

## Verification

After every change, in this order:

1. Format
2. Lint
3. Import / check scripts (no errors or warnings)
4. Tests for what changed (whole suite before committing)

## Architecture rules

- **Logic vs. presentation:** game logic lives in `core/`. Nodes display state and forward player input; they don't own rules.
- **Communication:** call down, signal up. Parents call children; children emit signals. No reaching up the tree with `get_parent()` or absolute node paths.
- **Node references:** use `@onready` with `%UniqueName`, or `@export` node references. No long `$A/B/C` paths.
- **Autoloads:** only for true global services (session, saves, settings). Never as a dumping ground for shared state.
- **Data:** content is a typed `Resource` subclass in `core/` with instances in `data/`. Adding content should not require new code.
- **Saves:** carry a format version. New fields get defaults; breaking changes add a migration.
- **Errors:** `assert` for programmer invariants, `push_error` for bad data or runtime failures. No silent fallbacks.

## Code style

- Follow the official GDScript style guide: `snake_case` files, functions and variables; `PascalCase` `class_name`s; `CONSTANT_CASE` constants and enum values; `_` prefix for private members; signals named in past tense (`budget_changed`).
- Type every variable, parameter and return value. Use `class_name` for reusable types. Prefer enums over flag booleans.
- Descriptive names over comments. Comment only *why*, never *what*.
- Keep files small and single-purpose. Stay under 500 lines; split before reaching it.

## Testing

- Test logic that can break in non-obvious ways: `core/` rules and calculations, resource validation, save round-trips and migrations.
- Don't test UI layout, engine behavior, addons, or trivial getters/setters.
- One test per behavior; no duplicate coverage.

## Cross-platform

Development happens on Windows and in Linux cloud sessions.

- Paths only through `res://` and `user://`; never OS-specific paths or separators.
- LF line endings (enforced by `.gitattributes`).
- No OS-specific tools or shell syntax in scripts or commands.

## Docs

- Game design lives in `docs/`, one file per system. Read only the doc for the system you're working on; don't infer design from code.
- Keep docs short and explicit: decisions and constraints, no essays or history.
- Update a doc in place when a decision changes; never append changelogs.
- The same applies to this file: keep it lean.

## Working in this repo

- Search before reading: use Grep/Glob to locate code, then read only the relevant line ranges.
- Edit in place with targeted edits. Never rewrite a whole file for a small change.
- Don't reread a file you just edited.
- Never edit `.godot/` or `*.import` files.
- `*.uid` files are committed and never hand-edited; when moving or renaming a script, move its `.uid` with it.
- When editing `.tscn`/`.tres` files, preserve `uid` and `ext_resource` ids. Prefer small edits; ask before creating complex scenes by hand.

## Commits

Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):

- Format: `<type>(<scope>): <description>`, imperative, lowercase, no trailing period
- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `style`
- Scope is the top-level folder: `feat(core): add budget resource`, `docs(design): define approval rating`
- Breaking changes: `!` after the scope and a `BREAKING CHANGE:` footer
- Commit sparingly: one commit per complete, verified unit of work, not per edit. Never commit work in progress or failing checks.
- Push rarely: only when a task or feature is finished, or when asked. Batch commits locally first; never push after every commit.

## Don't

- Don't put game rules in Nodes — move them to `core/`.
- Don't hardcode the player's office or nation — read it from data.
- Don't leave anything untyped — add the type.
- Don't edit `addons/`, `.godot/` or `*.import` — change project code or settings instead.
- Don't write tests for trivial or engine behavior — test the logic we own.
- Don't grow docs — cut before adding.
