#!/usr/bin/env bash
set -euo pipefail

APP_NAME="UCL_LIU_SWIFT"
DEST_APP="$HOME/Library/Input Methods/$APP_NAME.app"

killall "$APP_NAME" 2>/dev/null || true
rm -rf "$DEST_APP"

echo "Removed: $DEST_APP"
echo "User data is kept at: $HOME/Library/Application Support/UCL_LIU_SWIFT"
echo "Remove 肥米 from System Settings > Keyboard > Text Input if it is still listed."
