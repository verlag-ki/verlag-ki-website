"""Small integration check for the critical inquiry and publication flows."""
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

for page in ['/','/muster','/so-funktionierts','/groessenhilfe','/wunschfarben','/impressum','/datenschutz','/sitemap.xml']:
    assert request(page)['status'].startswith('200'),page
assert 'froschmuetze' not in request('/sitemap.xml')['body']
assert request('/muster/froschmuetze')['status'].startswith('404')
assert request('/api/inquiry','POST',{'name':'A','email':'invalid','subject':'Hallo','message':'Test'})['status'].startswith('422')
valid={'name':'Ada','email':'ada@example.org','subject':'Frage','message':'Hallo Biene','pattern':'','size':'','head_cm':'','color':'','wishes':''}
submitted=request('/api/inquiry','POST',valid)
assert submitted['status'].startswith('200') and '"mail_sent": false' in submitted['body']
assert app.db().execute('SELECT name FROM inquiries').fetchone()['name']=='Ada'
login=request('/admin/login','POST',{'password':'test-password'})
assert login['status'].startswith('303')
cookie=login['headers']['Set-Cookie'].split(';')[0]
assert request('/admin',cookie=cookie)['status'].startswith('200')
csrf=app.session({'HTTP_COOKIE':cookie})['csrf']
assert request('/admin/groessen/new','POST',{'csrf':csrf,'name':'Kind','min_cm':'50','max_cm':'54'},cookie)['status'].startswith('303')
assert request('/admin/farben/new','POST',{'csrf':csrf,'name':'Grün','hex':'#39803A'},cookie)['status'].startswith('303')
pattern={'csrf':csrf,'name':'Echte Froschmütze','slug':'echte-froschmuetze','description':'Echte gehäkelte Mütze mit Froschmotiv.','category':'Tiermützen','sizes':'Kind','colors':'Grün','status':'published','featured':'1'}
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
order=['Hier gibt’s was','Muster entdecken','Beliebte Muster','Alle Muster ansehen','<h3>So funktioniert’s','Die richtige Größe','Deine Wunschfarbe','Mit Liebe gehäkelt.','Schon eine Lieblingsmütze entdeckt?','Jetzt unverbindlich anfragen']
positions=[home.index(t,home.index('<main')) for t in order]
assert positions==sorted(positions), 'Abschnittsreihenfolge der Startseite'
assert 'Demo-Bild · KI-generiert' in home and 'Bienes Mützenparadies | Lustige Häkelmützen nach Wunsch' in home
assert home.count('data-contact')>=4 and 'wa.me/4915734487082' in home and '"@type": "WebSite"' in home
for asset in ['/style.css','/site.js','/favicon.svg','/brand/bee-mark.svg','/img/demo-hero.svg','/img/ki-hero.webp','/img/bee-flight.svg','/fonts/figtree-latin-wght-normal.woff2']:
    assert request(asset)['status'].startswith('200'),asset
assert request('/fonts/../app.py')['status'].startswith('404')
# Startseitenfoto über die Verwaltung austauschen
buf=io.BytesIO();Image.new('RGB',(800,870),'#e4d6c1').save(buf,'JPEG')
parts=[f'--{boundary}\r\nContent-Disposition: form-data; name="csrf"\r\n\r\n{csrf}\r\n'.encode(),f'--{boundary}\r\nContent-Disposition: form-data; name="alt"\r\n\r\nDrei gehäkelte Mützen auf einem Regal\r\n'.encode(),f'--{boundary}\r\nContent-Disposition: form-data; name="image"; filename="hero.jpg"\r\nContent-Type: image/jpeg\r\n\r\n'.encode()+buf.getvalue()+b'\r\n',f'--{boundary}--\r\n'.encode()]
assert request('/admin/startseite/hero','POST',b''.join(parts),cookie,f'multipart/form-data; boundary={boundary}')['status'].startswith('303')
home=request('/')['body']
assert 'Drei gehäkelte Mützen auf einem Regal' in home and 'ki-hero.webp' not in home
# Veröffentlichtes Muster erscheint mit Link auf der Startseite
assert '/muster/echte-froschmuetze' in home
detail=request('/muster/echte-froschmuetze')['body']
assert 'Preis auf Anfrage' in detail and 'type="radio" name="color" value="Grün"' in detail and 'Unverbindlich anfragen' in detail
print('OK: homepage structure, static assets, homepage photo upload, public routes, hidden demos, validation, inquiry storage, admin auth, size/color edit, image gate, publication and sitemap')
