"""Bienes Mützenparadies: Musterkatalog mit Anfragen per WhatsApp. Python 3.12, Pillow für Bilder."""
import base64
import cgi
import hashlib
import hmac
import html
import io
import json
import os
import re
import secrets
import sqlite3
import time
from datetime import datetime, timezone
from http import HTTPStatus
from http.cookies import SimpleCookie
from pathlib import Path
from urllib.parse import parse_qs, quote, unquote, urlparse
from wsgiref.simple_server import make_server

from PIL import Image, ImageOps, UnidentifiedImageError

BASE = Path(__file__).resolve().parent
DATA = Path(os.environ.get('DATA_DIR', str(BASE / 'data'))).resolve()
DATA.mkdir(parents=True, exist_ok=True)
(DATA / 'uploads').mkdir(exist_ok=True)
ORIGIN = os.environ.get('SITE_ORIGIN', 'http://localhost:8000').rstrip('/')
SECRET = os.environ.get('SECRET_KEY', '')
WHATSAPP = '4915734487082'
DB = DATA / 'site.sqlite3'
PUBLIC = BASE / 'public'
BRAND = BASE / 'brand'
STATIC = {'.css':'text/css; charset=utf-8','.js':'application/javascript; charset=utf-8','.svg':'image/svg+xml','.woff2':'font/woff2','.webp':'image/webp'}
# Demo-Illustrationen für die mitgelieferten Beispielmuster, bis echte Fotos hochgeladen sind.
# 'ki': KI-generierte Vorschaubilder aus der Designvorlage, 'illustration': gezeichnete Platzhalter.
# Beides sind gekennzeichnete Demos und müssen vor dem Livegang durch echte Fotos ersetzt werden.
DEMO_IMAGES = os.environ.get('DEMO_IMAGES','illustration')
DEMO_ART = {'froschmuetze':'frosch','schneemannmuetze':'schneemann','schweinchenmuetze':'schweinchen','monstermuetze':'monster','baer':'baer','einhornmuetze':'einhorn'}
SITE_IMAGES = {'hero':'Startseite: großes Bild neben der Überschrift','haekeln':'Startseite: Bild im Abschnitt „Mit Liebe gehäkelt.“'}
PAGES = {'/': ('Startseite', 'Bienes Mützenparadies | Lustige Häkelmützen nach Wunsch'), '/muster': ('Muster & Ideen', 'Häkelmützen und Muster | Bienes Mützenparadies'), '/so-funktionierts': ("So funktioniert's", 'So funktioniert die Mützenanfrage | Bienes Mützenparadies'), '/groessenhilfe': ('Größenhilfe', 'Mützengröße bestimmen und Kopfumfang messen'), '/wunschfarben': ('Wunschfarben', 'Wunschfarben für Häkelmützen | Bienes Mützenparadies'), '/impressum': ('Impressum', 'Impressum | Bienes Mützenparadies'), '/datenschutz': ('Datenschutz', 'Datenschutzerklärung | Bienes Mützenparadies')}

def db():
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    con.execute('PRAGMA foreign_keys=ON')
    return con

def init():
    with db() as c:
        c.executescript('''CREATE TABLE IF NOT EXISTS patterns (id INTEGER PRIMARY KEY, slug TEXT UNIQUE NOT NULL, name TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', category TEXT NOT NULL DEFAULT '', sizes TEXT NOT NULL DEFAULT '[]', colors TEXT NOT NULL DEFAULT '[]', price TEXT, status TEXT NOT NULL DEFAULT 'draft', featured INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS images (id INTEGER PRIMARY KEY, pattern_id INTEGER NOT NULL REFERENCES patterns(id) ON DELETE CASCADE, filename TEXT NOT NULL, alt TEXT NOT NULL, position INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS sizes (id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL, min_cm REAL, max_cm REAL, position INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS colors (id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL, hex TEXT NOT NULL, position INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS sessions (token_hash TEXT PRIMARY KEY, csrf TEXT NOT NULL, expires INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS rate (key TEXT PRIMARY KEY, window INTEGER NOT NULL, count INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS site_images (key TEXT PRIMARY KEY, filename TEXT NOT NULL, alt TEXT NOT NULL);''')
        if not c.execute('SELECT 1 FROM patterns LIMIT 1').fetchone():
            examples = [('froschmuetze','Fritzi, der Frosch','Ein lustiger grüner Frosch mit großen Augen.','Tiermützen'),('schneemannmuetze','Der kleine Schneemann','Eine winterliche Schneemannmütze mit freundlichem Gesicht.','Wintermotive'),('schweinchenmuetze','Das rosa Schweinchen','Ein niedliches Schweinchen mit runden Ohren.','Tiermützen'),('monstermuetze','Das Quatschmonster','Ein außergewöhnliches Fantasiemonster mit lustigen Details.','Monster & Co.'),('baer', 'Der kleine Bär','Eine gemütliche Tiermütze mit Bärenohren.','Tiermützen'),('einhornmuetze','Das Einhorn','Ein fantasievolles Einhorn mit goldenem Horn und bunter Mähne.','Fantasiewelt')]
            c.executemany("INSERT INTO patterns(slug,name,description,category,created_at,status) VALUES(?,?,?,?,?,'draft')", [(a,b,d,cat,now()) for a,b,d,cat in examples])

def now(): return datetime.now(timezone.utc).isoformat(timespec='seconds')
def esc(v): return html.escape(str(v if v is not None else ''), quote=True)
def excerpt(v, n=160): return (v[:n-1]+'…') if len(v)>n else v
def clean_slug(s): return re.sub(r'[^a-z0-9-]', '', s.lower().replace('ä','ae').replace('ö','oe').replace('ü','ue').replace('ß','ss').replace(' ','-')).strip('-')
def jlist(s):
    try: return json.loads(s or '[]')
    except (ValueError,TypeError): return []
def selected(c, rows): return [r for r in rows if r['name'] in jlist(c)]
def assets(path): return (PUBLIC / path.lstrip('/')).resolve()

def response(start, status, body, headers=None, content_type='text/html; charset=utf-8', cache='no-store'):
    if isinstance(body,str): body=body.encode('utf-8')
    hs=[('Content-Type',content_type),('Content-Length',str(len(body))),('X-Content-Type-Options','nosniff'),('Referrer-Policy','strict-origin-when-cross-origin'),('X-Frame-Options','DENY'),('Content-Security-Policy',"default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'"),('Cache-Control',cache)]
    start(f'{status} {HTTPStatus(status).phrase}',hs+(headers or []))
    return [body]
def redirect(start,path,headers=None): return response(start,303,'', [('Location',path)]+(headers or []))
def read_body(env, max_bytes=16000):
    n=int(env.get('CONTENT_LENGTH','0') or 0)
    if n>max_bytes: raise ValueError('Eingabe zu groß')
    return env['wsgi.input'].read(n)
def fields(env): return {k:v[-1] for k,v in parse_qs(read_body(env).decode('utf-8'),keep_blank_values=True).items()}
def session(env):
    cookie=SimpleCookie()
    try: cookie.load(env.get('HTTP_COOKIE',''))
    except Exception: return None
    token=cookie.get('bm_session')
    if not token: return None
    with db() as c:
        return c.execute('SELECT * FROM sessions WHERE token_hash=? AND expires>?',(hashlib.sha256(token.value.encode()).hexdigest(),int(time.time()))).fetchone()
def csrf_ok(env,f,s): return s and hmac.compare_digest(f.get('csrf',''),s['csrf']) and env.get('HTTP_ORIGIN',ORIGIN)==ORIGIN
def admin_password(p):
    stored=os.environ.get('ADMIN_PASSWORD_HASH','')
    try:
        alg,salt,digest=stored.split('$')
        calc=hashlib.pbkdf2_hmac('sha256',p.encode(),bytes.fromhex(salt),310000).hex()
        return alg=='pbkdf2' and hmac.compare_digest(calc,digest)
    except (ValueError,TypeError): return False
def client_ip(env):
    if os.environ.get('TRUST_PROXY')=='1' and env.get('HTTP_X_REAL_IP'): return env['HTTP_X_REAL_IP']
    return env.get('REMOTE_ADDR','')

def rate_ok(key,limit=5,seconds=3600):
    with db() as c:
        row=c.execute('SELECT window,count FROM rate WHERE key=?',(key,)).fetchone()
        t=int(time.time())
        c.execute('DELETE FROM rate WHERE window<?',(t-86400,))
        c.execute('DELETE FROM sessions WHERE expires<?',(t,))
        if not row or t-row['window']>=seconds: c.execute('REPLACE INTO rate VALUES(?,?,1)',(key,t));return True
        if row['count']>=limit:return False
        c.execute('UPDATE rate SET count=count+1 WHERE key=?',(key,));return True

