#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="UCL_LIU_SWIFT"
APP_DIR="${1:-$ROOT_DIR/.build/macos-input-method/$APP_NAME.app}"
DEST_DIR="$HOME/Library/Input Methods"
DEST_APP="$DEST_DIR/$APP_NAME.app"

if [[ ! -d "$APP_DIR" ]]; then
    "$ROOT_DIR/scripts/build-macos-input-method.sh"
fi

killall "$APP_NAME" 2>/dev/null || true
rm -rf "$DEST_APP"
mkdir -p "$DEST_DIR"
cp -R "$APP_DIR" "$DEST_APP"

if command -v xattr >/dev/null 2>&1; then
    xattr -dr com.apple.quarantine "$DEST_APP" 2>/dev/null || true
fi

echo "Installed: $DEST_APP"
echo "Now open System Settings > Keyboard > Text Input > Edit > Add Input Source."
echo "If UCL_LIU_SWIFT does not appear, log out and log back in."
