"""Bines Mützenparadies: Musterkatalog mit Anfragen per WhatsApp. Python 3.12, Pillow für Bilder."""
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

import legal_defaults

BASE = Path(__file__).resolve().parent
DATA = Path(os.environ.get('DATA_DIR', str(BASE / 'data'))).resolve()
DATA.mkdir(parents=True, exist_ok=True)
(DATA / 'uploads').mkdir(exist_ok=True)
ORIGIN = os.environ.get('SITE_ORIGIN', 'http://localhost:8000').rstrip('/')
SECRET = os.environ.get('SECRET_KEY', '')
WHATSAPP = '4915734487082'
DB = DATA / 'site.sqlite3'
PUBLIC = BASE / 'public'
ASSET_VERSION = hashlib.sha256(b''.join((BASE/'public'/n).read_bytes() for n in ('style.css','site.js'))).hexdigest()[:10]
BRAND = BASE / 'brand'
STATIC = {'.css':'text/css; charset=utf-8','.js':'application/javascript; charset=utf-8','.svg':'image/svg+xml','.woff2':'font/woff2','.webp':'image/webp'}
# Demo-Illustrationen für die mitgelieferten Beispielmuster, bis echte Fotos hochgeladen sind.
# 'ki': KI-generierte Vorschaubilder aus der Designvorlage, 'illustration': gezeichnete Platzhalter.
# Beides sind gekennzeichnete Demos und müssen vor dem Livegang durch echte Fotos ersetzt werden.
DEMO_IMAGES = os.environ.get('DEMO_IMAGES','illustration')
DEMO_ART = {'froschmuetze':'frosch','schneemannmuetze':'schneemann','schweinchenmuetze':'schweinchen','monstermuetze':'monster','baer':'baer','einhornmuetze':'einhorn'}
LEGAL = {'impressum':('Impressum',legal_defaults.IMPRESSUM),'datenschutz':('Datenschutzerklärung',legal_defaults.DATENSCHUTZ)}
SITE_IMAGES = {'hero':'Startseite: großes Bild neben der Überschrift','haekeln':'Startseite: Bild im Abschnitt „Mit Liebe gehäkelt.“'}
PAGES = {'/': ('Startseite', 'Bines Mützenparadies | Lustige Häkelmützen nach Wunsch'), '/muster': ('Muster & Ideen', 'Häkelmützen und Muster | Bines Mützenparadies'), '/so-funktionierts': ("So funktioniert's", 'So funktioniert die Mützenanfrage | Bines Mützenparadies'), '/wunschmotive': ('Wunschmotive', 'Wunschmotiv als Häkelmütze anfragen | Bines Mützenparadies'), '/groessenhilfe': ('Kopfumfang messen', 'Kopfumfang messen für deine Häkelmütze | Bines Mützenparadies'), '/impressum': ('Impressum', 'Impressum | Bines Mützenparadies'), '/datenschutz': ('Datenschutz', 'Datenschutzerklärung | Bines Mützenparadies')}

def db():
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    con.execute('PRAGMA foreign_keys=ON')
    return con

def init():
    with db() as c:
        c.executescript('''CREATE TABLE IF NOT EXISTS patterns (id INTEGER PRIMARY KEY, slug TEXT UNIQUE NOT NULL, name TEXT NOT NULL, description TEXT NOT NULL DEFAULT '', category TEXT NOT NULL DEFAULT '', sizes TEXT NOT NULL DEFAULT '[]', colors TEXT NOT NULL DEFAULT '[]', price TEXT, status TEXT NOT NULL DEFAULT 'draft', featured INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS images (id INTEGER PRIMARY KEY, pattern_id INTEGER NOT NULL REFERENCES patterns(id) ON DELETE CASCADE, filename TEXT NOT NULL, alt TEXT NOT NULL, position INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY, name TEXT NOT NULL, contact TEXT NOT NULL, message TEXT NOT NULL, pattern TEXT, head_cm TEXT, wishes TEXT, created_at TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE IF NOT EXISTS legal (key TEXT PRIMARY KEY, content TEXT NOT NULL, updated_at TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS sessions (token_hash TEXT PRIMARY KEY, csrf TEXT NOT NULL, expires INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS rate (key TEXT PRIMARY KEY, window INTEGER NOT NULL, count INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS site_images (key TEXT PRIMARY KEY, filename TEXT NOT NULL, alt TEXT NOT NULL);''')
        if not c.execute('SELECT 1 FROM patterns LIMIT 1').fetchone():
            examples = [('froschmuetze','Fritzi, der Frosch','Ein lustiger grüner Frosch mit großen Augen.','Tiermützen'),('schneemannmuetze','Der kleine Schneemann','Eine winterliche Schneemannmütze mit freundlichem Gesicht.','Wintermotive'),('schweinchenmuetze','Das rosa Schweinchen','Ein niedliches Schweinchen mit runden Ohren.','Tiermützen'),('monstermuetze','Das Quatschmonster','Ein außergewöhnliches Fantasiemonster mit lustigen Details.','Monster & Co.'),('baer', 'Der kleine Bär','Eine gemütliche Tiermütze mit Bärenohren.','Tiermützen'),('einhornmuetze','Das Einhorn','Ein fantasievolles Einhorn mit goldenem Horn und bunter Mähne.','Fantasiewelt')]
            c.executemany("INSERT INTO patterns(slug,name,description,category,created_at,status) VALUES(?,?,?,?,?,'draft')", [(a,b,d,cat,now()) for a,b,d,cat in examples])
        for key,(_,text) in LEGAL.items():
            c.execute('INSERT OR IGNORE INTO legal VALUES(?,?,?)',(key,text,now()))
            # Nie bearbeitete alte Vorlage durch die neue ersetzen; eigene Änderungen bleiben unangetastet
            row=c.execute('SELECT content FROM legal WHERE key=?',(key,)).fetchone()
            if row['content'].strip() in [t.strip() for t in legal_defaults.PREVIOUS.get(key,[])]:
                c.execute('UPDATE legal SET content=?,updated_at=? WHERE key=?',(text,now(),key))
        # Nachrichten aus dem Kontaktformular werden nach 6 Monaten gelöscht (siehe Datenschutz)
        c.execute("DELETE FROM messages WHERE created_at<datetime('now','-183 days')")