def icon(name, cls='i'):
    paths={
        'yarn':'<circle cx="12" cy="12" r="8.5"/><path d="M4.6 8.2c4.6-.4 10.3 3.5 12.6 10.4M3.8 13.4c3.3-4.1 9.6-6.7 15.6-5.4M8.3 4.4c3.6 2.3 6.4 7.7 5.9 15.9"/>',
        'tape':'<path d="M3.5 12a7 7 0 1 1 7 7H21v-3.5"/><circle cx="10.5" cy="12" r="2.4"/><path d="M14.5 19v-2M17.5 19v-2"/>',
        'palette':'<path d="M12 3.5a8.5 8.5 0 1 0 0 17c1.5 0 2.2-1.6 1.3-2.7-.9-1-.2-2.6 1.2-2.6h2.2a3.8 3.8 0 0 0 3.8-3.8C20.5 7 16.7 3.5 12 3.5Z"/><circle cx="7.6" cy="11.2" r="1.1"/><circle cx="10" cy="7.4" r="1.1"/><circle cx="14.6" cy="7.4" r="1.1"/>',
        'mail':'<rect x="3" y="5.5" width="18" height="13" rx="2.5"/><path d="m3.8 7.2 8.2 6 8.2-6"/>',
        'whatsapp':'<path d="M4.2 19.8 5.3 16A8.3 8.3 0 1 1 8.4 19Z"/><path d="M9.2 8.4c.3-.6.8-.6 1.1-.1l.8 1.5c.1.3 0 .6-.2.8l-.5.5c.5 1.2 1.6 2.3 2.8 2.8l.5-.5c.2-.2.5-.3.8-.2l1.5.8c.5.3.5.8-.1 1.1-1 .7-2.3.8-3.6.1a8 8 0 0 1-3.3-3.3c-.6-1.3-.6-2.6.2-3.5Z" fill="currentColor" stroke="none"/>',
        'arrow':'<path d="M5 12h14M13.5 6.5 19 12l-5.5 5.5"/>',
        'check':'<path d="m5 12.5 4.5 4.5L19 7.5"/>',
        'close':'<path d="M6 6l12 12M18 6 6 18"/>',
        'hook':'<path d="M5 19 17.5 6.5"/><path d="M17.5 6.5c.8-.8 2-.6 2.4.2.4.9-.1 1.8-1 1.9"/><path d="m8 13.5 2.5 2.5"/>',
        'heart':'<path d="M20 9c0 5-8 10-8 10S4 14 4 9a4 4 0 0 1 8-1 4 4 0 0 1 8 1Z"/>',
    }
    return f'<svg class="{cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">{paths.get(name,paths["yarn"])}</svg>'

def color_icon(name):
    """Mehrfarbige Symbole im Stil der Vorlage (Infokarten, Schritte, Merkmale)."""
    ink='#3A3027'
    art={
        'heart':f'<path d="M24 40s-14-8.6-14-18.5A7.8 7.8 0 0 1 24 16.6a7.8 7.8 0 0 1 14 4.9C38 31.4 24 40 24 40Z" fill="#FAEAE8" stroke="#C65A66" stroke-width="2.6" stroke-linejoin="round"/>',
        'yarn':f'<circle cx="22" cy="24" r="14" fill="#F2B8BE" stroke="{ink}" stroke-width="2.4"/><path d="M10.5 17c7-1 16 5 19 19M9 26c5-7 15-11 25-8M16 11.5c6 4 10 13 8.5 26" fill="none" stroke="#C65A66" stroke-width="2" stroke-linecap="round"/><path d="M30 38 43 9" stroke="#C9A24B" stroke-width="3" stroke-linecap="round"/><path d="M43 9c1-2.4 3.6-1.4 3 .6" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round"/><path d="M34 36c4 2 8 2 10 0" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round"/>',
        'tape':f'<path d="M20 30h22v8H20z" fill="#FBF1D4" stroke="{ink}" stroke-width="2.2" stroke-linejoin="round"/><path d="M25 30v4M29 30v3M33 30v4M37 30v3" stroke="{ink}" stroke-width="1.8" stroke-linecap="round"/><circle cx="19" cy="24" r="14" fill="#F3D68B" stroke="{ink}" stroke-width="2.4"/><circle cx="19" cy="24" r="5" fill="#fff" stroke="{ink}" stroke-width="2.2"/>',
        'palette':f'<path d="M24 8C14.6 8 7 15 7 23.6S14 40 22.6 40c2.8 0 3.6-2.6 2.2-4.3-1.3-1.6-.4-4 1.9-4H31c5.6 0 10-3.8 10-9.2C41 14.4 33.4 8 24 8Z" fill="#FFFDF9" stroke="{ink}" stroke-width="2.4" stroke-linejoin="round"/><circle cx="15" cy="23" r="3" fill="#C65A66"/><circle cx="19" cy="15.5" r="3" fill="#F3D68B"/><circle cx="27.5" cy="14.5" r="3" fill="#8BA17F"/><circle cx="34" cy="20.5" r="3" fill="#7FA8C9"/>',
        'gift':f'<rect x="9" y="19" width="30" height="21" rx="2.5" fill="#FAEAE8" stroke="{ink}" stroke-width="2.4"/><rect x="7" y="13" width="34" height="7" rx="2" fill="#FFFDF9" stroke="{ink}" stroke-width="2.4"/><path d="M24 13v27" stroke="#C65A66" stroke-width="3"/><path d="M24 13c-3-6-10-6-9-2 .6 2 5 2 9 2Zm0 0c3-6 10-6 9-2-.6 2-5 2-9 2Z" fill="none" stroke="{ink}" stroke-width="2.2" stroke-linejoin="round"/>',
        'search':f'<circle cx="21" cy="21" r="12" fill="#FAEAE8" stroke="#C65A66" stroke-width="2.8"/><path d="m30 30 10 10" stroke="#C65A66" stroke-width="4" stroke-linecap="round"/><path d="M15 21c0-3.3 2.7-6 6-6" fill="none" stroke="#C65A66" stroke-width="2.2" stroke-linecap="round"/>',
        'mail':f'<rect x="6" y="12" width="36" height="25" rx="3" fill="#FFFDF9" stroke="#C65A66" stroke-width="2.6"/><path d="m7.5 14 16.5 13 16.5-13M7.5 35.5 19 24M40.5 35.5 29 24" fill="none" stroke="#C65A66" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round"/>',
    }
    return f'<svg class="ci" viewBox="0 0 48 48" aria-hidden="true" focusable="false">{art[name]}</svg>'

def heart():
    return '<svg class="h-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 20.5s-7.5-4.6-7.5-10A4.3 4.3 0 0 1 12 7.6a4.3 4.3 0 0 1 7.5 2.9c0 5.4-7.5 10-7.5 10Z" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linejoin="round"/></svg>'

def info_cards():
    info=[('yarn',"So funktioniert’s",'Muster auswählen, Größe und Farbe angeben und unverbindlich anfragen.','Mehr erfahren','/so-funktionierts','sage'),('tape','Die richtige Größe','Hier erfährst du, wie du deinen Kopfumfang ganz einfach messen kannst.','Zur Größenhilfe','/groessenhilfe','honey'),('palette','Deine Wunschfarbe','Viele Muster sind in unterschiedlichen Farben möglich. Sag uns einfach, was dir gefällt.','Zu den Farboptionen','/wunschfarben','rose')]
    return ''.join(f'<a class="info-card {tone}" href="{url}">{color_icon(ic)}<div><h3>{title}</h3><p>{desc}</p><span class="text-link">{link} {icon("arrow")}</span></div></a>' for ic,title,desc,link,url,tone in info)

def logo(): return '<a class="brand" href="/"><img src="/brand/logo-compact.svg" alt="Bienes Mützenparadies – zur Startseite" width="247" height="54"></a>'

def site_image(key):
    with db() as c: return c.execute('SELECT * FROM site_images WHERE key=?',(key,)).fetchone()

def footer():
    return f'''<footer class="footer"><div class="wrap footer-grid"><div>{logo()}<p>Außergewöhnliche Häkelmützen, mit Liebe von Hand gemacht. Individuell auf Anfrage.</p></div><div><h2>Entdecken</h2><a href="/muster">Muster & Ideen</a><a href="/so-funktionierts">So funktioniert’s</a></div><div><h2>Hilfe</h2><a href="/groessenhilfe">Größenhilfe</a><a href="/wunschfarben">Wunschfarben</a><button type="button" data-contact>Kontakt</button></div><div><h2>Rechtliches</h2><a href="/impressum">Impressum</a><a href="/datenschutz">Datenschutz</a></div></div><div class="wrap footer-bottom"><span>© {datetime.now().year} Bienes Mützenparadies</span><span>Jede Mütze wird einzeln auf Anfrage gehäkelt.</span></div></footer>'''

