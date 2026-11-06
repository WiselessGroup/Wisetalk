#!/usr/bin/env python3
"""Makes the app's icons from assets/logo.png, the owl on a light ground:

- Android: an adaptive icon, the owl inside the 66 dp circle every launcher
  mask keeps, over a flat background colour that turns dark in the dark
  theme, and a one-colour owl for Android 13's themed icons;
- macOS: an Icon Composer AppIcon.icon for macOS 26, the owl over a fill
  that is light or dark with the system, and for older systems, which have
  one icon, the light tile in the asset catalog plus the dark one the app
  puts in the Dock itself while it runs (both drawn like Linux's);
- Windows: the same square as an .ico for the program and its installer;
- Linux: docs/logo.svg on a squircle with macOS's grid and shadow, as an SVG
  for icon themes and a PNG drawn from it (needs PyGObject and librsvg).

Run it again after the logo changes:

    python3 scripts/app-icons.py
"""

import json
import math
import re
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
LOGO = ROOT / "assets" / "logo.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
MAC_ASSETS = ROOT / "macos" / "Runner" / "Assets.xcassets"
MAC_ICONS = MAC_ASSETS / "AppIcon.appiconset"
MAC_DARK_ICON = MAC_ASSETS / "AppIconDark.imageset"
MAC_ICON_COMPOSER = ROOT / "macos" / "Runner" / "AppIcon.icon"
WINDOWS_ICON = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
LINUX = ROOT / "packaging" / "linux"
# Catppuccin Latte's base: the dark owl needs a light ground.
BACKGROUND = "#EFF1F5"
# Mocha's crust, for dark themes: darker than the owl's body, so its outline
# still shows.
BACKGROUND_DARK = "#11111B"
# The squircle's fill from top to bottom, and its hairline edge, per theme.
# The dark one runs from Mocha's mantle to its crust: the owl's navy body is
# lighter than both (about 1.4:1), so its silhouette holds, where Mocha's
# base at the top would swallow the head.
TILES = {
    "light": ("#FAFBFC", BACKGROUND, "#1B1E36", 0.08),
    "dark": ("#181825", BACKGROUND_DARK, "#CDD6F4", 0.10),
}
# How much of the squircle the owl's longer side takes.
OWL_ON_TILE = 0.66
# The owl's bounds in docs/logo.svg's 1254 px box, headphones and tufts
# included.
OWL_BOUNDS = (189, 206, 1065, 1086)
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
# How much of the 108 dp layer the owl's longer side takes: inside the
# 66 dp safe circle with a little room to spare.
SHARE = 0.56
# The same for the themed icon's one-colour owl: 48 of 108 dp.
MONO_SHARE = 48 / 108


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
    # The classic icon, for macOS before 26 when an Xcode before 26 builds
    # the app; Xcode 26 makes these bitmaps from AppIcon.icon instead. The
    # asset catalog's Contents.json already lists the files.
    for pixels in (16, 32, 64, 128, 256, 512, 1024):
        render(tile_svg("light"), pixels).save(MAC_ICONS / f"app_icon_{pixels}.png")

    # macOS before 26 knows one icon per app, so in the dark theme the app
    # shows this one in the Dock itself while it runs
    # (macos/Runner/AppDelegate.swift).
    MAC_DARK_ICON.mkdir(exist_ok=True)
    images = []
    for pixels, scale in ((512, "1x"), (1024, "2x")):
        name = f"app_icon_dark_{pixels}.png"
        render(tile_svg("dark"), pixels).save(MAC_DARK_ICON / name)
        images.append({"filename": name, "idiom": "mac", "scale": scale})
    contents = {"images": images, "info": {"author": "xcode", "version": 1}}
    (MAC_DARK_ICON / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")

    icon_composer()


def icon_colour(hex_colour: str) -> str:
    """#RRGGBB the way Icon Composer writes colours."""
    r, g, b = (int(hex_colour[i : i + 2], 16) / 255 for i in (1, 3, 5))
    return f"srgb:{r:.5f},{g:.5f},{b:.5f},1.00000"


def icon_composer() -> None:
    """macOS 26's icon, a folder Icon Composer opens and Xcode 26 compiles:
    the owl as one layer on a 1024 pt canvas, over the tile's gradient for
    each appearance. The system cuts the squircle and draws its edge, glass
    and shadow. The owl's layer isn't glass, so it looks as everywhere else.
    Xcode also renders the light one into the bitmaps older macOS shows."""
    assets = MAC_ICON_COMPOSER / "Assets"
    assets.mkdir(parents=True, exist_ok=True)
    owl_svg = (
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'
        ' viewBox="0 0 1024 1024">'
        f"{placed(logo_inner(), 1024, 1024 * OWL_ON_TILE)}</svg>"
    )
    render(owl_svg, 1024).save(assets / "owl.png")

    def gradient(theme: str) -> dict:
        top, bottom, _, _ = TILES[theme]
        return {
            "linear-gradient": [icon_colour(top), icon_colour(bottom)],
            "orientation": {"start": {"x": 0.5, "y": 0}, "stop": {"x": 0.5, "y": 1}},
        }

    manifest = {
        "fill-specializations": [
            {"value": gradient("light")},
            {"appearance": "dark", "value": gradient("dark")},
        ],
        "groups": [
            {
                "layers": [{"glass": False, "image-name": "owl.png", "name": "owl"}],
                "shadow": {"kind": "neutral", "opacity": 0.5},
                "translucency": {"enabled": False, "value": 0.5},
            }
        ],
        "supported-platforms": {"squares": ["macOS"]},
    }
    (MAC_ICON_COMPOSER / "icon.json").write_text(json.dumps(manifest, indent=2) + "\n")


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

        # Android 13 tints this one to the wallpaper when the user turns
        # themed icons on; Google keeps its drawing inside 48 of the 108 dp.
        size = round(108 * factor)
        render(monochrome_svg(), size, MONO_SHARE).save(folder / "ic_launcher_monochrome.png")

    adaptive = RES / "mipmap-anydpi-v26"
    adaptive.mkdir(exist_ok=True)
    (adaptive / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
        "</adaptive-icon>\n"
    )
    # Launchers read the background colour with the system's theme, so the
    # night one is what a dark theme shows. A mipmap-night foreground would
    # be ignored; the colour is what switches.
    for values, colour in (("values", BACKGROUND), ("values-night", BACKGROUND_DARK)):
        (RES / values / "ic_launcher_background.xml").write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            f'    <color name="ic_launcher_background">{colour}</color>\n'
            "</resources>\n"
        )


