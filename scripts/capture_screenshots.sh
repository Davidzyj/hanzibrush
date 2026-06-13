#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="$ROOT/build/DerivedDataScreenshots"
SCREENSHOT_DIR="$ROOT/screenshots/iphone-17-pro-max/en"
PREVIEW_DIR="$ROOT/build/screenshot-previews"
SCHEME="HanziBrush"
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2'
BUNDLE_ID="com.zhouyajie.hanzibrush"
DEVICE_NAME="iPhone 17 Pro Max"
PYTHON_BIN="${PYTHON_BIN:-/Users/xxq/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3}"

mkdir -p "$SCREENSHOT_DIR" "$PREVIEW_DIR"

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

DEVICE_ID="$(xcrun simctl list devices available | awk -F '[()]' -v name="$DEVICE_NAME" '$0 ~ name && /Shutdown|Booted/ {print $2; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "$DEVICE_NAME simulator not found" >&2
  exit 1
fi

xcrun simctl boot "$DEVICE_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE_ID" -b >/dev/null
xcrun simctl status_bar "$DEVICE_ID" override --time 9:41 --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100 >/dev/null || true
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

capture_tab() {
  local tab="$1"
  local name="$2"
  local out="$SCREENSHOT_DIR/$name.png"
  xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$BUNDLE_ID" --screenshot-demo-data --screenshot-tab "$tab" >/dev/null
  sleep 1.5

  for _ in {1..12}; do
    sleep 0.5
    xcrun simctl io "$DEVICE_ID" screenshot "$out" >/dev/null
    if "$PYTHON_BIN" "$ROOT/scripts/validate_screenshot.py" "$out" "$name" >/dev/null; then
      "$PYTHON_BIN" "$ROOT/scripts/validate_screenshot.py" "$out" "$name"
      return 0
    fi
  done

  echo "Failed to capture ready screenshot for $name" >&2
  "$PYTHON_BIN" "$ROOT/scripts/validate_screenshot.py" "$out" "$name" || true
  return 1
}

capture_tab today "01-today"
capture_tab practice "02-practice"
capture_tab artworks "03-artworks"
capture_tab library "04-library"
capture_tab settings "05-settings"

"$PYTHON_BIN" "$ROOT/scripts/make_contact_sheet.py" "$SCREENSHOT_DIR" "$PREVIEW_DIR/contact-sheet.jpg"

echo "Generated screenshots in $SCREENSHOT_DIR"
echo "Generated contact sheet: $PREVIEW_DIR/contact-sheet.jpg"
