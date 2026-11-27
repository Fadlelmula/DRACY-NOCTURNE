#!/usr/bin/env python3
"""Generate DRACY: NOCTURNE's original vector art assets.

No external images, anime designs, logos, or extracted game assets are used.
The output is deterministic and can be regenerated from this source file.
Run from the game directory: python tools/generate_art.py
"""
from pathlib import Path

from dracy_character_art import generate_dracy_character

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"

SVG_HEAD = '<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
DEFS = """
<defs>
  <linearGradient id="hair" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#e6edf9"/><stop offset=".28" stop-color="#aebfda"/><stop offset=".62" stop-color="#6f84aa"/><stop offset="1" stop-color="#35435f"/></linearGradient>
  <linearGradient id="hairLight" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#f5f7ff"/><stop offset=".5" stop-color="#c4d2e8"/><stop offset="1" stop-color="#7185aa"/></linearGradient>
  <radialGradient id="bruise"><stop stop-color="#8e648e" stop-opacity=".42"/><stop offset=".55" stop-color="#72557f" stop-opacity=".28"/><stop offset="1" stop-color="#5b426e" stop-opacity="0"/></radialGradient>
  <linearGradient id="skin" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#f4d9d6"/><stop offset=".7" stop-color="#e6bdbd"/><stop offset="1" stop-color="#cf9ca7"/></linearGradient>
  <linearGradient id="dress" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#17111d"/><stop offset=".55" stop-color="#09080e"/><stop offset="1" stop-color="#291020"/></linearGradient>
  <linearGradient id="burgundy" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#8f2848"/><stop offset=".5" stop-color="#4b1029"/><stop offset="1" stop-color="#240a19"/></linearGradient>
  <linearGradient id="silver" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#fff4f7"/><stop offset=".35" stop-color="#a99ba9"/><stop offset=".7" stop-color="#e2d7df"/><stop offset="1" stop-color="#746977"/></linearGradient>
  <radialGradient id="eye" cx="50%" cy="45%" r="65%"><stop stop-color="#ffb2b8"/><stop offset=".35" stop-color="#d5355d"/><stop offset=".75" stop-color="#7c0d31"/><stop offset="1" stop-color="#2b0616"/></radialGradient>
  <linearGradient id="night" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#160d24"/><stop offset=".6" stop-color="#281132"/><stop offset="1" stop-color="#09060e"/></linearGradient>
  <radialGradient id="moon"><stop stop-color="#f0c9c9"/><stop offset=".6" stop-color="#c56a78"/><stop offset="1" stop-color="#7d2746"/></radialGradient>
  <linearGradient id="window" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#273047"/><stop offset=".55" stop-color="#141a2b"/><stop offset="1" stop-color="#090b13"/></linearGradient>
</defs>
"""


def write_svg(relative: str, body: str, w: int, h: int, defs: str = DEFS) -> None:
    path = ASSETS / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(SVG_HEAD.format(w=w, h=h) + defs + body + "</svg>", encoding="utf-8")


