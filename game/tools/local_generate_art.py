#!/usr/bin/env python3
"""Free local sprite generation on an NVIDIA GPU.

Uses Stable Diffusion XL with the existing transparent vector previews as
img2img guides. The previews preserve pose, outfit, and expression layout;
the model only repaints the rendering. No reference-sheet crop is shipped,
and nothing is sent to a paid service.

First run downloads SDXL from Hugging Face (~7 GB). Requires:
    py -m pip install torch diffusers transformers accelerate safetensors pillow

Run from the game directory:
    py tools/local_generate_art.py --all
    py tools/local_generate_art.py --names neutral smiling standing
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREVIEWS = Path.home() / "AppData" / "Roaming" / "Godot" / "app_userdata" / "DRACY- NOCTURNE" / "art_review"
SOURCE = ROOT / "assets" / "characters" / "dracy" / "sprites" / "raw" / "generated"

NAMES = [
    "neutral", "smiling", "mischievous", "sarcastic", "angry",
    "embarrassed", "flirting", "sad", "suspicious", "frightened",
    "standing", "seated", "signature", "casual", "gothic", "alternative",
]

CHARACTER = (
    "highly detailed semi-realistic dark fantasy illustration of Dracy, a pale "
    "24-year-old Moroccan goth woman with long wavy ash silver-blue hair, cool "
    "blue-violet hair shadows, soft curtain bangs, crimson red eyes, heavy black "
    "winged eyeliner, subtle burgundy eyeshadow, a small beauty mark under her "
    "left eye, faint bruising on the left cheek and restrained scratch marks, "
    "dramatic gothic makeup, pale cool skin, black and burgundy clothing, "
    "intricate silver filigree jewellery, black roses and spider lily ornaments, "
    "soft dramatic rim light, painterly, sharp focus"
)

EXPRESSION = {
    "neutral": "calm neutral expression, composed gaze",
    "smiling": "warm closed-lip smile, amused eyes",
    "mischievous": "sly mischievous smirk, one brow raised",
    "sarcastic": "dry sarcastic half-smile, narrowed eyes",
    "angry": "controlled anger, lowered brows, tight lips",
    "embarrassed": "flushed embarrassed look, eyes away, blushing cheeks",
    "flirting": "flirtatious soft smile, direct crimson gaze",
    "sad": "restrained sadness, slightly lowered eyes",
    "suspicious": "suspicious narrowed gaze, guarded mouth",
    "frightened": "frightened expression, wide eyes, parted lips",
}

OUTFIT = {
    "standing": "full-body standing pose, black and burgundy gothic corset dress, lace, silver chains, thigh-high stockings, platform boots",
    "seated": "full-body seated on a dark gothic throne, velvet gown, hands resting calmly",
    "signature": "full-body standing pose, gothic corset dress, layered skirt, silver filigree, platform boots",
    "casual": "full-body standing pose, oversized charcoal knit sweater, burgundy pleated skirt, dark leggings, ankle boots",
    "gothic": "full-body standing pose, floor-length black velvet gown with high lace collar, burgundy panels, silver trim",
    "alternative": "full-body standing pose, cropped black harness top, plaid skirt, striped arm warmers, fishnet stockings",
}

NEGATIVE = (
    "text, letters, watermark, logo, cross, crucifix, religious symbol, "
    "multiple people, extra limbs, deformed hands, fused fingers, blurry, "
    "low quality, cartoon, chibi, oversized anime eyes"
)


def preview_path(name: str) -> Path:
    if name in EXPRESSION:
        return PREVIEWS / "expressions" / f"{name}.png"
    return PREVIEWS / f"dracy-{name}.png"


def load_guide(path: Path, size: tuple[int, int]) -> "object":
    from PIL import Image

    image = Image.open(path).convert("RGBA")
    background = Image.new("RGBA", image.size, (60, 205, 60, 255))
    background.alpha_composite(image)
    return background.convert("RGB").resize(size, Image.Resampling.LANCZOS)


def main() -> None:
    global PREVIEWS
    import torch
    from diffusers import StableDiffusionXLImg2ImgPipeline

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--all", action="store_true", help="generate every sprite")
    parser.add_argument("--names", nargs="*", default=[])
    parser.add_argument("--model", default="stabilityai/stable-diffusion-xl-base-1.0")
    parser.add_argument("--strength", type=float, default=0.55)
    parser.add_argument("--steps", type=int, default=30)
    parser.add_argument("--seed", type=int, default=24)
    parser.add_argument("--previews", type=Path, default=PREVIEWS)
    args = parser.parse_args()

    PREVIEWS = args.previews
    names = NAMES if args.all else args.names
    if not names:
        raise SystemExit("Pass --all or --names ...")

    SOURCE.mkdir(parents=True, exist_ok=True)
    pipe = StableDiffusionXLImg2ImgPipeline.from_pretrained(
        args.model, torch_dtype=torch.float16, use_safetensors=True
    )
    pipe.enable_model_cpu_offload()

    for index, name in enumerate(names):
        guide_source = preview_path(name)
        if not guide_source.exists():
            print(f"SKIP {name}: missing preview {guide_source}")
            continue
        portrait = name in EXPRESSION
        size = (832, 1216) if portrait else (768, 1344)
        guide = load_guide(guide_source, size)
        detail = EXPRESSION.get(name, OUTFIT.get(name, ""))
        prompt = (
            f"{CHARACTER}, {detail}, "
            "flat pure chroma-key green background, full figure centred, "
            "no scenery, no shadow on the background"
        )
        generator = torch.Generator(device="cpu").manual_seed(args.seed + index)
        image = pipe(
            prompt=prompt,
            negative_prompt=NEGATIVE,
            image=guide,
            strength=args.strength,
            num_inference_steps=args.steps,
            generator=generator,
        ).images[0]
        output = SOURCE / f"{name}.png"
        image.save(output)
        print(f"Saved {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
