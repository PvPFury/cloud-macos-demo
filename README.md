# Cloud Mac Demo

A tiny SwiftUI macOS app that exists to prove one thing: **you can build and
ship native macOS apps from a Windows PC, for free, using GitHub Actions.**

Every push to `main` runs `.github/workflows/macos-build.yml`, which:

1. boots a real Apple Silicon Mac (`macos-latest`, 3-core M1 + Xcode) in the cloud,
2. compiles the app with `swift build -c release`,
3. assembles a proper `.app` bundle (`Scripts/make-app.sh`) and signs it,
4. packages it into `CloudMacDemo.dmg` (`Scripts/make-dmg.sh`),
5. uploads the DMG as a workflow artifact.

## Get the app

1. Open the repo on GitHub → **Actions** → **macOS build** → latest green run.
2. Download the `CloudMacDemo-macos` artifact at the bottom of the run page.
3. On your Mac: unzip, open the DMG, drag **Cloud Mac Demo** to Applications.

> Ad-hoc signed by default — fine for your own Macs. To distribute to other
> Macs without Gatekeeper warnings, add Developer ID secrets (below).

## Build locally (on a Mac)

```sh
swift build -c release
bash Scripts/make-app.sh
bash Scripts/make-dmg.sh   # dist/CloudMacDemo.dmg
```

## Enable real code signing + notarization (optional)

Repo → **Settings → Secrets and variables → Actions**, add:

| Secret | Value |
|---|---|
| `MACOS_P12_BASE64` | Your **Developer ID Application** certificate exported as `.p12`, then `base64 -i cert.p12` |
| `MACOS_CERT_PASSWORD` | The password used when exporting the `.p12` |

Requires an [Apple Developer Program](https://developer.apple.com/programs/)
membership ($99/yr). The workflow then signs with `--options runtime
--timestamp` instead of ad-hoc. Notarization can be added later as a follow-up
step (`xcrun notarytool submit ... --wait` + `xcrun stapler staple`).

## Cost

- **Public repo: $0** — GitHub-hosted macOS runners are free and unlimited.
- Private repo: drawn from your 2,000 free included minutes (~190 macOS min/month).