def now(): return datetime.now(timezone.utc).isoformat(timespec='seconds')
def esc(v): return html.escape(str(v if v is not None else ''), quote=True)
def excerpt(v, n=160): return (v[:n-1]+'…') if len(v)>n else v
def clean_slug(s): return re.sub(r'[^a-z0-9-]', '', s.lower().replace('ä','ae').replace('ö','oe').replace('ü','ue').replace('ß','ss').replace(' ','-')).strip('-')
def assets(path): return (PUBLIC / path.lstrip('/')).resolve()

def response(start, status, body, headers=None, content_type='text/html; charset=utf-8', cache='no-store'):
    if isinstance(body,str): body=body.encode('utf-8')
    hs=[('Content-Type',content_type),('Content-Length',str(len(body))),('X-Content-Type-Options','nosniff'),('Referrer-Policy','strict-origin-when-cross-origin'),('X-Frame-Options','DENY'),('Content-Security-Policy',"default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'"),('Cache-Control',cache)]
    start(f'{status} {HTTPStatus(status).phrase}',hs+(headers or []))
    return [body]
def redirect(start,path,headers=None): return response(start,303,'', [('Location',path)]+(headers or []))
def read_body(env, max_bytes=64000):
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
        'idea':f'<path d="M24 7a12 12 0 0 0-7 21.7c1.3 1 2 2.3 2 3.8V34h10v-1.5c0-1.5.7-2.8 2-3.8A12 12 0 0 0 24 7Z" fill="#F3D68B" stroke="{ink}" stroke-width="2.4" stroke-linejoin="round"/><path d="M19 38.5h10M20.5 42.5h7" stroke="{ink}" stroke-width="2.4" stroke-linecap="round"/><path d="M24 25.5s-5-3-5-6.2a2.7 2.7 0 0 1 5-1.4 2.7 2.7 0 0 1 5 1.4c0 3.2-5 6.2-5 6.2Z" fill="#C65A66"/><path d="M6 17l3 1M42 17l-3 1M11 6l2 2.5M37 6l-2 2.5" stroke="#C65A66" stroke-width="2.2" stroke-linecap="round"/>',
        'parcel':f'<path d="M8 17 24 9l16 8v17l-16 8-16-8Z" fill="#E8D3B5" stroke="{ink}" stroke-width="2.4" stroke-linejoin="round"/><path d="m8 17 16 8 16-8M24 25v17" fill="none" stroke="{ink}" stroke-width="2.4" stroke-linejoin="round"/><path d="m16 13 16 8v6" fill="none" stroke="#C65A66" stroke-width="3" stroke-linejoin="round"/><path d="M30 35.5s-3-1.8-3-3.8a1.6 1.6 0 0 1 3-.8 1.6 1.6 0 0 1 3 .8c0 2-3 3.8-3 3.8Z" fill="#C65A66"/>',
        'search':f'<circle cx="21" cy="21" r="12" fill="#FAEAE8" stroke="#C65A66" stroke-width="2.8"/><path d="m30 30 10 10" stroke="#C65A66" stroke-width="4" stroke-linecap="round"/><path d="M15 21c0-3.3 2.7-6 6-6" fill="none" stroke="#C65A66" stroke-width="2.2" stroke-linecap="round"/>',
        'mail':f'<rect x="6" y="12" width="36" height="25" rx="3" fill="#FFFDF9" stroke="#C65A66" stroke-width="2.6"/><path d="m7.5 14 16.5 13 16.5-13M7.5 35.5 19 24M40.5 35.5 29 24" fill="none" stroke="#C65A66" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round"/>',
    }
    return f'<svg class="ci" viewBox="0 0 48 48" aria-hidden="true" focusable="false">{art[name]}</svg>'

def heart():
    return '<svg class="h-heart" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M12 20.5s-7.5-4.6-7.5-10A4.3 4.3 0 0 1 12 7.6a4.3 4.3 0 0 1 7.5 2.9c0 5.4-7.5 10-7.5 10Z" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linejoin="round"/></svg>'

def info_cards():
    info=[('yarn',"So funktioniert’s",'Muster auswählen, Kopfumfang angeben und unverbindlich anfragen.','Mehr erfahren','/so-funktionierts','sage'),('tape','Kopfumfang messen','Jede Mütze wird nach deinem Kopfumfang gehäkelt. So misst du ihn ganz einfach.','Zur Messanleitung','/groessenhilfe','honey'),('idea','Dein Wunschmotiv','Du hast eine eigene Idee? Lieblingstier oder Fantasiefigur – beschreib sie Bine einfach.','Zu den Wunschmotiven','/wunschmotive','rose')]
    return ''.join(f'<a class="info-card {tone}" href="{url}">{color_icon(ic)}<div><h3>{title}</h3><p>{desc}</p><span class="text-link">{link} {icon("arrow")}</span></div></a>' for ic,title,desc,link,url,tone in info)

def with_heart(text):
    """Herz an das letzte Wort koppeln, damit es auf dem Handy nicht allein umbricht."""
    head,_,last=text.rpartition(' ')
    return f'{head} <span class="nowrap">{last}{heart()}</span>' if head else f'<span class="nowrap">{last}{heart()}</span>'

def logo(): return '<a class="brand" href="/"><img src="/brand/logo-compact.svg" alt="Bines Mützenparadies – zur Startseite" width="247" height="54"></a>'

def site_image(key):
    with db() as c: return c.execute('SELECT * FROM site_images WHERE key=?',(key,)).fetchone()