def portrait_base() -> str:
    return """
<g id="dracy-portrait">
  <!-- long, layered hair silhouette -->
  <path d="M285 1180 C250 1030 245 850 274 650 C270 470 305 260 388 190 C440 145 500 158 545 190 C628 258 661 448 654 630 C681 830 675 1020 628 1180 Z" fill="url(#hair)"/>
  <path d="M323 1140 C286 910 310 690 318 520 C300 400 329 260 395 215 C368 344 362 475 380 620 C330 745 328 946 358 1150 Z" fill="#27334c" opacity=".72"/>
  <path d="M576 1160 C626 930 602 720 594 540 C620 398 586 265 518 217 C557 350 555 476 531 624 C584 765 580 980 548 1170 Z" fill="#202a40" opacity=".78"/>
  <!-- neck and shoulders -->
  <path d="M391 461 C398 522 389 550 356 570 L284 616 C252 646 231 707 220 792 L211 1200 L688 1200 L678 786 C666 703 645 646 610 617 L535 571 C502 551 496 520 502 461 Z" fill="url(#skin)"/>
  <path d="M391 474 C414 509 479 512 503 474 L512 559 C476 586 418 586 381 557 Z" fill="#c9949e" opacity=".55"/>
  <!-- face -->
  <path d="M343 267 C358 213 414 184 451 188 C500 186 550 219 563 270 C574 335 559 425 523 470 C498 504 471 528 450 535 C424 527 397 503 373 470 C338 426 326 333 343 267 Z" fill="url(#skin)"/>
  <path d="M343 294 C327 274 313 300 321 333 C326 352 336 365 348 363" fill="url(#skin)"/>
  <path d="M562 293 C579 272 592 300 584 333 C579 352 568 365 557 363" fill="url(#skin)"/>
  <!-- nose and face shading -->
  <path d="M450 354 C443 390 438 410 431 420 C439 427 451 429 461 423" fill="none" stroke="#ba7f8e" stroke-width="3" stroke-linecap="round" opacity=".65"/>
  <path d="M357 438 C395 469 428 476 451 475 C484 473 518 457 546 429" fill="none" stroke="#c18d99" stroke-width="2" opacity=".25"/>
  <!-- bangs and face-framing locks -->
  <path d="M325 353 C303 259 336 151 420 124 C508 96 590 156 607 267 C564 246 532 210 512 169 C493 232 458 270 404 290 C381 299 360 318 350 354 Z" fill="url(#hair)"/>
  <path d="M349 237 C381 167 450 137 519 158 C478 171 446 201 424 238 C397 253 369 249 349 237 Z" fill="url(#hairLight)" opacity=".55"/>
  <path d="M333 285 C321 395 326 521 303 653 C342 616 366 548 373 465 C358 399 352 337 361 291 Z" fill="url(#hair)"/>
  <path d="M565 281 C580 385 572 519 598 650 C557 612 538 542 530 463 C545 396 550 333 541 291 Z" fill="url(#hair)"/>
  <path d="M328 321 C341 472 324 629 300 754" fill="none" stroke="#b8c8e2" stroke-width="5" opacity=".48" stroke-linecap="round"/>
  <path d="M571 325 C556 475 576 626 603 750" fill="none" stroke="#aebfda" stroke-width="5" opacity=".42" stroke-linecap="round"/>
  <!-- unexplained injuries: faded, non-graphic, and narratively meaningful -->
  <ellipse cx="386" cy="428" rx="34" ry="20" fill="url(#bruise)" transform="rotate(-12 386 428)"/>
  <ellipse cx="520" cy="443" rx="27" ry="17" fill="url(#bruise)" transform="rotate(14 520 443)"/>
  <path d="M441 397 L449 420 M438 403 l7 -2 M440 410 l7 -2" fill="none" stroke="#9a5e70" stroke-width="2.4" stroke-linecap="round" opacity=".8"/>
  <path d="M523 429 l12 9 M527 425 l11 9" fill="none" stroke="#a9687b" stroke-width="2" stroke-linecap="round" opacity=".72"/>
  <circle cx="527" cy="458" r="3.2" fill="#4b2637" opacity=".9"/>
  <!-- black lace choker with a non-religious red gemstone -->
  <path d="M382 535 Q450 568 518 535" fill="none" stroke="#100b14" stroke-width="18" stroke-linecap="round"/>
  <path d="M382 535 Q450 568 518 535" fill="none" stroke="#6e3a53" stroke-width="2" stroke-dasharray="4 6"/>
  <path d="M450 557 L462 573 L450 589 L438 573 Z" fill="#8f183d" stroke="url(#silver)" stroke-width="3"/>
  <!-- gothic dress and bodice -->
  <path d="M281 616 C343 574 389 563 450 569 C515 563 564 579 614 619 L670 1200 L230 1200 Z" fill="url(#dress)"/>
  <path d="M331 596 L377 1200 L523 1200 L569 596 C519 622 481 631 450 631 C414 631 379 622 331 596 Z" fill="url(#burgundy)"/>
  <path d="M351 621 L380 1200 M548 621 L520 1200" stroke="#b54a68" stroke-width="3" opacity=".55"/>
  <path d="M308 649 C352 687 390 700 450 701 C510 700 550 687 591 649" fill="none" stroke="url(#silver)" stroke-width="5"/>
  <path d="M320 679 C365 717 405 728 450 728 C497 728 537 716 580 677" fill="none" stroke="#5c233c" stroke-width="9"/>
  <!-- lace collar -->
  <path d="M374 566 C401 604 429 620 450 621 C472 620 500 604 526 566 L548 603 C514 651 480 671 450 671 C419 671 386 650 352 603 Z" fill="#100b14" stroke="#6e3a53" stroke-width="2"/>
  <path d="M383 594 Q450 660 517 594" fill="none" stroke="#a56680" stroke-width="2" stroke-dasharray="4 7"/>
  <!-- silver jewelry -->
  <path d="M450 679 L450 786" stroke="url(#silver)" stroke-width="4"/>
  <circle cx="450" cy="800" r="17" fill="none" stroke="url(#silver)" stroke-width="5"/>
  <path d="M450 783 L460 800 L450 818 L440 800 Z" fill="#7d1839" stroke="url(#silver)" stroke-width="2"/>
  <path d="M367 641 C346 718 349 814 372 907" fill="none" stroke="url(#silver)" stroke-width="3" opacity=".85"/>
  <path d="M538 641 C557 721 553 817 531 908" fill="none" stroke="url(#silver)" stroke-width="3" opacity=".85"/>
  <circle cx="372" cy="911" r="8" fill="#1a0c17" stroke="url(#silver)" stroke-width="3"/>
  <circle cx="531" cy="912" r="8" fill="#1a0c17" stroke="url(#silver)" stroke-width="3"/>
  <!-- rings and hands suggested at lower frame -->
  <path d="M302 1038 C325 1009 353 1008 374 1034 L394 1082 C370 1110 333 1111 307 1087 Z" fill="url(#skin)"/>
  <path d="M596 1038 C573 1009 545 1008 524 1034 L504 1082 C528 1110 565 1111 591 1087 Z" fill="url(#skin)"/>
  <ellipse cx="337" cy="1063" rx="29" ry="18" fill="url(#bruise)" transform="rotate(18 337 1063)"/>
  <ellipse cx="638" cy="682" rx="31" ry="20" fill="url(#bruise)" transform="rotate(-24 638 682)"/>
  <path d="M626 674 l13 5 M630 681 l12 4" fill="none" stroke="#a9687b" stroke-width="2" stroke-linecap="round" opacity=".68"/>
  <path d="M315 1054 L357 1072 M583 1054 L541 1072" stroke="url(#silver)" stroke-width="6"/>
</g>
"""


EYES = """
<g fill="url(#eye)" stroke="#35101f" stroke-width="3">
  <path d="M363 390 Q388 367 420 389 Q391 420 363 390 Z"/>
  <path d="M480 389 Q512 367 537 390 Q509 420 480 389 Z"/>
</g>
<ellipse cx="392" cy="391" rx="8" ry="13" fill="#220714"/>
<ellipse cx="512" cy="391" rx="8" ry="13" fill="#220714"/>
<circle cx="386" cy="384" r="5" fill="#fff4f7"/>
<circle cx="506" cy="384" r="5" fill="#fff4f7"/>
<path d="M358 386 Q389 361 424 386 M476 386 Q508 361 542 386" fill="none" stroke="#27101b" stroke-width="5" stroke-linecap="round"/>
<path d="M357 383 L344 375 M424 386 L435 378 M476 386 L465 378 M543 383 L555 375" fill="none" stroke="#1b0d16" stroke-width="3" stroke-linecap="round"/>
"""