def demo_image(name,alt,width,height,lazy=True,label='Demo-Illustration'):
    """Gekennzeichnetes Demo-Bild: KI-Vorschau oder Illustration, je nach DEMO_IMAGES."""
    loading=' loading="lazy"' if lazy else ' fetchpriority="high"'
    if DEMO_IMAGES=='ki':
        return f'<img src="/img/ki-{name}.webp" alt="KI-generiertes Demo-Bild: {esc(alt)}" width="{width}" height="{height}"{loading}><span class="demo-badge">Demo-Bild · KI-generiert</span>'
    return f'<img src="/img/demo-{name}.svg" alt="Illustration: {esc(alt)}" width="{width}" height="{height}"{loading}><span class="demo-badge">{label}</span>'

def pattern_visual(p):
    if p['image']: return f'<img src="/uploads/{esc(p["image"])}" alt="{esc(p["image_alt"])}" loading="lazy" width="800" height="1000">'
    art=DEMO_ART.get(p['slug'])
    if art: return demo_image(art,p['name'],400,400,label='Illustration · Foto folgt' if p['status']=='published' else 'Demo-Illustration')
    return f'<div class="image-placeholder">{icon("yarn")}<span>Produktfoto folgt</span></div>'

def layout(title,description,content,canonical='/',robots='index,follow',schema=''):
    links=[('/','Startseite'),('/muster','Muster & Ideen'),('/so-funktionierts','So funktioniert’s'),('/groessenhilfe','Größenhilfe')]
    section='/muster' if canonical.startswith('/muster') else canonical
    cur=' aria-current="page"'
    nav=''.join(f'<a href="{u}"{cur if u==section else ""}>{t}</a>' for u,t in links)+'<button type="button" data-contact>Kontakt</button>'
    og=f'<meta property="og:type" content="website"><meta property="og:locale" content="de_DE"><meta property="og:site_name" content="Bienes Mützenparadies"><meta property="og:title" content="{esc(title)}"><meta property="og:description" content="{esc(description)}"><meta property="og:url" content="{esc(ORIGIN+canonical)}">'
    return f'''<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"><title>{esc(title)}</title><meta name="description" content="{esc(description)}"><meta name="robots" content="{robots}"><link rel="canonical" href="{esc(ORIGIN+canonical)}">{og}<meta name="theme-color" content="#FBF8F3"><link rel="icon" href="/favicon.svg" type="image/svg+xml"><link rel="preload" href="/fonts/chewy-latin-400-normal.woff2" as="font" type="font/woff2" crossorigin><link rel="preload" href="/fonts/figtree-latin-wght-normal.woff2" as="font" type="font/woff2" crossorigin><link rel="stylesheet" href="/style.css">{schema}</head><body><a class="skip" href="#main">Zum Inhalt springen</a><header class="site-header"><div class="wrap header-inner">{logo()}<nav class="desktop-nav" aria-label="Hauptnavigation">{nav}</nav><button class="btn btn-coral btn-small header-cta" type="button" data-contact>Jetzt anfragen</button><button class="menu-toggle" type="button" aria-expanded="false" aria-controls="mobile-nav" aria-label="Menü öffnen"><span></span><span></span><span></span></button></div><nav id="mobile-nav" class="mobile-nav" aria-label="Mobile Navigation" hidden>{nav}<button type="button" class="btn btn-coral" data-contact>Jetzt anfragen</button></nav></header><main id="main">{content}</main>{footer()}{dialog()}<script src="/site.js" defer></script></body></html>'''

def dialog():
    return f'''<dialog id="contact-dialog" aria-labelledby="contact-title" aria-describedby="contact-intro"><div class="dialog-head"><div><span class="eyebrow">Deine Anfrage</span><h2 id="contact-title">Schreib Biene!</h2></div><button class="icon-button" type="button" data-close aria-label="Kontaktfenster schließen">{icon("close")}</button></div><p id="contact-intro">Du hast eine Frage oder möchtest eine Mütze anfragen? Schreib Biene einfach per WhatsApp – deine Nachricht ist schon vorbereitet.</p><div class="contact-card whatsapp-card"><span class="contact-icon whatsapp-icon">{icon("whatsapp")}</span><h3>Per WhatsApp</h3><p>Diese Nachricht wird vorbereitet. Du kannst sie in WhatsApp vor dem Senden noch ändern:</p><pre id="whatsapp-preview" class="message-preview"></pre><a id="whatsapp-link" class="btn btn-whatsapp" href="https://wa.me/{WHATSAPP}" target="_blank" rel="noopener noreferrer">WhatsApp öffnen</a><small>WhatsApp ist ein externer Dienst von Meta. Eine Verbindung entsteht erst, wenn du auf den Button tippst. Mehr dazu in der <a href="/datenschutz">Datenschutzerklärung</a>. Kein WhatsApp? Die E-Mail-Adresse findest du im <a href="/impressum">Impressum</a>.</small></div></dialog>'''

def patterns(status='published'):
    with db() as c:
        return c.execute('SELECT p.*, (SELECT filename FROM images WHERE pattern_id=p.id ORDER BY position,id LIMIT 1) image, (SELECT alt FROM images WHERE pattern_id=p.id ORDER BY position,id LIMIT 1) image_alt FROM patterns p WHERE status=? ORDER BY featured DESC,id',(status,)).fetchall()

def card(p,demo=False):
    action=f'<a class="pattern-link" href="/muster/{esc(p["slug"])}">Muster ansehen {icon("arrow")}</a>' if not demo else '<span class="demo-label">Demo · noch nicht anfragbar</span>'
    return f'<article class="pattern-card"><div class="pattern-image">{pattern_visual(p)}</div><div class="pattern-body"><h3>{esc(p["name"])}</h3><p>{esc(p["description"])}</p>{action}</div></article>'

def listing(demo_fallback=False):
    items=patterns()
    if not items and demo_fallback: items=patterns('draft');demo=True
    else: demo=False
    return items,demo

def home():
    items,demo=listing(True)
    cards=''.join(card(p,demo) for p in items[:4])
    notice='<p class="demo-notice">Vorschau: Die Bilder dieser Beispielmotive sind '+('KI-generiert' if DEMO_IMAGES=='ki' else 'Illustrationen')+' und zeigen keine echten Mützen. Sobald Biene die ersten Muster freigegeben hat, erscheinen hier echte Fotos, die du direkt anfragen kannst.</p>' if demo else ''
    hero=site_image('hero')
    hero_img=f'<img src="/uploads/{esc(hero["filename"])}" alt="{esc(hero["alt"])}" width="1200" height="800" fetchpriority="high">' if hero else demo_image('hero','gehäkelte Froschmütze, Schweinchenmütze und Schneemannmütze',1200,800,lazy=False)
    story=site_image('haekeln')
    story_img=f'<img src="/uploads/{esc(story["filename"])}" alt="{esc(story["alt"])}" loading="lazy" width="800" height="640">' if story else demo_image('haekeln','gehäkelte Bärenmütze und Einhornmütze in einem Korb',800,640)
    features=''.join(f'<li>{color_icon(ic)}<span>{a}<br>{b}</span></li>' for ic,a,b in (('heart','Individuelle','Motive'),('yarn','Verschiedene','Größen'),('palette','Deine','Wunschfarben'),('gift','Mit Liebe','gehäkelt')))
    story_points=''.join(f'<li>{icon("check")}<span>{t}</span></li>' for t in ('Jede Mütze wird einzeln gehäkelt – keine Massenware.','Größe, Farbe und kleine Extras stimmst du persönlich mit Biene ab.','Preis und Anfertigungszeit besprechen wir mit dir, bevor es losgeht.'))
    return f'''<section class="hero" aria-labelledby="hero-title"><figure class="hero-media">{hero_img}</figure><div class="wrap hero-inner"><div class="hero-copy"><img class="bee-flight" src="/img/bee-flight.svg" alt="" width="170" height="96"><span class="eyebrow">Handgemachte Lieblingsmützen</span><h1 id="hero-title">Hier gibt’s was auf die <span class="nowrap">Mütze!{heart()}</span></h1><p class="lead">Einzigartige Häkelmützen nach deinen Wünschen. Mit viel Liebe von Biene gehäkelt.</p><a class="btn btn-coral" href="/muster">Muster entdecken {icon("arrow")}</a><ul class="features">{features}</ul></div></div></section>
<section class="section" id="beliebte-muster" aria-labelledby="muster-title"><div class="wrap"><div class="section-head"><div><h2 id="muster-title">Beliebte Muster{heart()}</h2><p>Entdecke unsere fantasievollen Häkelmützen und finde dein Lieblingsmotiv.</p></div><a href="/muster" class="text-link">Alle Muster ansehen {icon("arrow")}</a></div>{notice}<div class="cards">{cards or '<p>Noch keine Muster veröffentlicht. Schau bald wieder vorbei.</p>'}</div></div></section>
<section class="section info-section" aria-label="Gut zu wissen"><div class="wrap info-grid">{info_cards()}</div></section>
<section class="section story" aria-labelledby="story-title"><div class="wrap story-grid"><figure class="story-visual"><div class="story-frame">{story_img}</div></figure><div class="story-copy"><span class="eyebrow">Bienes Handarbeit</span><h2 id="story-title">Mit Liebe gehäkelt.{heart()}</h2><p>Ob Frosch, Schneemann, Schweinchen oder eine ganz eigene Idee: Hier entstehen Mützen mit Charakter. Keine Massenware, sondern handgemachte Einzelstücke, die mit viel Freude auf dem Sofa entstehen.</p><ul class="checklist">{story_points}</ul><a href="/so-funktionierts" class="text-link">So läuft deine Anfrage ab {icon("arrow")}</a></div></div></section>
<section class="final-cta" aria-labelledby="cta-title"><div class="wrap"><div class="cta-panel"><img src="/brand/bee-mark.svg" alt="" width="72" height="72"><h2 id="cta-title">Schon eine Lieblingsmütze entdeckt?</h2><p>Dann schreib uns einfach, welches Muster du dir wünschst.</p><button class="btn btn-coral" type="button" data-contact>Jetzt unverbindlich anfragen</button><small>Eine Anfrage ist noch keine Bestellung. Preis und Anfertigungszeit stimmen wir persönlich mit dir ab.</small></div></div></section>'''