def footer():
    return f'''<footer class="footer"><div class="wrap footer-grid"><div>{logo()}<p>Außergewöhnliche Häkelmützen, mit Liebe von Hand gemacht. Individuell auf Anfrage.</p></div><div><h2>Entdecken</h2><a href="/muster">Muster & Ideen</a><a href="/so-funktionierts">So funktioniert’s</a></div><div><h2>Hilfe</h2><a href="/groessenhilfe">Kopfumfang messen</a><a href="/wunschmotive">Wunschmotive</a><button type="button" data-contact>Kontakt</button></div><div><h2>Rechtliches</h2><a href="/impressum">Impressum</a><a href="/datenschutz">Datenschutz</a></div></div><div class="wrap footer-bottom"><span>© {datetime.now().year} Bines Mützenparadies</span><span>Jede Mütze wird einzeln auf Anfrage gehäkelt.</span></div></footer>'''

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
    links=[('/','Startseite'),('/muster','Muster & Ideen'),('/wunschmotive','Wunschmotive'),('/so-funktionierts','So funktioniert’s'),('/groessenhilfe','Kopfumfang')]
    section='/muster' if canonical.startswith('/muster') else canonical
    cur=' aria-current="page"'
    nav=''.join(f'<a href="{u}"{cur if u==section else ""}>{t}</a>' for u,t in links)
    og=f'<meta property="og:type" content="website"><meta property="og:locale" content="de_DE"><meta property="og:site_name" content="Bines Mützenparadies"><meta property="og:title" content="{esc(title)}"><meta property="og:description" content="{esc(description)}"><meta property="og:url" content="{esc(ORIGIN+canonical)}">'
    return f'''<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"><title>{esc(title)}</title><meta name="description" content="{esc(description)}"><meta name="robots" content="{robots}"><link rel="canonical" href="{esc(ORIGIN+canonical)}">{og}<meta name="theme-color" content="#FBF8F3"><link rel="icon" href="/favicon.svg" type="image/svg+xml"><link rel="preload" href="/fonts/chewy-latin-400-normal.woff2" as="font" type="font/woff2" crossorigin><link rel="preload" href="/fonts/figtree-latin-wght-normal.woff2" as="font" type="font/woff2" crossorigin><link rel="stylesheet" href="/style.css?v={ASSET_VERSION}">{schema}</head><body><a class="skip" href="#main">Zum Inhalt springen</a><header class="site-header"><div class="wrap header-inner">{logo()}<nav class="desktop-nav" aria-label="Hauptnavigation">{nav}</nav><button class="btn btn-coral btn-small header-cta" type="button" data-contact>Jetzt anfragen</button><button class="menu-toggle" type="button" aria-expanded="false" aria-controls="mobile-nav" aria-label="Menü öffnen"><span></span><span></span><span></span></button></div><nav id="mobile-nav" class="mobile-nav" aria-label="Mobile Navigation" hidden>{nav}<button type="button" class="btn btn-coral" data-contact>Jetzt anfragen</button></nav></header><main id="main">{content}</main>{footer()}{dialog()}<script src="/site.js?v={ASSET_VERSION}" defer></script></body></html>'''

def message_form(form_id,in_dialog=False):
    """Kontaktformular: im Kontaktfenster und eingebettet auf der Startseite. Speichert nur, verschickt keine E-Mail."""
    head='<button type="button" id="form-back" class="text-link">← Zurück</button><p id="form-summary" class="form-summary" hidden></p>' if in_dialog else ''
    return f'''<div class="message-box"><form id="{form_id}" class="contact-form message-form" novalidate{" hidden" if in_dialog else ""}>{head}<label>Dein Name <input name="name" autocomplete="name" required maxlength="100"></label><label>Telefon oder E-Mail <input name="contact" autocomplete="email" required maxlength="200" placeholder="Damit Bine dir antworten kann"></label><label>Deine Nachricht <textarea name="message" rows="5" required maxlength="5000" placeholder="Was möchtest du wissen?"></textarea></label><input type="hidden" name="pattern"><input type="hidden" name="head_cm"><input type="hidden" name="wishes"><div class="honeypot" aria-hidden="true"><label>Website <input name="website" tabindex="-1" autocomplete="off"></label></div><p class="form-note">Wir nutzen deine Angaben nur, um dir zu antworten. Mehr dazu in der <a href="/datenschutz">Datenschutzerklärung</a>.</p><button class="btn btn-coral" type="submit">Nachricht senden</button><p class="form-feedback" role="status" aria-live="polite"></p></form><div class="form-success" tabindex="-1" hidden><h3>Vielen Dank!</h3><p>Deine Nachricht ist angekommen. Bine meldet sich bei dir.</p></div></div>'''

