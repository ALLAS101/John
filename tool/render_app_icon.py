"""Renders the app icon exactly as specified in the design handoff
(design_extract/design_handoff_john_3_16/App Icon.dc.html, option "A —
Numeral", marked "Chosen"): a dark indigo tile with a warm gold glow rising
from the bottom and an italic serif "3:16" centered on it.

Not part of the Flutter app itself — a one-off content-authoring script
(like tool/generate_daily_audio.dart, but for the icon instead of verse
audio) run locally to produce assets/icon/icon.png, which
flutter_launcher_icons then reads to generate every platform's actual
icon files. Re-run this only if the design changes; there's no need to
run it as part of any build.

Usage: python tool/render_app_icon.py
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SIZE = 1024
SCALE = SIZE / 200  # the design mockup is authored at 200x200

FONT_PATH = "android/app/src/main/res/font/lora_italic.ttf"
OUT_PATH = "assets/icon/icon.png"


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def lerp(a, b, t):
    return a + (b - a) * t


def lerp_color(c1, c2, t):
    return tuple(lerp(c1[i], c2[i], t) for i in range(3))


def render_background(size):
    """linear-gradient(170deg, #1B2145 0%, #0C1026 60%, #080A18 100%)."""
    c0 = hex_to_rgb("1B2145")
    c1 = hex_to_rgb("0C1026")
    c2 = hex_to_rgb("080A18")

    angle_deg = 170
    theta = math.radians(angle_deg)
    # CSS gradient-line direction: 0deg points up, increases clockwise.
    dx, dy = math.sin(theta), -math.cos(theta)

    img = Image.new("RGB", (size, size))
    px = img.load()

    # Project the four corners onto the gradient axis to find the [min,max]
    # range that maps to [0%, 100%], per the CSS gradient spec.
    half = size / 2
    corners = [(-half, -half), (half, -half), (-half, half), (half, half)]
    projections = [cx * dx + cy * dy for cx, cy in corners]
    t_min, t_max = min(projections), max(projections)

    for y in range(size):
        cy = y - half
        for x in range(size):
            cx = x - half
            t_raw = cx * dx + cy * dy
            t = (t_raw - t_min) / (t_max - t_min)
            if t <= 0.6:
                color = lerp_color(c0, c1, t / 0.6)
            else:
                color = lerp_color(c1, c2, (t - 0.6) / 0.4)
            px[x, y] = tuple(int(round(v)) for v in color)
    return img


def add_glow(img, size, scale):
    """The bottom glow div: width 280 height 220, bottom:-70px, centered
    horizontally, radial-gradient(50% 50% at 50% 50%,
      rgba(232,182,90,0.55) 0%, rgba(217,119,66,0.22) 44%,
      rgba(10,13,28,0) 74%)."""
    box_w = 280 * scale
    box_h = 220 * scale
    box_bottom = size - (-70 * scale)  # bottom:-70px -> below the tile
    box_top = box_bottom - box_h
    box_left = (size - box_w) / 2
    cx = box_left + box_w / 2
    cy = box_top + box_h / 2
    rx = box_w / 2
    ry = box_h / 2

    gold = (232, 182, 90)
    orange = (217, 119, 66)
    dark = (10, 13, 28)
    stops = [(0.0, gold, 0.55), (0.44, orange, 0.22), (0.74, dark, 0.0)]

    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    op = overlay.load()
    base = img.load()

    # Only the glow's own bounding box (clipped to the canvas) can be
    # non-transparent -- cheap early-out for the rest of the 1024x1024.
    x0 = max(0, int(box_left))
    x1 = min(size, int(box_left + box_w) + 1)
    y0 = max(0, int(box_top))
    y1 = min(size, int(box_bottom) + 1)

    for y in range(y0, y1):
        ny = (y - cy) / ry
        for x in range(x0, x1):
            nx = (x - cx) / rx
            t = math.sqrt(nx * nx + ny * ny)
            if t >= stops[-1][0] and t > 0.74:
                continue
            # Find the segment t falls in.
            for i in range(len(stops) - 1):
                t0, c0, a0 = stops[i]
                t1, c1, a1 = stops[i + 1]
                if t0 <= t <= t1:
                    f = (t - t0) / (t1 - t0) if t1 > t0 else 0
                    color = lerp_color(c0, c1, f)
                    alpha = lerp(a0, a1, f)
                    break
            else:
                continue
            if alpha <= 0:
                continue
            r, g, b = base[x, y]
            out_r = r * (1 - alpha) + color[0] * alpha
            out_g = g * (1 - alpha) + color[1] * alpha
            out_b = b * (1 - alpha) + color[2] * alpha
            op[x, y] = (int(out_r), int(out_g), int(out_b), 255)

    composed = Image.alpha_composite(img.convert("RGBA"), overlay)
    return composed.convert("RGB")


def add_text(img, size, scale):
    """Centered italic "3:16", Lora, #FBF3E2, font-size 78px (scaled),
    with a soft gold text-shadow: 0 2px 24px rgba(232,182,90,0.35)."""
    font_size = int(round(78 * scale))
    font = ImageFont.truetype(FONT_PATH, font_size)
    text = "3:16"

    # Measure and center.
    tmp = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(tmp)
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = (size - tw) / 2 - bbox[0]
    ty = (size - th) / 2 - bbox[1]

    # Soft shadow layer: draw gold text, offset, then blur.
    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow_layer)
    shadow_offset_y = 2 * scale
    gold_alpha = int(255 * 0.35)
    sd.text((tx, ty + shadow_offset_y), text, font=font, fill=(232, 182, 90, gold_alpha))
    blur_radius = 24 * scale / 3  # CSS blur px -> approximate PIL sigma
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(blur_radius))

    composed = Image.alpha_composite(img.convert("RGBA"), shadow_layer)

    # Crisp text on top.
    final_draw = ImageDraw.Draw(composed)
    final_draw.text((tx, ty), text, font=font, fill=(251, 243, 226, 255))

    return composed.convert("RGB")


def main():
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    img = render_background(SIZE)
    img = add_glow(img, SIZE, SCALE)
    img = add_text(img, SIZE, SCALE)
    img.save(OUT_PATH, "PNG")
    print(f"Wrote {OUT_PATH} ({img.size[0]}x{img.size[1]}, mode={img.mode})")


if __name__ == "__main__":
    main()
