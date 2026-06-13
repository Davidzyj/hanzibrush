#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="$ROOT/build/DerivedData"
SCREENSHOT_DIR="$ROOT/screenshots"
SCHEME="HanziBrush"
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2'

mkdir -p "$SCREENSHOT_DIR"

xcodebuild \
  -project "$ROOT/HanziBrush.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_PATH="$(find "$DERIVED_DATA/Build/Products/Debug-iphonesimulator" -name 'HanziBrush.app' -maxdepth 2 -print -quit)"
if [[ -z "$APP_PATH" ]]; then
  echo "HanziBrush.app not found" >&2
  exit 1
fi

DEVICE_ID="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone 17 Pro Max/ && /Shutdown|Booted/ {print $2; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "iPhone 17 Pro Max simulator not found" >&2
  exit 1
fi

xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
xcrun simctl launch --terminate-running-process "$DEVICE_ID" com.zhouyajie.hanzibrush --screenshot-demo-data

echo "App launched with DEBUG-only screenshot demo data."
echo "Manual screenshot capture can now be performed into $SCREENSHOT_DIR."
