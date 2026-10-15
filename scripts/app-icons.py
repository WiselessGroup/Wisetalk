#!/usr/bin/env python3
"""Makes the app's icons from assets/logo.png, the owl on a light ground:

- Android: an adaptive icon, the owl inside the 66 dp circle every launcher
  mask keeps, over a flat background colour;
- macOS: a rounded square on Apple's 1024 px grid, in the asset catalog;
- Windows: the same square as an .ico for the program and its installer.

Run it again after the logo changes:

    python3 scripts/app-icons.py
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
LOGO = ROOT / "assets" / "logo.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
MAC_ICONS = ROOT / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
WINDOWS_ICON = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
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


def tile(size: int, body: float, radius: float, share: float) -> Image.Image:
    """The owl on a rounded square [body] of [size] wide, centred."""
    icon = Image.new("RGBA", (size, size))
    side = round(size * body)
    corner = (size - side) // 2
    mask = Image.new("L", (size, size))
    ImageDraw.Draw(mask).rounded_rectangle(
        (corner, corner, corner + side - 1, corner + side - 1),
        radius=round(side * radius),
        fill=255,
    )
    icon.paste(Image.new("RGBA", (size, size), BACKGROUND), (0, 0), mask)
    icon.alpha_composite(owl(size, body * share))
    return icon


def macos() -> None:
    # Apple's grid: an 824 px square with 185 px corners on a 1024 px canvas.
    # The asset catalog's Contents.json already lists these files.
    big = tile(1024, 824 / 1024, 185 / 824, 0.66)
    for pixels in (16, 32, 64, 128, 256, 512, 1024):
        big.resize((pixels, pixels), Image.LANCZOS).save(MAC_ICONS / f"app_icon_{pixels}.png")


def windows() -> None:
    big = tile(256, 1.0, 0.2, 0.7)
    sizes = [(s, s) for s in (16, 20, 24, 32, 40, 48, 64, 128, 256)]
    big.save(WINDOWS_ICON, format="ICO", sizes=sizes)


def android() -> None:
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


def main() -> None:
    android()
    macos()
    windows()


if __name__ == "__main__":
    main()
