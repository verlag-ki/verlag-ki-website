"""Erzeugt die Logo-Varianten aus brand/bee-mark.svg und der Schrift Chewy.

Die Schrift wird in Pfade umgewandelt, damit die Logos auch ohne installierte
Schrift (Druck, Etiketten, Geschenkkarten) korrekt aussehen.
Aufruf: python3 tools/make_logos.py   (benötigt fonttools und brotli)
"""
import re
from pathlib import Path

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
FONT = TTFont(ROOT / 'public' / 'fonts' / 'chewy-latin-400-normal.woff2')
INK, SAGE, CORAL = '#3A3027', '#5E7F52', '#C65A66'
HEART = 'M12 20.5s-7.5-4.6-7.5-10A4.3 4.3 0 0 1 12 7.6a4.3 4.3 0 0 1 7.5 2.9c0 5.4-7.5 10-7.5 10Z'


def text_path(text, x, y, size):
    """Liefert (Pfaddaten, Breite) für einen Text in Chewy."""
    glyphs = FONT.getGlyphSet()
    cmap = FONT.getBestCmap()
    scale = size / FONT['head'].unitsPerEm
    pen = SVGPathPen(glyphs)
    cursor = 0
    for ch in text:
        name = cmap[ord(ch)]
        glyphs[name].draw(TransformPen(pen, (scale, 0, 0, -scale, x + cursor * scale, y)))
        cursor += FONT['hmtx'][name][0]
    return pen.getCommands(), cursor * scale


def bee(uid):
    mark = (ROOT / 'brand' / 'bee-mark.svg').read_text()
    inner = mark.split('>', 1)[1].rsplit('</svg>', 1)[0]
    inner = re.sub(r'<title[^>]*>.*?</title>', '', inner)
    return inner.replace('bm-body', f'{uid}-body')


def heart(x, y, size, color, filled=False):
    s = size / 24
    fill = color if filled else 'none'
    return f'<path transform="translate({x:.1f} {y:.1f}) scale({s:.3f})" d="{HEART}" fill="{fill}" stroke="{color}" stroke-width="{2.4 if not filled else 0}" stroke-linejoin="round"/>'


def logo(uid, w_mark, name_size, sub_size, mono=False):
    ink = 'currentColor' if mono else INK
    sub = 'currentColor' if mono else SAGE
    red = 'currentColor' if mono else CORAL
    gap = w_mark * .16
    x = w_mark + gap
    top, top_w = text_path('Bienes', x, name_size * .92, name_size)
    bottom, bottom_w = text_path('Mützenparadies', x + name_size * .05, name_size * .92 + sub_size * 1.02, sub_size)
    height = name_size * .92 + sub_size * 1.25
    width = max(x + top_w + name_size * .62, x + bottom_w) + 4
    mark = bee(uid)
    if mono:
        mark = re.sub(r'fill="#(F3D68B|C65A66|FFFFFF)"', 'fill="none"', mark).replace('stroke="#FBF8F3"', 'stroke="#3A3027"').replace('#3A3027', 'currentColor')
    scale = w_mark / 64
    mark_y = (height - w_mark) / 2
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width:.0f} {height:.0f}" role="img" aria-label="Bienes Mützenparadies"{' color="#3A3027"' if mono else ''}>
<g transform="translate(0 {mark_y:.1f}) scale({scale:.3f})">{mark}</g>
<path d="{top}" fill="{ink}"/>
{heart(x + top_w + name_size * .04, name_size * .1, name_size * .4, red)}
<path d="{bottom}" fill="{sub}"/>
</svg>
'''


def main():
    brand = ROOT / 'brand'
    (brand / 'logo-full.svg').write_text(logo('lf', 96, 56, 36))
    (brand / 'logo-compact.svg').write_text(logo('lc', 56, 30, 20))
    (brand / 'logo-monochrome.svg').write_text(logo('lm', 96, 56, 36, mono=True))
    print('Logos geschrieben nach', brand)


if __name__ == '__main__':
    main()
