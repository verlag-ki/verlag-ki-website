"""Integrationsprüfung: öffentliche Seiten, WhatsApp-Anfrage, Verwaltung und Veröffentlichung."""
import hashlib
import io
import os
import secrets
import sys
import tempfile
from urllib.parse import urlencode

from PIL import Image

os.environ['DATA_DIR'] = tempfile.mkdtemp(prefix='biene-check-')
os.environ['SITE_ORIGIN'] = 'http://localhost:8000'
os.environ['SECRET_KEY'] = secrets.token_hex(32)
salt = secrets.token_bytes(16)
os.environ['ADMIN_PASSWORD_HASH'] = 'pbkdf2$' + salt.hex() + '$' + hashlib.pbkdf2_hmac('sha256',b'test-password',salt,310000).hex()
import app

def request(path, method='GET', data=None, cookie='', content_type='application/x-www-form-urlencoded'):
    raw = urlencode(data).encode() if isinstance(data,dict) else data or b''
    result = {}
    def start(status,headers): result.update(status=status,headers=dict(headers))
    env={'PATH_INFO':path,'REQUEST_METHOD':method,'QUERY_STRING':'','CONTENT_LENGTH':str(len(raw)),'CONTENT_TYPE':content_type,'wsgi.input':io.BytesIO(raw),'HTTP_COOKIE':cookie,'HTTP_ORIGIN':'http://localhost:8000','REMOTE_ADDR':'127.0.0.1'}
    result['body']=b''.join(app.app(env,start)).decode(errors='replace')
    return result

for page in ['/','/muster','/so-funktionierts','/groessenhilfe','/wunschmotive','/impressum','/datenschutz','/sitemap.xml']:
    assert request(page)['status'].startswith('200'),page
assert 'froschmuetze' not in request('/sitemap.xml')['body']
assert request('/muster/froschmuetze')['status'].startswith('404')
# Alte Adresse leitet weiter, keine Größen oder Farben mehr
wf=request('/wunschfarben')
assert wf['status'].startswith('301') and wf['headers']['Location']=='/wunschmotive'
for page in ['/','/muster','/wunschmotive','/so-funktionierts','/groessenhilfe']:
    assert 'farbe' not in request(page)['body'].lower(), f'Farbe noch erwähnt auf {page}'
assert 'Wunschmotiv' in request('/')['body']
import re as _re
for page in ['/','/muster','/wunschmotive','/so-funktionierts','/groessenhilfe','/impressum','/datenschutz']:
    assert not _re.search(r'\bBienes?\b',request(page)['body']), f'Noch „Biene“ auf {page}'
