#!/usr/bin/env python3
"""Check the selected app without assuming a specific subject or catalog size."""
import json
import plistlib
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from validate_content_pack import validate, read
ROOT=Path(__file__).resolve().parents[1]
def main():
    config=read(ROOT/'Core/Resources/app-config.json')
    pack=validate(ROOT/'Core/Resources/SelectedPack',ROOT/'Core/Resources/app-config.json')
    info=plistlib.loads((ROOT/'Configuration/Info.plist').read_bytes())
    assert info['CFBundleDisplayName']==config['appName']
    assert ('NSMicrophoneUsageDescription' in info)==config['featureFlags']['oralExam']
    project=(ROOT/'LearningApp.xcodeproj/project.pbxproj').read_text()
    assert config['bundleIdentifier'] in project
    for swift in (ROOT/'App').glob('*.swift'):assert swift.relative_to(ROOT).as_posix() in project
    for path in re.findall(r'"path" = "([^"$]+)";',project):
        if not path.endswith('.app'):assert (ROOT/path).exists(),path
    scheme=ET.parse(ROOT/'LearningApp.xcodeproj/xcshareddata/xcschemes'/f'{config["productName"]}.xcscheme')
    assert scheme.find('LaunchAction').attrib['buildConfiguration']=='Debug'
    for ref in scheme.findall('.//BuildableReference'):assert ref.attrib['BlueprintIdentifier'] in project
    store=read(ROOT/'Configuration/Tips.storekit')
    assert [x['productID'] for x in store['products']]==config['tipProductIds']
    assert all(x['type']=='Consumable' for x in store['products'])
    print(json.dumps({'status':'passed','pack':config['contentPackId'],'questions':len(pack['questions']),'cards':len(pack['cards']),'categories':len(pack['manifest']['categories']),'native_build_verified':False},indent=2))
if __name__=='__main__':main()
