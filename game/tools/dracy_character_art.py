#!/usr/bin/env python3
"""Generate Dracy's transparent character sprites.

The approved reference sheet is identity guidance only. These are original,
deterministically generated vector assets: no sheet crops, no embedded raster
images, and no religious cross motifs.

Artwork is authored as layered vector shapes so the project stays offline-first
and every output is reproducible from this file.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
DESIGN = ROOT.parent / "design" / "character-bible"

SVG_HEAD = '<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'

DEFS = """
<defs>
  <linearGradient id="hair" x1=".2" y1="0" x2=".8" y2="1">
    <stop stop-color="#eaf2fc"/><stop offset=".14" stop-color="#cfdcee"/>
    <stop offset=".36" stop-color="#a7b9d5"/><stop offset=".58" stop-color="#7489ae"/>
    <stop offset=".78" stop-color="#4d5f84"/><stop offset="1" stop-color="#2c3850"/>
  </linearGradient>
  <linearGradient id="hairDark" x1="0" y1="0" x2="1" y2="1">
    <stop stop-color="#5d7093"/><stop offset=".5" stop-color="#3b4a66"/><stop offset="1" stop-color="#232e44"/>
  </linearGradient>
  <linearGradient id="hairLight" x1="0" y1="0" x2="0" y2="1">
    <stop stop-color="#ffffff"/><stop offset=".4" stop-color="#e8f0fa"/><stop offset="1" stop-color="#b3c4dd"/>
  </linearGradient>
  <linearGradient id="skin" x1=".25" y1="0" x2=".8" y2="1">
    <stop stop-color="#f7eaea"/><stop offset=".4" stop-color="#ecd9dc"/>
    <stop offset=".72" stop-color="#dcc2c9"/><stop offset="1" stop-color="#c8a6b2"/>
  </linearGradient>
  <linearGradient id="skinShade" x1="0" y1="0" x2="0" y2="1">
    <stop stop-color="#c68f9c" stop-opacity="0"/><stop offset="1" stop-color="#b47b8b" stop-opacity=".55"/>
  </linearGradient>
  <radialGradient id="eye" cx="46%" cy="40%" r="62%">
    <stop stop-color="#ffd9dc"/><stop offset=".2" stop-color="#f2556f"/>
    <stop offset=".52" stop-color="#bf163c"/><stop offset=".8" stop-color="#7d0a24"/><stop offset="1" stop-color="#33040e"/>
  </radialGradient>
  <linearGradient id="lip" x1="0" y1="0" x2="0" y2="1">
    <stop stop-color="#c07686"/><stop offset=".45" stop-color="#9d4a60"/><stop offset="1" stop-color="#742840"/>
  </linearGradient>
  <linearGradient id="smoke" x1="0" y1="0" x2="0" y2="1">
    <stop stop-color="#63213c" stop-opacity=".6"/><stop offset=".55" stop-color="#9b4763" stop-opacity=".3"/>
    <stop offset="1" stop-color="#c07c8e" stop-opacity="0"/>
  </linearGradient>
  <linearGradient id="velvet" x1="0" y1="0" x2="1" y2="1">
    <stop stop-color="#1c1421"/><stop offset=".55" stop-color="#0c0911"/><stop offset="1" stop-color="#251020"/>
  </linearGradient>
  <linearGradient id="burgundy" x1="0" y1="0" x2="1" y2="1">
    <stop stop-color="#8f2648"/><stop offset=".45" stop-color="#5c1330"/><stop offset="1" stop-color="#2a0818"/>
  </linearGradient>
  <linearGradient id="silver" x1="0" y1="0" x2="1" y2="1">
    <stop stop-color="#fff7fb"/><stop offset=".3" stop-color="#b7abb8"/><stop offset=".62" stop-color="#efe6ed"/><stop offset="1" stop-color="#72687a"/>
  </linearGradient>
  <linearGradient id="stocking" x1="0" y1="0" x2="1" y2="0">
    <stop stop-color="#15101c"/><stop offset=".5" stop-color="#33243a"/><stop offset="1" stop-color="#110c17"/>
  </linearGradient>
  <radialGradient id="bruise">
    <stop stop-color="#8d638b" stop-opacity=".5"/><stop offset=".5" stop-color="#72557f" stop-opacity=".3"/>
    <stop offset="1" stop-color="#5b426e" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="blush">
    <stop stop-color="#d96d84" stop-opacity=".45"/><stop offset="1" stop-color="#d96d84" stop-opacity="0"/>
  </radialGradient>
</defs>
"""

EXPRESSIONS = [
    "neutral", "smiling", "mischievous", "sarcastic", "angry",
    "embarrassed", "flirting", "sad", "suspicious", "frightened",
]

# Portrait geometry shared by the portrait and every full-body sprite.
HEAD_PIVOT_X = 450.0
HEAD_PIVOT_Y = 414.0


def write_svg(relative: str, body: str, w: int, h: int, defs: str = DEFS) -> None:
    path = ASSETS / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(SVG_HEAD.format(w=w, h=h) + defs + body + "</svg>", encoding="utf-8")


def _back_hair(long: bool) -> str:
    if long:
        mass = ('<path d="M450 124 C344 124 280 196 266 302 C252 392 264 470 248 562 '
                'C232 662 232 762 214 862 C196 962 172 1084 156 1200 L306 1200 '
                'C296 1080 306 976 318 874 C332 748 324 636 330 536 C334 436 350 356 '
                '386 306 C406 280 426 268 450 268 C474 268 494 280 514 306 '
                'C550 356 566 436 570 536 C576 636 568 748 582 874 C594 976 604 1080 '
                '594 1200 L744 1200 C728 1084 704 962 686 862 C668 762 668 662 652 562 '
                'C636 470 648 392 634 302 C620 196 556 124 450 124 Z" fill="url(#hair)"/>')
        shade = ('<path d="M304 250 C276 380 292 520 268 700 C250 840 222 990 200 1130 '
                 'C238 1040 262 930 280 810 C302 660 300 500 316 372 Z" fill="url(#hairDark)" opacity=".45"/>'
                 '<path d="M596 250 C624 380 608 520 632 700 C650 840 678 990 700 1130 '
                 'C662 1040 638 930 620 810 C598 660 600 500 584 372 Z" fill="url(#hairDark)" opacity=".45"/>')
    else:
        mass = ('<path d="M450 124 C344 124 280 196 266 302 C254 380 264 452 254 520 '
                'C246 580 240 620 238 660 C258 620 276 570 284 512 C296 430 300 360 '
                '330 306 C356 262 400 240 450 240 C500 240 544 262 570 306 '
                'C600 360 604 430 616 512 C624 570 642 620 662 660 C660 620 654 580 '
                '646 520 C636 452 646 380 634 302 C620 196 556 124 450 124 Z" fill="url(#hair)"/>')
        shade = ('<path d="M310 250 C288 350 300 440 286 530 C300 500 312 450 316 390 '
                 'C320 330 322 286 330 262 Z" fill="url(#hairDark)" opacity=".4"/>'
                 '<path d="M590 250 C612 350 600 440 614 530 C600 500 588 450 584 390 '
                 'C580 330 578 286 570 262 Z" fill="url(#hairDark)" opacity=".4"/>')
    return mass + shade


def head_base(long_hair: bool = True, include_neck: bool = True) -> str:
    """Skull, hair, face, ears, choker and earrings. No expression features."""
    neck = ""
    if include_neck:
        neck = ('<path d="M412 618 C414 668 400 704 374 734 L372 778 L528 778 L526 734 '
                'C500 704 486 668 488 618 Z" fill="url(#skin)"/>'
                '<path d="M414 632 C426 674 474 674 486 632 L502 714 C478 752 422 752 398 714 Z" '
                'fill="url(#skinShade)" opacity=".5"/>')
    return f"""