def expression_overlay(name: str) -> str:
    brows = {
        "neutral": '<path d="M360 340 Q389 329 419 340 M481 340 Q511 329 540 340" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "smiling": '<path d="M360 337 Q389 324 419 336 M481 336 Q511 324 540 337" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "mischievous": '<path d="M359 342 Q389 328 420 344 M481 330 Q512 314 540 328" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "sarcastic": '<path d="M359 331 Q389 338 420 330 M481 344 Q511 333 540 340" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "angry": '<path d="M358 326 L421 348 M479 348 L542 326" fill="none" stroke="#3a1c2b" stroke-width="6" stroke-linecap="round"/>',
        "embarrassed": '<path d="M359 337 Q389 321 419 337 M481 337 Q511 321 540 337" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "flirting": '<path d="M359 337 Q389 326 419 341 M481 326 Q511 314 540 329" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "sad": '<path d="M359 342 Q389 326 419 344 M481 344 Q511 326 540 342" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "suspicious": '<path d="M359 338 Q389 326 419 341 M481 321 Q512 309 540 320" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
        "frightened": '<path d="M358 319 Q389 303 420 319 M480 319 Q511 303 542 319" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>',
    }[name]
    mouths = {
        "neutral": '<path d="M423 468 Q450 473 478 467" fill="none" stroke="#9e5267" stroke-width="4" stroke-linecap="round"/>',
        "smiling": '<path d="M416 460 Q450 492 485 459 Q450 474 416 460 Z" fill="#8e3d55" stroke="#6e263f" stroke-width="2"/><path d="M425 464 Q450 473 476 463" fill="none" stroke="#f5d7d9" stroke-width="4"/>',
        "mischievous": '<path d="M419 464 Q449 478 482 457" fill="none" stroke="#8e3d55" stroke-width="4" stroke-linecap="round"/><path d="M480 457 L487 463" stroke="#8e3d55" stroke-width="3"/>',
        "sarcastic": '<path d="M422 470 Q450 462 478 469" fill="none" stroke="#8e3d55" stroke-width="4" stroke-linecap="round"/>',
        "angry": '<path d="M424 476 Q450 460 477 476" fill="none" stroke="#813347" stroke-width="4" stroke-linecap="round"/>',
        "embarrassed": '<path d="M432 469 Q441 461 450 469 T468 469" fill="none" stroke="#9e5267" stroke-width="3" stroke-linecap="round"/>',
        "flirting": '<path d="M417 459 Q450 488 485 456" fill="none" stroke="#8e3d55" stroke-width="4" stroke-linecap="round"/><path d="M446 468 Q450 472 455 467" fill="#f6dadd"/>',
        "sad": '<path d="M425 477 Q450 463 476 477" fill="none" stroke="#8e3d55" stroke-width="4" stroke-linecap="round"/>',
        "suspicious": '<path d="M429 469 L471 466" fill="none" stroke="#8e3d55" stroke-width="4" stroke-linecap="round"/>',
        "frightened": '<ellipse cx="450" cy="470" rx="12" ry="16" fill="#68253d"/><ellipse cx="450" cy="476" rx="7" ry="6" fill="#c97788"/>',
    }[name]
    if name in ("neutral", "smiling", "sad", "frightened"):
        eyes = EYES
    elif name == "mischievous":
        eyes = EYES + '<path d="M358 386 Q389 375 424 390 L420 400 Q389 389 363 397 Z M476 400 Q509 382 542 388 L541 399 Q509 393 480 408 Z" fill="#e8c3c5"/>'
    elif name in ("sarcastic", "flirting"):
        eyes = EYES + '<path d="M358 384 Q389 378 424 389 L420 402 Q389 391 363 397 Z M476 389 Q509 378 542 384 L541 397 Q509 391 480 402 Z" fill="#e8c3c5"/>'
    elif name == "suspicious":
        eyes = EYES + '<path d="M358 384 Q389 379 424 390 L420 402 Q389 391 363 397 Z" fill="#e8c3c5"/><path d="M477 383 L542 376" stroke="#27101b" stroke-width="4"/>'
    elif name == "angry":
        eyes = EYES + '<path d="M363 394 Q389 405 419 394 M481 394 Q510 405 537 394" fill="none" stroke="#3a1c2b" stroke-width="3"/>'
    else:
        eyes = EYES
    blush = ''
    if name in ("embarrassed", "flirting", "smiling"):
        blush = '<ellipse cx="376" cy="441" rx="31" ry="13" fill="#d96d84" opacity=".3"/><ellipse cx="524" cy="441" rx="31" ry="13" fill="#d96d84" opacity=".3"/><path d="M368 440 l5 -4 m7 5 l5 -4 m130 -1 l5 -4 m7 5 l5 -4" stroke="#b65470" stroke-width="2" opacity=".5"/>'
    lashes = '<path d="M357 383 l-9 -8 M424 386 l8 -7 M476 386 l-8 -7 M543 383 l9 -8" stroke="#27101b" stroke-width="3" stroke-linecap="round"/>'
    return brows + eyes + lashes + blush + mouths


def generate_character() -> None:
    base = portrait_base()
    write_svg("characters/dracy/base.svg", base, 900, 1200)
    for name in ["neutral", "smiling", "mischievous", "sarcastic", "angry", "embarrassed", "flirting", "sad", "suspicious", "frightened"]:
        overlay = expression_overlay(name)
        write_svg(f"characters/dracy/expressions/{name}.svg", overlay, 900, 1200, defs="")
        # Complete transparent sprites are the in-game source of truth.
        write_svg(f"characters/dracy/sprites/expressions/{name}.svg", base + overlay, 900, 1200)
    # Profile illustration is a deliberate crop/composition of the master design.
    write_svg("characters/dracy/profile.svg", '<rect width="900" height="900" fill="#120a19"/><circle cx="450" cy="420" r="330" fill="#34132f"/><g transform="translate(-10 -80) scale(.98)">' + base + expression_overlay("smiling") + '</g>', 900, 900)
    generate_master_reference()


