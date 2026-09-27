#!/usr/bin/env python3
"""Offline content/config validation. No third-party Python packages required."""
import argparse
import json
import math
import re
from pathlib import Path
from urllib.parse import urlparse
ROOT = Path(__file__).resolve().parents[1]
FILES = ['manifest','learning_objectives','questions','cards','exam_config','sources','practice','experience','revisions']
class PackError(ValueError): pass

def require(ok, path, message):
    if not ok: raise PackError(f'{path}: {message}')

def read(path):
    try:
        def pairs(items):
            result={}
            for k,v in items:
                require(k not in result,str(path),f'doppelter JSON-Schlüssel {k}')
                result[k]=v
            return result
        return json.loads(Path(path).read_text(),object_pairs_hook=pairs,parse_constant=lambda s: (_ for _ in ()).throw(PackError(f'{path}: {s} ist keine JSON-Zahl')))
    except (OSError,json.JSONDecodeError) as e: raise PackError(f'{path}: {e}') from e

def schema_check(value,schema,path):
    """Exact subset used by checked-in Draft 2020-12 schemas, all offline."""
    if 'anyOf' in schema:
        errors=[]
        for option in schema['anyOf']:
            try: schema_check(value,option,path); return
            except PackError as e: errors.append(str(e))
        raise PackError(errors[0])
    if 'const' in schema: require(value==schema['const'] and type(value)==type(schema['const']),path,'nicht unterstützte Formatversion')
    t=schema.get('type');types={'object':dict,'array':list,'string':str,'integer':int,'number':(int,float),'boolean':bool,'null':type(None)}
    if t: require(isinstance(value,types[t]) and not(t in ['integer','number'] and isinstance(value,bool)),path,f'Typ {t} erwartet')
    if 'enum' in schema: require(value in schema['enum'],path,f'unbekannter Wert {value!r}')
    if t=='object':
        for k in schema.get('required',[]): require(k in value,path,f'Pflichtfeld {k} fehlt')
        if schema.get('additionalProperties') is False: require(set(value)<=set(schema['properties']),path,f'unbekannte Felder {set(value)-set(schema["properties"])}')
        for k,v in value.items():
            if k in schema.get('properties',{}):schema_check(v,schema['properties'][k],f'{path}.{k}')
    if t=='array':
        require(len(value)>=schema.get('minItems',0) and len(value)<=schema.get('maxItems',100000),path,'ungültige Anzahl')
        if schema.get('uniqueItems'):require(len(set(json.dumps(v,sort_keys=True) for v in value))==len(value),path,'doppelte Einträge')
        for i,v in enumerate(value):schema_check(v,schema['items'],f'{path}[{i}]')
    if t=='string':
        require(len(value.strip())>=schema.get('minLength',0),path,'Pflichttext leer')
        if 'pattern' in schema:require(re.search(schema['pattern'],value) is not None,path,'ungültiges Format')
    if t in ['integer','number']:
        require(math.isfinite(value),path,'Zahl muss endlich sein')
        if 'minimum' in schema:require(value>=schema['minimum'],path,'Wert zu klein')
        if 'maximum' in schema:require(value<=schema['maximum'],path,'Wert zu groß')
        if 'exclusiveMinimum' in schema:require(value>schema['exclusiveMinimum'],path,'Wert muss positiv sein')

def unique(items,path,key='id'):
    ids=[x[key] for x in items];require(len(ids)==len(set(ids)),path,'doppelte IDs');return set(ids)

def quotas(exam):
    if exam['selection']=='random':return {}
    weights=exam['categoryWeights'];total=sum(x['weight'] for x in weights)
    values=[(x['categoryID'],exam['questionCount']*x['weight']/total) for x in weights]
    result={i:math.floor(n) for i,n in values}
    for i,n in sorted(values,key=lambda x:(-(x[1]-math.floor(x[1])),x[0]))[:exam['questionCount']-sum(result.values())]:result[i]+=1
    return result