def dialog():
    return f'''<dialog id="contact-dialog" aria-labelledby="contact-title" aria-describedby="contact-intro"><div class="dialog-head"><div><span class="eyebrow">Deine Anfrage</span><h2 id="contact-title">Schreib Bine!</h2></div><button class="icon-button" type="button" data-close aria-label="Kontaktfenster schließen">{icon("close")}</button></div><p id="contact-intro">Du hast eine Frage oder möchtest eine Mütze anfragen? Such dir einfach aus, wie du uns erreichen möchtest.</p><div id="contact-choices" class="contact-choices"><div class="contact-card"><span class="contact-icon whatsapp-icon">{icon("whatsapp")}</span><h3>Per WhatsApp</h3><p>Schreib uns ganz unkompliziert eine Nachricht. Sie ist schon vorbereitet:</p><pre id="whatsapp-preview" class="message-preview"></pre><a id="whatsapp-link" class="btn btn-whatsapp" href="https://wa.me/{WHATSAPP}" target="_blank" rel="noopener noreferrer">WhatsApp öffnen</a><small>WhatsApp ist ein externer Dienst von Meta. Eine Verbindung entsteht erst, wenn du auf den Button tippst.</small></div><div class="contact-card"><span class="contact-icon coral-icon">{icon("mail")}</span><h3>Über das Kontaktformular</h3><p>Kein WhatsApp? Schreib uns deine Wünsche direkt hier auf der Website. Bine meldet sich per Telefon oder E-Mail bei dir.</p><button type="button" id="show-form" class="btn btn-coral">Kontaktformular öffnen</button></div></div>{message_form("contact-form",in_dialog=True)}</dialog>'''

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
    notice='<p class="demo-notice">Vorschau: Die Bilder dieser Beispielmotive sind '+('KI-generiert' if DEMO_IMAGES=='ki' else 'Illustrationen')+' und zeigen keine echten Mützen. Sobald Bine die ersten Muster freigegeben hat, erscheinen hier echte Fotos, die du direkt anfragen kannst.</p>' if demo else ''
    hero=site_image('hero')
    hero_img=f'<img src="/uploads/{esc(hero["filename"])}" alt="{esc(hero["alt"])}" width="1200" height="800" fetchpriority="high">' if hero else demo_image('hero','gehäkelte Froschmütze, Schweinchenmütze und Schneemannmütze',1200,800,lazy=False)
    story=site_image('haekeln')
    story_img=f'<img src="/uploads/{esc(story["filename"])}" alt="{esc(story["alt"])}" loading="lazy" width="800" height="640">' if story else demo_image('haekeln','gehäkelte Bärenmütze und Einhornmütze in einem Korb',800,640)
    features=''.join(f'<li>{color_icon(ic)}<span>{a}<br>{b}</span></li>' for ic,a,b in (('heart','Individuelle','Motive'),('tape','Genau nach','Kopfumfang'),('idea','Deine','Wunschmotive'),('gift','Mit Liebe','gehäkelt')))
    story_points=''.join(f'<li>{icon("check")}<span>{t}</span></li>' for t in ('Jede Mütze wird einzeln gehäkelt – keine Massenware.','Kopfumfang, Motiv und kleine Extras stimmst du persönlich mit Bine ab.','Preis und Anfertigungszeit besprechen wir mit dir, bevor es losgeht.'))
    return f'''<section class="hero" aria-labelledby="hero-title"><figure class="hero-media">{hero_img}</figure><div class="wrap hero-inner"><div class="hero-copy"><img class="bee-flight" src="/img/bee-flight.svg" alt="" width="170" height="96"><span class="eyebrow">Handgemachte Lieblingsmützen</span><h1 id="hero-title">Hier gibt’s was auf die {with_heart('Mütze!')}</h1><p class="lead">Einzigartige Häkelmützen nach deinen Wünschen. Mit viel Liebe von Bine gehäkelt.</p><a class="btn btn-coral" href="/muster">Muster entdecken {icon("arrow")}</a><ul class="features">{features}</ul></div></div></section>
<section class="section" id="beliebte-muster" aria-labelledby="muster-title"><div class="wrap"><div class="section-head"><div><h2 id="muster-title">{with_heart('Beliebte Muster')}</h2><p>Entdecke unsere fantasievollen Häkelmützen und finde dein Lieblingsmotiv.</p></div><a href="/muster" class="text-link">Alle Muster ansehen {icon("arrow")}</a></div>{notice}<div class="cards">{cards or '<p>Noch keine Muster veröffentlicht. Schau bald wieder vorbei.</p>'}</div></div></section>
<section class="section info-section" aria-label="Gut zu wissen"><div class="wrap info-grid">{info_cards()}</div></section>
<section class="section story" aria-labelledby="story-title"><div class="wrap story-grid"><figure class="story-visual"><div class="story-frame">{story_img}</div></figure><div class="story-copy"><span class="eyebrow">Bines Handarbeit</span><h2 id="story-title">{with_heart('Mit Liebe gehäkelt.')}</h2><p>Ob Frosch, Schneemann, Schweinchen oder eine ganz eigene Idee: Hier entstehen Mützen mit Charakter. Keine Massenware, sondern handgemachte Einzelstücke, die mit viel Freude auf dem Sofa entstehen.</p><ul class="checklist">{story_points}</ul><a href="/so-funktionierts" class="text-link">So läuft deine Anfrage ab {icon("arrow")}</a></div></div></section>
<section class="final-cta" id="kontakt" aria-labelledby="cta-title"><div class="wrap"><div class="cta-panel with-form"><div class="cta-intro"><img src="/brand/bee-mark.svg" alt="" width="72" height="72"><h2 id="cta-title">Schon eine Lieblingsmütze entdeckt?</h2><p>Dann schreib uns einfach, welches Muster du dir wünschst – direkt hier im Formular oder per WhatsApp.</p><button class="btn btn-whatsapp" type="button" data-contact>{icon("whatsapp")} Jetzt unverbindlich anfragen</button><small>Eine Anfrage ist noch keine Bestellung. Preis und Anfertigungszeit stimmen wir persönlich mit dir ab.</small></div><div class="cta-form"><h3>Schreib Bine direkt</h3>{message_form("home-contact-form")}</div></div></div></section>'''

def catalogue(query):
    items,demo=listing(True)
    cats=sorted({p['category'] for p in items if p['category']})
    current=query.get('kategorie',[''])[0]
    if current: items=[p for p in items if p['category']==current]
    filters='<a class="chip '+('active' if not current else '')+'" href="/muster">Alle Muster</a>'+''.join(f'<a class="chip {"active" if current==cat else ""}" href="/muster?kategorie={quote(cat)}">{esc(cat)}</a>' for cat in cats)
    notice='<p class="demo-notice">Diese Muster sind noch Gestaltungsbeispiele. Bine muss jedes Modell vor der Veröffentlichung freigeben.</p>' if demo else ''
    return f'<div class="wrap page-heading"><span class="eyebrow">MIT CHARAKTER GEHÄKELT</span><h1>Muster & Ideen</h1><p>Such dir ein Motiv aus. Kopfumfang und besondere Wünsche stimmen wir persönlich mit dir ab.</p></div><section class="wrap section narrow-top">{notice}<nav class="filter-row" aria-label="Musterkategorien">{filters}</nav><div class="cards">{"".join(card(p,demo) for p in items) if items else "<p>In dieser Kategorie gibt es noch keine Muster.</p>"}</div><p class="more-ideas">Deine Idee ist nicht dabei? <a class="text-link" href="/wunschmotive">Wunschmotiv anfragen {icon("arrow")}</a></p></section>'



def head_field(required=True):
    """Eingabe des Kopfumfangs – Mützen gibt es nicht in Größen, nur nach Zentimetern."""
    opt='' if required else ' (optional)'
    return f'<div class="head-field"><label for="head_cm">Dein Kopfumfang in cm{opt}</label><div class="input-suffix"><input id="head_cm" name="head_cm" type="number" inputmode="decimal" min="30" max="70" step="0.5" placeholder="z. B. 52"{" required" if required else ""}><span>cm</span></div><p class="field-help">Einmal waagerecht über Stirn und Ohren messen. <a href="/groessenhilfe">So misst du richtig</a></p></div>'

def detail(p):
    with db() as c:
        ims=c.execute('SELECT * FROM images WHERE pattern_id=? ORDER BY position,id',(p['id'],)).fetchall()
    if ims:
        main=f'<div class="main-image"><img id="main-image" src="/uploads/{esc(ims[0]["filename"])}" alt="{esc(ims[0]["alt"])}" width="1000" height="1000"></div>'
        thumbs=''.join(f'<button type="button" data-src="/uploads/{esc(i["filename"])}" data-alt="{esc(i["alt"])}" aria-label="Ansicht {n+1} zeigen"{" aria-current=\'true\'" if n==0 else ""}><img src="/uploads/{esc(i["filename"])}" alt="" loading="lazy"></button>' for n,i in enumerate(ims)) if len(ims)>1 else ''
        gallery=f'<div class="detail-gallery{"" if thumbs else " single"}">{"<div class=thumbs>"+thumbs+"</div>" if thumbs else ""}{main}</div>'
    else:
        art=DEMO_ART.get(p['slug'])
        inner=demo_image(art,p['name'],800,1000,lazy=False,label='Illustration · Foto folgt') if art else f'<div class="image-placeholder">{icon("yarn")}<span>Produktfoto folgt</span></div>'
        gallery=f'<div class="detail-gallery single"><div class="main-image">{inner}</div></div>'
    return f'''<div class="wrap breadcrumb"><a href="/muster">Muster & Ideen</a> / {esc(p['name'])}</div><section class="wrap detail-grid">{gallery}<div class="detail-content"><span class="eyebrow">Individuell gehäkelt</span><h1>{with_heart(esc(p['name']))}</h1><p>{esc(p['description'])}</p><p class="price">{esc(p['price'])+' €' if p['price'] else 'Preis auf Anfrage'}</p><form id="pattern-form" data-pattern="{esc(p['name'])}">{head_field()}<label>Hast du noch besondere Wünsche? <textarea name="wishes" rows="3" maxlength="1000" placeholder="z. B. größere Augen, mit Bommel …"></textarea></label><button class="btn btn-coral btn-block" type="submit">Unverbindlich anfragen {icon("arrow")}</button></form><p class="detail-note">Die Anfertigungszeit stimmen wir persönlich mit dir ab. Eine Anfrage ist noch keine Bestellung.</p></div></section>'''