def generate_master_reference() -> None:
    body = """
<rect width="1200" height="900" fill="#100a18"/>
<circle cx="360" cy="430" r="330" fill="#2a1530"/>
<circle cx="360" cy="430" r="285" fill="none" stroke="#6b2c4d" stroke-width="2"/>
<g transform="translate(55 25) scale(.70)">""" + portrait_base() + expression_overlay("neutral") + """</g>
<text x="760" y="105" fill="#f2e8ee" font-family="Georgia,serif" font-size="46">Dracy — Approved Master</text>
<text x="762" y="145" fill="#bd8ca5" font-family="sans-serif" font-size="17">Signature revision · silver-blue hair · unexplained injuries</text>
<g font-family="sans-serif" font-size="15" fill="#d8c5d3">
  <rect x="762" y="195" width="54" height="54" rx="8" fill="#aebfda"/><text x="832" y="229">SILVER-BLUE HAIR</text>
  <rect x="762" y="265" width="54" height="54" rx="8" fill="#b93458"/><text x="832" y="299">CRIMSON EYES</text>
  <rect x="762" y="335" width="54" height="54" rx="8" fill="#5b1736"/><text x="832" y="369">BURGUNDY + BLACK</text>
  <rect x="762" y="405" width="54" height="54" rx="8" fill="#d8d0da" stroke="#817487"/><text x="832" y="439">SILVER JEWELRY</text>
</g>
<path d="M540 372 L720 520" stroke="#a9637f" stroke-width="2" stroke-dasharray="5 6"/>
<text x="762" y="535" fill="#e5a2b8" font-family="sans-serif" font-size="18">FADING BRUISES / OLD SCARS</text>
<text x="762" y="568" fill="#bca5b5" font-family="sans-serif" font-size="15">Cause unknown. Connected to Nocturne through clues,</text>
<text x="762" y="592" fill="#bca5b5" font-family="sans-serif" font-size="15">not explanation. Never decorative, diagnostic, or graphic.</text>
<path d="M610 764 L720 650" stroke="#a9637f" stroke-width="2" stroke-dasharray="5 6"/>
<text x="762" y="665" fill="#e5a2b8" font-family="sans-serif" font-size="18">VISIBLE, RESTRAINED, CONSISTENT</text>
<text x="762" y="698" fill="#bca5b5" font-family="sans-serif" font-size="15">Keep marks present across expressions and outfits.</text>
<text x="762" y="722" fill="#bca5b5" font-family="sans-serif" font-size="15">Do not resolve their origin in M01.</text>
"""
    path = ROOT.parent / "design" / "character-bible" / "dracy-vector-master.svg"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(SVG_HEAD.format(w=1200, h=900) + DEFS + body + "</svg>", encoding="utf-8")


def small_head() -> str:
    """Shared full-body head so every pose and outfit keeps the same face."""
    return """
<ellipse cx="300" cy="252" rx="92" ry="119" fill="url(#skin)"/>
<path d="M210 260 C194 147 229 80 300 77 C371 80 406 147 390 260 L374 180 C344 150 316 141 300 142 C280 141 251 153 226 183 Z" fill="url(#hair)"/>
<path d="M212 236 C202 336 214 404 190 476 C230 450 245 394 242 327 Z M388 236 C398 336 386 404 410 476 C370 450 355 394 358 327 Z" fill="url(#hair)"/>
<path d="M235 177 Q270 126 321 119 M367 128 Q397 151 407 187" fill="none" stroke="url(#hairLight)" stroke-width="7" opacity=".62" stroke-linecap="round"/>
<ellipse cx="274" cy="309" rx="24" ry="13" fill="url(#bruise)" transform="rotate(-10 274 309)"/>
<ellipse cx="330" cy="314" rx="19" ry="11" fill="url(#bruise)" transform="rotate(12 330 314)"/>
<path d="M296 301 l5 17 M293 306 l6 -2 M294 312 l6 -2" fill="none" stroke="#9a5e70" stroke-width="1.8" stroke-linecap="round" opacity=".78"/>
<circle cx="333" cy="327" r="2.4" fill="#4b2637" opacity=".9"/>
<path d="M245 261 Q300 238 355 261" fill="none" stroke="#3a1c2b" stroke-width="5" stroke-linecap="round"/>
<ellipse cx="264" cy="281" rx="17" ry="11" fill="url(#eye)"/><ellipse cx="336" cy="281" rx="17" ry="11" fill="url(#eye)"/>
<circle cx="260" cy="277" r="4" fill="#fff"/><circle cx="332" cy="277" r="4" fill="#fff"/>
<path d="M251 278 l-10 -7 M282 271 l9 -6 M318 271 l9 -6 M349 278 l10 -7" fill="none" stroke="#1b0d16" stroke-width="2.4" stroke-linecap="round"/>
<path d="M286 325 Q300 333 314 324" fill="none" stroke="#93475d" stroke-width="3" stroke-linecap="round"/>
<path d="M273 359 L327 359 L319 408 L281 408 Z" fill="url(#skin)"/>
<path d="M278 384 Q300 396 322 384" fill="none" stroke="#100b14" stroke-width="10" stroke-linecap="round"/>
<path d="M294 392 L300 402 L306 392 L300 385 Z" fill="#8f183d" stroke="url(#silver)" stroke-width="1.6"/>
<path d="M251 421 Q223 476 241 536 M349 421 Q377 476 359 536" fill="none" stroke="url(#silver)" stroke-width="2.2"/>
<circle cx="241" cy="540" r="6" fill="#17101d" stroke="url(#silver)" stroke-width="2"/>
<circle cx="359" cy="540" r="6" fill="#17101d" stroke="url(#silver)" stroke-width="2"/>
"""


