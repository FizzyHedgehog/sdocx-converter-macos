# SDOCX Converter (macOS) - Project Master Context

> **Welcome to the macOS SDOCX Converter Development Workspace!**  
> This document contains the complete context, history, rules, and architecture of the macOS application. Any AI agent operating in this workspace should read this document first to resume work seamlessly.

---

## 1. Project Overview & Repository

- **Application Name**: SDOCX Converter (formerly Lite; all "Lite" branding has been completely removed)
- **Target OS**: macOS 12.0+ (Universal / Apple Silicon & Intel)
- **Local Workspace**: `~/Projects/sdocx-converter/sdocx-converter-macos` (symlinked from `~/Projects/sdocx-converter-macos`)
- **GitHub Repository**: [FizzyHedgehog/sdocx-converter-macos](https://github.com/FizzyHedgehog/sdocx-converter-macos)
- **Default Branch**: `main`
- **Release Status**: `v1.2.1` (Stable Public / Latest, update integrity verification), `v1.2.0` (text-capable engine)
- **Bundle Identifier**: `com.fizzyhedgehog.sdocx-converter`
- **Git Author**: `FizzyHedgehog <fizzyhedgehog@users.noreply.github.com>`
- **GitHub Personal Access Token**: Stored securely in `~/.config/github_token.txt` (Never commit tokens to git!)

---

## 2. Strict User Rules & Guidelines

1. **NO Local MacBook Downloads & Immediate Cleanup**:
   - **NEVER** save, copy, or download generated `.dmg` (or `.apk`) files to the MacBook's `~/Desktop` or personal user storage.
   - Built `.dmg` files reside only within `dist/` and must be sent directly to Telegram using `notify_telegram.send_telegram_document`.
   - Any temporary files, test scripts, or intermediate build files extracted on the MacBook must be deleted immediately after delivery.
2. **Direct Telegram Delivery & Full/Summary Dual Reporting**:
   - **MANDATORY SEND SEQUENCE (Message First, File Below)**:
     메시지(보고/설명)와 파일(DMG/APK)을 함께 전송할 때는 **반드시 설명 메시지(`send_full_and_summary`)를 먼저 전송**하고, **그 아래에 파일(`send_telegram_document`)을 후속 전송**합니다.
   - Build artifacts must be delivered directly to the user's Telegram chat using `notify_telegram.send_telegram_document(file_path, caption=..., platform="macos", reply_to_message_id=...)`.
   - **MANDATORY**: Whenever a fix or build is completed, deliver the `.dmg` file to Telegram AND always attach/provide the relevant GitHub link (branch, commit, or release) in the message.
   - Detailed task reports must always include both full content and a 3-line core summary via `notify_telegram.send_full_and_summary(full_content, summary_content, platform="macos", reply_to_message_id=...)`.
3. **Staging & Pre-release Workflow**:
   - Feature changes are maintained on `main` and tested via **GitHub Pre-releases** (e.g. `v1.0.1-beta`).
   - Normal users querying `/releases/latest` will never see pre-releases.
   - Only devices with Developer Mode enabled (7-tap gesture + the unlock password defined in `Sources/Models.swift`) with 'Include Pre-releases' enabled (automatically checked by default upon unlocking Developer Mode) will detect and test pre-releases.
   - Every pre-release release body MUST maintain a detailed changelog mapping specific user commands to implemented features.
   - **CRITICAL RULE FOR PROMOTING PRE-RELEASE TO PUBLIC RELEASE**:
     When the user requests to make a pre-release public (promote to stable release):
     You **MUST completely remove all developer-convenience and developer-related content** (e.g., Developer Mode, 7-tap gesture, the unlock password, pre-release update toggles, internal development details) from the release notes / changelog before publishing. Only end-user features, fixes, and UX improvements should be visible to regular users.
   - Do NOT overwrite the public stable release until the user explicitly approves.
4. **English Code, Commits & GitHub Releases (No Emojis)**:
   - All code comments, Git commit messages, GitHub Release titles, descriptions, and documentation must be written strictly in clear, professional English without emojis.
   - **Bilingual README & Release Notes**: The README and every GitHub Release body carry both English and Korean sections, using a consistent anchor pattern (`[English](#english) | [한국어](#한국어-설명)` plus `<a name="english"></a>` / `<a name="한국어"></a>` anchors). Korean text is exempt from the English-only rule and must read as native Korean, not machine translation.
   - **Standalone Platform Voice**: macOS-facing documentation and release notes must describe this app on its own terms. Do not phrase features as "the same as" or "ported from" another platform's release, and do not reference another platform's version numbers, screens, or workflows. Shared engine components may be described as the native conversion engine without cross-platform comparison.
5. **Preserve User Privacy, Terminal Silence & Guardrails**:
   - Keep GitHub profile anonymous (`FizzyHedgehog`).
   - **Terminal Silence Principle**: Never use audible commands (`afplay`, `say`).
   - **Timeout Guardrail**: Single task 30-minute timeout guardrail strictly observed.
6. **Spotlight Search Hygiene & Local App Cleanup**:
   - macOS Spotlight indexes any `.app` bundle located on the Mac, including inside `dist/`.
   - If an `.app` remains in `dist/` while another is in `/Applications/`, Spotlight displays duplicate app entries when searched by the user.
   - **MANDATORY**: Never leave `.app` bundles in `dist/` or anywhere in the workspace. `build_dmg.sh` automatically removes `dist/$APP_NAME.app` after creating the DMG. If any local test app is installed for verification, always remove it completely immediately after testing finishes.

---

## 3. Architecture & Build Pipeline

- **Language & Framework**: Swift / Cocoa / AppKit (Native macOS UI, no Electron, minimal memory footprint)
- **Source Code**:
  - `Sources/AppDelegate.swift`: Application lifecycle and menu bar integration
  - `Sources/MainWindowController.swift`: Main window layout, drag-and-drop drop zone, conversion queue
  - `Sources/Models.swift`: Data structures, conversion settings, pen/marker thickness multipliers
- **DMG Packaging**:
  - `build_dmg.sh`: Complete build & package script.
    - Runs `./build_native.sh` to compile the native Swift application.
    - Strips extended attributes (`xattr -cr`) and signs code with ad-hoc signature.
    - Creates HiDPI TIFF background (`/usr/bin/tiffutil -cathidpicheck ...`).
    - Uses `dmgbuild` with `dmg_settings.py` for Chrome-style symmetric window layout.
    - Signs the final DMG.
    - Automatically sends the resulting DMG to Telegram using `notify_telegram.py`.

---

## 4. Key Milestones Completed

- Stripped all "Lite" references across all Swift sources, plists, and build scripts.
- Chrome-style symmetric DMG window layout with centered icons and clean English visual cues.
- Replaced outdated `SDOCX_Converter_Lite.dmg` with `SDOCX_Converter.dmg` in GitHub Release v1.0.0.
- Released v1.1.0: Integrated in-app auto-updater, high-resolution vector squircle icon, reactive language switching, DMG installation checks, and automatic DMG volume unmounting.
- v1.2.0 rebuild: Replaced the bundled `sdocx2pdf-macOS-arm64` with a build of the Rust core at `sdocx2pdf` 0.4.0 (`feature/png-support`, commit `ad7d42a`), which also carries the earlier PNG embedding work. The previous binary silently dropped every `Text` object; the new one renders text with true glyph metrics, paragraph alignment, Korean line wrapping, embedded NanumBarunGothic fonts, image rotation, and precise dash intervals.
  - Verification: `모든 테스트.sdocx` -> 12 pages, 820 extracted characters vs. 826 in the reference PDF, whereas the previous bundled engine produced 0 characters.
  - The Swift sources required no changes: the new CLI keeps `--pen-width-multiplier`, `--marker-width-multiplier`, `--detailed-errors`, `--basic-split`, `--auto-split`.
  - Known engine limitations carried over: `.spi` stickers / lasso crops unsupported, highlighter opacity roughly 2x too strong, rotated text-box wrapping, page height +0.2877pt.
  - `build_dmg.sh` now auto-detects a Python interpreter that actually has `dmgbuild` installed instead of assuming `python3` on PATH.
- GitHub publishing (2026-10-21): rewrote `README.md` as a bilingual main page (badges, feature list, requirements, installation, updating, known limitations, build steps, architecture, credits — each mirrored in Korean). Published release `v1.2.0` as the new latest with the `SDOCX_Converter.dmg` asset, and converted the remaining releases (`v1.0.0`, `v1.0.1-beta`, `v1.1.0`) to bilingual English/Korean notes. The `v1.2.0-preview` release and tag were later deleted after its PNG embedding notes were folded into the `v1.2.0` release, leaving a single 1.2.0 entry. Repo description, topics, and a self-referential homepage link were also cleaned up.
- Cleaned up all Desktop build artifacts.

---

## 5. Telegram Integration & Listener Rules

- **Telegram Configuration**: `~/.config/sdocx_telegram_config.json`
  - macOS chat ID: stored in the config file (`macos_chat_id`)
  - Android chat ID: stored in the config file (`android_chat_id`)
- **Notification Utility**: `python3 ~/.sdocx_telegram_agent/notify_telegram.py`
  - Long responses are split safely within 3,800 characters.
  - Automatically routes to the macOS group when specifying `platform="macos"`.
  - Supports Telegram native reply format via `reply_to_message_id`.
  - **Full & Summary Dual Reporting**:
    Detailed task reports and completion notifications to Telegram should always provide both full details and a 3-line core summary using:
    `notify_telegram.send_full_and_summary(full_content, summary_content, platform="macos", reply_to_message_id=...)`
  - **Direct Deliverables Delivery & Order**:
    Deliver build artifacts (`.dmg`) directly to Telegram using `notify_telegram.send_telegram_document`.
    **MANDATORY SEQUENCE**: 메시지와 파일을 함께 전송할 때는 사용자가 맥락을 먼저 읽을 수 있도록 **반드시 설명 메시지(`send_full_and_summary`)를 먼저 보내고, 그 다음 바로 아래에 파일(`send_telegram_document`)을 전송**합니다.
- **Telegram Incoming Command Listener**:
  - Script: `python3 ~/.sdocx_telegram_agent/wait_for_telegram_macos.py`
  - Group: `sdocx-converter-macos` (chat ID from `~/.config/sdocx_telegram_config.json`)
  - **Multi-image Album Bundling**: Telegram sends album photos as separate messages sharing a `media_group_id` (or without it when pasted in Telegram Desktop). `dispatcher.py` runs a background thread that aggregates all consecutive photos and text captions per chat ID into a single combined event (`images: [...]`) after a 2.5-second debounce window. The agent always processes all photos and descriptions in a single bubble together in one turn.
  - **OPERATIONAL RULE**:
    Whenever the user says **"텔레그램 대기"**, **"텔레그램 기다려"**, **"대기해"**, **"텔레그램 리스너 켜줘"**, or asks to wait for Telegram messages:
    You **MUST execute the listener as a background task**:
    `run_command(CommandLine="python3 ~/.sdocx_telegram_agent/wait_for_telegram_macos.py", Cwd="~/Projects/sdocx-converter-macos", WaitMsBeforeAsync=1000)`
    Do NOT simply reply "대기하겠습니다" with plain text. Always launch the background listener so you wake up reactively when a command arrives from the macOS Telegram group!
  - **CONCISE STATUS OUTPUT RULE**:
    작업 완료 후 백그라운드 텔레그램 리스너를 실행하여 턴을 종료할 때는 장황한 요약이나 번호 목록 대신, 아래와 같이 간결한 한 줄 문구만 출력합니다:
    `현재 텔레그램 백그라운드 리스너(wait_for_telegram_macos.py)가 가동 중입니다.`

---

## 6. Developer Mode & Internal Testing Features (Hidden from Public)

- **Activation Gesture**: In the Preferences window, tap/click the application icon/version area 7 times consecutively.
- **Unlock Password**: defined as a constant in `Sources/Models.swift` (`promptDeveloperPassword`); not recorded in documentation.
- **Features Unlocked**:
  - **Include Pre-release Updates**: Automatically enabled (`true`) when Developer Mode is unlocked. When enabled, `UpdateManager` inspects `/releases` instead of `/releases/latest`, allowing immediate testing of pre-release staging builds (e.g. `v1.0.1-beta`).
  - **Simulation & Testing Tools**: Internal buttons to simulate update availability and verify download/restart workflows.
  - **Modal Termination Workaround**: Uses `exit(0)` instead of `NSApplication.shared.terminate(nil)` after launching the updater helper script (`/tmp/sdocx_updater.sh`), bypassing macOS AppKit sheet modal termination locks.
- **Strict Privacy & Sanitization Rule**:
  - All references to Developer Mode, the 7-tap gesture, the unlock password, simulation options, and internal update toggles must NEVER appear in public release notes, public commit messages, or public issue trackers.
  - This section in `PROJECT_CONTEXT.md` serves as the permanent internal reference.

---

## 7. Update Security (v1.2.1 and later)

- `UpdateManager` verifies the downloaded DMG against the `digest` field (`sha256:<hex>`) returned by the GitHub Releases API before offering installation. A mismatch deletes the temporary file, shows a localized error, and leaves the installed version untouched.
- Assets published without a digest skip the hash check; the installer still verifies the bundle as described below.
- The updater helper script validates the replacement bundle before touching the installed app: `CFBundleIdentifier` must equal `com.fizzyhedgehog.sdocx-converter` and `codesign --verify` must succeed. Use non-strict verification, because `dmgbuild` adds `com.apple.FinderInfo` to the app and that makes `--strict` fail on an otherwise valid bundle. If validation fails, the current installation is left in place and relaunched.
- Every release note publishes the DMG SHA-256 so users can check a download manually with `shasum -a 256`.
- Residual gap by design: the update that installs the first verifying build is performed by the previous, unverified updater. Protection applies from that build onward.

