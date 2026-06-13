#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "HanziBrush" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"

SIZES = [
    ("iphone", "20x20", "2x", 40),
    ("iphone", "20x20", "3x", 60),
    ("iphone", "29x29", "2x", 58),
    ("iphone", "29x29", "3x", 87),
    ("iphone", "40x40", "2x", 80),
    ("iphone", "40x40", "3x", 120),
    ("iphone", "60x60", "2x", 120),
    ("iphone", "60x60", "3x", 180),
    ("ios-marketing", "1024x1024", "1x", 1024),
]


def font(size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/Supplemental/Songti.ttc",
        "/System/Library/Fonts/PingFang.ttc",
        "/Library/Fonts/Arial Unicode.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size=size, index=0)
    return ImageFont.load_default()


def draw_icon(size: int) -> Image.Image:
    scale = size / 1024
    img = Image.new("RGB", (size, size), "#f8f1e6")
    draw = ImageDraw.Draw(img)

    for y in range(size):
        ratio = y / max(size - 1, 1)
        r = int(248 * (1 - ratio) + 224 * ratio)
        g = int(241 * (1 - ratio) + 216 * ratio)
        b = int(230 * (1 - ratio) + 196 * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

    # Subtle fibers, deterministic.
    for i in range(180):
        x = int((i * 73 % 1024) * scale)
        y = int((i * 137 % 1024) * scale)
        length = int((30 + (i % 46)) * scale)
        color = "#ddcbb5" if i % 2 else "#efe2cf"
        draw.line([(x, y), (min(size, x + length), max(0, y - int(8 * scale)))], fill=color, width=max(1, int(1.2 * scale)))

    margin = int(118 * scale)
    panel = [margin, margin, size - margin, size - margin]
    draw.rounded_rectangle(panel, radius=int(96 * scale), fill="#fff8ee", outline="#d8c8b4", width=max(2, int(6 * scale)))

    # Brush swoosh.
    swoosh = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(swoosh)
    sd.arc(
        [int(180 * scale), int(220 * scale), int(880 * scale), int(850 * scale)],
        start=202,
        end=342,
        fill=(28, 23, 18, 214),
        width=max(8, int(44 * scale)),
    )
    swoosh = swoosh.filter(ImageFilter.GaussianBlur(radius=max(0.2, 0.5 * scale)))
    img = Image.alpha_composite(img.convert("RGBA"), swoosh).convert("RGB")
    draw = ImageDraw.Draw(img)

    main_font = font(int(430 * scale))
    text = "墨"
    bbox = draw.textbbox((0, 0), text, font=main_font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(
        ((size - tw) / 2 - bbox[0], int(262 * scale) - bbox[1]),
        text,
        font=main_font,
        fill="#1c1712",
    )

    seal_size = int(166 * scale)
    seal_x = int(665 * scale)
    seal_y = int(676 * scale)
    draw.rounded_rectangle(
        [seal_x, seal_y, seal_x + seal_size, seal_y + seal_size],
        radius=int(26 * scale),
        fill="#a9362b",
    )
    seal_font = font(int(78 * scale))
    seal_text = "字"
    sb = draw.textbbox((0, 0), seal_text, font=seal_font)
    draw.text(
        (seal_x + (seal_size - (sb[2] - sb[0])) / 2 - sb[0], seal_y + (seal_size - (sb[3] - sb[1])) / 2 - sb[1] - int(4 * scale)),
        seal_text,
        font=seal_font,
        fill="#fff8ee",
    )

    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    images = []
    base = draw_icon(1024)
    for idiom, point_size, scale_name, pixels in SIZES:
        filename = f"app-icon-{pixels}.png"
        icon = base.resize((pixels, pixels), Image.Resampling.LANCZOS)
        icon.save(OUT / filename)
        images.append({
            "idiom": idiom,
            "size": point_size,
            "scale": scale_name,
            "filename": filename,
        })

    contents = {
        "images": images,
        "info": {"author": "xcode", "version": 1},
    }
    import json
    (OUT / "Contents.json").write_text(json.dumps(contents, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