def render_legal(text):
    """Einfache Schreibweise der Rechtstexte in HTML umwandeln (siehe legal_defaults.py)."""
    def inline(t):
        t=esc(t)
        t=re.sub(r'https?://[^\s<]+',lambda m:f'<a href="{m[0]}" target="_blank" rel="noopener noreferrer">{m[0]}</a>',t)
        t=re.sub(r'(?<![\w.])([\w.+-]+@[\w-]+\.[\w.-]*\w)',r'<a href="mailto:\1">\1</a>',t)
        return re.sub(r'\[([^\]]+)\]',r'<mark class="todo">[\1]</mark>',t)
    out=[]
    for block in re.split(r'\n\s*\n',text.replace('\r','').strip()):
        lines=block.strip().split('\n')
        if lines[0].startswith('## '):
            out.append(f'<h2>{inline(lines[0][3:].strip())}</h2>');lines=lines[1:]
        if lines: out.append('<p>'+'<br>'.join(inline(l) for l in lines)+'</p>')
    return ''.join(out)

MEASURE_SVG='<svg viewBox="0 0 320 300" role="img" aria-label="Zeichnung: Maßband waagerecht um den Kopf, über Stirn und Ohren"><ellipse cx="160" cy="288" rx="110" ry="8" fill="#3A3027" opacity=".07"/><path d="M110 250c-6 22-8 34-8 40h116c0-6-2-18-8-40" fill="#E9EFE3" stroke="#3A3027" stroke-width="4"/><ellipse cx="160" cy="150" rx="86" ry="100" fill="#F7E6D6" stroke="#3A3027" stroke-width="4"/><ellipse cx="74" cy="160" rx="13" ry="22" fill="#F7E6D6" stroke="#3A3027" stroke-width="4"/><ellipse cx="246" cy="160" rx="13" ry="22" fill="#F7E6D6" stroke="#3A3027" stroke-width="4"/><path d="M78 92c14-44 52-62 82-62s70 16 84 62c-26-18-54-24-84-24s-60 6-82 24Z" fill="#8A6A4E" stroke="#3A3027" stroke-width="4" stroke-linejoin="round"/><path d="M122 150q10-7 20 0M178 150q10-7 20 0" fill="none" stroke="#3A3027" stroke-width="4" stroke-linecap="round"/><circle cx="132" cy="166" r="5" fill="#3A3027"/><circle cx="188" cy="166" r="5" fill="#3A3027"/><path d="M142 204q18 12 36 0" fill="none" stroke="#3A3027" stroke-width="4" stroke-linecap="round"/><circle cx="116" cy="190" r="10" fill="#E98A93" opacity=".5"/><circle cx="204" cy="190" r="10" fill="#E98A93" opacity=".5"/><path d="M64 128c30 12 62 17 96 17s66-5 96-17v22c-30 12-62 17-96 17s-66-5-96-17Z" fill="#F3D68B" stroke="#3A3027" stroke-width="3.5" stroke-linejoin="round"/><path d="M86 137v9M106 142v12M126 145v9M146 147v12M166 147v9M186 146v12M206 143v9M226 139v12" stroke="#3A3027" stroke-width="2.5" stroke-linecap="round"/><rect x="232" y="118" width="62" height="34" rx="10" fill="#C65A66" stroke="#3A3027" stroke-width="3.5"/><text x="263" y="141" text-anchor="middle" font-family="Figtree, sans-serif" font-size="17" font-weight="700" fill="#fff">52 cm</text></svg>'

