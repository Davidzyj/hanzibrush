#!/usr/bin/env python3
import sys
from pathlib import Path
from PIL import Image, ImageStat


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: validate_screenshot.py <image> <name>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    name = sys.argv[2]
    if not path.exists():
        print(f"{name}: missing {path}", file=sys.stderr)
        return 1

    im = Image.open(path).convert("RGB")
    width, height = im.size
    stat = ImageStat.Stat(im)
    extrema = im.getextrema()
    variation = sum(high - low for low, high in extrema)
    content = im.crop((0, int(height * 0.09), width, int(height * 0.9)))
    pixels = content.getdata()
    dark_pixels = sum(1 for r, g, b in pixels if (r + g + b) / 3 < 150)
    dark_ratio = dark_pixels / max(1, content.width * content.height)

    # Reject blank launch screens and most SpringBoard/black captures.
    if width < 1000 or height < 1800:
        print(f"{name}: invalid size {width}x{height}", file=sys.stderr)
        return 1
    if variation < 80:
        print(f"{name}: likely blank, variation={variation}", file=sys.stderr)
        return 1
    if sum(stat.mean) / 3 < 20:
        print(f"{name}: too dark, mean={stat.mean}", file=sys.stderr)
        return 1
    if dark_ratio < 0.003:
        print(f"{name}: likely missing app content, dark_ratio={dark_ratio:.4f}", file=sys.stderr)
        return 1

    print(f"{name}: {width}x{height}, variation={variation:.1f}, mean={sum(stat.mean) / 3:.1f}, dark_ratio={dark_ratio:.4f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
