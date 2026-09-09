#!/usr/bin/env python3
"""Bootstrap a themed source tree from infocom/zork1.

The script intentionally does not alter actions.zil or dungeon.zil.  Those two
files define a game's story and world and are expected to be rewritten by the
new game's author.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "infocom" / "zork1"
THEMEABLE_FILES = {
    "zork1.zil",
    "main.zil",
    "clock.zil",
    "parser.zil",
    "syntax.zil",
    "macros.zil",
    "verbs.zil",
    "globals.zil",
}
STORY_FILES = {"actions.zil", "dungeon.zil"}
ZIL_TOKEN = re.compile(r"^[A-Z0-9][A-Z0-9?&-]*$")
SLUG = re.compile(r"^[a-z0-9][a-z0-9-]*$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Bootstrap a new game from Zork I's reusable framework."
    )
    parser.add_argument("config", type=Path, help="JSON retheme configuration")
    parser.add_argument("output", type=Path, help="new game directory (must not exist)")
    parser.add_argument(
        "--source", type=Path, default=DEFAULT_SOURCE, help="source zork1 directory"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="validate and report without copying"
    )
    return parser.parse_args()


def load_config(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read config {path}: {error}") from error

    slug = data.get("game_slug")
    if not isinstance(slug, str) or not SLUG.fullmatch(slug):
        raise ValueError("game_slug must match [a-z0-9][a-z0-9-]*")
    if not isinstance(data.get("game_name"), str) or not data["game_name"].strip():
        raise ValueError("game_name must be a non-empty string")

    identifiers = data.get("identifiers", {})
    if not isinstance(identifiers, dict):
        raise ValueError("identifiers must be a JSON object")
    for old, replacement in identifiers.items():
        new = replacement.get("to") if isinstance(replacement, dict) else replacement
        if not isinstance(old, str) or not isinstance(new, str):
            raise ValueError("identifier names and 'to' values must be strings")
        if isinstance(replacement, dict):
            unknown = set(replacement) - {"to", "where", "comment"}
            if unknown:
                raise ValueError(
                    f"unsupported identifier metadata for {old}: {', '.join(sorted(unknown))}"
                )
        if not ZIL_TOKEN.fullmatch(old) or not ZIL_TOKEN.fullmatch(new):
            raise ValueError(f"invalid ZIL identifier replacement: {old!r} -> {new!r}")
        if old == "ZORK-NUMBER":
            raise ValueError("ZORK-NUMBER is an engine compile-time selector; do not rename it")

    text = data.get("text", [])
    if not isinstance(text, list):
        raise ValueError("text must be a JSON array of {from, to} objects")
    for item in text:
        if not isinstance(item, dict) or not {"from", "to"} <= set(item):
            raise ValueError("each text replacement must contain 'from' and 'to'")
        unknown = set(item) - {"from", "to", "where", "comment"}
        if unknown:
            raise ValueError(
                f"unsupported text replacement metadata: {', '.join(sorted(unknown))}"
            )
        if not isinstance(item["from"], str) or not isinstance(item["to"], str):
            raise ValueError("text replacement values must be strings")
        if not item["from"]:
            raise ValueError("a text replacement 'from' value cannot be empty")
    return data


def token_pattern(token: str) -> re.Pattern[str]:
    token_char = r"A-Za-z0-9?&-"
    return re.compile(rf"(?<![{token_char}]){re.escape(token)}(?![{token_char}])")


def apply_replacements(content: str, config: dict) -> tuple[str, dict[str, int]]:
    counts: dict[str, int] = {}

    # Literal prose first, so an identifier replacement cannot change a source
    # phrase before the phrase has a chance to match.
    for item in config.get("text", []):
        old, new = item["from"], item["to"]
        count = content.count(old)
        if count:
            content = content.replace(old, new)
            counts[f"text:{old}"] = count

    # Longest first makes overlapping names deterministic (for example
    # GRUE-FUNCTION before GRUE).
    identifiers = config.get("identifiers", {})
    for old in sorted(identifiers, key=len, reverse=True):
        pattern = token_pattern(old)
        replacement = identifiers[old]
        new = replacement.get("to") if isinstance(replacement, dict) else replacement
        content, count = pattern.subn(new, content)
        if count:
            counts[f"identifier:{old}"] = count
    return content, counts


def selected_files(source: Path) -> list[Path]:
    return sorted(
        path for path in source.iterdir() if path.is_file() and path.name in THEMEABLE_FILES
    )


def story_stub(game_name: str, filename: str) -> bytes:
    purpose = (
        "world, rooms, objects, and GO routine"
        if filename == "dungeon.zil"
        else "game actions and puzzle logic"
    )
    return (
        f';"{game_name}: {filename}\n'
        f'Bootstrap placeholder for {purpose}.\n'
        'Write this file from scratch; no legacy story content was copied."\n'
    ).encode("utf-8")


def bootstrap_readme(config: dict) -> bytes:
    name = config["game_name"]
    slug = config["game_slug"]
    return f"""# {name}

