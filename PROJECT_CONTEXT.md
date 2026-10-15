# SDOCX Converter (macOS) - Project Master Context

> **Welcome to the macOS SDOCX Converter Development Workspace!**  
> This document contains the complete context, history, rules, and architecture of the macOS application. Any AI agent operating in this workspace should read this document first to resume work seamlessly.

---

## 1. Project Overview & Repository

- **Application Name**: SDOCX Converter (formerly Lite; all "Lite" branding has been completely removed)
- **Target OS**: macOS 12.0+ (Universal / Apple Silicon & Intel)
- **Local Workspace**: `~/Projects/sdocx-converter-macos`
- **GitHub Repository**: [FizzyHedgehog/sdocx-converter-macos](https://github.com/FizzyHedgehog/sdocx-converter-macos)
- **Default Branch**: `main`
- **Release Status**: `v1.0.0` (Asset: `SDOCX_Converter.dmg`, 5.70 MB)
- **Bundle Identifier**: `com.fizzyhedgehog.sdocx-converter`
- **Git Author**: `FizzyHedgehog <fizzyhedgehog@users.noreply.github.com>`
- **GitHub Personal Access Token**: Stored securely in `~/.config/github_token.txt` (Never commit tokens to git!)

---

## 2. Strict User Rules & Guidelines

1. **NO Local MacBook Downloads & Direct Telegram Delivery**:
   - **NEVER** save, copy, or download generated `.dmg` (or `.apk`) files to the MacBook's `~/Desktop` or personal user storage.
   - Built `.dmg` files reside only within `dist/` and must be sent directly to Telegram using `send_telegram_document`.
   - **MANDATORY**: Whenever a fix or build is completed, deliver the `.dmg` file to Telegram AND always attach/provide the relevant GitHub link (branch or commit) in the Telegram message.
2. **Hidden Feature Branch & Release Isolation**:
   - When developing or testing new features, work strictly on isolated feature branches (e.g. `feature/...`).
   - Do NOT overwrite public Release `v1.0.0` or `main` branch until the user explicitly tests and approves.
3. **English Code & Commits**:
   - All code comments, Git commit messages, and documentation must be written in clear English without emojis.
4. **Preserve User Privacy**:
   - Keep GitHub profile anonymous (`FizzyHedgehog`).

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
- Cleaned up all Desktop build artifacts.

---

## 5. Telegram Integration & Listener Rules

- **Telegram Configuration**: `~/.config/sdocx_telegram_config.json`
- **Notification Utility**: `python3 ~/.sdocx_telegram_agent/notify_telegram.py`
  - Long responses are split safely within 3,800 characters.
  - Can deliver messages, full/summary content, and binary artifacts (`.dmg`) directly to Telegram.
  - Automatically routes to the macOS group when specifying `platform="macos"`.
  - Supports Telegram native reply format via `reply_to_message_id`.
- **Telegram Incoming Command Listener**:
  - Script: `python3 ~/.sdocx_telegram_agent/wait_for_telegram_macos.py`
  - Group: `sdocx-converter-macos` (Chat ID: `-100XXXXXXXXXX`)
  - **OPERATIONAL RULE**:
    Whenever the user says **"텔레그램 대기"**, **"텔레그램 기다려"**, **"대기해"**, **"텔레그램 리스너 켜줘"**, or asks to wait for Telegram messages:
    You **MUST execute the listener as a background task**:
    `run_command(CommandLine="python3 ~/.sdocx_telegram_agent/wait_for_telegram_macos.py", Cwd="~/Projects/sdocx-converter-macos", WaitMsBeforeAsync=1000)`
    Do NOT simply reply "대기하겠습니다" with plain text. Always launch the background listener so you wake up reactively when a command arrives from the macOS Telegram group!
