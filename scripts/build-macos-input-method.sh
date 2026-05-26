#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="UCL_LIU_SWIFT"
BUILD_DIR="$ROOT_DIR/.build/macos-input-method"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/macos/$APP_NAME/Info.plist" "$CONTENTS_DIR/Info.plist"

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

echo "$APP_DIR"