<g id="dracy-head">
  {_back_hair(long_hair)}
  {neck}
  <!-- ears -->
  <path d="M304 452 C286 444 278 466 284 496 C289 520 302 532 314 524 L318 486 Z" fill="url(#skin)"/>
  <path d="M596 452 C614 444 622 466 616 496 C611 520 598 532 586 524 L582 486 Z" fill="url(#skin)"/>
  <path d="M306 476 C300 484 302 500 310 508 M594 476 C600 484 598 500 590 508" fill="none"
        stroke="#bd8492" stroke-width="2.2" stroke-linecap="round" opacity=".45"/>
  <!-- face -->
  <path d="M450 196 C376 196 320 240 306 318 C294 382 298 446 312 500 C330 568 388 636 450 664
           C512 636 570 568 588 500 C602 446 606 382 594 318 C580 240 524 196 450 196 Z" fill="url(#skin)"/>
  <path d="M450 212 C398 212 360 248 346 300 C372 266 406 242 450 242 C494 242 528 266 554 300
           C540 248 502 212 450 212 Z" fill="#fdece9" opacity=".32"/>
  <path d="M306 420 C314 500 350 570 398 614 C374 556 350 492 344 420 Z" fill="#c88e9c" opacity=".2"/>
  <path d="M594 420 C586 500 550 570 502 614 C526 556 550 492 556 420 Z" fill="#c88e9c" opacity=".24"/>
  <path d="M386 604 C412 636 430 650 450 654 C470 650 488 636 514 604" fill="none"
        stroke="#c18493" stroke-width="3" opacity=".22"/>
  <!-- soft under-fringe shadow across the forehead -->
  <path d="M330 318 C352 372 396 396 450 400 C504 396 548 372 570 318
           C560 386 512 418 450 422 C388 418 340 386 330 318 Z" fill="#c08a97" opacity=".12"/>
  <!-- jaw and temple shading for a painted read -->
  <path d="M352 560 C378 606 414 636 450 644 C486 636 522 606 548 560
           C524 622 490 652 450 656 C410 652 376 622 352 560 Z" fill="#c08494" opacity=".05"/>
  <!-- nose -->
  <path d="M449 474 C445 500 441 518 437 532 C443 540 452 543 461 538 C470 534 477 526 479 519"
        fill="none" stroke="#bd8390" stroke-width="2.6" stroke-linecap="round" opacity=".34"/>
  <path d="M436 536 C442 544 452 547 461 543 C469 539 476 532 480 525" fill="none"
        stroke="#a66a7a" stroke-width="2.2" stroke-linecap="round" opacity=".45"/>
  <path d="M446 530 C450 534 455 535 459 532" fill="none" stroke="#f3d4d6" stroke-width="2"
        stroke-linecap="round" opacity=".5"/>
  <!-- cheek warmth and lower-lid shadow -->
  <ellipse cx="352" cy="548" rx="52" ry="30" fill="url(#blush)" opacity=".5"/>
  <ellipse cx="548" cy="548" rx="52" ry="30" fill="url(#blush)" opacity=".5"/>
  <path d="M336 500 Q376 522 414 506 M486 506 Q524 522 564 500" fill="none"
        stroke="#c08a97" stroke-width="2" opacity=".28"/>
  <!-- restrained, narratively important injuries -->
  <ellipse cx="342" cy="540" rx="40" ry="23" fill="url(#bruise)" transform="rotate(-12 342 540)"/>
  <path d="M330 528 l11 8 M326 538 l14 9 M332 548 l11 7" fill="none" stroke="#a9687b"
        stroke-width="2" stroke-linecap="round" opacity=".55"/>
  <path d="M446 458 L456 500 M442 470 l10 -4 M445 482 l10 -4 M448 494 l10 -4" fill="none"
        stroke="#9f5d70" stroke-width="2" stroke-linecap="round" opacity=".58"/>
  <path d="M522 512 l16 11 M527 506 l16 10" fill="none" stroke="#ae6d7e" stroke-width="2"
        stroke-linecap="round" opacity=".5"/>
  <circle cx="542" cy="560" r="4.2" fill="#4a2436" opacity=".95"/>
  <!-- bangs and face-framing locks -->
  <path d="M450 140 C368 140 306 198 294 300 C290 344 296 380 306 408
           C322 372 340 344 362 324 C356 358 360 388 368 412
           C386 376 408 348 432 330 C430 362 438 392 448 414
           C462 380 478 354 496 334 C496 366 504 394 514 416
           C532 382 552 356 574 336 C580 370 584 396 582 420
           C598 384 608 344 606 300 C594 198 532 140 450 140 Z" fill="url(#hair)"/>
  <path d="M450 152 C388 156 338 196 318 262 C354 228 394 204 430 192
           C410 230 394 270 384 310 C416 278 444 246 462 216
           C468 252 476 286 488 316 C500 280 512 246 524 218
           C540 254 552 292 558 330 C578 296 592 258 588 220
           C566 178 516 154 450 152 Z" fill="url(#hairLight)" opacity=".55"/>
  <path d="M300 300 C284 400 292 500 278 600 C268 680 254 740 244 790
           C268 748 286 690 296 626 C310 540 312 430 318 340 Z" fill="url(#hair)"/>
  <path d="M600 300 C616 400 608 500 622 600 C632 680 646 740 656 790
           C632 748 614 690 604 626 C590 540 588 430 582 340 Z" fill="url(#hair)"/>
  <path d="M310 330 C300 430 306 530 292 630 C286 680 278 720 272 752
           C288 706 300 654 306 600 C318 510 318 410 324 348 Z" fill="url(#hairLight)" opacity=".4"/>
  <path d="M590 330 C600 430 594 530 608 630 C614 680 622 720 628 752
           C612 706 600 654 594 600 C582 510 582 410 576 348 Z" fill="url(#hairLight)" opacity=".38"/>
  <path d="M384 220 C356 282 342 348 336 414 M404 208 C380 274 372 340 370 402" fill="none"
        stroke="url(#hairLight)" stroke-width="4" stroke-linecap="round" opacity=".5"/>
  <path d="M516 220 C544 282 558 348 564 414 M496 208 C520 274 528 340 530 402" fill="none"
        stroke="url(#hairLight)" stroke-width="4" stroke-linecap="round" opacity=".45"/>
  <!-- choker with a red gemstone; deliberately no cross -->
  <path d="M388 744 Q450 780 512 744" fill="none" stroke="#0c0811" stroke-width="22" stroke-linecap="round"/>
  <path d="M388 744 Q450 780 512 744" fill="none" stroke="#6b3650" stroke-width="2.2"
        stroke-dasharray="4 6" opacity=".85"/>
  <path d="M450 774 L464 794 L450 814 L436 794 Z" fill="#8b1538" stroke="url(#silver)" stroke-width="3"/>
  <circle cx="450" cy="794" r="4.5" fill="#ffc0cb" opacity=".5"/>
  <!-- silver hoops and red gem drops -->
  <circle cx="300" cy="492" r="8" fill="none" stroke="#c9becb" stroke-width="3"/>
  <circle cx="600" cy="492" r="8" fill="none" stroke="#c9becb" stroke-width="3"/>
  <path d="M300 500 L300 514 M600 500 L600 514" stroke="#c9becb" stroke-width="2"/>
  <path d="M300 514 L306 526 L300 538 L294 526 Z" fill="#741530" stroke="#c9becb" stroke-width="1.6"/>
  <path d="M600 514 L606 526 L600 538 L594 526 Z" fill="#741530" stroke="#c9becb" stroke-width="1.6"/>
</g>
"""

def _eye(cx: float, s: int, openness: float, iris_dx: float, iris_dy: float,
         pupil: float, tag: str) -> str:
    cy = 480.0
    w = 54.0
    ht = 27.0 * openness
    hb = 22.0 * openness
    ix = cx - s * w
    ox = cx + s * w
    lid = (
        f'M{ix:.1f} {cy:.1f} '
        f'C{ix + s*16:.1f} {cy-ht*1.05:.1f} {cx-s*12:.1f} {cy-ht*1.12:.1f} {ox-s*10:.1f} {cy-ht*.88:.1f} '
        f'C{ox-s*2:.1f} {cy-ht*.6:.1f} {ox+s*2:.1f} {cy-8:.1f} {ox:.1f} {cy-2:.1f} '
        f'C{ox-s*10:.1f} {cy+hb*.85:.1f} {cx+s*6:.1f} {cy+hb:.1f} {ix+s*18:.1f} {cy+hb*.86:.1f} '
        f'C{ix+s*8:.1f} {cy+hb*.55:.1f} {ix:.1f} {cy+5:.1f} {ix:.1f} {cy:.1f} Z'
    )
    iris_cx = cx + iris_dx
    iris_cy = cy - 2 + iris_dy
    iris_ry = min(26.0, 28.0 * openness)
    parts = [
        # smoky socket, then a clipped almond so the iris fills the lid
        f'<ellipse cx="{cx:.1f}" cy="{cy-11:.1f}" rx="56" ry="24" fill="url(#smoke)"/>',
        f'<clipPath id="eyeClip{tag}"><path d="{lid}"/></clipPath>',
        f'<g clip-path="url(#eyeClip{tag})">',
        f'<path d="{lid}" fill="#efe0e4"/>',
        f'<ellipse cx="{cx:.1f}" cy="{cy+ht*.5:.1f}" rx="60" ry="{ht:.1f}" fill="#b98a99" opacity=".32"/>',
        f'<ellipse cx="{iris_cx:.1f}" cy="{iris_cy:.1f}" rx="27" ry="{iris_ry:.1f}" '
        f'fill="url(#eye)" stroke="#3c0a1a" stroke-width="2.6"/>',
        f'<ellipse cx="{iris_cx:.1f}" cy="{iris_cy:.1f}" rx="{10*pupil:.1f}" ry="{11*pupil:.1f}" fill="#1b030a"/>',
        f'<circle cx="{iris_cx-8:.1f}" cy="{iris_cy-8:.1f}" r="5" fill="#fff6f8" opacity=".92"/>',
        f'<circle cx="{iris_cx+8:.1f}" cy="{iris_cy+5:.1f}" r="2.4" fill="#ffd8dc" opacity=".7"/>',
        f'</g>',
        # heavy upper lid with an outer wing
        f'<path d="M{ix:.1f} {cy:.1f} '
        f'C{ix + s*16:.1f} {cy-ht*1.05:.1f} {cx-s*12:.1f} {cy-ht*1.12:.1f} {ox-s*10:.1f} {cy-ht*.88:.1f} '
        f'C{ox-s*2:.1f} {cy-ht*.6:.1f} {ox+s*2:.1f} {cy-8:.1f} {ox:.1f} {cy-2:.1f} '
        f'L{ox+s*14:.1f} {cy-ht*.95-2:.1f}" fill="none" stroke="#170810" stroke-width="8.5" '
        f'stroke-linecap="round" stroke-linejoin="round"/>',
        # crease and lower lash
        f'<path d="M{cx-s*30:.1f} {cy-ht-14:.1f} Q{cx:.1f} {cy-ht-25:.1f} {cx+s*32:.1f} {cy-ht-12:.1f}" '
        f'fill="none" stroke="#a76a7c" stroke-width="2.2" stroke-linecap="round" opacity=".4"/>',
        f'<path d="M{ix+s*8:.1f} {cy+hb*.7:.1f} Q{cx:.1f} {cy+hb*1.05:.1f} {ox-s*8:.1f} {cy+hb*.6:.1f}" '
        f'fill="none" stroke="#8e4a60" stroke-width="2.2" stroke-linecap="round" opacity=".55"/>',
        # three layered lashes at the outer corner
        f'<path d="M{ox-s*2:.1f} {cy-ht*.8:.1f} l{s*12} -8 M{ox-s*12:.1f} {cy-ht*.95:.1f} l{s*10} -9 '
        f'M{ox-s*22:.1f} {cy-ht:.1f} l{s*8} -8" fill="none" stroke="#170810" stroke-width="2.8" '
        f'stroke-linecap="round"/>',
    ]
    return "".join(parts)


BROWS = {
    "neutral": "M330 420 Q374 402 420 414 M480 414 Q526 402 570 420",
    "smiling": "M330 416 Q374 396 420 408 M480 408 Q526 396 570 416",
    "mischievous": "M330 418 Q374 400 420 416 M480 404 Q526 384 570 398",
    "sarcastic": "M330 410 Q374 404 420 408 M480 422 Q526 410 570 416",
    "angry": "M326 430 Q374 414 422 396 M478 396 Q526 414 574 430",
    "embarrassed": "M330 412 Q374 392 420 410 M480 410 Q526 392 570 412",
    "flirting": "M330 416 Q374 398 420 412 M480 400 Q526 384 570 398",
    "sad": "M326 402 Q374 420 420 432 M480 432 Q526 420 574 402",
    "suspicious": "M330 418 Q374 402 420 416 M480 396 Q526 384 570 402",
    "frightened": "M326 396 Q374 380 420 396 M480 396 Q526 380 574 396",
}

EYE_PARAMS = {
    "neutral": (0.88, 0, 0, 1.0),
    "smiling": (0.66, 0, 0, 1.0),
    "mischievous": (0.74, 4, 0, 1.0),
    "sarcastic": (0.52, -4, 1, 1.0),
    "angry": (0.78, 0, 0, 0.92),
    "embarrassed": (0.8, -6, 3, 1.0),
    "flirting": (0.56, 5, 0, 1.0),
    "sad": (0.86, 0, 4, 1.0),
    "suspicious": (0.48, 2, -1, 0.92),
    "frightened": (1.18, 0, 0, 0.68),
}

MOUTHS = {
    "neutral": (
        '<path d="M414 640 C424 630 433 627 441 633 C446 627 454 627 459 633 C467 627 476 630 486 640 '
        'C470 647 446 647 414 640 Z" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M418 644 C438 662 462 662 482 644 C470 653 448 655 418 644 Z" fill="url(#lip)" '
        'stroke="#5c1c2c" stroke-width="1.6" opacity=".95"/>'
        '<path d="M432 650 Q450 656 468 649" fill="none" stroke="#e8b7bd" stroke-width="2" opacity=".5"/>'),
    "smiling": (
        '<path d="M408 636 C420 626 432 623 442 630 C447 625 453 625 458 630 C468 623 480 626 492 636 '
        'C474 643 444 643 408 636 Z" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M414 640 C438 670 466 668 486 640 C472 652 446 655 414 640 Z" fill="url(#lip)" '
        'stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M420 639 C440 645 462 645 480 639 C462 643 440 643 420 639 Z" fill="#f7ecec" opacity=".9"/>'
        '<path d="M436 652 Q450 658 464 651" fill="none" stroke="#e8b7bd" stroke-width="2" opacity=".5"/>'),
    "mischievous": (
        '<path d="M412 640 C424 630 436 628 444 634 C450 628 456 629 460 634 C470 626 480 630 492 638 '
        'C472 646 442 646 412 640 Z" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M418 643 C442 656 470 656 490 640 C472 650 446 652 418 643 Z" fill="url(#lip)" '
        'stroke="#5c1c2c" stroke-width="1.6"/>'
        '<path d="M486 641 L494 646" stroke="#7f2c43" stroke-width="2.4" stroke-linecap="round"/>'),
    "sarcastic": (
        '<path d="M416 644 C428 636 440 634 449 638 C456 634 468 636 482 644 '
        'C468 648 446 648 416 644 Z" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M422 646 C442 654 462 653 478 645 C464 651 444 651 422 646 Z" fill="url(#lip)" '
        'stroke="#5c1c2c" stroke-width="1.5"/>'
        '<path d="M480 643 L490 649" stroke="#7f2c43" stroke-width="2.4" stroke-linecap="round"/>'),
    "angry": (
        '<path d="M416 646 C430 634 442 632 450 636 C458 632 470 634 484 646 C468 650 446 650 416 646 Z" '
        'fill="#6d2638" stroke="#4f1726" stroke-width="1.8"/>'
        '<path d="M422 648 C442 656 462 656 480 648 C466 654 444 654 422 648 Z" fill="#6d2638" '
        'stroke="#4f1726" stroke-width="1.5"/>'),
    "embarrassed": (
        '<ellipse cx="450" cy="642" rx="25" ry="12" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.6"/>'
        '<path d="M434 642 Q450 650 466 641" fill="none" stroke="#e8b7bd" stroke-width="2" opacity=".5"/>'),
    "flirting": (
        '<path d="M410 636 C422 626 434 624 443 631 C448 626 454 626 459 631 C470 624 482 627 492 636 '
        'C472 644 442 644 410 636 Z" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M416 640 C440 666 468 662 486 638 C470 650 442 653 416 640 Z" fill="url(#lip)" '
        'stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M446 648 Q450 653 456 647" fill="#f7dadd"/>'),
    "sad": (
        '<path d="M418 650 C430 640 442 638 450 642 C458 638 470 640 482 650 '
        'C468 654 446 654 418 650 Z" fill="url(#lip)" stroke="#5c1c2c" stroke-width="1.8"/>'
        '<path d="M424 652 C442 660 460 659 476 651 C462 657 442 657 424 652 Z" fill="url(#lip)" '
        'stroke="#5c1c2c" stroke-width="1.5"/>'),
    "suspicious": (
        '<path d="M426 644 L474 640" fill="none" stroke="#7a3147" stroke-width="3" stroke-linecap="round"/>'),
    "frightened": (
        '<ellipse cx="450" cy="644" rx="16" ry="21" fill="#5b1d30" stroke="#3f1020" stroke-width="1.8"/>'
        '<ellipse cx="450" cy="652" rx="8" ry="6" fill="#b85d73" opacity=".8"/>'),
}


def expression_overlay(mode: str) -> str:
    openness, iris_dx, iris_dy, pupil = EYE_PARAMS[mode]
    brows = (f'<path d="{BROWS[mode]}" fill="none" stroke="#2b1626" stroke-width="5.5" '
             f'stroke-linecap="round"/>')
    eyes = (_eye(376, -1, openness, iris_dx, iris_dy, pupil, "L") +
            _eye(524, 1, openness, iris_dx, iris_dy, pupil, "R"))
    blush = ""
    if mode in ("smiling", "embarrassed", "flirting"):
        blush = ('<ellipse cx="356" cy="556" rx="48" ry="22" fill="url(#blush)"/>'
                 '<ellipse cx="544" cy="556" rx="48" ry="22" fill="url(#blush)"/>'
                 '<path d="M334 556 l8 -5 m5 7 l8 -5 m5 7 l8 -5 M528 556 l8 -5 m5 7 l8 -5 m5 7 l8 -5" '
                 'stroke="#a94f66" stroke-width="2" opacity=".4"/>')
    tears = ""
    if mode == "frightened":
        tears = ('<path d="M352 512 C346 534 350 548 358 556" fill="none" stroke="#dce8ff" '
                 'stroke-width="3" opacity=".5"/>')
    elif mode == "sad":
        tears = ('<path d="M346 512 C342 528 345 540 351 547" fill="none" stroke="#dce8ff" '
                 'stroke-width="2.4" opacity=".32"/>')
    mouth = ('<g transform="translate(0 -30) translate(450 0) scale(1.12 1) translate(-450 0)">' +
             MOUTHS[mode] + '</g>')
    return brows + eyes + blush + tears + mouth


def portrait_body() -> str:
    return """
<g id="dracy-portrait-body">
  <!-- neck, shoulders and chest -->
  <path d="M360 748 C300 780 240 824 202 886 C176 928 164 998 160 1068 L156 1200
           L744 1200 L740 1068 C736 998 724 928 698 886 C660 824 600 780 540 748
           C514 788 486 806 450 806 C414 806 386 788 360 748 Z" fill="url(#skin)"/>
  <path d="M360 760 C390 796 414 810 450 810 C486 810 510 796 540 760 L556 828
           C520 862 486 876 450 876 C414 876 380 862 344 828 Z" fill="url(#skinShade)" opacity=".45"/>
  <path d="M330 846 C360 826 402 818 450 818 C498 818 540 826 570 846" fill="none"
        stroke="#f7dedd" stroke-width="4" opacity=".22"/>
  <path d="M206 900 C232 872 276 850 320 842 M694 900 C668 872 624 850 580 842" fill="none"
        stroke="#c68f9c" stroke-width="3" opacity=".25"/>
  <!-- black velvet bodice -->
  <path d="M198 934 C250 892 302 870 350 866 C384 892 414 900 450 900
           C486 900 516 892 550 866 C598 870 650 892 702 934 L730 1200 L170 1200 Z" fill="url(#velvet)"/>
  <!-- burgundy corset -->
  <path d="M276 1014 C316 1044 380 1058 450 1058 C520 1058 584 1044 624 1014
           L646 1200 L254 1200 Z" fill="url(#burgundy)"/>
  <path d="M276 1014 C316 1044 380 1058 450 1058 C520 1058 584 1044 624 1014" fill="none"
        stroke="#a45a73" stroke-width="2.4" stroke-dasharray="4 7" opacity=".8"/>
  <!-- silver neckline and corset trim -->
  <path d="M198 934 C250 892 302 870 350 866 C384 892 414 900 450 900
           C486 900 516 892 550 866 C598 870 650 892 702 934" fill="none"
        stroke="url(#silver)" stroke-width="4.5" opacity=".85"/>
  <path d="M262 1036 C302 1072 372 1088 450 1088 C528 1088 598 1072 638 1036" fill="none"
        stroke="url(#silver)" stroke-width="3" opacity=".7"/>
  <!-- boning and panel seams -->
  <path d="M314 1040 L300 1200 M370 1060 L362 1200 M530 1060 L538 1200 M586 1040 L600 1200"
        stroke="#c06b83" stroke-width="2.4" opacity=".5"/>
  <path d="M450 1058 L450 1200" stroke="#160c19" stroke-width="10" opacity=".85"/>
  <path d="M450 1058 L450 1200" stroke="url(#silver)" stroke-width="2.5" opacity=".55"/>
  <!-- front lacing -->
  <path d="M420 1070 L480 1092 M480 1070 L420 1092 M420 1110 L480 1132 M480 1110 L420 1132"
        stroke="url(#silver)" stroke-width="2.2" opacity=".7"/>
  <!-- pendant and chains -->
  <path d="M450 810 L450 966" stroke="url(#silver)" stroke-width="2.6" opacity=".9"/>
  <path d="M433 962 L450 936 L467 962 L450 990 Z" fill="#2a0b1b" stroke="url(#silver)" stroke-width="2.6"/>
  <path d="M441 962 L459 962 L455 980 L450 988 L445 980 Z" fill="#8f183d" opacity=".9"/>
  <path d="M258 964 C238 1030 240 1104 256 1170 M642 964 C662 1030 660 1104 644 1170" fill="none"
        stroke="url(#silver)" stroke-width="2.8" opacity=".65"/>
  <circle cx="256" cy="1172" r="7" fill="#1b0e1a" stroke="url(#silver)" stroke-width="2.4"/>
  <circle cx="644" cy="1172" r="7" fill="#1b0e1a" stroke="url(#silver)" stroke-width="2.4"/>
  <!-- gothic jewellery on skin -->
  <path d="M604 1006 C620 1050 620 1104 608 1150" fill="none" stroke="url(#silver)" stroke-width="2.4" opacity=".7"/>
  <path d="M608 1150 L616 1166 L606 1180 L598 1164 Z" fill="#741530" stroke="url(#silver)" stroke-width="1.8"/>
  <!-- shoulder injury, restrained and partly dressed over -->
  <ellipse cx="676" cy="952" rx="34" ry="20" fill="url(#bruise)" transform="rotate(-22 676 952)"/>
  <path d="M664 942 l12 5 M668 950 l11 4" fill="none" stroke="#a9687b" stroke-width="2"
        stroke-linecap="round" opacity=".5"/>
</g>
"""


def portrait_base() -> str:
    return head_base(long_hair=True) + portrait_body()


def make_portrait(mode: str) -> str:
    return portrait_base() + expression_overlay(mode)


def make_profile() -> str:
    return (
        '<rect width="900" height="900" fill="#120a19"/>'
        '<circle cx="450" cy="430" r="340" fill="#351531"/>'
        '<circle cx="450" cy="430" r="310" fill="none" stroke="#6d2948" stroke-width="2" opacity=".7"/>'
        '<g transform="translate(0 -30) scale(.94) translate(29 0)">' + make_portrait("smiling") + '</g>'
    )


def master_board() -> str:
    return (
        '<rect width="1400" height="1000" fill="#0d0814"/>'
        '<circle cx="400" cy="470" r="400" fill="#2a1430"/>'
        '<g transform="translate(-40 -10) scale(.78)">' + make_portrait("neutral") + '</g>'
        '<g transform="translate(860 -30) scale(.66)">' + standing_pose("neutral") + '</g>'
        '<text x="800" y="110" fill="#f5eaf0" font-family="Georgia,serif" font-size="44">Dracy</text>'
        '<text x="802" y="144" fill="#c58ba4" font-family="sans-serif" font-size="15">NOCTURNE · approved visual revision</text>'
        '<g font-family="sans-serif" font-size="14" fill="#d8c5d3">'
        '<rect x="800" y="190" width="40" height="40" rx="7" fill="#aebfda"/><text x="852" y="217">ASH SILVER-BLUE HAIR</text>'
        '<rect x="800" y="248" width="40" height="40" rx="7" fill="#b41338"/><text x="852" y="275">DEEP CRIMSON EYES</text>'
        '<rect x="800" y="306" width="40" height="40" rx="7" fill="#5a142f"/><text x="852" y="333">BLACK + BURGUNDY VELVET</text>'
        '<rect x="800" y="364" width="40" height="40" rx="7" fill="#72557f"/><text x="852" y="391">UNEXPLAINED INJURIES</text>'
        '</g>'
        '<text x="800" y="460" fill="#e4a4b8" font-family="sans-serif" font-size="16">Cause unknown. Tied to Nocturne by implication.</text>'
        '<text x="800" y="486" fill="#bca5b5" font-family="sans-serif" font-size="13">Restrained, non-graphic, never diagnostic or decorative.</text>'
        '<text x="800" y="534" fill="#e4a4b8" font-family="sans-serif" font-size="16">No religious cross imagery.</text>'
        '<text x="800" y="560" fill="#bca5b5" font-family="sans-serif" font-size="13">Black roses, spider lilies, chains, thorns, red gemstones.</text>'
    )

def head_group(mode: str, scale: float = 0.39, cx: float = 300, cy: float = 208) -> str:
    return (
        f'<g transform="translate({cx} {cy}) scale({scale}) translate({-HEAD_PIVOT_X} {-HEAD_PIVOT_Y})">'
        + head_base(long_hair=False, include_neck=True)
        + expression_overlay(mode)
        + "</g>"
    )


def _long_hair_body() -> str:
    return """
<path d="M250 300 C216 430 226 570 204 700 C186 810 166 912 156 992 C152 1032 154 1066 160 1092
         C178 1046 198 986 216 920 C238 820 254 730 264 640 C272 530 268 425 274 335 Z" fill="url(#hair)"/>
<path d="M350 300 C384 430 374 570 396 700 C414 810 434 912 444 992 C448 1032 446 1066 440 1092
         C422 1046 402 986 384 920 C362 820 346 730 336 640 C328 530 332 425 326 335 Z" fill="url(#hair)"/>
<path d="M258 360 C234 500 244 640 224 780 C212 870 198 950 190 1010
         C204 948 216 878 228 780 C242 660 244 520 254 400 Z" fill="url(#hairDark)" opacity=".5"/>
<path d="M342 360 C366 500 356 640 376 780 C388 870 402 950 410 1010
         C396 948 384 878 372 780 C358 660 356 520 346 400 Z" fill="url(#hairDark)" opacity=".5"/>
<path d="M240 400 C218 540 228 690 206 840 C196 910 184 980 176 1030" fill="none"
      stroke="url(#hairLight)" stroke-width="3" stroke-linecap="round" opacity=".3"/>
<path d="M360 400 C382 540 372 690 394 840 C404 910 416 980 424 1030" fill="none"
      stroke="url(#hairLight)" stroke-width="3" stroke-linecap="round" opacity=".26"/>
"""


def _front_locks() -> str:
    return """
<path d="M268 300 C252 400 258 496 247 584 C241 632 233 672 227 704
         C246 670 258 628 264 588 C274 520 276 430 282 360 Z" fill="url(#hair)"/>
<path d="M332 300 C348 400 342 496 353 584 C359 632 367 672 373 704
         C354 670 342 628 336 588 C326 520 324 430 318 360 Z" fill="url(#hair)"/>
<path d="M278 340 C268 424 272 508 262 590 C258 632 252 668 248 696
         C260 662 268 622 274 582 C282 508 280 424 286 380 Z" fill="url(#hairLight)" opacity=".42"/>
<path d="M322 340 C332 424 328 508 338 590 C342 632 348 668 352 696
         C340 662 332 622 326 582 C318 508 320 424 314 380 Z" fill="url(#hairLight)" opacity=".38"/>
"""


def _legs() -> str:
    return """
<path d="M246 640 C232 750 226 870 230 980 C234 1090 232 1190 234 1292
         L288 1292 C290 1190 292 1090 294 980 C298 870 298 750 302 640 Z" fill="url(#skin)"/>
<path d="M354 640 C368 750 374 870 370 980 C366 1090 368 1190 366 1292
         L312 1292 C310 1190 308 1090 306 980 C302 870 302 750 298 640 Z" fill="url(#skin)"/>
<path d="M252 760 C244 880 244 1010 250 1140 M348 760 C356 880 356 1010 350 1140" fill="none"
      stroke="#c9949e" stroke-width="2" opacity=".25"/>
"""


def _arms() -> str:
    return """
<path d="M228 344 C210 416 202 484 196 552 C190 620 184 688 183 730
         C183 752 194 766 208 764 C222 762 228 748 228 730 C230 690 236 626 242 556
         C248 484 256 418 262 362 Z" fill="url(#skin)"/>
<path d="M372 344 C390 416 398 484 404 552 C410 620 416 688 417 730
         C417 752 406 766 392 764 C378 762 372 748 372 730 C370 690 364 626 358 556
         C352 484 344 418 338 362 Z" fill="url(#skin)"/>
<path d="M196 540 C190 620 187 688 188 728 M404 540 C410 620 413 688 412 728" fill="none"
      stroke="#c9949e" stroke-width="2" opacity=".22"/>
"""


def _hands() -> str:
    return """
<g transform="translate(203 782)">
  <path d="M-17 -28 C-24 -20 -25 -2 -22 12 C-20 24 -12 32 -2 32 C8 32 14 24 14 12
           C14 -2 10 -20 2 -28 C-3 -32 -12 -32 -17 -28 Z" fill="url(#skin)"/>
  <path d="M-19 -6 C-26 2 -26 16 -19 24" fill="none" stroke="url(#skin)" stroke-width="9"
        stroke-linecap="round"/>
  <path d="M-8 4 L-8 22 M-1 6 L-1 24 M6 8 L6 22" stroke="#c9949e" stroke-width="1.6"
        stroke-linecap="round" opacity=".45"/>
  <path d="M-13 -22 C-9 -16 -7 -8 -8 0" fill="none" stroke="#c9949e" stroke-width="1.4" opacity=".4"/>
</g>
<g transform="translate(397 782) scale(-1 1)">
  <path d="M-17 -28 C-24 -20 -25 -2 -22 12 C-20 24 -12 32 -2 32 C8 32 14 24 14 12
           C14 -2 10 -20 2 -28 C-3 -32 -12 -32 -17 -28 Z" fill="url(#skin)"/>
  <path d="M-19 -6 C-26 2 -26 16 -19 24" fill="none" stroke="url(#skin)" stroke-width="9"
        stroke-linecap="round"/>
  <path d="M-8 4 L-8 22 M-1 6 L-1 24 M6 8 L6 22" stroke="#c9949e" stroke-width="1.6"
        stroke-linecap="round" opacity=".45"/>
  <path d="M-13 -22 C-9 -16 -7 -8 -8 0" fill="none" stroke="#c9949e" stroke-width="1.4" opacity=".4"/>
</g>
<path d="M196 752 l-3 10 M404 752 l3 10" stroke="#8f183d" stroke-width="3" stroke-linecap="round" opacity=".7"/>
"""


def _stockings(torn: bool = True, fishnet: bool = False) -> str:
    base = """
<path d="M238 848 C246 856 252 844 258 856 C264 844 272 858 278 846 C284 858 290 846 296 850
         L294 980 C292 1090 290 1190 288 1292 L234 1292 C232 1190 234 1090 230 980 Z" fill="url(#stocking)"/>
<path d="M362 848 C354 856 348 844 342 856 C336 844 328 858 322 846 C316 858 310 846 304 850
         L306 980 C308 1090 310 1190 312 1292 L366 1292 C368 1190 366 1090 370 980 Z" fill="url(#stocking)"/>
"""
    if fishnet:
        net = []
        for y in range(870, 1280, 34):
            net.append(f'<path d="M228 {y} L296 {y-16} M228 {y+16} L296 {y}" stroke="#4a2c4e" stroke-width="1.6" opacity=".7"/>')
            net.append(f'<path d="M372 {y} L304 {y-16} M372 {y+16} L304 {y}" stroke="#4a2c4e" stroke-width="1.6" opacity=".7"/>')
        base += "".join(net)
    if torn:
        base += """
<path d="M244 1082 L262 1090 L252 1102 L270 1110 L254 1122 L240 1104 Z" fill="url(#skin)"/>
<path d="M316 1140 L332 1146 L322 1158 L338 1164 L324 1174 L310 1158 Z" fill="url(#skin)"/>
<path d="M254 1112 L246 1180 M246 1160 L238 1190 M328 1158 L336 1210" stroke="#1a1222" stroke-width="2"
      stroke-linecap="round" opacity=".7"/>
"""
    return base


def _boots(style: str = "platform") -> str:
    if style == "ankle":
        return """
<path d="M232 1188 L290 1188 L296 1276 L300 1310 L222 1310 L218 1276 Z" fill="#0d0911" stroke="#5a1831" stroke-width="5"/>
<path d="M370 1188 L312 1188 L306 1276 L302 1310 L380 1310 L384 1276 Z" fill="#0d0911" stroke="#5a1831" stroke-width="5"/>
<path d="M218 1300 L300 1300 L300 1332 L212 1332 Z" fill="#0a070d"/>
<path d="M384 1300 L302 1300 L302 1332 L390 1332 Z" fill="#0a070d"/>
<path d="M230 1230 L292 1230 M372 1230 L310 1230" stroke="url(#silver)" stroke-width="3.5"/>
"""
    return """
<path d="M222 1216 L288 1216 L294 1310 L298 1352 L210 1352 L204 1310 Z" fill="#0d0911" stroke="#5a1831" stroke-width="5"/>
<path d="M378 1216 L312 1216 L306 1310 L302 1352 L390 1352 L396 1310 Z" fill="#0d0911" stroke="#5a1831" stroke-width="5"/>
<path d="M196 1352 L298 1352 Q304 1352 304 1360 L304 1384 L190 1384 L190 1360 Q190 1352 196 1352 Z" fill="#08060b"/>
<path d="M404 1352 L302 1352 Q296 1352 296 1360 L296 1384 L410 1384 L410 1360 Q410 1352 404 1352 Z" fill="#08060b"/>
<path d="M222 1248 L292 1248 M378 1248 L308 1248" stroke="url(#silver)" stroke-width="4"/>
<path d="M224 1300 L296 1300 M376 1300 L304 1300" stroke="#a94e6b" stroke-width="4" opacity=".8"/>
<path d="M242 1272 L258 1272 M358 1272 L342 1272" stroke="url(#silver)" stroke-width="5" stroke-linecap="round"/>
<path d="M300 1352 L300 1384" stroke="#050408" stroke-width="1"/>
"""


def _waist_rose(x: float = 236, y: float = 600) -> str:
    return f"""
<g transform="translate({x} {y})">
  <circle r="20" fill="#0b070e" stroke="#4a1830" stroke-width="2"/>
  <path d="M0 -18 C10 -10 10 4 0 12 C-10 4 -10 -10 0 -18 Z" fill="#2a0b1b"/>
  <path d="M0 -10 C6 -4 6 4 0 8 C-6 4 -6 -4 0 -10 Z" fill="#5a1831"/>
  <path d="M0 -4 C3 0 3 4 0 6 C-3 4 -3 0 0 -4 Z" fill="#8b1538"/>
  <path d="M-16 6 C-24 14 -12 20 -2 18 M16 6 C24 14 12 20 2 18" fill="none" stroke="#5a1831" stroke-width="3"/>
</g>
"""


def outfit_signature(expression: str = "neutral") -> str:
    return f"""
<ellipse cx="300" cy="1376" rx="186" ry="18" fill="#07050b" opacity=".5"/>
{_long_hair_body()}
{_legs()}
{_stockings(torn=True)}
{_boots("platform")}
<!-- short layered gothic skirt -->
<path d="M232 556 C210 636 188 728 172 836 C218 860 262 868 300 868 C338 868 382 860 428 836
         C412 728 390 636 368 556 Z" fill="url(#velvet)"/>
<path d="M246 560 C226 640 208 734 196 842 C234 858 268 864 300 864 C332 864 366 858 404 842
         C392 734 372 640 354 560 Z" fill="url(#burgundy)" opacity=".92"/>
<path d="M176 832 C220 856 262 864 300 864 C338 864 380 856 424 832" fill="none"
      stroke="url(#silver)" stroke-width="4" opacity=".8"/>
<path d="M202 864 L194 892 L226 880 L234 904 L262 884 L300 908 L338 884 L366 904 L374 880 L406 892 L398 864"
      fill="#0b070e" stroke="#5a1831" stroke-width="2"/>
<path d="M240 620 L228 850 M288 610 L284 872 M312 610 L316 872 M360 620 L372 850" stroke="#a94e6b"
      stroke-width="2.2" opacity=".5"/>
<!-- arms and hands -->
{_arms()}
<!-- fitted bodice -->
<path d="M234 348 C262 388 282 408 300 414 C318 408 338 388 366 348 L378 576 L222 576 Z" fill="url(#velvet)"/>
<path d="M250 426 C274 456 288 470 300 474 C312 470 326 456 350 426 L358 576 L242 576 Z" fill="url(#burgundy)"/>
<path d="M234 348 C262 388 282 408 300 414 C318 408 338 388 366 348" fill="none"
      stroke="url(#silver)" stroke-width="4" opacity=".9"/>
<path d="M268 470 L276 576 M332 470 L324 576 M300 474 L300 576" stroke="#c06b83" stroke-width="2.2" opacity=".55"/>
<path d="M284 500 L316 516 M316 500 L284 516 M284 536 L316 552 M316 536 L284 552" stroke="url(#silver)"
      stroke-width="2" opacity=".75"/>
<!-- off-shoulder sleeves -->
<path d="M214 344 C196 354 188 384 196 414 C206 436 224 446 240 440 L250 392 L244 352 Z" fill="url(#velvet)"/>
<path d="M386 344 C404 354 412 384 404 414 C394 436 376 446 360 440 L350 392 L356 352 Z" fill="url(#velvet)"/>
<path d="M196 410 C208 432 224 442 240 436 M404 410 C392 432 376 442 360 436" fill="none"
      stroke="#a94e6b" stroke-width="3" opacity=".8"/>
<!-- belt, rose, pendant -->
<path d="M230 552 L370 552 L374 586 L226 586 Z" fill="#0c0811"/>
<path d="M230 556 L370 556 M228 582 L372 582" stroke="url(#silver)" stroke-width="2.4" opacity=".8"/>
<path d="M288 554 L312 554 L308 578 L300 586 L292 578 Z" fill="#8b1538" stroke="url(#silver)" stroke-width="2"/>
{_waist_rose(238, 604)}
<path d="M300 312 L300 430" stroke="url(#silver)" stroke-width="2.4" opacity=".9"/>
<path d="M288 430 L300 410 L312 430 L300 450 Z" fill="#2a0b1b" stroke="url(#silver)" stroke-width="2.2"/>
<path d="M294 430 L306 430 L303 443 L300 449 L297 443 Z" fill="#8f183d"/>
<!-- jewellery and restrained injuries -->
<path d="M198 690 C204 706 206 722 204 738 M402 690 C396 706 394 722 396 738" fill="none"
      stroke="url(#silver)" stroke-width="3" stroke-linecap="round" opacity=".8"/>
<path d="M240 392 C252 404 266 410 280 412" fill="none" stroke="#a9687b" stroke-width="2"
      stroke-linecap="round" opacity=".45"/>
<ellipse cx="336" cy="372" rx="24" ry="14" fill="url(#bruise)" transform="rotate(-18 336 372)"/>
<path d="M190 748 l9 5 M189 760 l9 5 M192 772 l8 4" fill="none" stroke="#a9687b" stroke-width="1.8"
      stroke-linecap="round" opacity=".6"/>
{_hands()}
{_front_locks()}
{head_group(expression)}
"""


def outfit_casual(expression: str = "neutral") -> str:
    return f"""
<ellipse cx="300" cy="1376" rx="186" ry="18" fill="#07050b" opacity=".5"/>
{_long_hair_body()}
{_legs()}
<path d="M240 846 C248 854 254 842 260 854 C266 842 274 856 280 844 C286 856 292 844 298 848
         L296 980 C294 1090 292 1190 290 1292 L234 1292 C232 1190 234 1090 230 980 Z" fill="#151019"/>
<path d="M360 846 C352 854 346 842 340 854 C334 842 326 856 320 844 C314 856 308 844 302 848
         L304 980 C306 1090 308 1190 310 1292 L366 1292 C368 1190 366 1090 370 980 Z" fill="#151019"/>
{_boots("ankle")}
<!-- pleated burgundy skirt -->
<path d="M236 566 L364 566 L400 852 L200 852 Z" fill="url(#burgundy)"/>
<path d="M252 570 L240 850 M284 570 L280 850 M316 570 L320 850 M348 570 L360 850" stroke="#a94e6b"
      stroke-width="2.2" opacity=".55"/>
<path d="M200 852 L400 852" stroke="#0c0811" stroke-width="8"/>
<!-- oversized knit sweater -->
<path d="M214 350 C244 372 272 388 300 392 C328 388 356 372 386 350 L408 604 L192 604 Z" fill="#17121c"/>
<path d="M214 350 C244 372 272 388 300 392 C328 388 356 372 386 350" fill="none" stroke="#332540" stroke-width="6"/>
<path d="M244 470 L236 604 M356 470 L364 604 M276 486 L272 604 M324 486 L328 604" stroke="#2c2034"
      stroke-width="2.2" opacity=".8"/>
<path d="M232 592 L368 592" stroke="#4a2c4e" stroke-width="4"/>
<!-- long knit sleeves -->
<path d="M214 356 C190 450 180 570 186 706 C188 736 208 748 224 736 L236 704 C226 582 230 460 246 372 Z" fill="#17121c"/>
<path d="M386 356 C410 450 420 570 414 706 C412 736 392 748 376 736 L364 704 C374 582 370 460 354 372 Z" fill="#17121c"/>
<path d="M186 706 C188 736 208 748 224 736 M414 706 C412 736 392 748 376 736" fill="none"
      stroke="#332540" stroke-width="3"/>
<!-- choker chain and rings -->
<path d="M300 318 L300 372" stroke="url(#silver)" stroke-width="2.2" opacity=".85"/>
<path d="M290 372 L300 356 L310 372 L300 388 Z" fill="#741530" stroke="url(#silver)" stroke-width="1.8"/>
<path d="M206 602 C212 616 214 630 212 644 M394 602 C388 616 386 630 388 644" fill="none"
      stroke="url(#silver)" stroke-width="2.6" opacity=".75"/>
<path d="M228 640 l8 4 M228 652 l8 4 M372 640 l-8 4 M372 652 l-8 4" fill="none" stroke="#a9687b"
      stroke-width="1.6" stroke-linecap="round" opacity=".5"/>
{_hands()}
{_front_locks()}
{head_group(expression)}
"""

def outfit_gothic(expression: str = "neutral") -> str:
    return f"""
<ellipse cx="300" cy="1376" rx="186" ry="18" fill="#07050b" opacity=".5"/>
{_long_hair_body()}
{_legs()}
<!-- floor-length velvet gown -->
<path d="M232 560 C208 700 188 904 174 1108 L170 1332 L430 1332 L426 1108 C412 904 392 700 368 560 Z" fill="url(#velvet)"/>
<path d="M246 566 C228 704 212 906 202 1112 L198 1328 L402 1328 L398 1112 C388 906 372 704 354 566 Z" fill="url(#burgundy)" opacity=".45"/>
<path d="M182 1300 C232 1320 268 1328 300 1328 C332 1328 368 1320 418 1300" fill="none"
      stroke="url(#silver)" stroke-width="4" opacity=".7"/>
<path d="M214 620 C204 820 196 1040 190 1280 M386 620 C396 820 404 1040 410 1280" stroke="#5a1831"
      stroke-width="2.2" opacity=".6"/>
<path d="M250 700 C236 880 228 1080 224 1280 M350 700 C364 880 372 1080 376 1280" stroke="#a94e6b"
      stroke-width="2" opacity=".35"/>
<!-- arms and long sleeves -->
{_arms()}
<path d="M228 344 C206 424 198 512 192 600 C188 668 184 730 184 782 C184 802 196 812 208 808
         C220 804 226 790 226 772 C228 720 234 648 240 576 C246 496 254 424 262 362 Z" fill="url(#velvet)"/>
<path d="M372 344 C394 424 402 512 408 600 C412 668 416 730 416 782 C416 802 404 812 392 808
         C380 804 374 790 374 772 C372 720 366 648 360 576 C354 496 346 424 338 362 Z" fill="url(#velvet)"/>
<path d="M192 600 C188 668 184 730 184 782 M408 600 C412 668 416 730 416 782" fill="none"
      stroke="#5a1831" stroke-width="2.4" opacity=".7"/>
<!-- high lace collar -->
<path d="M258 368 C264 322 280 298 300 294 C320 298 336 322 342 368 L336 404 L264 404 Z" fill="url(#velvet)"/>
<path d="M258 368 C264 322 280 298 300 294 C320 298 336 322 342 368" fill="none"
      stroke="url(#silver)" stroke-width="2.4" opacity=".85"/>
<path d="M272 352 L300 386 L328 352" fill="none" stroke="#6b3650" stroke-width="2" stroke-dasharray="4 5"/>
<!-- fitted bodice and filigree -->
<path d="M244 386 C268 362 284 352 300 352 C316 352 332 362 356 386 L372 576 L228 576 Z" fill="url(#velvet)"/>
<path d="M300 352 L300 576" stroke="url(#silver)" stroke-width="2.4" opacity=".8"/>
<path d="M270 402 C258 460 258 520 266 576 M330 402 C342 460 342 520 334 576" stroke="#a94e6b"
      stroke-width="2.2" opacity=".55"/>
<path d="M264 470 C280 492 292 504 300 508 C308 504 320 492 336 470" fill="none"
      stroke="url(#silver)" stroke-width="2.4" opacity=".85"/>
<path d="M280 530 C290 540 296 544 300 546 C304 544 310 540 320 530" fill="none"
      stroke="#6b3650" stroke-width="2" stroke-dasharray="4 5"/>
<!-- sash and rose -->
<path d="M232 572 C262 592 282 602 300 604 C318 602 338 592 368 572 L374 608 C340 630 320 638 300 638
         C280 638 260 630 226 608 Z" fill="#0c0811" stroke="#5a1831" stroke-width="3"/>
<path d="M300 604 L300 640" stroke="url(#silver)" stroke-width="2.4"/>
{_waist_rose(238, 618)}
<!-- pendant -->
<path d="M300 392 L300 480" stroke="url(#silver)" stroke-width="2.2" opacity=".85"/>
<path d="M290 480 L300 462 L310 480 L300 500 Z" fill="#741530" stroke="url(#silver)" stroke-width="2"/>
{_hands()}
{_front_locks()}
{head_group(expression)}
"""


def outfit_alternative(expression: str = "neutral") -> str:
    return f"""
<ellipse cx="300" cy="1376" rx="186" ry="18" fill="#07050b" opacity=".5"/>
{_long_hair_body()}
{_legs()}
{_stockings(torn=False, fishnet=True)}
{_boots("platform")}
<!-- plaid mini skirt -->
<path d="M234 556 L366 556 L400 822 L200 822 Z" fill="#1a1220"/>
<path d="M244 566 L236 818 M274 566 L272 818 M300 566 L300 818 M326 566 L328 818 M356 566 L364 818"
      stroke="#7e1f3f" stroke-width="7" opacity=".75"/>
<path d="M220 640 L380 640 M210 730 L390 730" stroke="#7e1f3f" stroke-width="5" opacity=".6"/>
<path d="M200 822 L400 822" stroke="#0c0811" stroke-width="7"/>
<!-- cropped harness top -->
<path d="M236 358 C260 382 280 396 300 400 C320 396 340 382 364 358 L374 512 L226 512 Z" fill="#100d15"/>
<path d="M236 358 C260 382 280 396 300 400 C320 396 340 382 364 358" fill="none" stroke="#33203a" stroke-width="5"/>
<path d="M248 404 L352 404 M240 452 L360 452" stroke="#2a1226" stroke-width="12"/>
<path d="M248 404 L352 404 M240 452 L360 452" stroke="url(#silver)" stroke-width="2" stroke-dasharray="12 6"/>
<path d="M272 404 L272 512 M328 404 L328 512" stroke="#4a1830" stroke-width="2.4"/>
<path d="M300 400 L300 512" stroke="url(#silver)" stroke-width="2.4" opacity=".8"/>
<!-- bare midriff and harness chains -->
<path d="M236 512 L364 512 L368 556 L232 556 Z" fill="url(#skin)"/>
<path d="M244 520 C268 542 282 550 300 552 C318 550 332 542 356 520" fill="none" stroke="url(#silver)"
      stroke-width="2.2" opacity=".8"/>
<path d="M250 512 C242 530 240 544 242 556 M350 512 C358 530 360 544 358 556" fill="none"
      stroke="url(#silver)" stroke-width="2.4" opacity=".7"/>
<!-- arms with striped warmers -->
{_arms()}
<path d="M200 560 C194 640 190 720 190 780 C190 798 200 808 212 806
         C222 804 228 790 228 772 C230 720 236 648 242 580 Z" fill="#17121c"/>
<path d="M400 560 C406 640 410 720 410 780 C410 798 400 808 388 806
         C378 804 372 790 372 772 C370 720 364 648 358 580 Z" fill="#17121c"/>
<path d="M196 610 L232 610 M194 648 L234 648 M193 686 L236 686 M404 610 L368 610 M406 648 L366 648
         M407 686 L364 686" stroke="#7e1f3f" stroke-width="3" opacity=".8"/>
<!-- hardware -->
<path d="M300 312 L300 380" stroke="url(#silver)" stroke-width="2.2" opacity=".85"/>
<path d="M290 380 L300 364 L310 380 L300 396 Z" fill="#741530" stroke="url(#silver)" stroke-width="1.8"/>
<path d="M206 760 C214 774 216 788 214 800 M394 760 C386 774 384 788 386 800" fill="none"
      stroke="url(#silver)" stroke-width="2.6" opacity=".75"/>
<ellipse cx="342" cy="376" rx="22" ry="13" fill="url(#bruise)" transform="rotate(-16 342 376)"/>
<path d="M192 706 l9 5 M191 718 l9 5" fill="none" stroke="#a9687b" stroke-width="1.8"
      stroke-linecap="round" opacity=".55"/>
{_hands()}
{_front_locks()}
{head_group(expression)}
"""


def seated_pose(expression: str = "neutral") -> str:
    return f"""
<ellipse cx="300" cy="1152" rx="200" ry="18" fill="#07050b" opacity=".5"/>
<!-- chair -->
<path d="M168 190 Q170 148 300 144 Q430 148 432 190 L432 700 L168 700 Z" fill="#160f1d"
      stroke="#5b213c" stroke-width="8"/>
<path d="M196 212 Q198 178 300 174 Q402 178 404 212 L404 676 L196 676 Z" fill="#24142a"
      stroke="#3f2639" stroke-width="3"/>
<path d="M300 196 L300 660 M210 300 L390 300" stroke="#3a2136" stroke-width="2" opacity=".6"/>
<circle cx="180" cy="166" r="14" fill="#2a1430" stroke="#6d2948" stroke-width="3"/>
<circle cx="420" cy="166" r="14" fill="#2a1430" stroke="#6d2948" stroke-width="3"/>
<path d="M150 660 L450 660 L470 708 L130 708 Z" fill="#120c17" stroke="#4a1b32" stroke-width="5"/>
<path d="M162 708 L152 1010 M438 708 L448 1010" stroke="#2c1728" stroke-width="18"/>
<path d="M156 1010 L444 1010" stroke="#4a1b32" stroke-width="12"/>
<path d="M166 990 L434 990" stroke="#2c1728" stroke-width="4" opacity=".7"/>
<!-- hair over the chair -->
<path d="M248 250 C214 400 226 560 204 720 C188 840 170 960 160 1060 L158 1104 L214 1104
         C228 980 244 850 254 720 C266 580 262 420 268 310 Z" fill="url(#hair)"/>
<path d="M352 250 C386 400 374 560 396 720 C412 840 430 960 440 1060 L442 1104 L386 1104
         C372 980 356 850 346 720 C334 580 338 420 332 310 Z" fill="url(#hair)"/>
<path d="M256 320 C232 470 244 620 224 780 C214 860 202 940 194 1000" fill="none"
      stroke="url(#hairLight)" stroke-width="3" opacity=".3"/>
<!-- torso -->
<path d="M244 386 C268 362 284 352 300 352 C316 352 332 362 356 386 L372 680 L228 680 Z" fill="url(#velvet)"/>
<path d="M258 430 C278 456 290 468 300 472 C310 468 322 456 342 430 L352 680 L248 680 Z" fill="url(#burgundy)"/>
<path d="M244 386 C268 362 284 352 300 352 C316 352 332 362 356 386" fill="none"
      stroke="url(#silver)" stroke-width="3.6" opacity=".85"/>
<path d="M276 470 L280 680 M324 470 L320 680" stroke="#c06b83" stroke-width="2.2" opacity=".5"/>
<path d="M288 500 L312 514 M312 500 L288 514 M288 536 L312 550 M312 536 L288 550" stroke="url(#silver)"
      stroke-width="2" opacity=".7"/>
<!-- draped skirt over the lap -->
<path d="M228 664 C210 700 190 760 184 828 C230 850 268 858 300 858 C332 858 370 850 416 828
         C410 760 390 700 372 664 Z" fill="url(#velvet)"/>
<path d="M240 670 C226 706 212 762 208 826 C242 842 272 848 300 848 C328 848 358 842 392 826
         C388 762 374 706 360 670 Z" fill="url(#burgundy)" opacity=".9"/>
<path d="M188 824 C230 846 268 854 300 854 C332 854 370 846 412 824" fill="none"
      stroke="url(#silver)" stroke-width="3.4" opacity=".75"/>
<path d="M250 700 L240 840 M300 692 L300 848 M350 700 L360 840" stroke="#a94e6b" stroke-width="2"
      opacity=".45"/>
<!-- arms resting -->
<path d="M246 400 C218 470 206 552 216 622 C220 646 236 656 250 648 L264 606 C256 552 262 486 274 442 Z" fill="url(#velvet)"/>
<path d="M354 400 C382 470 394 552 384 622 C380 646 364 656 350 648 L336 606 C344 552 338 486 326 442 Z" fill="url(#velvet)"/>
<path d="M246 400 C218 470 206 552 216 622 M354 400 C382 470 394 552 384 622" fill="none"
      stroke="#5a1831" stroke-width="2.4" opacity=".7"/>
<!-- legs and boots -->
<path d="M262 840 C256 920 258 1000 264 1080 L292 1080 C294 1000 294 920 292 840 Z" fill="url(#stocking)"/>
<path d="M338 840 C344 920 342 1000 336 1080 L308 1080 C306 1000 306 920 308 840 Z" fill="url(#stocking)"/>
<path d="M272 920 L286 928 M272 956 L286 964 M328 920 L314 928 M328 956 L314 964" stroke="#b17b8d"
      stroke-width="2" opacity=".4"/>
<path d="M254 1068 L294 1068 L298 1130 L302 1158 L244 1158 L240 1130 Z" fill="#0d0911" stroke="#5a1831" stroke-width="5"/>
<path d="M346 1068 L306 1068 L302 1130 L298 1158 L356 1158 L360 1130 Z" fill="#0d0911" stroke="#5a1831" stroke-width="5"/>
<path d="M240 1158 L302 1158 L302 1184 L232 1184 Z" fill="#08060b"/>
<path d="M360 1158 L298 1158 L298 1184 L368 1184 Z" fill="#08060b"/>
<path d="M252 1100 L296 1100 M348 1100 L304 1100" stroke="url(#silver)" stroke-width="3.4"/>
<!-- hands, pendant, rose -->
<path d="M236 636 C230 648 232 662 242 668 C252 674 262 668 264 656 C266 644 258 634 248 634 Z" fill="url(#skin)"/>
<path d="M364 636 C370 648 368 662 358 668 C348 674 338 668 336 656 C334 644 342 634 352 634 Z" fill="url(#skin)"/>
<path d="M300 374 L300 436" stroke="url(#silver)" stroke-width="2.2" opacity=".85"/>
<path d="M290 436 L300 420 L310 436 L300 454 Z" fill="#741530" stroke="url(#silver)" stroke-width="2"/>
{_waist_rose(262, 606)}
<!-- seated injuries -->
<ellipse cx="252" cy="470" rx="20" ry="13" fill="url(#bruise)" transform="rotate(-24 252 470)"/>
<path d="M244 462 l8 4 M246 470 l8 4" fill="none" stroke="#a9687b" stroke-width="1.8"
      stroke-linecap="round" opacity=".55"/>
<g transform="translate(300 236) scale(0.37) translate({-HEAD_PIVOT_X} {-HEAD_PIVOT_Y})">
{head_base(long_hair=False, include_neck=True)}
{expression_overlay(expression)}
</g>
"""


def standing_pose(expression: str = "neutral") -> str:
    return outfit_signature(expression)


def generate_dracy_character() -> None:
    write_svg("characters/dracy/base.svg", portrait_base(), 900, 1200)
    for mode in EXPRESSIONS:
        write_svg(f"characters/dracy/sprites/expressions/{mode}.svg", make_portrait(mode), 900, 1200)
        # Legacy overlay path retained for compatibility with older previews.
        write_svg(f"characters/dracy/expressions/{mode}.svg", expression_overlay(mode), 900, 1200, defs="")
    write_svg("characters/dracy/profile.svg", make_profile(), 900, 900)

    write_svg("characters/dracy/sprites/poses/standing.svg", standing_pose("neutral"), 600, 1400)
    write_svg("characters/dracy/sprites/poses/seated.svg", seated_pose("neutral"), 600, 1200)
    write_svg("characters/dracy/sprites/outfits/signature.svg", outfit_signature("neutral"), 600, 1400)
    write_svg("characters/dracy/sprites/outfits/casual.svg", outfit_casual("neutral"), 600, 1400)
    write_svg("characters/dracy/sprites/outfits/gothic.svg", outfit_gothic("neutral"), 600, 1400)
    write_svg("characters/dracy/sprites/outfits/alternative.svg", outfit_alternative("neutral"), 600, 1400)

    # Legacy outfit/pose paths retained but now point at the revised designs.
    write_svg("characters/dracy/outfits/nocturne.svg", outfit_signature("neutral"), 600, 1400)
    write_svg("characters/dracy/outfits/velvet.svg", outfit_gothic("neutral"), 600, 1400)
    write_svg("characters/dracy/outfits/casual.svg", outfit_casual("neutral"), 600, 1400)
    write_svg("characters/dracy/outfits/ritual.svg", outfit_alternative("neutral"), 600, 1400)
    write_svg("characters/dracy/poses/confident.svg", standing_pose("neutral"), 600, 1400)
    write_svg("characters/dracy/poses/camera.svg", standing_pose("neutral"), 600, 1400)
    write_svg("characters/dracy/poses/phone.svg", standing_pose("neutral"), 600, 1400)

    DESIGN.mkdir(parents=True, exist_ok=True)
    (DESIGN / "dracy-vector-master.svg").write_text(
        SVG_HEAD.format(w=1400, h=1000) + DEFS + master_board() + "</svg>",
        encoding="utf-8",
    )
    print("Generated Dracy's revised transparent character set.")


if __name__ == "__main__":
    generate_dracy_character()