Bootstrapped from the reusable ZIL framework in `infocom/zork1`.

- Entry point: `{slug}.zil`
- Rewrite `dungeon.zil` with the rooms, objects, and `GO` routine.
- Rewrite `actions.zil` with game actions and puzzle logic.
- Review the remaining framework-specific candidates documented in
  `docs/ZORK1-RETHEME.md` in the zilscript repository.
- The applied theme settings are preserved in `retheme.json`.

No Zork I `actions.zil`, `dungeon.zil`, tests, cover, compiled story, or
historical README were copied.
""".encode("utf-8")


def main() -> int:
    args = parse_args()
    try:
        config = load_config(args.config)
        source = args.source.resolve()
        output = args.output.resolve()
        if not source.is_dir():
            raise ValueError(f"source directory does not exist: {source}")
        if output.exists():
            raise ValueError(f"output already exists: {output}")
        if output == source or source in output.parents:
            raise ValueError("output cannot be the source directory or inside it")

        files = selected_files(source)
        found = {path.name for path in files}
        missing = sorted(THEMEABLE_FILES - found)
        if missing:
            raise ValueError(f"source is missing framework files: {', '.join(missing)}")
        totals: dict[str, int] = {}
        planned: list[tuple[Path, Path, bytes]] = []
        for source_file in files:
            relative = source_file.relative_to(source)
            destination_name = (
                f"{config['game_slug']}.zil" if relative.as_posix() == "zork1.zil" else relative.name
            )
            destination = output / relative.parent / destination_name

            content = source_file.read_text(encoding="utf-8")
            content, counts = apply_replacements(content, config)
            payload = content.encode("utf-8")
            for key, count in counts.items():
                totals[key] = totals.get(key, 0) + count
            planned.append((source_file, destination, payload))

        for filename in sorted(STORY_FILES):
            planned.append(
                (
                    source / filename,
                    output / filename,
                    story_stub(config["game_name"], filename),
                )
            )
        planned.append((args.config, output / "retheme.json", args.config.read_bytes()))
        planned.append((args.config, output / "README.md", bootstrap_readme(config)))

        print(f"Source: {source}")
        print(f"Output: {output}")
        print(f"Entry point: {config['game_slug']}.zil")
        print(
            f"Files: {len(planned)} "
            f"({len(THEMEABLE_FILES)} rethemed framework, {len(STORY_FILES)} new story stubs, config, README)"
        )
        for key in sorted(totals):
            label = key.replace("\n", r"\n")
            if len(label) > 88:
                label = label[:85] + "..."
            print(f"  {totals[key]:3}  {label}")

        if args.dry_run:
            return 0

        output.mkdir(parents=True)
        for source_file, destination, payload in planned:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(payload)
        print("Created successfully.")
        return 0
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