def full_body(outfit: str, pose: str = "stand") -> str:
    colors = {
        "nocturne": ("#120d17", "#681b38", "#b14b69"),
        "velvet": ("#20121e", "#3c1429", "#a74a68"),
        "casual": ("#17131d", "#302136", "#a14967"),
        "ritual": ("#0d0a12", "#48112b", "#c06b83"),
    }
    dark, wine, trim = colors[outfit]
    arm_left = "M206 448 C178 548 176 665 196 752"
    arm_right = "M394 448 C424 548 426 665 406 752"
    if pose == "confident":
        arm_left = "M206 448 C160 532 165 605 221 630 L270 596"
        arm_right = "M394 448 C420 552 420 632 386 702"
    elif pose == "camera":
        arm_left = "M206 448 C184 542 206 613 258 628"
        arm_right = "M394 448 C428 532 411 596 360 614"
    elif pose == "phone":
        arm_left = "M206 448 C190 554 219 636 273 642"
        arm_right = "M394 448 C412 554 384 621 336 639"
    top = f'<path d="M204 438 Q300 392 300 392 Q300 392 396 438 L370 682 L230 682 Z" fill="{dark}" stroke="{wine}" stroke-width="8"/>'
    skirt = f'<path d="M230 650 L370 650 L426 1120 Q300 1170 174 1120 Z" fill="{dark}" stroke="{wine}" stroke-width="7"/><path d="M300 670 L300 1135 M252 667 L221 1130 M348 667 L379 1130" stroke="{trim}" stroke-width="3" opacity=".5"/>'
    if outfit == "casual":
        top = f'<path d="M213 444 Q247 411 300 414 Q353 411 387 444 L373 662 L227 662 Z" fill="{dark}"/><path d="M250 450 Q300 505 350 450" fill="none" stroke="{trim}" stroke-width="6"/><circle cx="300" cy="520" r="45" fill="{wine}"/><path d="M282 493 L300 475 L318 493 L310 533 L300 548 L290 533 Z" fill="none" stroke="{trim}" stroke-width="3"/>'
        skirt = f'<path d="M231 650 L369 650 L397 1010 L203 1010 Z" fill="{dark}" stroke="{wine}" stroke-width="6"/><path d="M250 658 L239 1002 M275 658 L270 1002 M325 658 L330 1002 M350 658 L361 1002" stroke="{trim}" stroke-width="2" opacity=".45"/>'
    elif outfit == "ritual":
        top = f'<path d="M207 438 L254 408 L300 430 L346 408 L393 438 L424 1120 L176 1120 Z" fill="{dark}" stroke="{wine}" stroke-width="7"/><path d="M254 408 L300 690 L346 408 M300 430 L300 1120" stroke="{trim}" stroke-width="3" opacity=".7"/>'
        skirt = ""
    elif outfit == "velvet":
        top = f'<path d="M207 438 L252 410 L300 432 L348 410 L393 438 L380 690 L220 690 Z" fill="{wine}" stroke="{dark}" stroke-width="7"/><path d="M252 410 L300 510 L348 410 M300 432 L300 686" stroke="{trim}" stroke-width="4"/>'
    # Shared approved head keeps identity consistent across outfits and poses.
    head = small_head()
    legs = '<path d="M258 1095 L276 1360 M342 1095 L324 1360" stroke="#d7b4b8" stroke-width="29" stroke-linecap="round"/><path d="M244 1350 L287 1350 L286 1380 L230 1380 Q226 1360 244 1350 Z M313 1350 L356 1350 L374 1380 L318 1380 Z" fill="#100b14" stroke="#63213b" stroke-width="4"/>'
    if outfit in ("ritual",):
        legs = '<path d="M257 1110 L270 1370 M343 1110 L330 1370" stroke="#d7b4b8" stroke-width="25" stroke-linecap="round"/><path d="M241 1355 L285 1355 L285 1380 L225 1380 Z M315 1355 L359 1355 L375 1380 L315 1380 Z" fill="#100b14" stroke="#63213b" stroke-width="4"/>'
    arms = f'<path d="{arm_left} {arm_right}" fill="none" stroke="{dark}" stroke-width="42" stroke-linecap="round"/><path d="{arm_left} {arm_right}" fill="none" stroke="{wine}" stroke-width="4" stroke-linecap="round"/>'
    hands = '<circle cx="221" cy="635" r="18" fill="url(#skin)"/><circle cx="379" cy="710" r="18" fill="url(#skin)"/>'
    if pose == "camera":
        hands = '<rect x="267" y="586" width="88" height="58" rx="8" fill="#0c0a10" stroke="url(#silver)" stroke-width="4"/><circle cx="311" cy="615" r="20" fill="#25182c" stroke="url(#silver)" stroke-width="5"/><circle cx="311" cy="615" r="11" fill="#6e2344"/><path d="M252 606 L267 603 M337 603 L350 606" stroke="#d8c6d4" stroke-width="6"/>'
    elif pose == "phone":
        hands = '<rect x="298" y="585" width="46" height="82" rx="7" fill="#0c0a10" stroke="url(#silver)" stroke-width="3" transform="rotate(-9 321 626)"/><rect x="306" y="595" width="30" height="53" rx="3" fill="#702444" transform="rotate(-9 321 626)"/>'
    jewelry = '<path d="M300 411 L300 520" stroke="url(#silver)" stroke-width="3"/><path d="M289 522 L300 543 L311 522 Z" fill="#701c3d" stroke="url(#silver)" stroke-width="2"/><path d="M244 444 Q218 510 241 560 M356 444 Q382 510 359 560" fill="none" stroke="url(#silver)" stroke-width="2"/>'
    return f'<ellipse cx="300" cy="1378" rx="180" ry="18" fill="#07050b" opacity=".55"/>{legs}{skirt}{arms}{top}{head}{hands}{jewelry}'


