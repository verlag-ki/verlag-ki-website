#!/bin/bash
set -euo pipefail
aevo_project_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$aevo_project_dir"
if [ "$(uname -s)" != "Darwin" ]; then
  echo "Dieser Schritt benötigt erst später den Mac mit Xcode. Die Kernprüfungen laufen separat mit swift test."
  exit 1
fi
python3 Scripts/validate_project.py
swift test
xcodebuild -project LearningApp.xcodeproj -scheme "$(python3 -c 'import json; print(json.load(open("Core/Resources/app-config.json"))["productName"])')" -configuration Debug \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
echo "Simulator-Build beendet. Jetzt LearningApp.xcodeproj öffnen und die Geräteprüfungen durchführen."