def simple_page(path):
    if path=='/so-funktionierts':
        steps=[('search','Lieblingsmütze aussuchen','Stöbere durch die Muster-Galerie und finde deine Lieblingsmütze.'),('tape','Kopfumfang angeben','Miss deinen Kopfumfang in Zentimetern und gib ihn bei deiner Anfrage an.'),('mail','Anfrage schicken','Per WhatsApp oder Kontaktformular – deine Auswahl ist schon eingetragen.'),('heart','Mit Liebe gehäkelt','Nach der persönlichen Abstimmung häkelt Bine deine Mütze individuell für dich.'),('parcel','Versand oder Abholung','Wir schicken dir deine fertige Mütze gut verpackt per Post – oder du holst sie in Kiel ab. Das klären wir bei deiner Anfrage.')]
        steps_html=''.join(f'<article><div class="step-icon"><span class="step-no">{n+1}</span>{color_icon(ic)}</div><h2>{h}</h2><p>{t}</p></article>' for n,(ic,h,t) in enumerate(steps))
        return f'<div class="wrap page-heading center"><span class="eyebrow">Ganz einfach</span><h1>{with_heart('So funktioniert’s')}</h1><p>Von der Idee bis zu deiner individuellen Mütze – in fünf Schritten.</p></div><section class="wrap section narrow-top"><div class="steps">{steps_html}</div><p class="callout">Ob ein Wunsch möglich ist und wie lange die Anfertigung dauert, besprechen wir persönlich mit dir. Eine Anfrage ist unverbindlich.</p><p class="center"><button class="btn btn-coral" type="button" data-contact>Jetzt anfragen</button></p></section><section class="section info-section"><div class="wrap info-grid">{info_cards()}</div></section>'
    if path=='/groessenhilfe':
        steps=''.join(f'<li><strong>{h}</strong><span>{t}</span></li>' for h,t in (('Maßband nehmen','Am besten ein weiches Maßband aus dem Nähkästchen. Alternativ eine Schnur, die du danach an ein Lineal hältst.'),('Richtig anlegen','Das Maßband einmal waagerecht um den Kopf legen: etwa zwei Finger breit über den Augenbrauen und über die Ohren.'),('Nicht zu straff','Es soll anliegen, aber nicht drücken. Dann den Wert in Zentimetern ablesen.'),('Zur Sicherheit zweimal','Miss am besten ein zweites Mal und gib uns den Wert bei deiner Anfrage an.')))
        return f'''<div class="wrap page-heading"><span class="eyebrow">Passt wie angegossen</span><h1>{with_heart('Kopfumfang messen')}</h1><p>Bei Bines Mützen gibt es keine Größen wie S, M oder L. Jede Mütze wird nach deinem Kopfumfang in Zentimetern gehäkelt. So misst du ihn:</p></div><section class="wrap section narrow-top measure-grid"><div class="measure-art">{MEASURE_SVG}</div><div><ol class="measure-steps">{steps}</ol><form id="pattern-form" class="measure-form" data-pattern="">{head_field()}<button class="btn btn-coral" type="submit">Mit diesem Kopfumfang anfragen {icon("arrow")}</button></form><p class="field-help">Die Angabe hilft Bine beim Häkeln. Die Passform besprecht ihr bei Bedarf persönlich.</p></div></section>'''
    if path=='/wunschmotive':
        ideas=''.join(f'<li>{t}</li>' for t in ('dein Lieblingstier','eine Fantasiefigur','ein kleines Monster','Obst oder Gemüse','ein Tier mit Schlappohren'))
        return f'''<div class="wrap page-heading"><span class="eyebrow">Deine Idee</span><h1>{with_heart('Dein Wunschmotiv')}</h1><p>Dein Lieblingstier ist nicht dabei? Oder du hast eine ganz eigene Figur im Kopf? Beschreib Bine deine Idee – sie schaut, ob und wie sie sich als Mütze häkeln lässt.</p></div><section class="wrap section narrow-top wish-grid"><div class="wish-card">{color_icon("idea")}<h2>Ideen zum Beispiel</h2><ul class="idea-list">{ideas}</ul><p class="field-help">Figuren aus Filmen, Serien oder Büchern, die rechtlich geschützt sind, kann Bine leider nicht nachhäkeln. Eigene Ideen und Fantasiefiguren sind dagegen herzlich willkommen.</p></div><form id="pattern-form" class="wish-form" data-pattern="Eigenes Wunschmotiv" data-wishes-label="Mein Wunschmotiv"><label>Beschreib dein Wunschmotiv <textarea name="wishes" rows="5" maxlength="1000" required placeholder="z. B. ein Fuchs mit Schlappohren und buschigem Schwanz"></textarea></label>{head_field(required=False)}<button class="btn btn-coral btn-block" type="submit">Wunschmotiv anfragen {icon("arrow")}</button><p class="field-help">Ob dein Motiv möglich ist, was es kostet und wie lange es dauert, besprecht ihr ganz unverbindlich.</p></form></section>'''
    if path in ('/impressum','/datenschutz'):
        key=path[1:]
        with db() as c: text=c.execute('SELECT content FROM legal WHERE key=?',(key,)).fetchone()['content']
        return f'<div class="wrap legal"><h1>{LEGAL[key][0]}</h1>{render_legal(text)}</div>'
    return ''

def contact_message(env,start):
    """Nachricht aus dem Kontaktformular speichern – ohne E-Mail-Versand."""
    def answer(status,data):return response(start,status,json.dumps(data),content_type='application/json')
    try:f=fields(env)
    except (UnicodeDecodeError,ValueError):return answer(400,{'error':'Ungültige Eingabe.'})
    if env.get('HTTP_ORIGIN',ORIGIN)!=ORIGIN:return answer(403,{'error':'Ungültige Herkunft.'})
    if f.get('website'):return answer(200,{'ok':True})
    if not rate_ok('msg:'+hashlib.sha256(client_ip(env).encode()).hexdigest(),5,3600):return answer(429,{'error':'Zu viele Nachrichten in kurzer Zeit. Bitte versuche es später erneut oder schreib per WhatsApp.'})
    vals={k:f.get(k,'').strip() for k in ('name','contact','message','pattern','head_cm','wishes')}
    limits={'name':100,'contact':200,'message':5000,'pattern':120,'head_cm':10,'wishes':1000}
    if not vals['name'] or not vals['message'] or len(re.sub(r'\D','',vals['contact']))<6 and '@' not in vals['contact'] or any(len(vals[k])>n for k,n in limits.items()):
        return answer(422,{'error':'Bitte gib deinen Namen, eine Telefonnummer oder E-Mail-Adresse und deine Nachricht an.'})
    with db() as c:c.execute('INSERT INTO messages(name,contact,message,pattern,head_cm,wishes,created_at) VALUES(?,?,?,?,?,?,?)',(*vals.values(),now()))
    return answer(200,{'ok':True})

def admin_shell(body,s):
    return f'''<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>Verwaltung | Bines Mützenparadies</title><link rel="stylesheet" href="/style.css?v={ASSET_VERSION}"></head><body><header class="admin-header wrap"><a href="/">← Website</a><strong>Verwaltung</strong>{'<form method="post" action="/admin/logout"><input type="hidden" name="csrf" value="'+esc(s['csrf'])+'"><button>Abmelden</button></form>' if s else ''}</header><main class="wrap admin-main">{body}</main></body></html>'''
def hidden_csrf(s):return f'<input type="hidden" name="csrf" value="{esc(s["csrf"])}">'
def contact_links(contact):
    """Telefonnummer oder E-Mail aus dem Formular direkt anklickbar machen."""
    contact=contact.strip()
    if '@' in contact: return f'<a href="mailto:{esc(contact)}">{esc(contact)}</a>'
    digits=re.sub(r'\D','',contact)
    if contact.startswith('+'): intl=digits
    elif digits.startswith('00'): intl=digits[2:]
    elif digits.startswith('0'): intl='49'+digits[1:]
    else: intl=digits
    if len(intl)<7: return esc(contact)
    return f'{esc(contact)} · <a href="https://wa.me/{intl}" target="_blank" rel="noopener noreferrer">per WhatsApp antworten</a> · <a href="tel:+{intl}">anrufen</a>'

