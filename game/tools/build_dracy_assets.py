#!/usr/bin/env python3
"""Validate and manifest Dracy's approved, separated transparent sprite set.

Run from the game directory: python tools/build_dracy_assets.py
The PNG master reference remains unchanged; game sprites are original SVG
interpretations generated from the approved visual specification.
"""
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
CHARACTER = ROOT / "assets" / "characters" / "dracy"
REFERENCE = CHARACTER / "references" / "dracy-master-reference.png"
EXPECTED_REFERENCE_SHA256 = "f89c54468e7a67c108abc3087619755392705709c1fb90b046e78abc75f17305"
EXPRESSIONS = ["neutral", "smiling", "mischievous", "sarcastic", "angry", "embarrassed", "flirting", "sad", "suspicious", "frightened"]
POSES = ["standing", "seated"]
OUTFITS = ["signature", "casual", "gothic", "alternative"]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def svg_size(path: Path) -> tuple[int, int]:
    root = ET.parse(path).getroot()
    return int(root.attrib["width"]), int(root.attrib["height"])


def validate_sprite(path: Path, expected: tuple[int, int]) -> None:
    if not path.exists():
        raise SystemExit(f"Missing sprite: {path}")
    width, height = svg_size(path)
    if (width, height) != expected:
        raise SystemExit(f"Unexpected dimensions for {path}: {(width, height)} != {expected}")
    text = path.read_text(encoding="utf-8")
    if "<image" in text or "dracy-master-reference.png" in text:
        raise SystemExit(f"Sprite must not embed the reference sheet: {path}")
    if path.parent.name in {"expressions", "poses", "outfits"}:
        # A full-canvas background rectangle would break transparency.
        if re.search(r'<rect width="(?:900|600)" height="(?:1200|1400)"', text):
            raise SystemExit(f"Sprite appears to contain an opaque background: {path}")
        if "<text" in text:
            raise SystemExit(f"Sprite must not contain text: {path}")


def main() -> None:
    if not REFERENCE.exists():
        raise SystemExit(f"Approved reference is missing: {REFERENCE}")
    reference_hash = sha256(REFERENCE)
    if reference_hash != EXPECTED_REFERENCE_SHA256:
        raise SystemExit("Approved reference hash does not match the documented master")

    assets = []
    for name in EXPRESSIONS:
        path = CHARACTER / "sprites" / "expressions" / f"{name}.svg"
        validate_sprite(path, (900, 1200))
        assets.append({"name": name, "type": "expression", "path": str(path.relative_to(ROOT)), "width": 900, "height": 1200})
    for name in POSES:
        path = CHARACTER / "sprites" / "poses" / f"{name}.svg"
        expected = (600, 1200) if name == "seated" else (600, 1400)
        validate_sprite(path, expected)
        assets.append({"name": name, "type": "pose", "path": str(path.relative_to(ROOT)), "width": expected[0], "height": expected[1]})
    for name in OUTFITS:
        path = CHARACTER / "sprites" / "outfits" / f"{name}.svg"
        validate_sprite(path, (600, 1400))
        assets.append({"name": name, "type": "outfit", "path": str(path.relative_to(ROOT)), "width": 600, "height": 1400})

    manifest = {
        "character": "Dracy",
        "approved_reference": str(REFERENCE.relative_to(ROOT)),
        "approved_reference_sha256": reference_hash,
        "pipeline": "game/tools/generate_art.py + game/tools/build_dracy_assets.py",
        "style": "Original transparent semi-stylized vector interpretation guided by the approved reference; no reference-sheet crops.",
        "license": "Project proprietary — see LICENSE",
        "assets": assets,
    }
    output = CHARACTER / "sprites" / "asset-manifest.json"
    output.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Validated {len(assets)} Dracy sprites and wrote {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
