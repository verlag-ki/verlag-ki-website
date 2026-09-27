#!/usr/bin/env python3
"""Generate an isolated app from the shared engine. Never mutates canonical source."""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from validate_content_pack import ROOT, PackError, read, require, validate
from create_project import main as create_project

COPIED=['App','Core','Scripts','Schemas','Tests','ContentPacks','AppConfigs','ContentInputs','Package.swift']

def safe_path(relative):
    p=(ROOT/relative).resolve()
    require(p.is_relative_to(ROOT),relative,'Pfad verlässt Projekt')
    require(p.exists(),relative,'Datei oder Ordner fehlt')
    require(not Path(relative).is_absolute(),relative,'relativer Pfad erforderlich')
    return p

def project_resources(destination,config,pack):
    resources=destination/'Core/Resources'
    shutil.rmtree(resources);resources.mkdir()
    shutil.copytree(pack,resources/'SelectedPack')
    (resources/'app-config.json').write_text(json.dumps(config,ensure_ascii=False,indent=2)+'\n')
    legal=read(safe_path(config['legalFile']))
    legal['privacyURL']=config['privacyURL'];legal['supportURL']=config['supportURL']
    # Contact routing comes from config; operator data must be reviewed for each new app.
    require(legal['operatorInfo']['email']==config['supportEmail'],'legal.operatorInfo.email','muss zur Supportadresse passen')
    (resources/'legal.json').write_text(json.dumps(legal,ensure_ascii=False,indent=2)+'\n')
    icon=safe_path(config['iconAssetPath']);require(icon.is_dir(),str(icon),'AppIcon.appiconset erwartet')
    contents=read(icon/'Contents.json')
    for image in contents.get('images',[]):
        if image.get('filename'):
            f=(icon/image['filename']).resolve();require(f.is_relative_to(icon.resolve()) and f.is_file(),str(icon),'Icon-Datei fehlt oder ungültiger Pfad')
    target=destination/'App/Assets.xcassets/AppIcon.appiconset'
    shutil.rmtree(target,ignore_errors=True);shutil.copytree(icon,target)
    shutil.copy(safe_path(config['storeMetadataPath']),destination/'StoreMetadata.json')
    (destination/'Configuration').mkdir(exist_ok=True)
    create_project(destination)

def swift_path(supplied=None):
    value=supplied or os.environ.get('LEARNING_SWIFT') or shutil.which('swift')
    require(value and Path(value).is_file(),'Swift','Toolchain fehlt. Swift installieren oder --swift /Pfad/zu/swift angeben.')
    return os.path.abspath(value)

def generate(config_path, output=None, swift=None, build_ios=False):
    config=read(config_path);pack=safe_path('ContentPacks/'+config.get('contentPackId',''))
    validate(pack,config_path)
    compiler=swift_path(swift)
    # Validate all optional assets before producing output.
    for key in ['legalFile','iconAssetPath','storeMetadataPath']:safe_path(config[key])
    target=Path(output).resolve() if output else ROOT/'Generated'/config['appId']
    require(not target.exists(),str(target),'Ziel existiert bereits. Einen neuen --output-Pfad verwenden; vorhandene Arbeit wird nicht überschrieben.')
    require(not ROOT.is_relative_to(target),str(target),'Ziel darf kein übergeordneter Projektpfad sein')
    target.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.learning-build-',dir=target.parent) as temporary:
        stage=Path(temporary)/'project';stage.mkdir()
        for name in COPIED:
            src=ROOT/name;dest=stage/name
            if src.is_dir():shutil.copytree(src,dest,ignore=shutil.ignore_patterns('.build','__pycache__','*.pyc','xcuserdata'))
            else:shutil.copy(src,dest)
        project_resources(stage,config,pack)
        # Every generated app must exercise the actual selected resources with Swift.
        log=stage/'GenerationTests.log'
        with log.open('w') as stream:
            result=subprocess.run([compiler,'test','--filter','RuntimePackTests'],cwd=stage,stdout=stream,stderr=subprocess.STDOUT)
        require(result.returncode==0,'Swift-Tests',log.read_text()[-5000:])
        if build_ios:
            require(sys.platform=='darwin' and shutil.which('xcodebuild'),'Xcode','--build-ios benötigt einen Mac mit Xcode')
            subprocess.run(['xcodebuild','-project','LearningApp.xcodeproj','-scheme',config['productName'],'-configuration','Debug','-sdk','iphonesimulator','-destination','generic/platform=iOS Simulator','CODE_SIGNING_ALLOWED=NO','build'],cwd=stage,check=True)
        # Build caches contain absolute staging paths and do not belong in the deliverable.
        shutil.rmtree(stage/'.build',ignore_errors=True)
        for cache in stage.rglob('__pycache__'):shutil.rmtree(cache)
        report={'appId':config['appId'],'contentPackId':config['contentPackId'],'engineVersion':'0.5.0','runtimeTests':'passed','nativeBuildVerified':build_ios,'configSHA256':hashlib.sha256(Path(config_path).read_bytes()).hexdigest()}
        (stage/'GenerationReport.json').write_text(json.dumps(report,indent=2)+'\n')
        stage.rename(target)
    print(f'Fertig: {target}/LearningApp.xcodeproj · Scheme {config["productName"]}')
    return target

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--config',required=True);p.add_argument('--output');p.add_argument('--swift');p.add_argument('--build-ios',action='store_true');a=p.parse_args()
    try:generate(Path(a.config),a.output,a.swift,a.build_ios)
    except (PackError,OSError,subprocess.CalledProcessError) as e:p.exit(1,f'Fehler: {e}\n')
if __name__=='__main__':main()