def admin_home(s,query):
    with db() as c: open_count=c.execute('SELECT COUNT(*) FROM messages WHERE done=0').fetchone()[0]
    tab=query.get('tab',['nachrichten'])[0]
    tabs=[('nachrichten',f'Nachrichten ({open_count})' if open_count else 'Nachrichten'),('muster','Muster'),('startseite','Startseite'),('rechtliches','Impressum & Datenschutz')]
    nav='<nav class="filter-row">'+''.join(f'<a class="chip{" active" if t==tab else ""}" href="/admin?tab={t}">{label}</a>' for t,label in tabs)+'</nav>'
    with db() as c:
        if tab=='nachrichten':
            rows=c.execute('SELECT * FROM messages ORDER BY done, id DESC').fetchall()
            body='<h1>Nachrichten</h1><p>Hier landen alle Nachrichten aus dem Kontaktformular. Es wird keine E-Mail verschickt – schau also ab und zu hier rein. Nach 6 Monaten werden Nachrichten automatisch gelöscht.</p>'
            for r in rows:
                details=' · '.join(x for x in (f'Muster: {esc(r["pattern"])}' if r['pattern'] else '',f'Kopfumfang: {esc(r["head_cm"])} cm' if r['head_cm'] else '') if x)
                wishes=f'<p><strong>Wünsche:</strong> {esc(r["wishes"])}</p>' if r['wishes'] else ''
                body+=f'<article class="admin-item message-item{" is-done" if r["done"] else ""}"><h2>{esc(r["name"])} <small>{esc(r["created_at"][:16].replace("T"," "))} UTC{" · erledigt" if r["done"] else ""}</small></h2><p>{contact_links(r["contact"])}</p>{"<p>"+details+"</p>" if details else ""}{wishes}<p class="message">{esc(r["message"])}</p><form method="post" action="/admin/nachricht/{r["id"]}">{hidden_csrf(s)}<button class="btn btn-dark btn-small" name="done" value="{0 if r["done"] else 1}">{"Wieder öffnen" if r["done"] else "Als erledigt markieren"}</button><button class="btn btn-outline btn-small" name="delete" value="1" onclick="return confirm(\'Nachricht endgültig löschen?\')">Löschen</button></form></article>'
            if not rows: body+='<p>Noch keine Nachrichten.</p>'
        elif tab=='rechtliches':
            body='<h1>Impressum & Datenschutz</h1><p>So schreibst du: <code>## Überschrift</code> für eine Zwischenüberschrift, eine Leerzeile für einen neuen Absatz. Text in [eckigen Klammern] wird auf der Website gelb markiert – so siehst du, was noch fehlt. E-Mail-Adressen und Links werden automatisch anklickbar.</p>'
            for key,(title,_) in LEGAL.items():
                row=c.execute('SELECT * FROM legal WHERE key=?',(key,)).fetchone()
                body+=f'<form class="admin-form" method="post" action="/admin/rechtliches/{key}">{hidden_csrf(s)}<h2>{title}</h2><p class="field-help">Zuletzt geändert: {esc(row["updated_at"][:16].replace("T"," "))} UTC · <a href="/{key}" target="_blank">Seite ansehen</a></p><label class="visually-hidden" for="legal-{key}">{title}</label><textarea id="legal-{key}" name="content" rows="22" maxlength="40000" class="legal-editor">{esc(row["content"])}</textarea><button class="btn btn-coral" type="submit">{title} speichern</button></form>'
        elif tab=='startseite':
            body='<h1>Bilder der Startseite</h1><p>Solange hier kein Foto hinterlegt ist, zeigt die Startseite eine als Demo gekennzeichnete Illustration. Bitte nur eigene, echte Fotos verwenden. Bine wird nicht mit Gesicht gezeigt.</p>'
            for key,label in SITE_IMAGES.items():
                cur=c.execute('SELECT * FROM site_images WHERE key=?',(key,)).fetchone()
                preview=f'<div class="admin-photo"><img src="/uploads/{esc(cur["filename"])}" alt="{esc(cur["alt"])}"><p>Aktuelles Foto</p><label class="check"><input type="checkbox" name="remove" value="1"> Foto entfernen</label></div>' if cur else '<p>Derzeit: Demo-Illustration</p>'
                body+=f'<form class="admin-form" method="post" enctype="multipart/form-data" action="/admin/startseite/{key}">{hidden_csrf(s)}<h2>{esc(label)}</h2>{preview}<label>Neues Foto (JPEG, PNG, WebP) <input type="file" name="image" accept="image/jpeg,image/png,image/webp"></label><label>Bildbeschreibung (Alt-Text) <input name="alt" maxlength="180" value="{esc(cur["alt"] if cur else "")}" placeholder="z. B. Gehäkelte Froschmütze und Schneemannmütze auf einem Holzregal"></label><button class="btn btn-coral" type="submit">Speichern</button></form>'
        else:
            rows=c.execute('SELECT * FROM patterns ORDER BY id DESC').fetchall()
            body='<h1>Muster</h1><p>Ein Muster lässt sich veröffentlichen, sobald Bine es freigegeben hat und es ein echtes Foto hat. Die mitgelieferten Motive haben eine Illustration und können bis zum Foto damit online gehen.</p><p><a class="btn btn-coral" href="/admin/pattern/new">Neues Muster</a></p><div class="admin-list">'+''.join(f'<a href="/admin/pattern/{r["id"]}"><strong>{esc(r["name"])}</strong><span>{esc(r["status"])} · {esc(r["category"])}</span></a>' for r in rows)+'</div>'
    return admin_shell(nav+body,s)

