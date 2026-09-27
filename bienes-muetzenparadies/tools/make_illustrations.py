"""Erzeugt die gekennzeichneten Demo-Illustrationen unter public/img/.

Die Grafiken sind Platzhalter, bis echte Fotos von Bines Mützen vorliegen.
Aufruf: python3 tools/make_illustrations.py
"""
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / 'public' / 'img'
INK = '#3A3027'


def defs(uid, base, dark):
    """Häkelstruktur (versetzte Maschenreihen) und Rippenbündchen."""
    return f'''<pattern id="st-{uid}" width="16" height="12" patternUnits="userSpaceOnUse">
<rect width="16" height="12" fill="{base}"/>
<path d="M1 6.5q3.5-5.5 7 0q3.5-5.5 7 0" fill="none" stroke="{dark}" stroke-width="1.6" stroke-linecap="round" opacity=".38"/>
<path d="M-7 12.5q3.5-5.5 7 0M9 12.5q3.5-5.5 7 0" fill="none" stroke="{dark}" stroke-width="1.6" stroke-linecap="round" opacity=".22"/>
</pattern>
<pattern id="rib-{uid}" width="11" height="20" patternUnits="userSpaceOnUse">
<rect width="11" height="20" fill="{dark}"/>
<path d="M5.5 0v20" stroke="#fff" stroke-width="3.4" opacity=".16"/>
</pattern>'''


def hat(uid, base, dark, band=None, extras_back='', extras_front=''):
    """Grundform einer Beanie, 400 breit, Unterkante bei y=392."""
    band_uid = uid + 'b'
    band_defs = defs(band_uid, band, band) if band else ''
    band_fill = f'rib-{band_uid}' if band else f'rib-{uid}'
    return f'''<defs>{defs(uid, base, dark)}{band_defs}</defs>
{extras_back}
<path d="M84 336C80 206 138 128 200 128s120 78 116 208Z" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/>
<path d="M112 206c18-40 50-62 88-66" fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round" opacity=".22"/>
{extras_front}
<rect x="70" y="322" width="260" height="70" rx="26" fill="url(#{band_fill})" stroke="{INK}" stroke-width="5"/>'''


def eye(x, y, r=13):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{INK}"/><circle cx="{x+r*.35}" cy="{y-r*.4}" r="{r*.32}" fill="#fff"/>'


