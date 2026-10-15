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

## 📥 Installation & First-Time Launch (macOS Sequoia 15+)

Because SDOCX Converter Lite is a free, open-source project without a paid Apple Developer certificate ($99/year), macOS requires a **2-step authorization on first setup (Step 1 for opening the DMG, Step 2 for launching the app)**.

Follow the exact flow below:

---

### 1️⃣ Step 1: Double-click DMG ➔ Blocked
When you double-click the downloaded **`SDOCX_Converter_Lite.dmg`**, macOS blocks it with a security warning (*"Apple cannot check it for malicious software"*).

👉 **How to unblock (Choose either option):**
- **Option A (System Settings)**: Click **Done** ➔ Go to **System Settings ➔ Privacy & Security** ➔ Scroll down to the Security section and click **Open Anyway** next to the DMG warning ➔ Enter your Mac password.
- **Option B (Terminal)**: Open Terminal and run:
  ```bash
  xattr -cr ~/Downloads/SDOCX_Converter_Lite.dmg
  ```
*(The DMG will now open cleanly).*

---

### 2️⃣ Step 2: Open App in DMG or Drag to Applications ➔ Blocked
Once the DMG window is open, **double-click the app icon** (for 1-click auto-install) or **drag it to the Applications folder**.  
When launched for the first time, macOS blocks the app again with a security warning.

👉 **How to unblock (Choose either option):**
- **Option A (System Settings)**: Click **Done** ➔ Go to **System Settings ➔ Privacy & Security** ➔ Click **Open Anyway** next to the app warning ➔ Enter your Mac password.
- **Option B (Terminal)**: Open Terminal and run:
  ```bash
  xattr -cr "/Applications/SDOCX Converter Lite.app"
  ```

---

### 3️⃣ Step 3: 1-Click Auto Move & DMG Auto-Eject (Complete!)
1. When prompted with **"Move to Applications Folder?"**, click **"Move to Applications Folder"**.
2. The app automatically moves to `/Applications`, launches, and **the installation disk image (DMG) is automatically unmounted and cleanly removed from Finder and your Desktop!**
3. Subsequent launches will open immediately without any prompts!

---

<details open>
<summary><strong>🇰🇷 한국어 설치 및 최초 실행 가이드 (macOS Sequoia 15+ 필수 확인)</strong></summary>
<br/>

본 프로그램은 무료 오픈소스 소프트웨어로 유료 Apple 개발자 인증서가 등록되어 있지 않아, **최초 설치 시 2단계 승인 (1단계: DMG 열 때, 2단계: 앱 열 때)** 과정이 진행됩니다. 아래 순서대로 진행해 주세요:

---

#### 1️⃣ 1단계: DMG 파일 더블클릭 시 차단 발생
다운로드한 **`SDOCX_Converter_Lite.dmg`** 파일을 더블클릭하면 *"Apple이 악성 소프트웨어가 있는지 확인할 수 없기 때문에..."* 경고창이 뜨며 차단됩니다.

👉 **해결 방법 (둘 중 편한 방법 선택):**
- **방법 A (시스템 설정)**: 경고창에서 **[완료]** 클릭 ➔ **시스템 설정 ➔ 개인정보 보호 및 보안**으로 이동 ➔ 화면 아래 보안 섹션에서 **`...차단했습니다` 옆의 [그래도 열기]** 클릭 ➔ Mac 암호 입력
- **방법 B (터미널 1줄 입력)**: 터미널을 열고 아래 명령어 실행:
  ```bash
  xattr -cr ~/Downloads/SDOCX_Converter_Lite.dmg
  ```
*(이제 DMG 파일이 정상적으로 열립니다).*

---

#### 2️⃣ 2단계: DMG 내 앱 더블클릭 또는 Applications 폴더로 끌기 시 오류/차단 발생
열린 DMG 창 안에서 **앱 아이콘을 더블클릭**하거나 **`Applications` 폴더로 드래그**한 후 앱을 실행하면, 첫 실행 보안 정책으로 인해 다시 한번 차단 오류/경고창이 발생합니다.

👉 **해결 방법 (둘 중 편한 방법 선택):**
- **방법 A (시스템 설정)**: 경고창에서 **[완료]** 클릭 ➔ **시스템 설정 ➔ 개인정보 보호 및 보안**에서 **`...차단했습니다` 옆의 [그래도 열기]**를 한 번 더 클릭 ➔ Mac 암호 입력
- **방법 B (터미널 1줄 입력)**: 터미널을 열고 아래 명령어 실행:
  ```bash
  xattr -cr "/Applications/SDOCX Converter Lite.app"
  ```

---

#### 3️⃣ 3단계: 1클릭 자동 이동 및 DMG 자동 정리 (설치 완료!)
1. 정상 승인 후 앱이 실행되면서 **"응용 프로그램 폴더로 이동하시겠습니까?"** 안내창이 뜹니다.
2. **[응용 프로그램 폴더로 이동]**을 클릭합니다.
3. 앱이 자동으로 `/Applications` 폴더로 이동되어 실행되며, **설치 가상 디스크(DMG)는 Finder와 바탕화면에서 자동으로 마운트 해제되어 깔끔하게 사라집니다!**
4. 이제 모든 설정이 완료되었으며, 이후부터는 일반 앱과 똑같이 **더블클릭만으로 언제든 즉시 실행**됩니다!
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