def pattern_editor(s,p=None,error=''):
    with db() as c:
        ims=c.execute('SELECT * FROM images WHERE pattern_id=? ORDER BY position,id',(p['id'],)).fetchall() if p else []
    current=lambda key: p[key] if p else ''
    images=''.join(f'<div class="admin-photo"><img src="/uploads/{esc(i["filename"])}" alt="{esc(i["alt"])}"><label>Bildbeschreibung <input name="alt_{i["id"]}" value="{esc(i["alt"])}"></label><label>Reihenfolge <input type="number" name="pos_{i["id"]}" value="{i["position"]}"></label><label><input type="checkbox" name="remove_{i["id"]}" value="1"> Bild löschen</label></div>' for i in ims)
    return admin_shell(f'<p><a href="/admin">← Muster</a></p><h1>{"Muster bearbeiten" if p else "Neues Muster"}</h1><p class="error">{esc(error)}</p><form method="post" enctype="multipart/form-data" action="/admin/pattern/{p["id"] if p else "new"}" class="admin-form">{hidden_csrf(s)}<label>Name <input name="name" value="{esc(current("name"))}" required maxlength="120"></label><label>URL-Kürzel <input name="slug" value="{esc(current("slug"))}" placeholder="wird aus dem Namen erzeugt" pattern="[a-z0-9-]+"></label><label>Beschreibung <textarea name="description" rows="4" required>{esc(current("description"))}</textarea></label><label>Kategorie <input name="category" value="{esc(current("category"))}" list="category-list" required></label><datalist id="category-list">'+''.join(f'<option value="{x}"></option>' for x in ('Tiermützen','Lustige Motive','Wintermotive','Fantasiewelt','Monster & Co.','Weitere Ideen'))+f'</datalist><label>Freigegebener Preis in Euro (optional) <input type="number" step="0.01" min="0" name="price" value="{esc(current("price"))}"></label><label>Status <select name="status">'+''.join(f'<option value="{st}" {"selected" if current("status")==st else ""}>{st}</option>' for st in ('draft','published','archived'))+f'</select></label><label class="check"><input type="checkbox" name="featured" value="1" {"checked" if p and p["featured"] else ""}> Auf Startseite hervorheben</label><h2>Bilder</h2>{images}<label>Neue Produktbilder (JPEG, PNG, WebP; maximal 8 MB je Bild) <input type="file" name="images" accept="image/jpeg,image/png,image/webp" multiple></label><label>Bildbeschreibungen für neue Bilder <input name="new_alt" placeholder="z. B. Gehäkelte Froschmütze von vorn"></label><p>Vor Veröffentlichung nur echte Fotos freigegebener Muster hochladen.</p><button class="btn btn-coral" type="submit">Muster speichern</button></form>{f"<form method='post' action='/admin/pattern/{p['id']}/delete' onsubmit='return confirm(&quot;Muster endgültig löschen?&quot;)'>{hidden_csrf(s)}<button class='text-link'>Muster löschen</button></form>" if p else ""}',s)

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
    match=re.fullmatch(r'/admin/nachricht/(\d+)',path)
    if match:
        with db() as c:
            if f.get('delete')=='1':c.execute('DELETE FROM messages WHERE id=?',(match[1],))
            elif f.get('done') in ('0','1'):c.execute('UPDATE messages SET done=? WHERE id=?',(int(f['done']),match[1]))
        return redirect(start,'/admin?tab=nachrichten')
    match=re.fullmatch(r'/admin/rechtliches/(impressum|datenschutz)',path)
    if match:
        content=f.get('content','').replace('\r\n','\n').strip()
        if not content:return response(start,422,admin_shell('<h1>Der Text darf nicht leer sein.</h1><p><a href="/admin?tab=rechtliches">Zurück</a></p>',s))
        with db() as c:c.execute('UPDATE legal SET content=?,updated_at=? WHERE key=?',(content[:40000],now(),match[1]))
        return redirect(start,'/admin?tab=rechtliches')
    match=re.fullmatch(r'/admin/pattern/(new|\d+)',path)
    if match:
        ident=match[1];name=f.get('name','').strip()[:120];slug=clean_slug(f.get('slug','') or name);status=f.get('status','draft')
        if not name or not slug or status not in ('draft','published','archived'):return response(start,422,'Name, URL und Status prüfen')
        with db() as c:
            try:
                vals=(slug,name,f.get('description','').strip()[:3000],f.get('category','').strip()[:80],'[]','[]',f.get('price','').strip() or None,status,1 if f.get('featured') else 0)
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
            versioned=path.startswith('/fonts/') or (path in ('/style.css','/site.js') and parse_qs(env.get('QUERY_STRING','')).get('v',[''])[0]==ASSET_VERSION)
            cache='public, max-age=31536000, immutable' if versioned else 'no-cache'
            return response(start,200,p.read_bytes(),content_type=STATIC[p.suffix],cache=cache)
        if path=='/api/nachricht' and env.get('REQUEST_METHOD')=='POST':return contact_message(env,start)
        if path=='/wunschfarben':return response(start,301,'',[('Location','/wunschmotive')])
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
            desc='Entdecke außergewöhnliche Tiermützen und fantasievolle Häkelmützen. Wähle dein Lieblingsmuster, gib deinen Kopfumfang an oder frag dein eigenes Wunschmotiv an.' if path=='/' else 'Handgemachte Häkelmützen nach Kopfumfang und Wunschmotiv. Entdecke Muster und frag deine Lieblingsmütze unverbindlich an.'
            content=home() if path=='/' else catalogue(parse_qs(env.get('QUERY_STRING',''))) if path=='/muster' else simple_page(path)
            canonical=path
            graph=[{'@type':'Organization','@id':ORIGIN+'/#organisation','name':'Bines Mützenparadies','url':ORIGIN+'/','logo':ORIGIN+'/brand/logo-full.svg'},{'@type':'WebSite','@id':ORIGIN+'/#website','name':'Bines Mützenparadies','url':ORIGIN+'/','inLanguage':'de-DE','publisher':{'@id':ORIGIN+'/#organisation'}}]
            schema='<script type="application/ld+json">'+json.dumps({'@context':'https://schema.org','@graph':graph},ensure_ascii=False).replace('<','\\u003c')+'</script>' if path=='/' else ''
            return response(start,200,layout(PAGES[path][1],desc,content,canonical,schema=schema))
        m=re.fullmatch(r'/muster/([a-z0-9-]+)',path)
        if m:
            with db() as c:p=c.execute("SELECT * FROM patterns WHERE slug=? AND status='published'",(m[1],)).fetchone()
            if not p:return response(start,404,layout('Muster nicht gefunden','', '<div class="wrap legal"><h1>Muster nicht gefunden</h1><a href="/muster">Zur Übersicht</a></div>',path,robots='noindex'))
            return response(start,200,layout(f'{p["name"]} häkeln lassen | Bines Mützenparadies',excerpt(p['description']),detail(p),path))
        return response(start,404,layout('Seite nicht gefunden','', '<div class="wrap legal"><h1>Seite nicht gefunden</h1><a href="/">Zur Startseite</a></div>',path,robots='noindex'))
    except Exception as exc:
        import traceback;traceback.print_exc()
        return response(start,500,'Ein Fehler ist aufgetreten. Bitte versuche es später erneut.')

if __name__=='__main__':
    init()
    print('Bines Mützenparadies auf http://127.0.0.1:8000')
    make_server('127.0.0.1',8000,app).serve_forever()
