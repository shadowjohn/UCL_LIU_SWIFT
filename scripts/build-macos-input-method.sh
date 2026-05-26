#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="UCL_LIU_SWIFT"
BUILD_DIR="$ROOT_DIR/.build/macos-input-method"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICON_FILE="$RESOURCES_DIR/UCL_LIU_SWIFT.png"
ICON_BASE64="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII="
ENTITLEMENTS_FILE="$ROOT_DIR/macos/$APP_NAME/UCL_LIU_SWIFT.entitlements"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/macos/$APP_NAME/Info.plist" "$CONTENTS_DIR/Info.plist"

if printf '' | base64 --decode >/dev/null 2>&1; then
    printf '%s' "$ICON_BASE64" | base64 --decode > "$ICON_FILE"
else
    printf '%s' "$ICON_BASE64" | base64 -D > "$ICON_FILE"
fi

if [[ -f "$ROOT_DIR/pinyi.txt" ]]; then
    cp "$ROOT_DIR/pinyi.txt" "$RESOURCES_DIR/pinyi.txt"
fi

swiftc \
    -O \
    -framework AppKit \
    -framework Carbon \
    -framework InputMethodKit \
    "$ROOT_DIR"/Sources/FeimiCore/*.swift \
    "$ROOT_DIR"/macos/$APP_NAME/*.swift \
    -o "$MACOS_DIR/$APP_NAME"

plutil -lint "$CONTENTS_DIR/Info.plist"

if command -v codesign >/dev/null 2>&1; then
    if ! codesign --force --deep --sign - --entitlements "$ENTITLEMENTS_FILE" "$APP_DIR"; then
        echo "Warning: ad-hoc code signing failed; macOS may not list the input method." >&2
    fi
fi

echo "$APP_DIR"