assert 'Schreib Bine!' in request('/')['body'] and '<title>Bines Mützenparadies' in request('/')['body']
# Kontaktfenster: WhatsApp und Kontaktformular
home=request('/')['body']
assert 'contact-form' in home and 'whatsapp-preview' in home and 'wa.me/4915734487082' in home
assert request('/api/nachricht','POST',{'name':'Ada','contact':'','message':'Hallo'})['status'].startswith('422'), 'Kontakt fehlt'
assert request('/api/nachricht','POST',{'name':'Ada','contact':'0151 2345678','message':'Hallo Bine','pattern':'Fritzi, der Frosch','head_cm':'52','wishes':'Mit Bommel'})['status'].startswith('200')
assert request('/api/nachricht','POST',{'name':'Bot','contact':'x@y.de','message':'Spam','website':'http://spam'})['status'].startswith('200')
assert app.db().execute('SELECT COUNT(*) FROM messages').fetchone()[0]==1, 'Honeypot darf nichts speichern'
# Rechtstexte: Standardtexte mit markierten offenen Stellen
imp=request('/impressum')['body']
assert 'Spreeallee 207' in imp and '§ 5 DDG' in imp and '§ 19 Abs. 1 UStG' in imp and 'href="mailto:info@mieten-macht-sinn.de"' in imp
assert '<mark class="todo">' not in imp and 'TMG' not in imp and 'ec.europa.eu/consumers/odr' not in imp, 'Impressum vollständig und aktuell'
# Unveränderte alte Vorlage wird beim Update ersetzt
import legal_defaults
with app.db() as c:c.execute("UPDATE legal SET content=? WHERE key='impressum'",(legal_defaults.PREVIOUS['impressum'][0],))
assert '§ 5 DDG' in request('/impressum')['body']
# Ohne Größen: nur Kopfumfang in cm
assert 'name="head_cm"' in request('/groessenhilfe')['body'] and 'Größenempfehlung' not in request('/groessenhilfe')['body']
assert 'data-wishes-label="Mein Wunschmotiv"' in request('/wunschmotive')['body']
# Hinter Nginx zählt die echte Besucheradresse, aber nur mit TRUST_PROXY=1
assert app.client_ip({'REMOTE_ADDR':'127.0.0.1','HTTP_X_REAL_IP':'203.0.113.9'})=='127.0.0.1'
os.environ['TRUST_PROXY']='1'
assert app.client_ip({'REMOTE_ADDR':'127.0.0.1','HTTP_X_REAL_IP':'203.0.113.9'})=='203.0.113.9'
del os.environ['TRUST_PROXY']
login=request('/admin/login','POST',{'password':'test-password'})
assert login['status'].startswith('303')
cookie=login['headers']['Set-Cookie'].split(';')[0]
inbox=request('/admin',cookie=cookie)
assert inbox['status'].startswith('200') and 'Nachrichten (1)' in inbox['body'] and 'wa.me/491512345678' in inbox['body'] and 'Mit Bommel' in inbox['body']
csrf=app.session({'HTTP_COOKIE':cookie})['csrf']
mid=app.db().execute('SELECT id FROM messages').fetchone()['id']
assert request(f'/admin/nachricht/{mid}','POST',{'csrf':csrf,'done':'1'},cookie)['status'].startswith('303')
assert app.db().execute('SELECT done FROM messages').fetchone()['done']==1
assert request(f'/admin/nachricht/{mid}','POST',{'csrf':csrf,'delete':'1'},cookie)['status'].startswith('303')
assert app.db().execute('SELECT COUNT(*) FROM messages').fetchone()[0]==0
# Impressum in der Verwaltung ändern
assert request('/admin/rechtliches/impressum','POST',{'csrf':csrf,'content':'## Angaben\nBine Test\nMusterweg 1\n\nMail: test@example.org'},cookie)['status'].startswith('303')
imp=request('/impressum')['body']
assert '<h2>Angaben</h2><p>Bine Test<br>Musterweg 1</p>' in imp and 'href="mailto:test@example.org"' in imp
assert request('/admin/rechtliches/impressum','POST',{'csrf':csrf,'content':'<script>alert(1)</script>'},cookie)['status'].startswith('303')
assert '<script>alert' not in request('/impressum')['body'], 'Rechtstexte werden nicht als HTML ausgeführt'
pattern={'csrf':csrf,'name':'Echte Froschmütze','slug':'echte-froschmuetze','description':'Echte gehäkelte Mütze mit Froschmotiv.','category':'Tiermützen','status':'published','featured':'1'}
assert request('/admin/pattern/new','POST',pattern,cookie)['status'].startswith('303')
assert request('/muster/echte-froschmuetze')['status'].startswith('404'), 'Bildlose Muster dürfen nicht online gehen'
# Check the successful image-assisted publication path with the same handler used by the admin.
pid=app.db().execute('SELECT id FROM patterns WHERE slug=?',('echte-froschmuetze',)).fetchone()['id']
im=Image.new('RGB',(600,700),'#39803a');buf=io.BytesIO();im.save(buf,'PNG')
filename='sample.png';boundary='----biene-boundary'
parts=[]
for key,value in pattern.items():
    parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{key}"\r\n\r\n{value}\r\n'.encode())
parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="new_alt"\r\n\r\nGehäkelte Froschmütze\r\n'.encode())
parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="images"; filename="{filename}"\r\nContent-Type: image/png\r\n\r\n'.encode()+buf.getvalue()+b'\r\n')
parts.append(f'--{boundary}--\r\n'.encode())
published=request(f'/admin/pattern/{pid}','POST',b''.join(parts),cookie,f'multipart/form-data; boundary={boundary}')
assert published['status'].startswith('303'), published['status']+' '+published['body'][:200]
assert request('/muster/echte-froschmuetze')['status'].startswith('200')
assert 'echte-froschmuetze' in request('/sitemap.xml')['body']
assert 'Gehäkelte Froschmütze' in request('/muster/echte-froschmuetze')['body']
# Startseite: verbindliche Texte, Reihenfolge und Demo-Kennzeichnung
home=request('/')['body']
order=['Hier gibt’s was','Muster entdecken','id="muster-title"','Alle Muster ansehen','<h3>So funktioniert’s','<h3>Kopfumfang messen','<h3>Dein Wunschmotiv','id="story-title"','Schon eine Lieblingsmütze entdeckt?','Jetzt unverbindlich anfragen']
positions=[home.index(t,home.index('<main')) for t in order]
assert positions==sorted(positions), 'Abschnittsreihenfolge der Startseite'
assert 'Demo-Illustration' in home and 'ki-hero.webp' not in home and 'Bines Mützenparadies | Lustige Häkelmützen nach Wunsch' in home
assert 'id="home-contact-form"' in home and home.index('id="home-contact-form"')>home.index('id="cta-title"'), 'Formular unten auf der Startseite'
assert f'/style.css?v={app.ASSET_VERSION}' in home and f'/site.js?v={app.ASSET_VERSION}' in home
css_res={}
def _s(st,h): css_res.update(st=st,h=dict(h))
env={'PATH_INFO':'/style.css','QUERY_STRING':'v='+app.ASSET_VERSION,'REQUEST_METHOD':'GET','wsgi.input':io.BytesIO(),'REMOTE_ADDR':'127.0.0.1'}
b''.join(app.app(env,_s)); assert 'immutable' in css_res['h']['Cache-Control']
env.update(QUERY_STRING='',wsgi_input=None); env['wsgi.input']=io.BytesIO()
b''.join(app.app(env,_s)); assert css_res['h']['Cache-Control']=='no-cache', 'Unversionierte Adresse nicht lange zwischenspeichern'
assert home.count('data-contact')>=4 and 'wa.me/4915734487082' in home and '"@type": "WebSite"' in home
for asset in ['/style.css','/site.js','/favicon.svg','/brand/bee-mark.svg','/img/demo-hero.svg','/img/ki-hero.webp','/img/bee-flight.svg','/fonts/figtree-latin-wght-normal.woff2']:
    assert request(asset)['status'].startswith('200'),asset
assert request('/fonts/../app.py')['status'].startswith('404')
# Startseitenfoto über die Verwaltung austauschen
buf=io.BytesIO();Image.new('RGB',(800,870),'#e4d6c1').save(buf,'JPEG')
parts=[f'--{boundary}\r\nContent-Disposition: form-data; name="csrf"\r\n\r\n{csrf}\r\n'.encode(),f'--{boundary}\r\nContent-Disposition: form-data; name="alt"\r\n\r\nDrei gehäkelte Mützen auf einem Regal\r\n'.encode(),f'--{boundary}\r\nContent-Disposition: form-data; name="image"; filename="hero.jpg"\r\nContent-Type: image/jpeg\r\n\r\n'.encode()+buf.getvalue()+b'\r\n',f'--{boundary}--\r\n'.encode()]
assert request('/admin/startseite/hero','POST',b''.join(parts),cookie,f'multipart/form-data; boundary={boundary}')['status'].startswith('303')
home=request('/')['body']
assert 'Drei gehäkelte Mützen auf einem Regal' in home and 'demo-hero.svg' not in home
# Veröffentlichtes Muster erscheint mit Link auf der Startseite
assert '/muster/echte-froschmuetze' in home
detail=request('/muster/echte-froschmuetze')['body']
assert 'Preis auf Anfrage' in detail and 'name="head_cm"' in detail and 'required' in detail and 'name="size"' not in detail and 'Unverbindlich anfragen' in detail
# Mitgeliefertes Motiv mit Illustration lässt sich ohne Foto veröffentlichen
fid=app.db().execute("SELECT id FROM patterns WHERE slug='froschmuetze'").fetchone()['id']
frog={'csrf':csrf,'name':'Fritzi, der Frosch','slug':'froschmuetze','description':'Ein lustiger grüner Frosch mit großen Augen.','category':'Tiermützen','status':'published'}
parts=[f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode() for k,v in frog.items()]+[f'--{boundary}--\r\n'.encode()]
assert request(f'/admin/pattern/{fid}','POST',b''.join(parts),cookie,f'multipart/form-data; boundary={boundary}')['status'].startswith('303')
frog_page=request('/muster/froschmuetze')
assert frog_page['status'].startswith('200') and 'Illustration · Foto folgt' in frog_page['body'] and 'demo-frosch.svg' in frog_page['body']
assert '/muster/froschmuetze' in request('/sitemap.xml')['body']
print('OK: homepage structure, WhatsApp and contact form, message inbox, editable legal pages, head circumference only, wish motifs, proxy address, static assets, homepage photo upload, public routes, hidden demos, admin auth, image gate, illustrated publication, publication and sitemap')
