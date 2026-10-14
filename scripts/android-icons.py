#!/usr/bin/env python3
"""Makes Android's launcher icons from assets/logo.png.

An adaptive icon: the owl as the foreground, inside the 66 dp circle every
launcher mask keeps, over a flat background colour. Run it again after the
logo changes:

    python3 scripts/android-icons.py
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
LOGO = ROOT / "assets" / "logo.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
# Catppuccin Latte's base: the dark owl needs a light ground.
BACKGROUND = "#EFF1F5"
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
# How much of the 108 dp layer the owl's longer side takes: inside the
# 66 dp safe circle with a little room to spare.
SHARE = 0.56


def owl(size: int, share: float) -> Image.Image:
    """The owl, cropped to itself and centred on a transparent square."""
    logo = Image.open(LOGO).convert("RGBA")
    logo = logo.crop(logo.getbbox())
    side = round(size * share)
    scale = side / max(logo.size)
    logo = logo.resize(
        (round(logo.width * scale), round(logo.height * scale)), Image.LANCZOS
    )
    layer = Image.new("RGBA", (size, size))
    layer.paste(logo, ((size - logo.width) // 2, (size - logo.height) // 2), logo)
    return layer


def main() -> None:
    for name, factor in DENSITIES.items():
        folder = RES / f"mipmap-{name}"
        folder.mkdir(exist_ok=True)
        owl(round(108 * factor), SHARE).save(folder / "ic_launcher_foreground.png")
        # The plain icon, for anything that doesn't read adaptive ones.
        size = round(48 * factor)
        plain = Image.new("RGBA", (size, size), BACKGROUND)
        plain.alpha_composite(owl(size, 0.78))
        plain.save(folder / "ic_launcher.png")

    adaptive = RES / "mipmap-anydpi-v26"
    adaptive.mkdir(exist_ok=True)
    (adaptive / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        "</adaptive-icon>\n"
    )
    (RES / "values" / "ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">{BACKGROUND}</color>\n'
        "</resources>\n"
    )


if __name__ == "__main__":
    main()
