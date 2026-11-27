# Dracy — Approved Visual Specification

## Source of truth

- Master reference: `game/assets/characters/dracy/references/dracy-master-reference.png`
- Original attachment preserved at `game/assets/characters/dracy/references/source/dracy-master-reference-source.png`
- Earlier JPEG source preserved at `game/assets/characters/dracy/references/source/dracy-master-reference-source.jpg`
- Reference dimensions: 1199 × 1312
- Source SHA-256: `f89c54468e7a67c108abc3087619755392705709c1fb90b046e78abc75f17305`
- Master PNG SHA-256: `f89c54468e7a67c108abc3087619755392705709c1fb90b046e78abc75f17305`

The reference controls appearance only. The character bible controls canon. Text accidentally rendered inside the reference is not canonical.

## Canonical appearance

### Hair

- Long, flowing, slightly wavy ash silver-blue hair.
- Cool blue-violet shadows with pale silver-blue highlights.
- Soft curtain bangs and face-framing locks.
- Hair remains silver-blue in every outfit, expression, pose, and future illustration.

### Face and makeup

- Pale, cool-toned complexion.
- Oval-heart facial structure with high cheekbones and a defined jaw.
- Large almond-shaped deep crimson-red eyes.
- Dramatic black upper eyeliner, defined lashes, and strong arched brows.
- Small straight nose and full muted rose lips.
- One small dark beauty mark on her left cheekbone.
- Confident, direct gaze; mysterious and slightly intimidating rather than generic or coy.

### Injuries

The bruises and scars are intentional narrative evidence, not decoration.

- Fine stitched scar across the bridge of the nose.
- Fading purple bruise beneath the right eye.
- Small cheek scratches and a subtle beauty-mark-adjacent scratch.
- Bruising and scratches on the shoulder/upper arm and forearm.
- Natural, restrained, non-graphic rendering.
- Their cause is unknown in M01 and may be connected to Nocturne.
- Do not diagnose them, sexualize them, use them as proof of abuse, or make them a symbol of helplessness.
- Dracy may cover them, deflect, make a dark joke, or offer a partial truth. She does not owe the player an explanation.

### Clothing and accessories

- Black and burgundy gothic velvet clothing.
- Structured bodice, layered straps, buckles, chains, and dark hardware.
- Black lace choker with a red gemstone pendant.
- Silver earrings, rings, bracelets, and layered chains.
- Platform boots and dark hosiery in full-body designs.
- Non-religious gothic motifs only: black roses, spider lilies, chains, red gemstones, filigree, and thorned ornament.
- **No religious cross imagery in game sprites or future artwork.** The master reference contains crosses; derived game assets deliberately replace them.

### Palette

| Role | Approximate color |
|---|---|
| Hair highlight | `#DCE7F5` |
| Hair midtone | `#91A5C6` |
| Hair shadow | `#465978` |
| Eyes | `#B81338` with dark crimson shadow |
| Skin | `#E8C8C8` with cool violet shadow |
| Burgundy | `#5B1736` |
| Black velvet | `#100C16` |
| Silver | `#D8D2DC` |
| Bruise | muted violet `#72557F` at low opacity |

## Asset pipeline

1. Preserve the approved reference unchanged in `references/`.
2. Generate new transparent game sprites using the reference as identity guidance.
3. Never use the whole sheet as an in-game sprite.
4. Never crop low-quality character art out of the reference sheet.
5. Store raw generated assets in `sprites/raw/`.
6. Process approved raw assets into `sprites/expressions/`, `sprites/poses/`, and `sprites/outfits/`.
7. Keep backgrounds separate.
8. Preserve aspect ratio; never stretch or distort.
9. Maintain consistent head scale, shoulder line, eye line, and transparent padding.
10. Run `python tools/build_dracy_assets.py` to validate dimensions, transparency, naming, and manifest generation.

## Required expression set

`neutral`, `smiling`, `mischievous`, `sarcastic`, `angry`, `embarrassed`, `flirting`, `sad`, `suspicious`, `frightened`.

## Required pose and outfit set

- `standing` — neutral full-body standing pose in the signature gothic outfit
- `seated` — seated pose in the signature gothic outfit
- `casual` — modern casual dark outfit
- `gothic` — formal floor-length gothic outfit
- `alternative` — alternative dark outfit

All poses and outfits preserve the same face, hair, eyes, beauty mark, injuries, and overall silhouette language.

## Implementation status (M01)

- The approved reference is preserved unchanged and is the appearance authority.
- No image-generation service is currently usable: every configured image model returns an insufficient-balance error. The free Grok model and the newer default image tool fail the same way.
- The shipped sprites are therefore an original, reproducible vector interpretation, not crops and not final painted key art.
- `game/tools/dracy_character_art.py` authors the shared head, ten expression overlays, two poses, and four outfits.
- Portrait sprites are 900 × 1200; standing/outfit sprites are 600 × 1400; the seated sprite is 600 × 1200.
- The expression set and outfit/pose set are complete and validated, but the vector rendering is flatter and more stylized than the reference. Treat it as a production placeholder.
- `game/tools/render_previews.gd` rasterizes the ten expressions plus the poses, outfits, and backgrounds into `user://art_review` for visual review.
- When an image service is funded, generate a separated raw sprite set, then replace the vector files without changing paths. Keep the reference and the vector generator so the fallback remains reproducible.