def seated_pose() -> str:
    """Transparent seated pose using the shared approved head and palette."""
    chair = """
<path d="M178 690 L178 300 Q180 220 300 215 Q420 220 422 300 L422 690 Z" fill="#17101d" stroke="#63213b" stroke-width="7"/>
<path d="M205 665 L205 315 Q207 252 300 248 Q393 252 395 315 L395 665 Z" fill="#211225" stroke="#3c2035" stroke-width="3"/>
<path d="M166 690 L434 690 L452 742 L148 742 Z" fill="#120c17" stroke="#63213b" stroke-width="5"/>
<g transform="translate(300 405)">
  <circle r="38" fill="none" stroke="#6d2948" stroke-width="5"/>
  <circle r="22" fill="none" stroke="#96415f" stroke-width="4"/>
  <path d="M0 -34 C-20 -18 -18 2 0 16 C18 2 20 -18 0 -34 Z M-34 0 C-18 -20 2 -18 16 0 C2 18 -18 20 -34 0 Z M34 0 C18 -20 -2 -18 -16 0 C-2 18 18 20 34 0 Z M0 34 C-20 18 -18 -2 0 -16 C18 -2 20 18 0 34 Z" fill="#3d142d" stroke="#8f3655" stroke-width="2"/>
  <circle r="9" fill="#a93455"/>
</g>
"""
    hair_back = '<path d="M218 250 C190 390 206 548 184 676 C238 636 256 548 248 430 Z M382 250 C410 390 394 548 416 676 C362 636 344 548 352 430 Z" fill="url(#hair)"/>'
    torso = """
<path d="M213 405 Q300 366 387 405 L370 690 L230 690 Z" fill="url(#dress)" stroke="#5b1736" stroke-width="7"/>
<path d="M245 414 L268 682 M355 414 L332 682" stroke="#b14b69" stroke-width="3" opacity=".55"/>
<path d="M228 470 Q300 510 372 470 M231 520 Q300 558 369 520 M236 570 Q300 606 364 570" fill="none" stroke="url(#silver)" stroke-width="3"/>
<path d="M284 486 L300 470 L316 486 L308 532 L300 548 L292 532 Z" fill="#5b1736" stroke="url(#silver)" stroke-width="2"/>
"""
    arms = """
<path d="M216 430 C178 512 170 614 214 674 L258 690" fill="none" stroke="#120d17" stroke-width="44" stroke-linecap="round"/>
<path d="M384 430 C424 520 430 626 386 704 L352 772" fill="none" stroke="#120d17" stroke-width="44" stroke-linecap="round"/>
<path d="M216 430 C178 512 170 614 214 674" fill="none" stroke="#681b38" stroke-width="4" stroke-linecap="round"/>
<path d="M384 430 C424 520 430 626 386 704" fill="none" stroke="#681b38" stroke-width="4" stroke-linecap="round"/>
<ellipse cx="197" cy="474" rx="27" ry="18" fill="url(#bruise)" transform="rotate(-24 197 474)"/>
<path d="M185 463 l12 5 M189 471 l11 4" fill="none" stroke="#a9687b" stroke-width="2" stroke-linecap="round" opacity=".7"/>
"""
    thighs = """
<path d="M252 681 C226 724 218 772 248 806 L333 806 C326 754 319 710 300 686 Z" fill="url(#skin)"/>
<path d="M300 686 C319 714 326 758 333 806 L420 806 C438 768 416 716 348 681 Z" fill="url(#skin)"/>
<path d="M244 792 L337 792 M333 792 L424 792" stroke="#100b14" stroke-width="18"/>
<path d="M251 781 L263 803 M318 781 L330 803 M342 781 L354 803 M405 781 L417 803" stroke="url(#silver)" stroke-width="3"/>
"""
    lower_legs = """
<path d="M257 810 C250 900 252 1010 266 1094" fill="none" stroke="#241a2b" stroke-width="42" stroke-linecap="round"/>
<path d="M352 810 C362 900 360 1010 346 1094" fill="none" stroke="#241a2b" stroke-width="42" stroke-linecap="round"/>
<path d="M244 1080 L286 1080 L291 1152 L224 1152 Q220 1104 244 1080 Z M324 1080 L366 1080 L390 1152 L323 1152 Z" fill="#0c0910" stroke="#63213b" stroke-width="5"/>
<path d="M241 1110 L283 1110 M329 1110 L371 1110" stroke="url(#silver)" stroke-width="4"/>
"""
    hands = '<ellipse cx="247" cy="692" rx="20" ry="15" fill="url(#skin)" transform="rotate(-18 247 692)"/><ellipse cx="348" cy="777" rx="20" ry="15" fill="url(#skin)" transform="rotate(24 348 777)"/>'
    jewelry = '<path d="M236 430 Q210 506 232 574 M364 430 Q390 506 368 574" fill="none" stroke="url(#silver)" stroke-width="2.4"/><circle cx="232" cy="578" r="7" fill="#17101d" stroke="url(#silver)" stroke-width="2"/><circle cx="368" cy="578" r="7" fill="#17101d" stroke="url(#silver)" stroke-width="2"/>'
    return f'<ellipse cx="300" cy="1158" rx="190" ry="18" fill="#07050b" opacity=".55"/>{chair}{hair_back}{thighs}{lower_legs}{torso}{arms}{small_head()}{hands}{jewelry}'


def generate_outfits_and_poses() -> None:
    for outfit in ["nocturne", "velvet", "casual", "ritual"]:
        write_svg(f"characters/dracy/outfits/{outfit}.svg", full_body(outfit), 600, 1400)
    for pose in ["confident", "camera", "phone"]:
        write_svg(f"characters/dracy/poses/{pose}.svg", full_body("nocturne", pose), 600, 1400)
    # Approved, organized in-game asset set.
    write_svg("characters/dracy/sprites/poses/standing.svg", full_body("nocturne"), 600, 1400)
    write_svg("characters/dracy/sprites/poses/seated.svg", seated_pose(), 600, 1200)
    write_svg("characters/dracy/sprites/outfits/signature.svg", full_body("nocturne"), 600, 1400)
    write_svg("characters/dracy/sprites/outfits/casual.svg", full_body("casual"), 600, 1400)
    write_svg("characters/dracy/sprites/outfits/gothic.svg", full_body("velvet"), 600, 1400)
    write_svg("characters/dracy/sprites/outfits/alternative.svg", full_body("ritual"), 600, 1400)


def stars(seed: int = 1) -> str:
    points = []
    for i in range(75):
        x = (i * 193 + seed * 71) % 1600
        y = (i * 97 + seed * 43) % 560
        r = 1 + (i % 3)
        points.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#d8bdd8" opacity="{0.15 + (i % 5) * 0.08}"/>')
    return "".join(points)


def rain_lines() -> str:
    return "".join(f'<path d="M{x} {y} l-18 74" stroke="#91a6c4" stroke-width="2" opacity="{0.08 + (x % 4) * 0.035}"/>' for x, y in [(115,80),(240,20),(410,130),(590,60),(760,10),(930,110),(1120,40),(1310,120),(1480,20)])


