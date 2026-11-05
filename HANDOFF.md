# Handoff

Updated: 2026-11-05 22:20 EAT, commit (see git log), session launch-v1

## Goal

Ship Cleaning Mode: a macOS menu bar app with one job. It locks the keyboard
so you can wipe it clean. Open source (MIT), public repo, site at
https://cleaning.mulualem.com (repo `../cleaning-mode-site`), launch kit for social.

## In flight

- main / launch-v1: social posts. The owner said "go" for the drafts in
  `_/social/2026-11-05-launch-video/post.md` ("Ready-to-post drafts").
  Next: load the `social-post` skill, then the `claude-in-chrome` skill. Upload the
  GitHub social preview, then fill one tab per platform (X, YouTube Short, TikTok,
  Instagram Reel, LinkedIn, Threads, Bluesky, Mastodon). The owner presses Post.
  Files: `_/social/2026-11-05-launch-video/upload/video-16x9|9x16|1x1.mp4` (2-3 MB each,
  15.5 s, audio; under 9 MB, so one file_upload per tab, no parts).
  Platform map: X/Bluesky/Mastodon 16x9; YouTube Short/TikTok/Instagram/Threads 9x16;
  LinkedIn 1x1 (link goes in the first comment after the owner says "posted").

## Blocked / waiting

- Chrome extension not connected to this session (2026-11-05 22:10). First it was
  listed but every call timed out; after a Chrome restart it was not listed at all.
  Likely the extension is signed in to a different claude.ai account than the session
  (inputonlineshared@yahoo.com). Owner is restarting Claude. First call:
  `tabs_context_mcp` with createIfEmpty. If it still fails: the fallback is intent URLs
  (x.com/intent/post, bsky.app/intent/compose, threads intent, mastodon /share) with the
  text filled in, plus `open -R` on the video for drag and drop.
- GitHub social preview (Settings > Social preview): `_/social/2026-11-05-launch/og-1200x630.png`
  (1200x630, 119 KB). No API for it; needs the browser.
- Notarized builds need a Developer ID on the owner's paid team. Until then the
  release is ad hoc signed and users click "Open Anyway" once.

## Decisions (last 2 weeks)

- 2026-11-05: Menu-bar-only (LSUIElement), no main window. Popover = MenuBarExtra `.window` style.
- 2026-11-05: App Sandbox off (event taps that drop events need it), hardened runtime on, macOS 14+.
- 2026-11-05: Lock always has a timer (30 s to 5 min). No "until I say stop" mode: safety.
- 2026-11-05: Caps Lock state restored at unlock via IOHIDSetModifierLockState.
- 2026-11-05: Bundle ID com.mulualem.cleaning-mode, product name "Cleaning Mode", module cleaning_mode.
- 2026-11-05: Unit tests drive `KeyboardLock.handle()` with real CGEvents. CI: GitHub Actions `macos-26`.
- 2026-11-05: v1.0.0 released by the owner (Cleaning-Mode.zip, download link 200).
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
- After the posts: add a `log` entry to `~/.claude/social-post/accounts.json`.
- Owner check: one real wipe (Caps Lock, volume and brightness keys; not the Touch ID key).
- Owner: Developer ID + notarize step in `scripts/release.sh`, then Product Hunt.

## Do not touch

- none