def validate(pack_dir, config_path=None):
    pack_dir=Path(pack_dir); data={name:read(pack_dir/f'{name}.json') for name in FILES}
    for name,value in data.items():schema_check(value,read(ROOT/'Schemas'/f'{name}.schema.json'),name)
    m=data['manifest'];cats=unique(m['categories'],'manifest.categories');objs={x['id']:x for x in data['learning_objectives']}
    unique(data['learning_objectives'],'learning_objectives')
    for x in objs.values():require(x['categoryID'] in cats,x['id'],'Kategorie fehlt')
    unique(data['sources'],'sources');sources={(x['title'],x['url']) for x in data['sources']}
    for s in data['sources']:
        u=urlparse(s['url']);require(u.scheme=='https' and bool(u.hostname) and not u.username and not u.password,s['id'],'gültige HTTPS-Quelle erforderlich')
    qs=data['questions'];cards=data['cards'];p=data['practice'];items=qs+cards+p['cases']+p['oral'];unique(items,'content')
    for item in items:
        path=item['id']
        for source in item['sources']:require((source['title'],source['url']) in sources,path,'Quelle fehlt im Register')
        if item.get('field') is not None:require(item['field'] in cats,path,'Kategorie fehlt')
    for q in qs:
        require(q['competency'] in objs and objs[q['competency']]['categoryID']==q['field'],q['id'],'Lernziel fehlt oder falsche Kategorie')
        opts=unique(q['options'],q['id']+'.options');require(set(q['correctIDs'])<=opts,q['id'],'richtige Antwort nicht vorhanden')
        require(q['type']!='singleChoice' or len(q['correctIDs'])==1,q['id'],'Single Choice braucht eine Lösung')
    for c in cards:
        if c['competency'] is not None:require(c['competency'] in objs and objs[c['competency']]['categoryID']==c['field'],c['id'],'ungültiges Lernziel')
    for c in p['cases']:
        ids=unique(c['nodes'],c['id']+'.nodes');require(c['nodes'][0]['id']=='start',c['id'],'Startknoten fehlt')
        nodes={n['id']:n for n in c['nodes']}
        for n in c['nodes']:
            unique(n['choices'],c['id']+'.'+n['id'])
            for x in n['choices']:require(x['next'] is None or x['next'] in ids,c['id'],'Folgeknoten fehlt')
        def visit(n,seen):
            require(n not in seen,c['id'],'Zyklus im Fall')
            for x in nodes[n]['choices']:
                if x['next']:visit(x['next'],seen|{n})
        visit('start',set())
    if p['preparation']:
        form=p['preparation'];unique(form['fields'],'practice.preparation.fields')
        legacy={'occupation','situation','topic','objective','method','steps','conversationNotes'}
        for f in form['fields']:require(f['storage']!='legacy' or f['id'] in legacy,f['id'],'unbekanntes Altdatenfeld')
    required={'writtenExam':data['exam_config'],'flashcards':cards,'oralExam':p['oral'],'scenarioTraining':p['cases'],'practicePreparation':p['preparation']}
    for mod in m['modules']:require(bool(required[mod]),mod,'Modul enthält keine passenden Daten')
    exam=data['exam_config']
    if exam:
        unique(exam['categoryWeights'],'exam_config.categoryWeights','categoryID')
        require(all(x['categoryID'] in cats for x in exam['categoryWeights']),'exam_config','Gewichtung unbekannter Kategorie')
        require(bool(exam['categoryWeights'])==(exam['selection']=='weightedRandom'),'exam_config','Gewichte nur bei weightedRandom, dort erforderlich')
        def count(pool):return len({q['family'] for q in pool}) if exam['uniqueFamilies'] else len(pool)
        if exam['uniqueFamilies']:
            families={}
            for q in qs:
                require(q['family'] not in families or families[q['family']]==q['field'],q['id'],'Familie über mehrere Kategorien verteilt');families[q['family']]=q['field']
        if exam['selection']=='random':require(count(qs)>=exam['questionCount'],'exam_config','zu wenige Aufgaben oder Familien')
        for cat,n in quotas(exam).items():require(count([q for q in qs if q['field']==cat])>=n,'exam_config',f'Kategorie {cat} benötigt {n} Aufgabenfamilien')
    ids={x['id'] for x in qs+cards}
    for rev in data['revisions']:require(rev['contentID'] in ids,'revisions','Inhaltsreferenz fehlt')
    for name,entries in data['experience'].items():unique(entries,'experience.'+name)
    for impulse in data['experience']['impulses']:
        if impulse['source']:require(urlparse(impulse['source']['url']).scheme=='https',impulse['id'],'Zitatquelle ungültig')
    if config_path:
        config=read(config_path);schema_check(config,read(ROOT/'Schemas/app_config.schema.json'),'AppConfig')
        require(config['contentPackId']==m['packId'],'AppConfig.contentPackId','falsches Paket')
        for mod,on in config['featureFlags'].items():
            if on and mod not in ['tips','ratings']:require(mod in m['modules'],'AppConfig.featureFlags.'+mod,'Modul fehlt im Pack')
        require(len(config['tipProductIds'])==len(config['tipLabels']),'AppConfig.tipLabels','Anzahl passt nicht zu Produktkennungen')
        require(not config['featureFlags']['tips'] or bool(config['tipProductIds']),'AppConfig.tipProductIds','Trinkgeldprodukte fehlen')
        for key in ['privacyURL','imprintURL','supportURL']:
            u=urlparse(config[key]);require(not config[key] or (u.scheme=='https' and bool(u.hostname) and not u.username and not u.password),'AppConfig.'+key,'ungültige HTTPS-Adresse')
        require(not config['legacyMigration'] or bool(m['legacyBackupFormats']),'AppConfig.legacyMigration','kein Altdatenformat deklariert')
    return data

def main():
    parser=argparse.ArgumentParser();parser.add_argument('pack');parser.add_argument('--config');args=parser.parse_args()
    try:
        data=validate(args.pack,args.config);print(f"OK: {data['manifest']['packId']} · {len(data['questions'])} Aufgaben · {len(data['cards'])} Karten")
    except PackError as e:parser.exit(1,f'Fehler: {e}\n')
if __name__=='__main__':main()
