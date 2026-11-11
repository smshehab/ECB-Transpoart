#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
rm -rf android ios web
flutter create --platforms=android,ios,web --org com.ecbtransport .
cp tool/templates/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
cp tool/templates/Info.plist ios/Runner/Info.plist
cp tool/templates/index.html web/index.html
