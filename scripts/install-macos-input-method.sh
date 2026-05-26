#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="UCL_LIU_SWIFT"
APP_DIR="${1:-$ROOT_DIR/.build/macos-input-method/$APP_NAME.app}"
DEST_DIR="$HOME/Library/Input Methods"
DEST_APP="$DEST_DIR/$APP_NAME.app"
ENTITLEMENTS_FILE="$ROOT_DIR/macos/$APP_NAME/UCL_LIU_SWIFT.entitlements"

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

if command -v codesign >/dev/null 2>&1; then
    if ! codesign --force --deep --sign - --entitlements "$ENTITLEMENTS_FILE" "$DEST_APP"; then
        echo "Warning: ad-hoc code signing failed; macOS may not list the input method." >&2
    fi
fi

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [[ -x "$LSREGISTER" ]]; then
    "$LSREGISTER" -f "$DEST_APP" 2>/dev/null || true
fi

"$DEST_APP/Contents/MacOS/$APP_NAME" install || {
    echo "Warning: input source registration failed. Try logging out and back in, then add the input source manually."
}

echo "Installed: $DEST_APP"
echo "Now open System Settings > Keyboard > Text Input > Edit > Add Input Source."
echo "If UCL_LIU_SWIFT does not appear, press Shift+Command+Q to log out, then log back in."
