#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking Release configuration..."
xcodebuild \
  -project "$ROOT/HanziBrush.xcodeproj" \
  -scheme HanziBrush \
  -configuration Release \
  -showBuildSettings >/tmp/hanzibrush-release-settings.txt

if grep -q "SWIFT_ACTIVE_COMPILATION_CONDITIONS.*DEBUG" /tmp/hanzibrush-release-settings.txt; then
  echo "Release build unexpectedly contains DEBUG compilation condition." >&2
  exit 1
fi

echo "Checking screenshot demo data isolation..."
if grep -R --line-number --fixed-strings -- "--screenshot-demo-data" "$ROOT/HanziBrush/App" | grep -v "AppStore.swift"; then
  echo "Screenshot argument is referenced outside AppLaunchConfiguration." >&2
  exit 1
fi

if ! grep -q "#if DEBUG" "$ROOT/HanziBrush/App/AppStore.swift"; then
  echo "DEBUG guard for screenshot demo data missing." >&2
  exit 1
fi

echo "Checking no obvious active network code in Swift app source..."
if grep -R --line-number -E "URLSession|dataTask|NWConnection|URLRequest|AsyncImage" "$ROOT/HanziBrush/App" --include '*.swift'; then
  echo "Potential active network code found. Review before release." >&2
  exit 1
fi

echo "Preflight release check passed."
