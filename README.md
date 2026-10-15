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

### 🚀 Recommended: 1-Click Install (with macOS Gatekeeper Guide)

> [!TIP]
> **⚡️ 1-Second Terminal Bypass (Skip All Security Prompts — Highly Recommended!)**  
> If you don't want to deal with macOS Security prompts, simply run this in Terminal right after downloading:
> ```bash
> xattr -cr ~/Downloads/SDOCX_Converter_Lite.dmg
> ```
> This immediately strips the web quarantine flag so the DMG and app open without any security warnings!

#### Standard GUI Method (macOS Sequoia 15+ Gatekeeper):
Because SDOCX Converter Lite is a free, independent open-source project without a paid Apple Developer certificate ($99/year), macOS (especially **macOS Sequoia 15+**) requires confirming **"Open Anyway" twice** on first launch: once for the DMG, and once for the app.

1. **Step 1 (Open DMG & "Open Anyway")**: Download **`SDOCX_Converter_Lite.dmg`** from [GitHub Releases](https://github.com/FizzyHedgehog/sdocx-converter-lite/releases) and double-click it.  
   - If blocked by macOS, click **Done**. Go to **System Settings ➔ Privacy & Security**, scroll down to Security, and click **Open Anyway** next to the DMG warning ➔ enter your Mac password.
2. **Step 2 (Double-click App in DMG & "Open Anyway")**: Inside the DMG window, double-click **SDOCX Converter Lite**.  
   - On first launch, macOS will block the app once: click **Done**. Go to **System Settings ➔ Privacy & Security** again, and click **Open Anyway** next to the app warning ➔ enter your password.
3. **Step 3 (1-Click Auto Move & Auto Eject)**: A prompt will appear: **"Move to Applications Folder?"**.  
   - Click **"Move to Applications Folder"**.
   - The app is automatically moved to `/Applications`, launched, and the installation disk image (DMG) is automatically unmounted and cleanly removed from Finder and your Desktop!  
   *(Traditional drag-and-drop to the Applications folder shortcut also works).*

<details open>
<summary><strong>🇰🇷 한국어 설치 가이드 (macOS Sequoia 15+ 1클릭 설치 및 [그래도 열기] 해결법)</strong></summary>
<br/>

> [!TIP]
> **⚡️ 터미널 1초 해결법 (보안 경고창 없이 바로 열기 - 가장 추천!)**  
> 다운로드 후 터미널(Terminal)을 열고 아래 한 줄을 실행하면 웹 격리 속성이 제거되어 **보안 경고창 없이 DMG와 앱이 즉시 열립니다**:
> ```bash
> xattr -cr ~/Downloads/SDOCX_Converter_Lite.dmg
> ```

#### GUI 표준 설치 방법 (시스템 설정 ➔ 그래도 열기 2단계 승인):
본 앱은 무료 오픈소스 소프트웨어로 유료 개발자 인증서가 등록되어 있지 않아, **macOS 최신 버전(Sequoia 15 이상)**에서는 최초 실행 시 보안 정책에 따라 **총 2번의 [그래도 열기] 승인**이 필요합니다.

1. **1단계 (DMG 열기 & 그래도 열기)**: 다운로드한 `SDOCX_Converter_Lite.dmg`를 더블클릭합니다.  
   - *"Apple이 악성 소프트웨어가 있는지 확인할 수 없기 때문에..."* 경고창이 뜨면 **[완료]**를 누릅니다.
   - **시스템 설정 ➔ 개인정보 보호 및 보안**으로 이동하여 화면 아래 **`...차단했습니다` 옆의 [그래도 열기]** 클릭 ➔ Mac 암호를 입력합니다.
2. **2단계 (DMG 내 앱 실행 & 그래도 열기)**: 열린 DMG 창에서 **`SDOCX Converter Lite` 앱을 더블클릭**합니다.  
   - 첫 실행 차단 경고창이 뜨면 **[완료]**를 누릅니다.
   - **시스템 설정 ➔ 개인정보 보호 및 보안**에서 **[그래도 열기]**를 한 번 더 클릭 ➔ Mac 암호를 입력합니다.
3. **3단계 (1클릭 자동 설치 & DMG 자동 정리)**: 앱에서 **"응용 프로그램 폴더로 이동하시겠습니까?"** 안내창이 뜹니다.  
   - **[응용 프로그램 폴더로 이동]**을 클릭합니다.
   - 앱이 자동으로 `/Applications`로 이동되어 실행되며, **설치 가상 디스크(DMG)는 Finder와 바탕화면에서 자동으로 마운트 해제되어 깔끔하게 사라집니다!**
   *(기존처럼 Applications 폴더로 드래그 앤 드롭하셔도 동일하게 설치됩니다.)*
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