def catalogue(query):
    items,demo=listing(True)
    cats=sorted({p['category'] for p in items if p['category']})
    current=query.get('kategorie',[''])[0]
    if current: items=[p for p in items if p['category']==current]
    filters='<a class="chip '+('active' if not current else '')+'" href="/muster">Alle Muster</a>'+''.join(f'<a class="chip {"active" if current==cat else ""}" href="/muster?kategorie={quote(cat)}">{esc(cat)}</a>' for cat in cats)
    notice='<p class="demo-notice">Diese Muster sind noch Gestaltungsbeispiele. Biene muss jedes Modell vor der Veröffentlichung freigeben.</p>' if demo else ''
    return f'<div class="wrap page-heading"><span class="eyebrow">MIT CHARAKTER GEHÄKELT</span><h1>Muster & Ideen</h1><p>Such dir ein Motiv aus. Größe, Farbe und besondere Wünsche stimmen wir persönlich mit dir ab.</p></div><section class="wrap section narrow-top">{notice}<nav class="filter-row" aria-label="Musterkategorien">{filters}</nav><div class="cards">{"".join(card(p,demo) for p in items) if items else "<p>In dieser Kategorie gibt es noch keine Muster.</p>"}</div></section>'

def swatch_svg(hx):
    if not re.fullmatch(r'#[0-9a-fA-F]{6}',hx or ''):
        return '<svg viewBox="0 0 30 30" aria-hidden="true"><circle cx="15" cy="15" r="13.5" fill="#fff" stroke="#B6AA9B"/><path d="M15 8v14M8 15h14" stroke="#6B6158" stroke-width="1.6" stroke-linecap="round"/></svg>'
    return f'<svg viewBox="0 0 30 30" aria-hidden="true"><circle cx="15" cy="15" r="13.5" fill="{hx}" stroke="#B6AA9B"/></svg>'

def detail(p):
    with db() as c:
        ims=c.execute('SELECT * FROM images WHERE pattern_id=? ORDER BY position,id',(p['id'],)).fetchall()
        sizes=c.execute('SELECT * FROM sizes ORDER BY position,id').fetchall()
        colors=c.execute('SELECT * FROM colors ORDER BY position,id').fetchall()
    sizes=selected(p['sizes'],sizes);colors=selected(p['colors'],colors)
    if ims:
        main=f'<div class="main-image"><img id="main-image" src="/uploads/{esc(ims[0]["filename"])}" alt="{esc(ims[0]["alt"])}" width="1000" height="1000"></div>'
        thumbs=''.join(f'<button type="button" data-src="/uploads/{esc(i["filename"])}" data-alt="{esc(i["alt"])}" aria-label="Ansicht {n+1} zeigen"{" aria-current=\'true\'" if n==0 else ""}><img src="/uploads/{esc(i["filename"])}" alt="" loading="lazy"></button>' for n,i in enumerate(ims)) if len(ims)>1 else ''
        gallery=f'<div class="detail-gallery{"" if thumbs else " single"}">{"<div class=thumbs>"+thumbs+"</div>" if thumbs else ""}{main}</div>'
    else:
        art=DEMO_ART.get(p['slug'])
        inner=demo_image(art,p['name'],800,1000,lazy=False,label='Illustration · Foto folgt') if art else f'<div class="image-placeholder">{icon("yarn")}<span>Produktfoto folgt</span></div>'
        gallery=f'<div class="detail-gallery single"><div class="main-image">{inner}</div></div>'
    def size_box(name,rng=''):
        return f'<label class="size-option"><input type="radio" name="size" value="{esc(name)}" required><span>{esc(name)}{"<small>"+rng+"</small>" if rng else ""}</span></label>'
    size_opts=''.join(size_box(s['name'],f'{s["min_cm"]:g}–{s["max_cm"]:g} cm' if s['min_cm'] is not None and s['max_cm'] is not None else '') for s in sizes)+size_box('Individueller Kopfumfang')
    col_opts=''.join(f'<label class="swatch-option"><input type="radio" name="color" value="{esc(c["name"])}"><span>{swatch_svg(c["hex"])}{esc(c["name"])}</span></label>' for c in colors)
    return f'''<div class="wrap breadcrumb"><a href="/muster">Muster & Ideen</a> / {esc(p['name'])}</div><section class="wrap detail-grid">{gallery}<div class="detail-content"><span class="eyebrow">Individuell gehäkelt</span><h1>{esc(p['name'])}{heart()}</h1><p>{esc(p['description'])}</p><p class="price">{esc(p['price'])+' €' if p['price'] else 'Preis auf Anfrage'}</p><form id="pattern-form" data-pattern="{esc(p['name'])}"><fieldset><legend>Größe wählen</legend><div class="size-options">{size_opts}</div></fieldset><p class="field-help">Unsicher? <a href="/groessenhilfe">Zur Größenhilfe</a> – oder gib unten deinen Kopfumfang an.</p><label>Kopfumfang in cm (optional) <input name="head_cm" type="number" inputmode="decimal" min="20" max="80" step="0.1" placeholder="z. B. 51"></label><fieldset><legend>Wunschfarbe</legend><div class="swatch-options">{col_opts}<label class="swatch-option"><input type="radio" name="color" value="Individuelle Wunschfarbe"><span>{swatch_svg("")}Andere Farbe</span></label></div></fieldset><label>Hast du noch besondere Wünsche? <textarea name="wishes" rows="3" maxlength="1000" placeholder="z. B. andere Augenfarbe, längere Ohren …"></textarea></label><button class="btn btn-coral btn-block" type="submit">Unverbindlich anfragen {icon("arrow")}</button></form><p class="detail-note">Die Anfertigungszeit stimmen wir persönlich mit dir ab. Eine Anfrage ist noch keine Bestellung.</p></div></section>'''

