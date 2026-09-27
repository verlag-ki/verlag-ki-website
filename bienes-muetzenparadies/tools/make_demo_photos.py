"""Schneidet KI-generierte Demo-Bilder aus der Designvorlage aus.

Die Bilder sind KEINE echten Produktfotos. Sie dienen nur der Vorschau und
werden auf der Website sichtbar als „Demo-Bild · KI-generiert“ gekennzeichnet.
Vor dem Livegang durch echte Fotos ersetzen (Verwaltung) oder
DEMO_IMAGES=illustration setzen.

Aufruf: python3 tools/make_demo_photos.py PFAD/ZUR/DESIGNVORLAGE.png
"""
import sys
from pathlib import Path

from PIL import Image, ImageFilter

OUT = Path(__file__).resolve().parent.parent / 'public' / 'img'


def tile(col, row):
    """Kachel aus der Kategorieseite (Variante 4), Rand der Karte abgeschnitten."""
    x = (691, 842, 993, 1144)[col]
    y = (531, 665)[row]
    return (x + 3, y + 3, x + 131, y + 88)


CROPS = {
    'ki-hero': ((300, 48, 652, 345), 1000),     # Variante 1: Frosch, Schwein, Schneemann
    'ki-haekeln': ((300, 490, 652, 760), 900),  # Variante 3: Bär und Einhorn im Korb
    'ki-frosch': ((96, 902, 348, 1154), 640),   # Produktseite: Fritzi, der Frosch
    'ki-schweinchen': (tile(1, 0), 480),
    'ki-schneemann': (tile(2, 0), 480),
    'ki-baer': (tile(3, 0), 480),
    'ki-einhorn': (tile(0, 1), 480),
    'ki-monster': (tile(1, 1), 480),
}


def main(src):
    sheet = Image.open(src).convert('RGB')
    for name, (box, width) in CROPS.items():
        part = sheet.crop(box)
        height = round(part.height * width / part.width)
        part = part.resize((width, height), Image.LANCZOS).filter(ImageFilter.UnsharpMask(radius=1.4, percent=60, threshold=2))
        part.save(OUT / f'{name}.webp', 'WEBP', quality=86, method=6)
        print(name, part.size)


if __name__ == '__main__':
    main(sys.argv[1])
