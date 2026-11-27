#!/usr/bin/env python3
"""Turn downloaded/generated character renders into game-ready transparent sprites.

Sources live in assets/characters/dracy/sprites/raw/generated/ and are named
after the sprite they replace, e.g. neutral.png, standing.png, gothic.png.
Outputs are written to assets/characters/dracy/sprites/generated/ as PNGs.

The game prefers generated PNGs when they exist; deleting that folder restores
the reproducible vector fallback. No source file is ever cropped into a sprite:
this script only removes a flat background and fits the whole render to a canvas.

Run from the game directory: py tools/import_generated_art.py
"""
from __future__ import annotations

from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "characters" / "dracy" / "sprites"
SOURCE = ASSETS / "raw" / "generated"
TARGET = ASSETS / "generated"

SIZES = {
    "neutral": (900, 1200), "smiling": (900, 1200),
    "mischievous": (900, 1200), "sarcastic": (900, 1200),
    "angry": (900, 1200), "embarrassed": (900, 1200),
    "flirting": (900, 1200), "sad": (900, 1200),
    "suspicious": (900, 1200), "frightened": (900, 1200),
    "standing": (600, 1400), "seated": (600, 1200),
    "signature": (600, 1400), "casual": (600, 1400),
    "gothic": (600, 1400), "alternative": (600, 1400),
}

PORTRAITS = set(list(SIZES)[:10])
EXTENSIONS = (".png", ".jpg", ".jpeg", ".webp")


def find_source(name: str) -> Path | None:
    for extension in EXTENSIONS:
        candidate = SOURCE / f"{name}{extension}"
        if candidate.exists():
            return candidate
    return None


def border_color(image: Image.Image) -> tuple[int, int, int]:
    """Most common colour along a thin border strip of the render."""
    pixels = []
    width, height = image.size
    strip = 6
    for x in range(width):
        for y in list(range(strip)) + list(range(height - strip, height)):
            pixels.append(image.getpixel((x, y))[:3])
    for y in range(height):
        for x in list(range(strip)) + list(range(width - strip, width)):
            pixels.append(image.getpixel((x, y))[:3])
    return Counter(pixels).most_common(1)[0][0]


def remove_background(image: Image.Image, background: str) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()
    if background == "green":
        key = (60, 230, 60)
        tolerance = 92
    elif background == "white":
        key = border_color(image)
        tolerance = 46
    elif background == "black":
        key = border_color(image)
        tolerance = 46
    else:
        key = border_color(image)
        tolerance = 54

    for y in range(height):
        for x in range(width):
            r, g, b, _ = pixels[x, y]
            if background == "green":
                distance = max(0, g - max(r, b))
                strength = max(r, g, b)
                is_bg = distance > 34 and strength > 70
            else:
                distance = max(abs(r - key[0]), abs(g - key[1]), abs(b - key[2]))
                is_bg = distance < tolerance
            if is_bg:
                # Feather the edge so chroma spill does not leave a hard halo.
                softness = 22 if background == "green" else 16
                alpha = 0 if distance > tolerance else max(0, min(255, int((tolerance - distance) / softness * 255)))
                pixels[x, y] = (r, g, b, alpha)
    return rgba


def fit_to_canvas(image: Image.Image, size: tuple[int, int], portrait: bool) -> Image.Image:
    target_w, target_h = size
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise SystemExit("Generated render has no visible subject after background removal")
    subject = image.crop(bbox)
    margin = 0.06 if portrait else 0.02
    scale = min(target_w * (1 - margin * 2) / subject.width,
                target_h * (1 - margin * 2) / subject.height)
    new_size = (max(1, int(subject.width * scale)), max(1, int(subject.height * scale)))
    subject = subject.resize(new_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    x = (target_w - new_size[0]) // 2
    y = int(target_h * margin) if portrait else target_h - new_size[1] - int(target_h * margin)
    canvas.alpha_composite(subject, (x, max(0, y)))
    return canvas


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--background", choices=("auto", "green", "white", "black"),
                        default="green", help="flat background used by the generator")
    args = parser.parse_args()

    if not SOURCE.exists():
        raise SystemExit(f"Put the generated renders in {SOURCE}")
    TARGET.mkdir(parents=True, exist_ok=True)

    imported = []
    for name, size in SIZES.items():
        path = find_source(name)
        if path is None:
            continue
        raw = Image.open(path)
        raw.load()
        transparent = remove_background(raw, args.background)
        fitted = fit_to_canvas(transparent, size, name in PORTRAITS)
        output = TARGET / f"{name}.png"
        fitted.save(output, optimize=True)
        imported.append(f"{name} -> {output.relative_to(ROOT)}")
    if not imported:
        raise SystemExit(f"No generated renders found in {SOURCE}")
    print(f"Imported {len(imported)} generated sprites:")
    for line in imported:
        print("  " + line)
    print("Game code prefers these PNGs automatically. Delete the folder to restore vector art.")


if __name__ == "__main__":
    main()