def simple_page(path):
    if path=='/so-funktionierts':
        steps=[('search','Lieblingsmütze aussuchen','Stöbere durch die Muster-Galerie und finde deine Lieblingsmütze.'),('tape','Größe und Wunschfarbe wählen','Wähle die passende Größe oder gib deinen Kopfumfang an – und sag uns deine Wunschfarbe.'),('mail','Anfrage schicken','Schreib Biene per WhatsApp – deine Auswahl steht schon in der Nachricht.'),('heart','Mit Liebe gehäkelt','Nach der persönlichen Abstimmung häkelt Biene deine Mütze individuell für dich.')]
        steps_html=''.join(f'<article><div class="step-icon"><span class="step-no">{n+1}</span>{color_icon(ic)}</div><h2>{h}</h2><p>{t}</p></article>' for n,(ic,h,t) in enumerate(steps))
        return f'<div class="wrap page-heading center"><span class="eyebrow">Ganz einfach</span><h1>So funktioniert’s{heart()}</h1><p>Von der Idee bis zu deiner individuellen Mütze – in vier Schritten.</p></div><section class="wrap section narrow-top"><div class="steps">{steps_html}</div><p class="callout">Biene häkelt in ihrer Freizeit. Ob ein Wunsch möglich ist und wie lange die Anfertigung dauert, besprechen wir deshalb persönlich mit dir. Eine Anfrage ist unverbindlich.</p><p class="center"><button class="btn btn-coral" type="button" data-contact>Jetzt anfragen</button></p></section><section class="section info-section"><div class="wrap info-grid">{info_cards()}</div></section>'
    if path=='/groessenhilfe':
        with db() as c: sizes=c.execute('SELECT * FROM sizes WHERE min_cm IS NOT NULL AND max_cm IS NOT NULL ORDER BY min_cm').fetchall()
        sizes_json=json.dumps([dict(s) for s in sizes]).replace('<','\\u003c')
        rows=''.join(f'<tr><th scope="row">{esc(s["name"])}</th><td>{s["min_cm"]:g} bis {s["max_cm"]:g} cm</td></tr>' for s in sizes)
        return f'<div class="wrap page-heading"><span class="eyebrow">PASST WIE ANGEGOSSEN?</span><h1>Die richtige Größe finden</h1><p>Miss deinen Kopfumfang mit einem flexiblen Maßband etwa oberhalb der Augenbrauen und über den Ohren. Lege es bequem an, ohne es straff zu ziehen.</p></div><section class="wrap section narrow-top size-grid"><div class="measure-card">{color_icon("tape")}<h2>So misst du</h2><p>Führe das Maßband einmal waagerecht um den Kopf. Notiere den Wert in Zentimetern. Wiederhole die Messung zur Sicherheit.</p></div><div><h2>Größenempfehlung</h2><label>Wie groß ist dein Kopfumfang? <span class="input-suffix"><input type="number" id="head-size" inputmode="decimal" min="20" max="80" step="0.1" placeholder="z. B. 51"> cm</span></label><p id="size-result" role="status" aria-live="polite">{ "Bitte gib deinen Kopfumfang ein." if sizes else "Die Maßtabelle wird noch mit Biene abgestimmt. Frag uns gern nach deiner Größe." }</p><script type="application/json" id="sizes-json">{sizes_json}</script>{"<table><thead><tr><th>Größe</th><th>Kopfumfang</th></tr></thead><tbody>"+rows+"</tbody></table>" if sizes else "<p>Noch keine verbindlichen Zentimeterbereiche hinterlegt.</p>"}<p class="field-help">Die Empfehlung ist keine Passformgarantie.</p><button class="btn btn-coral" type="button" data-contact>Größe persönlich anfragen</button></div></section>'
    if path=='/wunschfarben':
        with db() as c: cols=c.execute('SELECT * FROM colors ORDER BY position,id').fetchall()
        swatches=''.join(f'<div class="swatch">{swatch_svg(x["hex"])}{esc(x["name"])}</div>' for x in cols)
        return '<div class="wrap page-heading"><span class="eyebrow">GANZ DEIN GESCHMACK</span><h1>Deine Wunschfarbe</h1><p>Viele Muster sind in unterschiedlichen Farben möglich. Welche Wolle zu welchem Motiv passt, klären wir bei deiner Anfrage.</p></div><section class="wrap section narrow-top"><div class="swatches">'+(swatches or '<p>Die verfügbaren Wollfarben werden noch ergänzt.</p>')+'</div><p class="callout">Farben können auf Bildschirmen anders wirken als die tatsächliche Wolle. Auch für eine besondere Wunschfarbe kannst du uns schreiben.</p><button class="btn btn-coral" type="button" data-contact>Farbe anfragen</button></section>'
    if path=='/impressum':
        return '''<div class="wrap legal"><h1>Impressum</h1><p class="pending">Vor Veröffentlichung prüfen: Die folgenden Betreiberangaben stammen aus dem Projektbrief. Ein Abgleich mit dem aktuellen Impressum von Mieten macht Sinn war nicht möglich.</p><h2>Angaben zum Anbieter</h2><p>Bienes Mützenparadies<br>Julian Kürten<br>Spreeallee 207<br>24111 Kiel<br>Deutschland</p><h2>Kontakt</h2><p>Telefon: <a href="tel:+4917647147503">0176 47147503</a><br>E-Mail: <a href="mailto:info@mieten-macht-sinn.de">info@mieten-macht-sinn.de</a><br>WhatsApp: <a href="https://wa.me/4915734487082">+49 157 34487082</a></p><p class="pending">Vor Veröffentlichung ergänzen oder prüfen: aktuelle Firmierung und Adresse, Umsatzsteuer-Identifikationsnummer oder Wirtschafts-Identifikationsnummer, soweit vorhanden beziehungsweise anzugeben, sowie weitere tatsächlich erforderliche Angaben.</p></div>'''
    if path=='/datenschutz':
        return '''<div class="wrap legal"><h1>Datenschutzerklärung</h1><p class="pending">Vor Veröffentlichung ergänzen und rechtlich prüfen: Rechenzentrum des Servers, Abschluss des Auftragsverarbeitungsvertrags mit Hetzner, Löschfrist für WhatsApp-Chats und Datum dieser Fassung. Diese Punkte sind unten in eckigen Klammern markiert.</p>
<h2>1. Verantwortlicher</h2><p>Julian Kürten, Bienes Mützenparadies<br>Spreeallee 207, 24111 Kiel, Deutschland<br>E-Mail: <a href="mailto:info@mieten-macht-sinn.de">info@mieten-macht-sinn.de</a><br>Telefon: 0176 47147503</p>
<h2>2. Das Wichtigste in Kürze</h2><p>Diese Website kommt ohne Kontaktformular, ohne Analyse- oder Werbedienste und ohne Cookies für Besucherinnen und Besucher aus. Schriften, Bilder und Skripte werden vom eigenen Server geladen, nicht von Drittanbietern. Anfragen laufen ausschließlich über WhatsApp, und zwar erst, wenn du selbst auf den WhatsApp-Button tippst.</p>
<h2>3. Hosting</h2><p>Die Website läuft auf einem Server der Hetzner Online GmbH, Industriestr. 25, 91710 Gunzenhausen, Deutschland. Standort des Servers: [Rechenzentrum eintragen, z. B. Nürnberg oder Falkenstein]. Mit Hetzner besteht ein Vertrag zur Auftragsverarbeitung nach Art. 28 DSGVO [Abschluss prüfen].</p>
<h2>4. Aufruf der Website und Server-Protokolle</h2><p>Beim Aufruf einer Seite verarbeitet der Server technisch notwendige Angaben: IP-Adresse, Datum und Uhrzeit, aufgerufene Adresse, Statuscode, übertragene Datenmenge, zuvor besuchte Seite und Browserkennung. Das ist nötig, um die Seite auszuliefern, sie vor Angriffen zu schützen und Fehler zu finden. Rechtsgrundlage ist Art. 6 Abs. 1 lit. f DSGVO.</p><p>In den Zugriffsprotokollen speichern wir die IP-Adresse nur gekürzt (bei IPv4 ohne die letzte Zahl, bei IPv6 nur die ersten beiden Blöcke). Fehlerprotokolle können die vollständige IP-Adresse enthalten. Beide Protokolle werden nach 14 Tagen automatisch gelöscht.</p>
<h2>5. Kontakt per WhatsApp</h2><p>Für Anfragen bieten wir einen Direktlink zu WhatsApp an. Es ist kein WhatsApp-Widget eingebunden, und beim bloßen Besuch der Website entsteht keine Verbindung zu WhatsApp. Deine Angaben zu Muster, Größe, Kopfumfang, Wunschfarbe und Wünschen bleiben zunächst nur in deinem Browser. Erst wenn du auf „WhatsApp öffnen“ tippst, werden sie als vorbereiteter Text an WhatsApp übergeben. Gesendet wird nichts automatisch: Du kannst die Nachricht in WhatsApp ändern oder verwerfen.</p><p>Anbieter von WhatsApp ist die WhatsApp Ireland Limited, 4 Grand Canal Square, Grand Canal Harbour, Dublin 2, Irland. Dabei können Daten auch an die Meta Platforms, Inc. in den USA übermittelt werden. Details findest du in den <a href="https://www.whatsapp.com/legal/privacy-policy-eea" target="_blank" rel="noopener noreferrer">Datenschutzhinweisen von WhatsApp</a>.</p><p>Schreibst du uns, verarbeiten wir deine Telefonnummer, deinen WhatsApp-Namen und den Inhalt eurer Nachrichten, um deine Anfrage zu beantworten und gegebenenfalls deine Mütze anzufertigen. Rechtsgrundlage ist Art. 6 Abs. 1 lit. b DSGVO. Wir löschen den Chat, wenn deine Anfrage erledigt ist [Frist festlegen], soweit keine gesetzlichen Aufbewahrungspflichten bestehen, etwa für Rechnungen.</p><p>Wenn du WhatsApp nicht nutzen möchtest, schreib uns eine E-Mail an die Adresse im <a href="/impressum">Impressum</a>. Deine E-Mail verarbeiten wir zu denselben Zwecken und löschen sie nach denselben Regeln.</p>
<h2>6. Cookies</h2><p>Für Besucherinnen und Besucher setzt die Website keine Cookies. Nur im passwortgeschützten Verwaltungsbereich wird ein technisch notwendiges Sitzungs-Cookie für die Anmeldung gesetzt. Es läuft nach spätestens 8 Stunden ab (§ 25 Abs. 2 Nr. 2 TDDDG, Art. 6 Abs. 1 lit. f DSGVO). Zum Schutz vor Passwort-Ausprobieren speichern wir bei Anmeldeversuchen einen nicht rückrechenbaren Hashwert der IP-Adresse für höchstens 24 Stunden.</p>
<h2>7. Deine Rechte</h2><p>Du hast nach der DSGVO das Recht auf Auskunft (Art. 15), Berichtigung (Art. 16), Löschung (Art. 17), Einschränkung der Verarbeitung (Art. 18) und Datenübertragbarkeit (Art. 20). Du kannst einer Verarbeitung, die auf Art. 6 Abs. 1 lit. f DSGVO beruht, widersprechen (Art. 21). Eine erteilte Einwilligung kannst du jederzeit für die Zukunft widerrufen. Schreib uns dafür einfach an die oben genannte Adresse.</p>
<h2>8. Beschwerde bei der Aufsichtsbehörde</h2><p>Du kannst dich bei einer Datenschutzaufsichtsbehörde beschweren. Für uns zuständig ist das Unabhängige Landeszentrum für Datenschutz Schleswig-Holstein, Holstenstraße 98, 24103 Kiel, Telefon 0431 988-1200, E-Mail <a href="mailto:mail@datenschutzzentrum.de">mail@datenschutzzentrum.de</a> [Kontaktdaten vor Veröffentlichung prüfen].</p>
<p>Stand: [Datum eintragen]</p></div>'''
    return ''

