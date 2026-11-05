# Handoff

Updated: 2026-11-05 07:55 EAT, commit (see git log), session launch-v1

## Goal

Ship Cleaning Mode: a macOS menu bar app with one job. It locks the keyboard
so you can wipe it clean. Open source (MIT), public repo, site at
https://cleaning.mulualem.com (repo `../cleaning-mode-site`), launch kit for social.

## In flight

- main / launch-v1: app done (tests + CI green, e2e lock verified). Site v1 live.
  Waiting for launch video worker (`_/social/2026-11-05-launch*`). Next: copy
  readme-hero into docs/images, make repo public, `./scripts/release.sh --publish`,
  put demo.mp4 on the site and redeploy.

## Blocked / waiting

- Notarized builds need a Developer ID on the owner's paid team. Until then the
  release is ad hoc signed and users click "Open Anyway" once.
- GitHub social preview must be uploaded by hand: `_/social/2026-11-05-launch/og-1200x630.png`.

## Decisions (last 2 weeks)

- 2026-11-05: Menu-bar-only (LSUIElement), no main window. Popover = MenuBarExtra `.window` style.
- 2026-11-05: App Sandbox off (event taps that drop events need it), hardened runtime on, macOS 14+.
- 2026-11-05: Lock always has a timer (30 s to 5 min). No "until I say stop" mode: safety.
- 2026-11-05: Caps Lock state restored at unlock via IOHIDSetModifierLockState.
- 2026-11-05: Bundle ID com.mulualem.cleaning-mode, product name "Cleaning Mode", module cleaning_mode.
- 2026-11-05: UI-test template target deleted. Unit tests drive `KeyboardLock.handle()` with real CGEvents.
- 2026-11-05: CI: GitHub Actions `macos-26` runs the tests on every push.
- 2026-11-05: E2E check: launch the built binary from a shell (inherits the terminal's
  Accessibility trust), drive it with `_/social/2026-11-05-launch/raw/e2e.sh` + `keys`/`click`.
  The owner's menu bar manager hides new items: click the « chevron first.

## Next

- Owner check: install the release, grant Accessibility, wipe the keyboard once for real
  (incl. Caps Lock, volume and brightness keys, Touch ID key not pressed).
- Owner: Developer ID + notarize step in `scripts/release.sh`.
- Owner: post the launch kit (`_/campaign/launch-campaign.md`, `_/social/*/post.md`).

## Do not touch

- none
