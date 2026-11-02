#!/usr/bin/env bash
# Package dist/CloudMacDemo.app into a compressed, internet-enabled-style DMG.
set -euo pipefail

APP_DIR="dist/CloudMacDemo.app"
DMG="dist/CloudMacDemo.dmg"

if [[ ! -d "${APP_DIR}" ]]; then
  echo "error: ${APP_DIR} missing - run Scripts/make-app.sh first" >&2
  exit 1
fi

STAGE="$(mktemp -d)"
trap 'rm -rf "${STAGE}"' EXIT
cp -R "${APP_DIR}" "${STAGE}/"

hdiutil create -volname "Cloud Mac Demo" -srcfolder "${STAGE}" -ov -format UDZO "${DMG}"
echo "OK: ${DMG}"