def admin_shell(body,s):
    return f'''<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>Verwaltung | Bienes Mützenparadies</title><link rel="stylesheet" href="/style.css"></head><body><header class="admin-header wrap"><a href="/">← Website</a><strong>Verwaltung</strong>{'<form method="post" action="/admin/logout"><input type="hidden" name="csrf" value="'+esc(s['csrf'])+'"><button>Abmelden</button></form>' if s else ''}</header><main class="wrap admin-main">{body}</main></body></html>'''
def hidden_csrf(s):return f'<input type="hidden" name="csrf" value="{esc(s["csrf"])}">'
def admin_home(s,query):
    tab=query.get('tab',['muster'])[0]
    nav='<nav class="filter-row"><a class="chip" href="/admin?tab=muster">Muster</a><a class="chip" href="/admin?tab=groessen">Größen</a><a class="chip" href="/admin?tab=farben">Farben</a><a class="chip" href="/admin?tab=startseite">Startseite</a></nav>'
    with db() as c:
        if tab=='startseite':
            body='<h1>Bilder der Startseite</h1><p>Solange hier kein Foto hinterlegt ist, zeigt die Startseite eine als Demo gekennzeichnete Illustration. Bitte nur eigene, echte Fotos verwenden. Biene wird nicht mit Gesicht gezeigt.</p>'
            for key,label in SITE_IMAGES.items():
                cur=c.execute('SELECT * FROM site_images WHERE key=?',(key,)).fetchone()
                preview=f'<div class="admin-photo"><img src="/uploads/{esc(cur["filename"])}" alt="{esc(cur["alt"])}"><p>Aktuelles Foto</p><label class="check"><input type="checkbox" name="remove" value="1"> Foto entfernen</label></div>' if cur else '<p>Derzeit: Demo-Illustration</p>'
                body+=f'<form class="admin-form" method="post" enctype="multipart/form-data" action="/admin/startseite/{key}">{hidden_csrf(s)}<h2>{esc(label)}</h2>{preview}<label>Neues Foto (JPEG, PNG, WebP) <input type="file" name="image" accept="image/jpeg,image/png,image/webp"></label><label>Bildbeschreibung (Alt-Text) <input name="alt" maxlength="180" value="{esc(cur["alt"] if cur else "")}" placeholder="z. B. Gehäkelte Froschmütze und Schneemannmütze auf einem Holzregal"></label><button class="btn btn-coral" type="submit">Speichern</button></form>'
        elif tab in ('groessen','farben'):
            is_size=tab=='groessen';table='sizes' if is_size else 'colors';rows=c.execute(f'SELECT * FROM {table} ORDER BY position,id').fetchall()
            body=f'<h1>{"Größen" if is_size else "Wollfarben"}</h1><p>{"Zentimeterbereiche werden erst nach fachlicher Freigabe angezeigt." if is_size else "Farbnamen und Farbfelder können hier gepflegt werden."}</p>'
            body+=''.join(f'<form class="admin-item admin-inline" method="post" action="/admin/{tab}/{r["id"]}">{hidden_csrf(s)}<input name="name" value="{esc(r["name"])}" required aria-label="Name"><input name="{ "min_cm" if is_size else "hex" }" value="{esc(r["min_cm"] if is_size else r["hex"])}" aria-label="{ "Minimum cm" if is_size else "Hex-Farbe" }">'+(f'<input name="max_cm" value="{esc(r["max_cm"])}" aria-label="Maximum cm">' if is_size else '')+f'<button class="btn btn-dark">Speichern</button><button name="delete" value="1" onclick="return confirm(\'Eintrag löschen?\')">Löschen</button></form>' for r in rows)
            body+=f'<h2>Neu anlegen</h2><form class="admin-item admin-inline" method="post" action="/admin/{tab}/new">{hidden_csrf(s)}<input name="name" placeholder="Name" required><input name="{ "min_cm" if is_size else "hex" }" placeholder="{ "Minimum cm" if is_size else "#RRGGBB" }">'+('<input name="max_cm" placeholder="Maximum cm">' if is_size else '')+'<button class="btn btn-coral">Anlegen</button></form>'
        else:
            rows=c.execute('SELECT * FROM patterns ORDER BY id DESC').fetchall()
            body='<h1>Muster</h1><p>Ein Muster lässt sich veröffentlichen, sobald Biene es freigegeben hat und es ein echtes Foto hat. Die mitgelieferten Motive haben eine Illustration und können bis zum Foto damit online gehen.</p><p><a class="btn btn-coral" href="/admin/pattern/new">Neues Muster</a></p><div class="admin-list">'+''.join(f'<a href="/admin/pattern/{r["id"]}"><strong>{esc(r["name"])}</strong><span>{esc(r["status"])} · {esc(r["category"])}</span></a>' for r in rows)+'</div>'
    return admin_shell(nav+body,s)

