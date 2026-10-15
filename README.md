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

---

## 📥 Installation

### Method 1: Direct DMG Download (Recommended)
1. Download **`SDOCX_Converter_Lite.dmg`** from [GitHub Releases](https://github.com/FizzyHedgehog/sdocx-converter-lite/releases).
2. Open the disk image.
3. Drag **SDOCX Converter Lite** to your **Applications** folder.

> [!NOTE]
> **First-time Launch on macOS (Gatekeeper)**  
> Because SDOCX Converter Lite is a free, independent open-source project without a paid Apple Developer certificate ($99/year), macOS (especially **macOS Sequoia 15+**) requires confirming **"Open Anyway" twice** on first launch: once when opening the DMG, and once when opening the installed app.
> 
> **Standard GUI Method (System Settings — 2 Steps):**
> 1. **Step 1 (Open DMG)**: Double-click `SDOCX_Converter_Lite.dmg`. When blocked, click **Done**. Go to **System Settings** ➔ **Privacy & Security**, scroll down to Security, and click **Open Anyway** next to the DMG warning ➔ enter your password. Drag the app to `/Applications`.
> 2. **Step 2 (Open App)**: Open `/Applications` and double-click `SDOCX Converter Lite`. When blocked, click **Done**. Go to **System Settings** ➔ **Privacy & Security** again, click **Open Anyway** next to the app warning ➔ enter your password. (Only needed once; subsequent launches open immediately!).
> 
> **Fast Terminal Shortcuts (Bypasses both prompts in 1 second!):**
> - **Before opening the DMG (Recommended)**: Run this in Terminal to remove the browser quarantine flag from the DMG file directly:
>   ```bash
>   xattr -cr ~/Downloads/SDOCX_Converter_Lite.dmg
>   ```
> - **Or after moving the app to `/Applications`**:
>   ```bash
>   xattr -cr "/Applications/SDOCX Converter Lite.app"
>   ```

<details>
<summary><strong>🇰🇷 한국어 안내 (macOS Sequoia 15+ 최초 실행 시 2단계 승인 해결법)</strong></summary>
<br/>

본 프로그램은 무료 오픈소스 소프트웨어로 유료 Apple 개발자 계정 인증서가 등록되어 있지 않아, **최신 macOS(Sequoia 15 이상)**에서는 보안 정책에 따라 **총 2번의 [그래도 열기] 승인**이 필요합니다. (바이러스나 악성코드가 아니며 안심하고 여셔도 됩니다.)

#### 방법 1: 시스템 설정에서 2회 승인 (GUI 표준 방식)
1. **1단계 (DMG 열기)**: 다운로드한 `SDOCX_Converter_Lite.dmg`를 더블클릭합니다. 경고창이 뜨면 **[완료]**를 누른 뒤, **시스템 설정 ➔ 개인정보 보호 및 보안**으로 이동하여 화면 아래 보안 섹션에서 **`...차단했습니다` 옆의 [그래도 열기]** 클릭 ➔ Mac 암호를 입력합니다. 이제 열린 창에서 앱을 **`Applications(응용 프로그램)` 폴더로 드래그**합니다.
2. **2단계 (앱 첫 실행)**: `응용 프로그램` 폴더에서 `SDOCX Converter Lite`를 더블클릭합니다. 경고창이 뜨면 **[완료]**를 누른 뒤, **시스템 설정 ➔ 개인정보 보호 및 보안**에서 **[그래도 열기]**를 한 번 더 클릭 ➔ Mac 암호를 입력합니다.
3. 이제 영구 승인되어, 이후부터는 일반 앱과 똑같이 **더블클릭만으로 언제든 즉시 실행**됩니다!

---

#### 방법 2: 터미널 한 줄 명령어 (가장 빠르고 간편한 방법)
터미널을 이용하시면 위의 2단계(경고 2회 + 암호 2회)를 거칠 필요 없이 바로 실행할 수 있습니다:

* **DMG 열기 전 (가장 추천)**: 터미널을 열고 아래 명령어를 입력하여 다운로드된 DMG의 웹 격리 꼬리표를 바로 해제합니다:
  ```bash
  xattr -cr ~/Downloads/SDOCX_Converter_Lite.dmg
  ```
  *(이렇게 하면 시스템 설정에 들어갈 필요 없이 DMG가 바로 열립니다)*

* **또는 앱을 `응용 프로그램` 폴더에 넣은 후**:
  ```bash
  xattr -cr "/Applications/SDOCX Converter Lite.app"
  ```
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