def bedroom() -> str:
    return f"""
<rect width="1600" height="900" fill="#100b16"/>
<rect x="0" y="620" width="1600" height="280" fill="#0b0810"/>
<path d="M0 620 L1600 570 L1600 900 L0 900 Z" fill="#17101d"/>
<rect x="70" y="80" width="650" height="470" rx="8" fill="#2c1b2d" stroke="#594054" stroke-width="12"/>
<rect x="94" y="104" width="602" height="422" fill="url(#window)"/>
<g opacity=".45">{rain_lines()}
<rect x="120" y="350" width="110" height="176" fill="#0b0e19"/><rect x="250" y="290" width="150" height="236" fill="#0b0e19"/><rect x="430" y="380" width="90" height="146" fill="#0b0e19"/>
<rect x="135" y="372" width="22" height="26" fill="#b56c76" opacity=".5"/><rect x="285" y="325" width="26" height="31" fill="#8f527b" opacity=".45"/><rect x="458" y="405" width="18" height="22" fill="#bd8b78" opacity=".35"/>
</g>
<path d="M400 104 L400 526 M94 314 L696 314" stroke="#594054" stroke-width="10"/>
<rect x="820" y="182" width="500" height="330" rx="12" fill="#09070d" stroke="#513447" stroke-width="8"/>
<rect x="844" y="206" width="452" height="282" fill="#171326"/>
<path d="M870 450 L1060 276 L1160 388 L1240 308 L1280 454 Z" fill="#28142e"/>
<circle cx="1216" cy="266" r="38" fill="#a54666" opacity=".8"/>
<rect x="1018" y="512" width="110" height="18" rx="4" fill="#352335"/><path d="M1073 530 L1073 652 L1010 690 L1138 690" fill="none" stroke="#2d1c2d" stroke-width="18"/>
<rect x="760" y="558" width="630" height="34" rx="6" fill="#352132"/>
<path d="M796 592 L770 840 M1346 592 L1380 840" stroke="#241623" stroke-width="26"/>
<rect x="822" y="608" width="88" height="130" rx="4" fill="#1d1322" transform="rotate(-5 866 670)"/><rect x="930" y="622" width="65" height="110" rx="4" fill="#41182e" transform="rotate(4 962 677)"/>
<ellipse cx="914" cy="632" rx="28" ry="10" fill="#6b334d"/><path d="M906 570 Q914 540 923 570" fill="none" stroke="#66505e" stroke-width="4"/>
<rect x="0" y="720" width="620" height="180" fill="#211321"/><path d="M0 720 Q310 670 620 720" fill="#30202f"/><path d="M0 740 Q310 700 620 740" fill="none" stroke="#563346" stroke-width="4"/>
<path d="M1360 90 Q1390 170 1360 250" fill="none" stroke="#9d526b" stroke-width="3" opacity=".5"/>
<circle cx="1360" cy="270" r="12" fill="#d0848e" opacity=".7"/><circle cx="1360" cy="330" r="9" fill="#b1607c" opacity=".6"/><circle cx="1360" cy="382" r="11" fill="#d0848e" opacity=".55"/>
<rect x="1420" y="340" width="130" height="190" rx="4" fill="#0a0710" stroke="#493044" stroke-width="7"/>
<path d="M1440 480 L1470 410 L1490 452 L1520 382 L1532 500 Z" fill="#32162e"/><circle cx="1508" cy="377" r="19" fill="#9f3c60"/>
"""


def rain_window() -> str:
    return f"""
<rect width="1600" height="900" fill="#090a13"/>
<rect x="120" y="40" width="1360" height="820" rx="20" fill="#241a2c" stroke="#594057" stroke-width="24"/>
<rect x="155" y="75" width="1290" height="750" fill="url(#window)"/>
{rain_lines()}
<g opacity=".65"><rect x="180" y="480" width="210" height="345" fill="#090c16"/><rect x="420" y="390" width="270" height="435" fill="#090c16"/><rect x="730" y="510" width="160" height="315" fill="#090c16"/><rect x="930" y="420" width="330" height="405" fill="#090c16"/><rect x="1300" y="500" width="130" height="325" fill="#090c16"/>
<rect x="205" y="520" width="28" height="35" fill="#b47383" opacity=".4"/><rect x="480" y="450" width="36" height="42" fill="#8b5c91" opacity=".4"/><rect x="1020" y="480" width="32" height="40" fill="#be8a85" opacity=".3"/></g>
<circle cx="1180" cy="235" r="90" fill="#b1b7cf" opacity=".08"/><circle cx="1180" cy="235" r="54" fill="#d3c8dc" opacity=".08"/>
<path d="M800 75 L800 825 M155 440 L1445 440" stroke="#594057" stroke-width="22"/>
<path d="M90 860 Q330 800 570 860 T1060 860 T1530 860" fill="none" stroke="#72405c" stroke-width="7" opacity=".4"/>
"""


def rooftop() -> str:
    return f"""
<rect width="1600" height="900" fill="url(#night)"/>{stars(3)}
<circle cx="1190" cy="205" r="118" fill="url(#moon)" opacity=".9"/><circle cx="1232" cy="171" r="112" fill="#21112d"/>
<path d="M0 560 L180 520 L320 570 L500 500 L690 560 L880 490 L1080 550 L1270 470 L1450 530 L1600 500 L1600 900 L0 900 Z" fill="#100a18"/>
<g fill="#0a0710"><path d="M90 520 L90 280 L170 240 L250 280 L250 520 Z"/><path d="M320 540 L320 340 L430 285 L540 340 L540 540 Z"/><path d="M1050 550 L1050 310 L1180 245 L1310 310 L1310 550 Z"/><path d="M1360 550 L1360 380 L1440 330 L1520 380 L1520 550 Z"/></g>
<g fill="#6e2949" opacity=".55"><path d="M135 340 L135 410 L172 410 L172 340 Z"/><path d="M390 380 L390 455 L470 455 L470 380 Z"/><path d="M1120 360 L1120 440 L1240 440 L1240 360 Z"/></g>
<path d="M0 690 L1600 650 L1600 900 L0 900 Z" fill="#0b0810"/><path d="M0 690 L1600 650" stroke="#6f3853" stroke-width="8"/>
<path d="M90 690 L90 490 M1510 650 L1510 440 M90 510 L1510 460" stroke="#261726" stroke-width="18"/>
<path d="M0 805 L1600 750 M0 870 L1600 820" stroke="#271724" stroke-width="5" opacity=".8"/>
"""