def pattern_editor(s,p=None,error=''):
    with db() as c:
        sizes=c.execute('SELECT * FROM sizes ORDER BY position,id').fetchall();colors=c.execute('SELECT * FROM colors ORDER BY position,id').fetchall();ims=c.execute('SELECT * FROM images WHERE pattern_id=? ORDER BY position,id',(p['id'],)).fetchall() if p else []
    current=lambda key: p[key] if p else ''
    checks=lambda key,rows: ''.join(f'<label class="check"><input type="checkbox" name="{key}" value="{esc(r["name"])}" {"checked" if p and r["name"] in jlist(p[key]) else ""}> {esc(r["name"])}</label>' for r in rows)
    images=''.join(f'<div class="admin-photo"><img src="/uploads/{esc(i["filename"])}" alt="{esc(i["alt"])}"><label>Bildbeschreibung <input name="alt_{i["id"]}" value="{esc(i["alt"])}"></label><label>Reihenfolge <input type="number" name="pos_{i["id"]}" value="{i["position"]}"></label><label><input type="checkbox" name="remove_{i["id"]}" value="1"> Bild löschen</label></div>' for i in ims)
    return admin_shell(f'<p><a href="/admin">← Muster</a></p><h1>{"Muster bearbeiten" if p else "Neues Muster"}</h1><p class="error">{esc(error)}</p><form method="post" enctype="multipart/form-data" action="/admin/pattern/{p["id"] if p else "new"}" class="admin-form">{hidden_csrf(s)}<label>Name <input name="name" value="{esc(current("name"))}" required maxlength="120"></label><label>URL-Kürzel <input name="slug" value="{esc(current("slug"))}" placeholder="wird aus dem Namen erzeugt" pattern="[a-z0-9-]+"></label><label>Beschreibung <textarea name="description" rows="4" required>{esc(current("description"))}</textarea></label><label>Kategorie <input name="category" value="{esc(current("category"))}" list="category-list" required></label><datalist id="category-list">'+''.join(f'<option value="{x}"></option>' for x in ('Tiermützen','Lustige Motive','Wintermotive','Fantasiewelt','Monster & Co.','Weitere Ideen'))+f'</datalist><fieldset><legend>Größen</legend>{checks("sizes",sizes) or "<p>Lege zuerst Größen in der Verwaltung an.</p>"}</fieldset><fieldset><legend>Farben</legend>{checks("colors",colors) or "<p>Lege zuerst Farben in der Verwaltung an.</p>"}</fieldset><label>Freigegebener Preis in Euro (optional) <input type="number" step="0.01" min="0" name="price" value="{esc(current("price"))}"></label><label>Status <select name="status">'+''.join(f'<option value="{st}" {"selected" if current("status")==st else ""}>{st}</option>' for st in ('draft','published','archived'))+f'</select></label><label class="check"><input type="checkbox" name="featured" value="1" {"checked" if p and p["featured"] else ""}> Auf Startseite hervorheben</label><h2>Bilder</h2>{images}<label>Neue Produktbilder (JPEG, PNG, WebP; maximal 8 MB je Bild) <input type="file" name="images" accept="image/jpeg,image/png,image/webp" multiple></label><label>Bildbeschreibungen für neue Bilder <input name="new_alt" placeholder="z. B. Gehäkelte Froschmütze von vorn"></label><p>Vor Veröffentlichung nur echte Fotos freigegebener Muster hochladen.</p><button class="btn btn-coral" type="submit">Muster speichern</button></form>{f"<form method='post' action='/admin/pattern/{p['id']}/delete' onsubmit='return confirm(&quot;Muster endgültig löschen?&quot;)'>{hidden_csrf(s)}<button class='text-link'>Muster löschen</button></form>" if p else ""}',s)

def process_image(item):
    """Prüft ein hochgeladenes Bild, entfernt Metadaten und speichert es als WebP."""
    limit=int(os.environ.get('MAX_UPLOAD_MB','8'))*1024*1024
    data=item.file.read(limit+1)
    if len(data)>limit:raise ValueError('Bild zu groß')
    try:
        image=Image.open(io.BytesIO(data));image.verify();image=Image.open(io.BytesIO(data))
        if image.format not in ('JPEG','PNG','WEBP') or image.width*image.height>30000000:raise ValueError('Ungültiges Bildformat')
        image=ImageOps.exif_transpose(image).convert('RGB');image.thumbnail((1800,1800))
        filename=secrets.token_hex(16)+'.webp';image.save(DATA/'uploads'/filename,'WEBP',quality=82,method=6)
    except (UnidentifiedImageError,OSError,ValueError) as exc:raise ValueError('Bild konnte nicht verarbeitet werden') from exc
    return filename

def upload_images(fs,pid):
    uploaded=fs['images'] if 'images' in fs else []
    if not isinstance(uploaded,list):uploaded=[uploaded]
    for item in uploaded:
        if not getattr(item,'filename',None):continue
        filename=process_image(item)
        alt=fs.getfirst('new_alt','').strip() or 'Handgehäkelte Mütze'
        with db() as c:c.execute('INSERT INTO images(pattern_id,filename,alt,position) VALUES(?,?,?,?)',(pid,filename,alt,0))

def admin_action(env,start,path,s):
    if path=='/admin/login':
        f=fields(env);key='login:'+hashlib.sha256(client_ip(env).encode()).hexdigest()
        if not rate_ok(key,8,900):return response(start,429,admin_shell('<h1>Bitte später erneut versuchen.</h1>',None))
        if not SECRET or not admin_password(f.get('password','')):return response(start,401,admin_shell('<h1>Anmelden</h1><p>Passwort nicht korrekt oder Zugang noch nicht eingerichtet.</p><form method="post"><input type="password" name="password" required><button class="btn btn-dark">Anmelden</button></form>',None))
        token=secrets.token_urlsafe(32);csrf=secrets.token_urlsafe(32)
        with db() as c:c.execute('INSERT INTO sessions VALUES(?,?,?)',(hashlib.sha256(token.encode()).hexdigest(),csrf,int(time.time())+8*3600))
        secure='; Secure' if ORIGIN.startswith('https://') else ''
        return redirect(start,'/admin',[('Set-Cookie',f'bm_session={token}; HttpOnly; SameSite=Lax; Path=/admin; Max-Age=28800{secure}')])
    if not s:return response(start,403,'Zugriff verweigert')
    if path.startswith(('/admin/pattern/','/admin/startseite/')) and env.get('CONTENT_TYPE','').startswith('multipart/form-data'):
        fs=cgi.FieldStorage(fp=env['wsgi.input'],environ=env,keep_blank_values=True,limit=12*1024*1024)
        f={k:fs.getfirst(k,'') for k in fs.keys() if k not in ('images','image')}
    else:fs=None;f=fields(env)
    if not csrf_ok(env,f,s):return response(start,403,'Sitzungsschutz fehlgeschlagen')
    if path=='/admin/logout':
        with db() as c:c.execute('DELETE FROM sessions WHERE token_hash=?',(s['token_hash'],))
        return redirect(start,'/admin',[('Set-Cookie','bm_session=; HttpOnly; SameSite=Lax; Path=/admin; Max-Age=0')])
    match=re.fullmatch(r'/admin/startseite/(hero|haekeln)',path)
    if match:
        key=match[1];alt=f.get('alt','').strip()[:180]
        with db() as c:cur=c.execute('SELECT * FROM site_images WHERE key=?',(key,)).fetchone()
        item=fs['image'] if fs is not None and 'image' in fs else None
        if item is not None and getattr(item,'filename',None):
            if not alt:return response(start,422,admin_shell('<h1>Bitte eine Bildbeschreibung angeben.</h1><p><a href="/admin?tab=startseite">Zurück</a></p>',s))
            try:filename=process_image(item)
            except ValueError as err:return response(start,422,admin_shell(f'<h1>{esc(err)}</h1><p><a href="/admin?tab=startseite">Zurück</a></p>',s))
            with db() as c:c.execute('REPLACE INTO site_images VALUES(?,?,?)',(key,filename,alt))
            if cur:(DATA/'uploads'/cur['filename']).unlink(missing_ok=True)
        elif cur and f.get('remove')=='1':
            with db() as c:c.execute('DELETE FROM site_images WHERE key=?',(key,))
            (DATA/'uploads'/cur['filename']).unlink(missing_ok=True)
        elif cur and alt:
            with db() as c:c.execute('UPDATE site_images SET alt=? WHERE key=?',(alt,key))
        return redirect(start,'/admin?tab=startseite')
    match=re.fullmatch(r'/admin/(groessen|farben)/(new|\d+)',path)
    if match:
        table='sizes' if match[1]=='groessen' else 'colors';name=f.get('name','').strip()[:80]
        if f.get('delete')=='1' and match[2]!='new':
            with db() as c:c.execute(f'DELETE FROM {table} WHERE id=?',(match[2],))
            return redirect(start,'/admin?tab='+match[1])
        if not name:return response(start,422,'Name fehlt')
        if table=='sizes':
            try:
                minimum=float(f['min_cm']);maximum=float(f['max_cm']);assert 20<=minimum<=maximum<=80
            except (ValueError,KeyError,AssertionError):return response(start,422,'Bitte gültige Zentimeterbereiche von 20 bis 80 angeben.')
            vals=(name,minimum,maximum)
        else:
            hx=f.get('hex','').strip()
            if not re.fullmatch(r'#[0-9a-fA-F]{6}',hx):return response(start,422,'Bitte Farbe im Format #RRGGBB angeben.')
            vals=(name,hx)
        with db() as c:
            try:
                if match[2]=='new':c.execute(f'INSERT INTO {table}(name,{"min_cm,max_cm" if table=="sizes" else "hex"}) VALUES({"?,?,?" if table=="sizes" else "?,?"})',vals)
                else:c.execute(f'UPDATE {table} SET name=?, {"min_cm=?,max_cm=?" if table=="sizes" else "hex=?"} WHERE id=?',(*vals,match[2]))
            except sqlite3.IntegrityError:return response(start,409,'Name bereits vorhanden')
        return redirect(start,'/admin?tab='+match[1])
    match=re.fullmatch(r'/admin/pattern/(new|\d+)',path)
    if match:
        ident=match[1];name=f.get('name','').strip()[:120];slug=clean_slug(f.get('slug','') or name);status=f.get('status','draft')
        if not name or not slug or status not in ('draft','published','archived'):return response(start,422,'Name, URL und Status prüfen')
        with db() as c:
            try:
                vals=(slug,name,f.get('description','').strip()[:3000],f.get('category','').strip()[:80],json.dumps(fs.getlist('sizes') if fs else []),json.dumps(fs.getlist('colors') if fs else []),f.get('price','').strip() or None,status,1 if f.get('featured') else 0)
                if ident=='new':cur=c.execute('INSERT INTO patterns(slug,name,description,category,sizes,colors,price,status,featured,created_at) VALUES(?,?,?,?,?,?,?,?,?,?)',(*vals,now()));pid=cur.lastrowid
                else:pid=int(ident);c.execute('UPDATE patterns SET slug=?,name=?,description=?,category=?,sizes=?,colors=?,price=?,status=?,featured=? WHERE id=?',(*vals,pid))
            except sqlite3.IntegrityError:return response(start,409,'URL-Kürzel bereits vorhanden')
        if fs:
            try:upload_images(fs,pid)
            except ValueError as err:return response(start,422,pattern_editor(s,db().execute('SELECT * FROM patterns WHERE id=?',(pid,)).fetchone(),str(err)))
        with db() as c:
            for im in c.execute('SELECT * FROM images WHERE pattern_id=?',(pid,)).fetchall():
                if f.get('remove_'+str(im['id']))=='1':
                    c.execute('DELETE FROM images WHERE id=?',(im['id'],));(DATA/'uploads'/im['filename']).unlink(missing_ok=True)
                else:c.execute('UPDATE images SET alt=?,position=? WHERE id=?',(f.get('alt_'+str(im['id']),im['alt'])[:180],int(f.get('pos_'+str(im['id']),im['position']) or 0),im['id']))
            if status=='published' and slug not in DEMO_ART and not c.execute('SELECT 1 FROM images WHERE pattern_id=?',(pid,)).fetchone():c.execute("UPDATE patterns SET status='draft' WHERE id=?",(pid,))
        return redirect(start,f'/admin/pattern/{pid}')
    match=re.fullmatch(r'/admin/pattern/(\d+)/delete',path)
    if match:
        with db() as c:
            for im in c.execute('SELECT filename FROM images WHERE pattern_id=?',(match[1],)).fetchall():(DATA/'uploads'/im['filename']).unlink(missing_ok=True)
            c.execute('DELETE FROM patterns WHERE id=?',(match[1],))
        return redirect(start,'/admin')
    return response(start,404,'Nicht gefunden')