def motif(kind, uid):
    if kind == 'frosch':
        base, dark = '#86AE5F', '#56803A'
        back = ''.join(f'<circle cx="{x}" cy="158" r="46" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5"/>' for x in (138, 262))
        front = ''.join(f'<circle cx="{x}" cy="160" r="29" fill="#fff" stroke="{INK}" stroke-width="4"/>{eye(x+3, 164, 13)}' for x in (138, 262))
        front += f'<path d="M150 268q50 38 100 0" fill="none" stroke="{INK}" stroke-width="6" stroke-linecap="round"/><circle cx="128" cy="262" r="15" fill="#E7898F" opacity=".55"/><circle cx="272" cy="262" r="15" fill="#E7898F" opacity=".55"/>'
        return hat(uid, base, dark, extras_back=back, extras_front=front)
    if kind == 'schneemann':
        base, dark = '#F7F4EE', '#B9B1A6'
        back = f'<circle cx="200" cy="112" r="30" fill="url(#st-{uid}b)" stroke="{INK}" stroke-width="5"/>'
        mouth = ''.join(f'<circle cx="{x}" cy="{y}" r="5.5" fill="{INK}"/>' for x, y in ((160, 286), (178, 296), (200, 300), (222, 296), (240, 286)))
        front = eye(166, 230, 12) + eye(234, 230, 12) + f'<path d="M196 248l62 14-62 12Z" fill="#E48A3C" stroke="{INK}" stroke-width="4.5" stroke-linejoin="round"/><path d="M214 256l4 13M232 259l3 8" stroke="{INK}" stroke-width="3" stroke-linecap="round" opacity=".5"/>' + mouth
        return hat(uid, base, dark, band='#C65A66', extras_back=back, extras_front=front)
    if kind == 'schweinchen':
        base, dark = '#F0AFB2', '#D27C83'
        back = f'<path d="M108 214 94 128l76 42Z" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/><path d="M292 214l14-86-76 42Z" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/>'
        front = eye(160, 234, 11) + eye(240, 234, 11) + f'<ellipse cx="200" cy="276" rx="42" ry="29" fill="#E3959B" stroke="{INK}" stroke-width="5"/><ellipse cx="185" cy="276" rx="7" ry="10" fill="{INK}"/><ellipse cx="215" cy="276" rx="7" ry="10" fill="{INK}"/>'
        return hat(uid, base, dark, extras_back=back, extras_front=front)
    if kind == 'monster':
        base, dark = '#A897CC', '#7A68A6'
        back = f'<path d="M146 152q-18-44 6-66 4 32 30 50Z" fill="#F3D68B" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/><path d="M254 152q18-44-6-66-4 32-30 50Z" fill="#F3D68B" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/>'
        spots = ''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#C9BDE3" opacity=".8"/>' for x, y, r in ((122, 282, 11), (282, 250, 14), (262, 300, 8), (138, 230, 7)))
        front = spots + f'<circle cx="200" cy="222" r="42" fill="#fff" stroke="{INK}" stroke-width="5"/>' + eye(206, 228, 19) + f'<path d="M160 290q40 22 80 0" fill="none" stroke="{INK}" stroke-width="6" stroke-linecap="round"/><path d="M178 297l7 16 8-13M209 300l8 13 7-16" fill="#fff" stroke="{INK}" stroke-width="4" stroke-linejoin="round"/>'
        return hat(uid, base, dark, extras_back=back, extras_front=front)
    if kind == 'baer':
        base, dark = '#B98B63', '#87603F'
        back = ''.join(f'<circle cx="{x}" cy="168" r="42" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5"/><circle cx="{x}" cy="168" r="20" fill="#E3C3A1"/>' for x, _ in ((118, 0), (282, 0)))
        front = eye(164, 236, 11) + eye(236, 236, 11) + f'<ellipse cx="200" cy="280" rx="46" ry="34" fill="#E3C3A1" stroke="{INK}" stroke-width="5"/><path d="M186 268q14-10 28 0-4 12-14 14-10-2-14-14Z" fill="{INK}"/><path d="M200 282v10m-12 4q12 8 24 0" fill="none" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>'
        return hat(uid, base, dark, extras_back=back, extras_front=front)
    if kind == 'einhorn':
        base, dark = '#FAF6F1', '#C9BFB4'
        back = f'<path d="M150 168 130 118l44 22Z" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/><path d="M250 168l20-50-44 22Z" fill="url(#st-{uid})" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/><path d="M180 146 200 58l20 88Z" fill="#F3D68B" stroke="{INK}" stroke-width="5" stroke-linejoin="round"/><path d="M186 120l24-10M190 100l19-8M194 80l13-5" stroke="{INK}" stroke-width="3.5" stroke-linecap="round" opacity=".6"/>'
        mane = ''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}" stroke="{INK}" stroke-width="4"/>' for x, y, r, c in ((248, 150, 17, '#E9A7B3'), (274, 172, 17, '#C9BDE3'), (292, 202, 16, '#F3D68B'), (304, 236, 15, '#A9C7A0'), (310, 272, 14, '#E9A7B3')))
        front = mane + f'<path d="M150 240q14 12 28 0M222 240q14 12 28 0" fill="none" stroke="{INK}" stroke-width="5" stroke-linecap="round"/><path d="M152 246l-6 8M176 246l5 8M224 246l-5 8M248 246l6 8" stroke="{INK}" stroke-width="3.5" stroke-linecap="round"/><circle cx="140" cy="272" r="13" fill="#E9A7B3" opacity=".6"/><circle cx="260" cy="272" r="13" fill="#E9A7B3" opacity=".6"/><path d="M186 286q14 10 28 0" fill="none" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>'
        return hat(uid, base, dark, band='#E9A7B3', extras_back=back, extras_front=front)
    raise ValueError(kind)


CARDS = {
    'frosch': '#E6EEDD', 'schneemann': '#E6ECF0', 'schweinchen': '#F8E7E5',
    'monster': '#ECE7F3', 'baer': '#F3E9DC', 'einhorn': '#F7EFE4',
}


def card_svg(kind):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 500" role="img" aria-label="Demo-Illustration einer Häkelmütze">
<rect width="400" height="500" fill="{CARDS[kind]}"/>
<ellipse cx="200" cy="436" rx="150" ry="16" fill="{INK}" opacity=".08"/>
<g transform="translate(0 44)">{motif(kind, kind)}</g>
</svg>'''


def yarn(cx, cy, r, color, dark, uid):
    lines = ''.join(f'<path d="M{cx-r*.95} {cy+o}q{r*.95} {-r*.55} {r*1.9} 0" fill="none" stroke="{dark}" stroke-width="3" opacity=".55"/>' for o in (-r*.45, -r*.1, r*.25))
    return f'''<g><clipPath id="y-{uid}"><circle cx="{cx}" cy="{cy}" r="{r}"/></clipPath>
<circle cx="{cx}" cy="{cy}" r="{r}" fill="{color}"/>
<g clip-path="url(#y-{uid})">{lines}<path d="M{cx-r*.4} {cy-r}q{-r*.3} {r} {r*.2} {r*2}M{cx+r*.1} {cy-r}q{-r*.4} {r} {r*.35} {r*2}" fill="none" stroke="{dark}" stroke-width="3" opacity=".45"/></g>
<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{INK}" stroke-width="4.5"/></g>'''