def impossible_street() -> str:
    return f"""
<rect width="1600" height="900" fill="url(#night)"/>{stars(8)}
<circle cx="800" cy="210" r="98" fill="url(#moon)" opacity=".75"/>
<path d="M0 900 L620 420 L980 420 L1600 900 Z" fill="#120b18"/>
<path d="M660 900 L725 420 M940 900 L875 420" stroke="#5e2848" stroke-width="7" opacity=".65"/>
<g fill="#0b0710"><path d="M0 900 L0 250 L250 190 L600 390 L620 900 Z"/><path d="M1600 900 L1600 210 L1340 170 L1000 390 L980 900 Z"/></g>
<g fill="#34142b" stroke="#5e2848" stroke-width="4"><path d="M105 390 L265 350 L290 440 L120 480 Z"/><path d="M385 505 L520 465 L535 535 L395 575 Z"/><path d="M1180 390 L1330 350 L1360 445 L1200 480 Z"/><path d="M1060 520 L1210 475 L1230 550 L1075 590 Z"/></g>
<g stroke="#9b536f" stroke-width="4" fill="none" opacity=".6"><path d="M150 422 l65 -16 m-55 36 l80 -18"/><path d="M1240 414 l70 -18 m-58 38 l82 -19"/></g>
<g stroke="#352032" stroke-width="12"><path d="M310 250 L310 560 M1280 230 L1280 550"/></g>
<g fill="#d095a7"><circle cx="310" cy="285" r="19"/><circle cx="1280" cy="270" r="19"/><circle cx="520" cy="495" r="14"/><circle cx="1080" cy="500" r="14"/></g>
<g fill="#d58ca6" opacity=".13"><circle cx="310" cy="285" r="90"/><circle cx="1280" cy="270" r="90"/><circle cx="520" cy="495" r="65"/><circle cx="1080" cy="500" r="65"/></g>
<path d="M710 480 L890 480 L876 530 L724 530 Z" fill="#271020" stroke="#9b536f" stroke-width="3"/>
<path d="M742 496 l28 -12 l26 12 l-26 12 Z M816 496 l28 -12 l26 12 l-26 12 Z" fill="none" stroke="#c4869d" stroke-width="3"/>
<path d="M0 900 Q400 820 800 900 T1600 900" fill="#251020" opacity=".45"/>
"""


def nocturne_glimpse() -> str:
    return f"""
<rect width="1600" height="900" fill="#100918"/>{stars(11)}
<circle cx="1180" cy="230" r="150" fill="url(#moon)"/><circle cx="1235" cy="190" r="142" fill="#170b1c" opacity=".75"/>
<path d="M0 760 L220 610 L390 690 L570 550 L760 680 L950 520 L1160 680 L1350 560 L1600 720 L1600 900 L0 900 Z" fill="#0b0710"/>
<g fill="#0d0912" stroke="#3b1a31" stroke-width="5"><path d="M280 740 L360 250 L430 180 L500 250 L580 740 Z"/><path d="M1010 740 L1100 220 L1180 130 L1260 220 L1350 740 Z"/><path d="M610 740 L720 370 L800 300 L880 370 L990 740 Z"/></g>
<g fill="#28101f"><path d="M390 340 Q430 270 470 340 L450 520 L410 520 Z"/><path d="M1130 320 Q1180 230 1230 320 L1205 500 L1155 500 Z"/><path d="M735 440 Q800 350 865 440 L835 600 L765 600 Z"/></g>
<path d="M520 900 L520 690 Q800 560 1080 690 L1080 900 Z" fill="#09060d"/>
<path d="M690 900 L690 720 Q800 650 910 720 L910 900 Z" fill="#1b0b19" stroke="#59223f" stroke-width="6"/>
<g fill="#b6a3b7" opacity=".35">{''.join(f'<circle cx="{x}" cy="{y}" r="{2 + i%3}"/>' for i,(x,y) in enumerate([(560,430),(620,510),(700,380),(820,470),(910,390),(1030,500),(460,560),(1140,430),(770,590),(960,570)]))}</g>
<path d="M0 850 Q400 790 800 850 T1600 850" fill="#190b18"/>
"""


def cover() -> str:
    return f"""
<rect width="1600" height="900" fill="url(#night)"/>{stars(17)}
<circle cx="1180" cy="260" r="185" fill="url(#moon)" opacity=".85"/><circle cx="1250" cy="205" r="175" fill="#1c0d26"/>
<path d="M0 900 L0 690 L300 590 L540 680 L810 520 L1100 640 L1380 540 L1600 650 L1600 900 Z" fill="#0b0710"/>
<path d="M770 900 C790 690 840 540 930 430 C975 370 1040 365 1090 430 C1170 540 1195 710 1210 900 Z" fill="#0b0710"/>
<path d="M910 430 C930 335 1000 300 1050 350 C1090 392 1082 450 1070 500 C1040 540 950 525 910 430 Z" fill="#100a15"/>
<path d="M929 421 C937 350 983 328 1014 356" fill="none" stroke="#69354f" stroke-width="7" opacity=".5"/>
<path d="M760 900 Q1000 810 1240 900" fill="#200c1d"/>
<g fill="#c05a7c" opacity=".45"><circle cx="640" cy="560" r="5"/><circle cx="700" cy="620" r="3"/><circle cx="1320" cy="590" r="4"/><circle cx="1380" cy="680" r="3"/></g>
"""


def generate_backgrounds() -> None:
    write_svg("backgrounds/bedroom.svg", bedroom(), 1600, 900)
    write_svg("backgrounds/rain_window.svg", rain_window(), 1600, 900)
    write_svg("backgrounds/rooftop.svg", rooftop(), 1600, 900)
    write_svg("backgrounds/impossible_street.svg", impossible_street(), 1600, 900)
    write_svg("backgrounds/nocturne_glimpse.svg", nocturne_glimpse(), 1600, 900)
    write_svg("backgrounds/menu_nocturne.svg", cover(), 1600, 900)
    write_svg("ui/cover_prologue.svg", cover(), 1600, 900)


def main() -> None:
    generate_dracy_character()
    generate_backgrounds()
    print("Generated original DRACY vector artwork in", ASSETS)


if __name__ == "__main__":
    main()
