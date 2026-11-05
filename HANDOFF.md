# Handoff

Updated: 2026-11-05 22:33 EAT, commit (see git log), session launch-posts

## Goal

Ship Cleaning Mode: a macOS menu bar app with one job. It locks the keyboard
so you can wipe it clean. Open source (MIT), public repo, site at
https://cleaning.mulualem.com (repo `../cleaning-mode-site`), launch kit for social.

## In flight

- main / launch-posts: all 8 posts are filled and ready in Chrome (X thread, YouTube Short,
  TikTok, Instagram Reel, LinkedIn, Threads, Bluesky, Mastodon). The owner presses Post in
  each tab. After the owner says "posted": post the LinkedIn link comment (text in
  `_/social/2026-11-05-launch-video/post.md`), then set the `log` status in
  `~/.claude/social-post/accounts.json`.

## Blocked / waiting

- GitHub social preview (Settings > Social preview): `_/social/2026-11-05-launch/og-1200x630.png`
  (1200x630, 119 KB). Not set yet (`usesCustomOpenGraphImage` false). It changes a public page,
  so it waits for the owner's yes. No API for it; the Chrome extension can do it.
- Notarized builds need a "Developer ID Application" certificate on the owner's paid team.
  The keychain has none (2026-11-05). Do not use the "Apple Distribution: Neil Bisht" identity
  that is there. Until then the release is ad hoc signed and users click "Open Anyway" once.

## Decisions (last 2 weeks)

- 2026-11-05: Menu-bar-only (LSUIElement), no main window. Popover = MenuBarExtra `.window` style.
- 2026-11-05: App Sandbox off (event taps that drop events need it), hardened runtime on, macOS 14+.
- 2026-11-05: Lock always has a timer (30 s to 5 min). No "until I say stop" mode: safety.
- 2026-11-05: Caps Lock state restored at unlock via IOHIDSetModifierLockState.
- 2026-11-05: Bundle ID com.mulualem.cleaning-mode, product name "Cleaning Mode", module cleaning_mode.
- 2026-11-05: Unit tests drive `KeyboardLock.handle()` with real CGEvents. CI: GitHub Actions `macos-26`.
- 2026-11-05: v1.0.0 released by the owner (Cleaning-Mode.zip, download link 200).
  Checked 2026-11-05: SHA-256 matches GitHub, universal (x86_64, arm64), version 1.0.0, macOS 14.0,
  ad hoc signature valid, CI green on d563adc.
- 2026-11-05: Launch audio remixed: 3 soft low-passed whooshes instead of 6 hissy ones
  (`_/social/2026-11-05-launch-video/raw/audio.py`). Owner approved the video.
  Evidence: `_/shots/2026-11-05-2150-launch-audio/cmp-whoosh-spectrum.png`.
- 2026-11-05: Do not claim "first" or "only": Cleanable (github.com/lerodic/Cleanable) is
  also an open-source Mac keyboard-cleaning app.
- 2026-11-05: E2E: launch the built binary from a shell (inherits Accessibility trust),
  drive it with `_/social/2026-11-05-launch/raw/e2e.sh`. Click the « chevron first.

## Next

- Reddit r/macapps and Show HN: by hand (the extension blocks reddit.com). Text in
  `_/campaign/launch-campaign.md`.
- Owner check: one real wipe (Caps Lock, volume and brightness keys; not the Touch ID key).
- Owner: Developer ID + notarize step in `scripts/release.sh`, then Product Hunt.

## Do not touch

- none