def squircle(x: float, y: float, side: float, radius: float, smoothing: float) -> str:
    """An SVG path for a square with Apple's continuous corners: each corner
    eases out of the straight edge before its arc, the way Figma's corner
    smoothing does (0.6 is the iOS and macOS look)."""
    p = (1 + smoothing) * radius
    arc_measure = 90 * (1 - smoothing)
    arc = math.sin(math.radians(arc_measure / 2)) * radius * math.sqrt(2)
    alpha = (90 - arc_measure) / 2
    p3_to_p4 = radius * math.tan(math.radians(alpha / 2))
    beta = 45 * smoothing
    c = p3_to_p4 * math.cos(math.radians(beta))
    d = c * math.tan(math.radians(beta))
    b = (p - arc - c - d) / 3
    a = 2 * b
    r, s = radius, side
    ab, abc, bc = a + b, a + b + c, b + c
    path = [
        f"M{s - p} 0",
        f"c{a} 0 {ab} 0 {abc} {d}",
        f"a{r} {r} 0 0 1 {arc} {arc}",
        f"c{d} {c} {d} {bc} {d} {abc}",
        f"L{s} {s - p}",
        f"c0 {a} 0 {ab} {-d} {abc}",
        f"a{r} {r} 0 0 1 {-arc} {arc}",
        f"c{-c} {d} {-bc} {d} {-abc} {d}",
        f"L{p} {s}",
        f"c{-a} 0 {-ab} 0 {-abc} {-d}",
        f"a{r} {r} 0 0 1 {-arc} {-arc}",
        f"c{-d} {-c} {-d} {-bc} {-d} {-abc}",
        f"L0 {p}",
        f"c0 {-a} 0 {-ab} {d} {-abc}",
        f"a{r} {r} 0 0 1 {arc} {-arc}",
        f"c{c} {-d} {bc} {-d} {abc} {-d}",
        "Z",
    ]
    d_attr = " ".join(path)
    # Two decimals are far below a pixel at any size an icon is shown.
    d_attr = re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group()):.2f}".rstrip("0").rstrip("."), d_attr)
    return f'<path transform="translate({x} {y})" d="{d_attr}"'