def hero_svg():
    # Querformat 1200 x 800: Mützen auf einer Decke vor einer Stuhllehne.
    # Die linke Hälfte bleibt ruhig, dort blendet die Website das Bild weich aus.
    slats = ''.join(f'<rect x="{x}" y="40" width="70" height="560" rx="14" fill="#C49A70" stroke="#8E6A48" stroke-width="4"/>' for x in (690, 830, 970, 1110))
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 800" role="img" aria-label="Demo-Illustration: Froschmütze, Schweinchenmütze und Schneemannmütze auf einer Decke">
<defs><linearGradient id="wall" x1="0" x2="1"><stop offset="0" stop-color="#F6EEE3"/><stop offset="1" stop-color="#EADBC7"/></linearGradient>
<pattern id="knit" width="22" height="16" patternUnits="userSpaceOnUse"><rect width="22" height="16" fill="#F7F0E5"/><path d="M2 8q4.5-7 9 0q4.5-7 9 0" fill="none" stroke="#DCCDB8" stroke-width="2" stroke-linecap="round"/></pattern></defs>
<rect width="1200" height="800" fill="url(#wall)"/>
<rect x="640" y="18" width="560" height="56" rx="20" fill="#C49A70" stroke="#8E6A48" stroke-width="4"/>
{slats}
<path d="M0 560C220 520 420 600 640 560s420-60 560-20V800H0Z" fill="url(#knit)"/>
<path d="M0 560C220 520 420 600 640 560s420-60 560-20" fill="none" stroke="#D9C8B0" stroke-width="4"/>
<ellipse cx="850" cy="560" rx="200" ry="20" fill="{INK}" opacity=".08"/>
<ellipse cx="1070" cy="700" rx="200" ry="22" fill="{INK}" opacity=".1"/>
<ellipse cx="670" cy="748" rx="240" ry="24" fill="{INK}" opacity=".12"/>
<g transform="translate(610 70) scale(1.25)">{motif('schweinchen', 'h2')}</g>
<g transform="translate(790 205) scale(1.25)">{motif('schneemann', 'h1')}</g>
<g transform="translate(390 200) scale(1.4)">{motif('frosch', 'h3')}</g>
{yarn(430, 700, 42, '#F3D68B', '#C9A24B', 'hy')}
<path d="M470 712c40 18 70 30 120 26" fill="none" stroke="#C9A24B" stroke-width="3.5" stroke-linecap="round"/>
</svg>'''


def story_svg():
    label = (OUT.parent.parent / 'brand' / 'bee-mark.svg').read_text()
    inner = label.split('>', 1)[1].rsplit('</svg>', 1)[0].replace('id="t"', 'id="st-t"').replace('bm-body', 'st-body').replace('aria-labelledby="t"', '')
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 640" role="img" aria-label="Demo-Illustration: Wollknäuel, Häkelnadel, angefangene Mütze und Stoffetikett mit Bienenlogo">
<rect width="800" height="640" fill="#E9ECE3"/>
<g opacity=".35" stroke="#C9D0BE" stroke-width="2">{''.join(f'<path d="M0 {y}h800"/>' for y in range(18, 640, 22))}</g>
{yarn(170, 180, 88, '#8BA17F', '#5F7654', 's1')}
{yarn(300, 110, 56, '#F3D68B', '#C9A24B', 's2')}
{yarn(150, 380, 62, '#C65A66', '#94404A', 's3')}
<path d="M246 214c60 30 110 70 160 64s60-40 110-20" fill="none" stroke="#5F7654" stroke-width="4" stroke-linecap="round"/>
<g transform="translate(360 160) rotate(8)">
<defs>{defs('sh', '#8BA17F', '#5F7654')}</defs>
<path d="M40 220C40 140 90 96 160 96s120 44 120 124Z" fill="url(#st-sh)" stroke="{INK}" stroke-width="5" stroke-dasharray="0" />
<path d="M40 220h240" stroke="{INK}" stroke-width="5"/>
<rect x="28" y="214" width="264" height="66" rx="24" fill="url(#rib-sh)" stroke="{INK}" stroke-width="5"/>
<path d="M150 96q10-26 40-36" fill="none" stroke="#5F7654" stroke-width="4" stroke-linecap="round"/>
</g>
<g transform="rotate(-18 520 520)"><rect x="370" y="512" width="300" height="14" rx="7" fill="#C9A24B" stroke="{INK}" stroke-width="4.5"/><rect x="470" y="508" width="70" height="22" rx="8" fill="#F3D68B" stroke="{INK}" stroke-width="4"/><path d="M670 519q18 0 18-13" fill="none" stroke="{INK}" stroke-width="4.5" stroke-linecap="round"/></g>
<g transform="translate(610 70) rotate(6)">
<rect width="150" height="96" rx="6" fill="#FBF8F3" stroke="{INK}" stroke-width="4"/>
<path d="M0 12h150M0 84h150" stroke="#C65A66" stroke-width="2" stroke-dasharray="6 5"/>
<g transform="translate(47 20) scale(.88)">{inner}</g>
</g>
</svg>'''


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for kind in CARDS:
        (OUT / f'demo-{kind}.svg').write_text(card_svg(kind))
    (OUT / 'demo-hero.svg').write_text(hero_svg())
    (OUT / 'demo-haekeln.svg').write_text(story_svg())
    print('Illustrationen geschrieben nach', OUT)


if __name__ == '__main__':
    main()
