#!/bin/bash
# Builds a universal Release, signs it ad hoc, and zips it to dist/Cleaning-Mode.zip.
# With --publish, it also makes the GitHub release v<MARKETING_VERSION> and uploads the zip.
# Ad hoc because there is no Developer ID yet: users open it with "Open Anyway" once.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(xcodebuild -project cleaning-mode.xcodeproj -target cleaning-mode -showBuildSettings 2>/dev/null \
  | awk '$1 == "MARKETING_VERSION" { print $3 }')
app="build/release/Build/Products/Release/Cleaning Mode.app"

rm -rf build/release dist
xcodebuild -project cleaning-mode.xcodeproj -scheme cleaning-mode -configuration Release \
  -derivedDataPath build/release ONLY_ACTIVE_ARCH=NO CODE_SIGN_IDENTITY=- build -quiet
codesign --verify --strict "$app"
lipo -archs "$app/Contents/MacOS/Cleaning Mode"
mkdir dist
ditto -c -k --sequesterRsrc --keepParent "$app" dist/Cleaning-Mode.zip
shasum -a 256 dist/Cleaning-Mode.zip
echo "Built Cleaning Mode $version"

if [[ "${1:-}" == "--publish" ]]; then
  gh release create "v$version" dist/Cleaning-Mode.zip --title "Cleaning Mode $version" --notes-file docs/release-notes.md
fi
