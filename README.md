# SDOCX Converter Lite

<p align="center">
  <img src="assets/notification_icon.png" width="128" height="128" alt="SDOCX Converter Lite Icon" />
</p>

<p align="center">
  <strong>Fast, native macOS GUI app and Finder Quick Action to convert Samsung Notes (<code>.sdocx</code>) files to PDF.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2011.0%2B-blue" alt="macOS 11.0+" />
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon%20(arm64)-orange" alt="Apple Silicon" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-F05138" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License" />
</p>

---

## 💎 Why SDOCX Converter Lite? (True Vector PDFs vs. Blurry Raster)

> **No more blurry, pixelated notes!**  
> When exporting notes directly to PDF within Samsung Notes, handwritten strokes and highlights are often rasterized into **low-resolution bitmap images**, resulting in severe pixelation and blurry text when zooming in.  
> 
> **SDOCX Converter Lite** solves this fundamentally: by exporting the original **`.sdocx`** file and processing it through our native engine, all handwriting, S-Pen strokes, and markers are accurately reconstructed into **infinitely scalable vector graphics (PDF vector paths)**. Your notes stay razor-sharp at any zoom level, print sizes, and on high-density Retina / 4K displays.

---

## ✨ Features

- **🎯 Infinitely Scalable Vector Quality**: Preserves 100% vector accuracy for all handwritten strokes without raster blur.
- **🚀 Native Apple Silicon (ARM64) Performance**: High-speed offline conversion powered by Swift and native binaries. Zero Electron/Python overhead for end users.
- **📂 Batch & Recursive Folder Conversion**: Drag & drop multiple `.sdocx` files or entire folders. Nested subdirectories are automatically scanned and queued.
- **⚡️ Finder Quick Action Integration**: Right-click any `.sdocx` file or folder in Finder and convert to PDF instantly without opening the main window.
- **🔔 Rich System Notifications**: Banner alerts with file details and app badge when conversions finish in the background.
- **🌐 Automatic System Language Detection**: Automatically switches between English and Korean based on your macOS system preferences.
- **🗑 Clean Uninstallation**: Built-in 1-click uninstaller in Preferences that cleans up Finder Quick Actions, preferences, and the app bundle safely.

---

## 📥 Installation

### Method 1: Direct DMG Download (Recommended)
1. Download **`SDOCX_Converter_Lite.dmg`** from [GitHub Releases](https://github.com/FizzyHedgehog/sdocx-converter-lite/releases).
2. Open the disk image.
3. Drag **SDOCX Converter Lite** to your **Applications** folder.

> [!NOTE]
> **First-time Launch on macOS (Gatekeeper)**  
> Because SDOCX Converter Lite is a free, independent open-source project without a paid Apple Developer certificate ($99/year), macOS Gatekeeper may show a standard verification dialog on first launch.
> 
> **How to open (one-time only):**
> - **Option 1 (Recommended)**: In Finder (`/Applications`), **Right-click (or Control + Click)** on `SDOCX Converter Lite` ➔ select **Open** ➔ click **Open** in the prompt.
> - **Option 2**: Go to **System Settings** ➔ **Privacy & Security**, scroll down to the Security section, and click **Open Anyway**.
> - **Option 3 (Terminal)**: Run `xattr -cr "/Applications/SDOCX Converter Lite.app"`

<details>
<summary><strong>🇰🇷 한국어 안내 (최초 1회 실행 시 '확인되지 않은 개발자' 팝업 해결법)</strong></summary>
<br/>

본 앱은 무료 오픈소스 프로젝트로 유료 Apple 개발자 계정 인증서가 등록되어 있지 않아, 다운로드 후 최초 1회 실행 시 macOS Gatekeeper 안내창이 나타날 수 있습니다. (컴퓨터 바이러스나 손상이 아닙니다.)

**간단 실행 방법 (최초 1회만 필요):**
1. **가장 간편한 방법 (추천)**: Finder의 `응용 프로그램(/Applications)` 폴더에서 앱 아이콘을 **우클릭(또는 Control + 클릭)** ➔ **[열기]** 선택 ➔ 팝업창에서 **[열기]** 클릭
2. **시스템 설정에서 허용**: **시스템 설정** ➔ **개인정보 보호 및 보안** ➔ 화면 아래 보안 섹션에서 **[확인 없이 열기]** 클릭
3. **터미널 명령어 한 줄**: 터미널에서 `xattr -cr "/Applications/SDOCX Converter Lite.app"` 실행

한 번 허용해 두시면 이후부터는 일반 앱과 똑같이 더블클릭으로 바로 열립니다.
</details>

---

## 🛠 Building from Source

### Prerequisites
- macOS 11.0 or newer
- Xcode Command Line Tools (`xcode-select --install`)
- Python 3 with `dmgbuild` and `pillow` (`pip3 install dmgbuild pillow`)

### Build Steps
```bash
git clone https://github.com/FizzyHedgehog/sdocx-converter-lite.git
cd sdocx-converter-lite

# Build the native macOS application bundle
./build_native.sh

# Build distribution DMG with custom layout
./build_dmg.sh
```
The output `.dmg` will be generated in `dist/SDOCX_Converter_Lite.dmg`.

---

## 📜 Credits & License

- **Core Converter Engine**: Based on the open-source project [squ1dd13/sdocx2pdf](https://github.com/squ1dd13/sdocx2pdf) by **squ1dd13**, licensed under the **MIT License**.
- **macOS GUI & Packaging**: Developed by **FizzyHedgehog**.
- Distributed under the terms of the **MIT License**. See [LICENSE.txt](LICENSE.txt) for the full license text.