def app(env,start):
    init();path=unquote(env.get('PATH_INFO','/'));method=env.get('REQUEST_METHOD','GET')
    if method=='HEAD':method='GET'  # Gunicorn sendet bei HEAD keinen Inhalt mit
    try:
        if path.startswith('/uploads/') and method=='GET':
            name=path.removeprefix('/uploads/')
            if not re.fullmatch(r'[0-9a-f]{32}\.webp',name):return response(start,404,'Nicht gefunden')
            p=DATA/'uploads'/name
            if not p.is_file():return response(start,404,'Nicht gefunden')
            return response(start,200,p.read_bytes(),content_type='image/webp',cache='public, max-age=86400')
        if method=='GET' and (path in ('/style.css','/site.js','/favicon.svg') or re.fullmatch(r'/(fonts|img|brand)/[a-z0-9-]+\.(woff2|svg|webp)',path)):
            p=(BRAND/path.removeprefix('/brand/')) if path.startswith('/brand/') else PUBLIC/path[1:]
            if not p.is_file():return response(start,404,'Nicht gefunden')
            cache='public, max-age=31536000, immutable' if path.startswith('/fonts/') else 'public, max-age=3600'
            return response(start,200,p.read_bytes(),content_type=STATIC[p.suffix],cache=cache)
        if path.startswith('/admin'):
            s=session(env)
            if method=='POST':return admin_action(env,start,path,s)
            if path=='/admin' and not s:return response(start,200,admin_shell('<h1>Anmelden</h1><form method="post" action="/admin/login"><label>Passwort <input type="password" name="password" required autocomplete="current-password"></label><button class="btn btn-dark">Anmelden</button></form>',None))
            if not s:return redirect(start,'/admin')
            query=parse_qs(env.get('QUERY_STRING',''))
            if path=='/admin':return response(start,200,admin_home(s,query))
            m=re.fullmatch(r'/admin/pattern/(new|\d+)',path)
            if m:
                with db() as c:p=c.execute('SELECT * FROM patterns WHERE id=?',(m[1],)).fetchone() if m[1]!='new' else None
                if m[1]!='new' and not p:return response(start,404,'Nicht gefunden')
                return response(start,200,pattern_editor(s,p))
            return response(start,404,'Nicht gefunden')
        if path=='/robots.txt':return response(start,200,f'User-agent: *\nDisallow: /admin\nDisallow: /api/\nSitemap: {ORIGIN}/sitemap.xml\n',content_type='text/plain; charset=utf-8')
        if path=='/sitemap.xml':
            urls=list(PAGES)
            with db() as c:urls += ['/muster/'+r['slug'] for r in c.execute("SELECT slug FROM patterns WHERE status='published'")]
            xml='<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'+''.join(f'<url><loc>{esc(ORIGIN+u)}</loc></url>' for u in urls)+'</urlset>'
            return response(start,200,xml,content_type='application/xml; charset=utf-8')
        if method!='GET':return response(start,405,'Methode nicht erlaubt')
        if path in PAGES:
            desc='Entdecke außergewöhnliche Tiermützen und fantasievolle Häkelmützen. Wähle dein Lieblingsmuster, die passende Größe und deine Wunschfarbe.' if path=='/' else 'Außergewöhnliche handgemachte Häkelmützen nach Wunsch. Entdecke Motive, Größenhilfe und persönliche Anfragen.'
            content=home() if path=='/' else catalogue(parse_qs(env.get('QUERY_STRING',''))) if path=='/muster' else simple_page(path)
            canonical=path
            graph=[{'@type':'Organization','@id':ORIGIN+'/#organisation','name':'Bienes Mützenparadies','url':ORIGIN+'/','logo':ORIGIN+'/brand/logo-full.svg'},{'@type':'WebSite','@id':ORIGIN+'/#website','name':'Bienes Mützenparadies','url':ORIGIN+'/','inLanguage':'de-DE','publisher':{'@id':ORIGIN+'/#organisation'}}]
            schema='<script type="application/ld+json">'+json.dumps({'@context':'https://schema.org','@graph':graph},ensure_ascii=False).replace('<','\\u003c')+'</script>' if path=='/' else ''
            return response(start,200,layout(PAGES[path][1],desc,content,canonical,schema=schema))
        m=re.fullmatch(r'/muster/([a-z0-9-]+)',path)
        if m:
            with db() as c:p=c.execute("SELECT * FROM patterns WHERE slug=? AND status='published'",(m[1],)).fetchone()
            if not p:return response(start,404,layout('Muster nicht gefunden','', '<div class="wrap legal"><h1>Muster nicht gefunden</h1><a href="/muster">Zur Übersicht</a></div>',path,robots='noindex'))
            return response(start,200,layout(f'{p["name"]} häkeln lassen | Bienes Mützenparadies',excerpt(p['description']),detail(p),path))
        return response(start,404,layout('Seite nicht gefunden','', '<div class="wrap legal"><h1>Seite nicht gefunden</h1><a href="/">Zur Startseite</a></div>',path,robots='noindex'))
    except Exception as exc:
        import traceback;traceback.print_exc()
        return response(start,500,'Ein Fehler ist aufgetreten. Bitte versuche es später erneut.')

if __name__=='__main__':
    init()
    print('Bienes Mützenparadies auf http://127.0.0.1:8000')
    make_server('127.0.0.1',8000,app).serve_forever()
