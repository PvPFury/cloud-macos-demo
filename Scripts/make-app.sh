#!/usr/bin/env bash
# Assemble dist/CloudMacDemo.app from the SPM release build and sign it.
# Ad-hoc signed by default. To ship to other Macs, add repository secrets
# MACOS_P12_BASE64 and MACOS_CERT_PASSWORD (Developer ID Application cert).
set -euo pipefail

APP_NAME="CloudMacDemo"
BINARY=".build/release/${APP_NAME}"
APP_DIR="dist/${APP_NAME}.app"
TMP="${RUNNER_TEMP:-/tmp}"

if [[ ! -f "${BINARY}" ]]; then
  echo "error: ${BINARY} not found - run 'swift build -c release' first" >&2
  exit 1
fi

rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
cp "${BINARY}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"

cat > "${APP_DIR}/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>CloudMacDemo</string>
  <key>CFBundleDisplayName</key>
  <string>Cloud Mac Demo</string>
  <key>CFBundleIdentifier</key>
  <string>com.example.cloudmacdemo</string>
  <key>CFBundleExecutable</key>
  <string>CloudMacDemo</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

if [[ -n "${MACOS_P12_BASE64:-}" && -n "${MACOS_CERT_PASSWORD:-}" ]]; then
  echo "Signing with Developer ID certificate from repository secrets..."
  KEYCHAIN_PATH="${TMP}/signing.keychain-db"
  security create-keychain -p "" "${KEYCHAIN_PATH}" 2>/dev/null || true
  security set-keychain-settings -lut 21600 "${KEYCHAIN_PATH}"
  security unlock-keychain -p "" "${KEYCHAIN_PATH}"
  echo "${MACOS_P12_BASE64}" | base64 --decode > "${TMP}/cert.p12"
  security import "${TMP}/cert.p12" -k "${KEYCHAIN_PATH}" \
    -P "${MACOS_CERT_PASSWORD}" -T /usr/bin/codesign
  security set-key-partition-list -S apple-tool:,apple: -k "" "${KEYCHAIN_PATH}" >/dev/null
  security list-keychains -d user -s "${KEYCHAIN_PATH}" login.keychain-db
  codesign --force --options runtime --timestamp \
    --sign "Developer ID Application" "${APP_DIR}"
else
  echo "Signing ad-hoc (no MACOS_P12_BASE64 secret configured)..."
  codesign --force --deep --sign - "${APP_DIR}"
fi

codesign --verify --strict --verbose=2 "${APP_DIR}"
echo "OK: ${APP_DIR}"
