#!/usr/bin/env python3
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def font(size: int):
    for candidate in [
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: make_contact_sheet.py <screenshot_dir> <out>", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    out = Path(sys.argv[2])
    files = sorted(src.glob("*.png"))
    if not files:
        print(f"no screenshots found in {src}", file=sys.stderr)
        return 1

    thumb_w = 260
    label_h = 42
    gap = 18
    cols = min(5, len(files))
    rows = (len(files) + cols - 1) // cols

    thumbs = []
    for path in files:
        im = Image.open(path).convert("RGB")
        ratio = thumb_w / im.width
        thumb_h = int(im.height * ratio)
        thumbs.append((path, im.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS), im.size))

    thumb_h = max(t[1].height for t in thumbs)
    sheet = Image.new("RGB", (cols * thumb_w + (cols + 1) * gap, rows * (thumb_h + label_h) + (rows + 1) * gap), "#efe4d2")
    draw = ImageDraw.Draw(sheet)
    label_font = font(18)

    for index, (path, thumb, size) in enumerate(thumbs):
        row, col = divmod(index, cols)
        x = gap + col * (thumb_w + gap)
        y = gap + row * (thumb_h + label_h + gap)
        sheet.paste(thumb, (x, y))
        draw.text((x, y + thumb_h + 8), f"{path.name}  {size[0]}x{size[1]}", fill="#1c1712", font=label_font)

    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out, quality=90)
    print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
