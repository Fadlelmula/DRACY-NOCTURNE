#!/usr/bin/env python3
"""Synthesize original, royalty-free atmospheric audio for DRACY: NOCTURNE.

Run from the game directory: python tools/generate_audio.py
Outputs 22.05 kHz mono WAV files. No samples or third-party recordings are used.
"""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050


def note(midi: int) -> float:
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))


def save_wave(relative: str, samples: list[float]) -> None:
    path = ROOT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    peak = max(1e-6, max(abs(x) for x in samples))
    gain = min(1.0, 0.72 / peak)
    pcm = bytearray()
    for value in samples:
        v = int(max(-1.0, min(1.0, value * gain)) * 32767)
        pcm += struct.pack("<h", v)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm)


def smoothstep(x: float) -> float:
    x = max(0.0, min(1.0, x))
    return x * x * (3.0 - 2.0 * x)


def make_music(name: str, chords: list[list[int]], melody: list[int], seed: int) -> None:
    rng = random.Random(seed)
    duration = 32.0
    count = int(RATE * duration)
    out = [0.0] * count
    chord_len = duration / len(chords)
    for bar, chord in enumerate(chords):
        start = int(bar * chord_len * RATE)
        end = int((bar + 1) * chord_len * RATE)
        for i, midi in enumerate(chord):
            freq = note(midi)
            phase = rng.random() * math.tau
            drift = 0.6 + rng.random() * 0.4
            for n in range(start, end):
                t = (n - start) / RATE
                local = (n - start) / max(1, end - start)
                env = smoothstep(local / 0.18) * smoothstep((1.0 - local) / 0.22)
                tremolo = 0.82 + 0.18 * math.sin(math.tau * 0.08 * t + phase)
                tone = math.sin(math.tau * freq * t + phase)
                tone += 0.24 * math.sin(math.tau * freq * 2.003 * t + phase * 0.7)
                tone += 0.09 * math.sin(math.tau * freq * 3.0 * t)
                out[n] += tone * env * tremolo * (0.085 / (1.0 + i * 0.16)) * drift
    # Sparse bell-like motif; deliberately quiet so dialogue remains dominant.
    for step, midi in enumerate(melody):
        at = step * (duration / len(melody))
        start = int(at * RATE)
        freq = note(midi)
        for n in range(start, min(count, start + int(3.8 * RATE))):
            t = (n - start) / RATE
            env = (1.0 - math.exp(-t * 24.0)) * math.exp(-t * 1.35)
            out[n] += (math.sin(math.tau * freq * t) + 0.32 * math.sin(math.tau * freq * 2.01 * t)) * env * 0.055
    # Gentle high air and a short seam fade keep the loop unobtrusive.
    low = 0.0
    for n in range(count):
        t = n / RATE
        low = low * 0.985 + (rng.random() * 2.0 - 1.0) * 0.015
        seam = smoothstep(t / 0.8) * smoothstep((duration - t) / 0.8)
        out[n] = (out[n] + low * 0.08) * seam
    save_wave(f"music/{name}.wav", out)


def make_rain() -> None:
    rng = random.Random(812)
    duration = 24.0
    count = int(RATE * duration)
    out = [0.0] * count
    low = 0.0
    lower = 0.0
    for n in range(count):
        white = rng.random() * 2.0 - 1.0
        low = low * 0.965 + white * 0.035
        lower = lower * 0.996 + white * 0.004
        t = n / RATE
        seam = smoothstep(t / 1.2) * smoothstep((duration - t) / 1.2)
        out[n] = (low * 0.7 + lower * 0.5) * seam
    save_wave("ambience/rain.wav", out)


def make_sfx(name: str, kind: str) -> None:
    rng = random.Random(sum(ord(c) for c in name))
    durations = {"click": 0.08, "message": 0.22, "transition": 0.7, "heartbeat": 0.55}
    duration = durations[kind]
    count = int(RATE * duration)
    out = [0.0] * count
    for n in range(count):
        t = n / RATE
        if kind == "click":
            out[n] = math.sin(math.tau * 720 * t) * math.exp(-t * 65) * 0.35
        elif kind == "message":
            out[n] = (math.sin(math.tau * 880 * t) + 0.5 * math.sin(math.tau * 1320 * t)) * math.exp(-t * 16) * 0.24
        elif kind == "transition":
            white = rng.random() * 2.0 - 1.0
            out[n] = white * math.sin(math.pi * t / duration) * 0.09 + math.sin(math.tau * (180 - 90 * t) * t) * 0.05
        else:
            beat = math.exp(-((t % 0.28) / 0.035)) if t > 0.05 else 0.0
            out[n] = math.sin(math.tau * (68 - 20 * t) * t) * beat * 0.55
    save_wave(f"sfx/{name}.wav", out)


def main() -> None:
    make_music("prologue_theme", [[50, 57, 62, 65], [46, 53, 58, 62], [41, 48, 53, 57], [48, 55, 60, 64], [50, 57, 62, 65], [46, 53, 58, 62], [41, 48, 53, 57], [48, 55, 60, 64]], [74, 77, 81, 77, 72, 74, 69, 72, 74, 77, 76, 72], 41)
    make_music("after_midnight", [[45, 52, 57, 60], [41, 48, 53, 57], [43, 50, 55, 59], [40, 47, 52, 55], [45, 52, 57, 60], [41, 48, 53, 57], [43, 50, 55, 59], [40, 47, 52, 55]], [69, 72, 76, 72, 67, 69, 64, 67, 69, 71, 72, 67], 92)
    make_music("rain_ambience", [[50, 57, 62], [50, 57, 62], [48, 55, 60], [48, 55, 60]], [69, 0, 72, 0, 67, 0, 64, 0], 13)
    make_rain()
    for name, kind in [("click", "click"), ("message", "message"), ("transition", "transition"), ("heartbeat", "heartbeat")]:
        make_sfx(name, kind)
    print("Generated original DRACY audio in", ROOT)


if __name__ == "__main__":
    main()