def logo_inner() -> str:
    """docs/logo.svg's drawing, without its <svg> element and title."""
    logo = (ROOT / "docs" / "logo.svg").read_text()
    inner = logo[logo.index(">", logo.index("<svg")) + 1 : logo.rindex("</svg>")]
    return re.sub(r"\s*<title>.*?</title>", "", inner)


def placed(inner: str, canvas: float, side: float) -> str:
    """The owl's drawing scaled so its longer side is [side], centred on a
    [canvas] wide square."""
    left, top, right, bottom = OWL_BOUNDS
    scale = side / max(right - left, bottom - top)
    dx = canvas / 2 - (left + right) / 2 * scale
    dy = canvas / 2 - (top + bottom) / 2 * scale
    return f'<g transform="translate({dx:.2f} {dy:.2f}) scale({scale:.5f})">{inner}</g>'


def tile_svg(theme: str = "light") -> str:
    """The owl on Apple's grid as an SVG: a 1024 canvas, an 824 squircle
    100 px in with corners of about 185, and the soft shadow under it. The
    owl takes the same share of the square as in AppIcon.icon. [theme] is
    "light" or "dark"; the owl stays the same on both."""
    top, bottom, edge, edge_opacity = TILES[theme]
    shape = squircle(100, 100, 824, 185, 0.6)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1024 1024" width="1024" height="1024">
  <title>Wisetalk</title>
  <defs>
    <linearGradient id="ground" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{top}"/>
      <stop offset="1" stop-color="{bottom}"/>
    </linearGradient>
    <filter id="shadow" x="-10%" y="-10%" width="120%" height="125%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="10"/>
      <feOffset dy="10"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.3"/></feComponentTransfer>
    </filter>
  </defs>
  {shape} fill="#000" filter="url(#shadow)"/>
  {shape} fill="url(#ground)"/>
  {shape} fill="none" stroke="{edge}" stroke-opacity="{edge_opacity}" stroke-width="2"/>
  {placed(logo_inner(), 1024, 824 * OWL_ON_TILE)}
</svg>
"""


def monochrome_svg() -> str:
    """The owl in one colour for themed icons, on a 1024 canvas filled edge
    to edge (render() scales it): the launcher keeps only the alpha, so the
    eyes, beak and chest are cut out of the silhouette to stay readable."""
    inner = logo_inner()
    holes = {"#FEE6DE", "#F48793"}  # the whites of the eyes, the beak
    inner = re.sub(
        r'(fill|stroke)="(#[0-9A-Fa-f]{6})"',
        lambda m: f'{m.group(1)}="{"#000" if m.group(2).upper() in holes else "#FFF"}"',
        inner,
    )
    # The chest's lighter V, which shares its colour with the tufts.
    inner = re.sub(r'(<path d="M504 882[^"]*" fill=")#FFF', r"\1#000", inner)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1024 1024">
  <mask id="owl" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">
    {placed(inner, 1024, 1024)}
  </mask>
  <rect width="1024" height="1024" fill="#FFF" mask="url(#owl)"/>
</svg>
"""


def render(svg: str, size: int, share: float = 1.0) -> Image.Image:
    """[svg], drawn [size] px wide by librsvg, what GNOME draws icons with,
    shrunk to [share] of that and centred."""
    import io

    import gi

    gi.require_version("Rsvg", "2.0")
    import cairo
    from gi.repository import Rsvg

    handle = Rsvg.Handle.new_from_data(svg.encode())
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, size, size)
    side = size * share
    viewport = Rsvg.Rectangle()
    viewport.x, viewport.y = (size - side) / 2, (size - side) / 2
    viewport.width, viewport.height = side, side
    handle.render_document(cairo.Context(surface), viewport)
    png = io.BytesIO()
    surface.write_to_png(png)
    png.seek(0)
    return Image.open(png).convert("RGBA")


def linux() -> None:
    # Linux has no light and dark app icons, only whole icon themes, so the
    # AppImage carries the light tile; the dark one is for macOS.
    svg = tile_svg("light")
    (LINUX / "wisetalk.svg").write_text(svg)
    # The same drawing as a PNG, for .DirIcon and whatever can't read SVG.
    render(svg, 512).save(LINUX / "wisetalk.png")


def main() -> None:
    android()
    macos()
    windows()
    linux()


if __name__ == "__main__":
    main()
