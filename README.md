# SDOCX Converter for macOS

<p align="center"><b>English</b> | <a href="#한국어">한국어</a></p>

<a name="english"></a>

Fast, native macOS app and Finder Quick Action that converts Samsung Notes (`.sdocx`) files into lossless vector PDFs — handwriting, typed text, and images in one pass.

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2011.0%2B-blue" alt="macOS 11.0+" />
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon%20(arm64)-orange" alt="Apple Silicon" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-F05138" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/core-Rust%20Native-red" alt="Rust Native" />
  <img src="https://img.shields.io/badge/content-handwriting%20%7C%20text%20%7C%20images-yellow" alt="Handwriting, Text and Images" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License" />
</p>

---

## Why SDOCX Converter? (True Vector PDFs vs. Rasterized Bitmaps)

When exporting notes directly to PDF inside the Samsung Notes application, handwritten strokes and highlights are frequently rasterized into low-resolution bitmap images, causing noticeable pixelation and blur when zooming in or printing.

**SDOCX Converter** solves this issue fundamentally: by reading the raw `.sdocx` container and reconstructing all pen strokes, mathematical curves, and markers through a native vector engine, the output PDF contains true mathematical vector paths. Your notes remain razor-sharp at any zoom level and on high-density Retina displays.

---

## Key Features

- **Lossless Vector Rendering**: Handwriting, highlights, formulas, shapes, typed text, and embedded images all become smooth vector curves — no pixelation at any zoom level.
- **Full Typed-Text Layout**: Typed text is laid out with true glyph font metrics, block flow layout, and Korean syllable-level line wrapping, so notes that mix handwriting and text convert completely and in the right places.
- **Embedded Fonts (Korean & Latin)**: The engine embeds **NanumBarunGothic** (Regular/Bold, SIL Open Font License) and renders all text with it, so every Mac produces the same output. Layout fidelity depends on the font a note was written with: notes written with Samsung's default fonts render most faithfully, while notes in other fonts may see slightly shifted line breaks or glyph placement because the metrics no longer match.
- **Rich Text Styling**: Bold, italic, underline, strikethrough, paragraph alignment (left / center / right), and bulleted or numbered lists are all carried into the PDF.
- **Dashed & Dotted Strokes**: Dashed and dotted pen and shape strokes render as true vector dash/dot patterns (spacing calibrated against Samsung Notes' own rendering) instead of solid lines.
- **Images (JPEG & PNG)**: Embedded images keep their rotation and placement, avoid colliding with text, and can be used as page backgrounds with clear text margins.
- **Batch & Recursive Folder Conversion**: Drag & drop multiple `.sdocx` files or entire folders. Nested subdirectories are discovered and queued automatically.
- **Finder Quick Action**: Right-click any `.sdocx` file or folder in Finder and convert to PDF without opening the main window.
- **Custom Stroke Thickness**: Adjust pen and marker stroke multipliers in Settings to match your own handwriting weight.
- **Intelligent Page Splitting**: Wide continuous-canvas notes can be split, and pageless documents can inherit page breaks from embedded PDFs.
- **System Notifications & Menu Bar Mode**: Native banner notifications report completion, and the app can live in the menu bar for background conversions.
- **Reactive UI & Themes**: Switch between English and Korean instantly without a restart, and follow the system appearance or pin light/dark mode.
- **Integrated In-App Auto-Update**: Checks GitHub Releases in the background, shows release notes and download progress, then replaces the app in `/Applications` and relaunches.
- **1-Click Install & Clean Ejection**: On first launch the app offers to move itself to `/Applications` and automatically unmounts the disk image.
- **100% Offline & Private**: Everything is converted locally on your Mac. No uploads, no telemetry.

---

## Requirements

- macOS 11.0 or newer
- Apple Silicon Mac (arm64)

---

## Installation & First-Time Launch (macOS Sequoia 15+)

Because SDOCX Converter is an open-source project without a paid Apple Developer certificate, macOS Gatekeeper may prompt security confirmations on first launch.

### Step 1: Open the DMG
When opening the downloaded **`SDOCX_Converter.dmg`**, macOS may display a Gatekeeper dialog (*"Apple cannot check it for malicious software"*).

**How to open (choose either option):**
- **Option A (System Settings)**: Click **Done** → go to **System Settings > Privacy & Security** → scroll to Security and click **Open Anyway** next to the DMG prompt → enter your Mac password.
- **Option B (Terminal)**: Open Terminal and run:
  ```bash
  xattr -cr ~/Downloads/SDOCX_Converter.dmg
  ```

### Step 2: Launch the App
Inside the opened DMG window, double-click the app icon or drag it to the Applications folder.
If Gatekeeper prompts on the first run:

- **Option A (System Settings)**: Click **Done** → **System Settings > Privacy & Security** → **Open Anyway** → enter your Mac password.
- **Option B (Terminal)**:
  ```bash
  xattr -cr "/Applications/SDOCX Converter.app"
  ```

### Step 3: 1-Click Move & Automatic Cleanup
1. When prompted with **"Move to Applications Folder?"**, click **"Move to Applications Folder"**.
2. The app moves itself to `/Applications`, launches, and **automatically unmounts the installation disk image**.
3. Subsequent launches open normally without any prompts.

---

## Updating

- **Automatic check on launch**: The app quietly checks GitHub Releases for new versions and shows the release notes with a one-tap download when an update is available.
- **Manual check**: Open **Settings > Software Update > Check for Updates** at any time.
- **Direct reinstall**: Download the latest `SDOCX_Converter.dmg` from [Releases](https://github.com/FizzyHedgehog/sdocx-converter-macos/releases) and replace the app in `/Applications`. Your settings are preserved.

---

## Known Limitations

The current conversion engine is verified against reference documents, but the following items are not yet complete:

- **Free-form (lasso) cropped images and stickers** are stored in Samsung's proprietary `.spi` format and do not appear in the PDF. Rectangular crops work normally.
- **Highlighter strokes** render about twice as dark as in Samsung Notes' own PDF export.
- **Rotated multi-line text boxes**: line wrapping inside rotated text boxes can differ from the original in some cases.
- **Image formats**: only JPEG and PNG are supported; other formats report an unsupported-format error.
- **Font substitution**: all text is rendered with the embedded NanumBarunGothic. Notes written with fonts other than Samsung's defaults may show shifted line breaks or slightly different glyph placement, because Samsung's own default fonts are proprietary and cannot be embedded.

---

## Building from Source

### Prerequisites
- macOS 11.0 or newer with Xcode Command Line Tools (`xcode-select --install`)
- Rust toolchain with the `aarch64-apple-darwin` target (to rebuild the conversion engine)
- Python 3 with `dmgbuild` and `pillow` (`pip3 install dmgbuild pillow`)

### Build Steps
```bash
git clone https://github.com/FizzyHedgehog/sdocx-converter-macos.git
cd sdocx-converter-macos

# Build the native macOS application bundle (includes the bundled engine binary)
./build_native.sh

# Build the distribution DMG with the custom layout
./build_dmg.sh
```
The output is written to `dist/SDOCX_Converter.dmg`. `build_dmg.sh` automatically picks a Python interpreter that has `dmgbuild` installed.

---

## Technical Architecture

```
[ UI Layer (Swift, AppKit / SwiftUI) ]
   ├── App.swift              (application lifecycle, open-with handling)
   ├── MainWindowController   (drop zone, conversion queue, batch summary)
   ├── MenuBarController      (menu bar mode, background conversions)
   ├── Views / Models         (settings, localization, queue state)
   └── UpdateManager          (GitHub Releases self-updater)
                   │ (Process invocation: bundled CLI)
                   ▼
[ Native Core (Rust CLI: sdocx2pdf-macOS-arm64) ]
   ├── sdocx Parser                 (ZIP container & page extraction)
   ├── Stroke & Shape Reconstructor (path & Bezier interpolation)
   ├── Text Layout Engine           (glyph metrics, block flow, alignment)
   └── krilla Vector Engine         (PDF 1.7 lossless vector generation)
```

- **UI**: Swift, AppKit / SwiftUI, PDFKit, UserNotifications
- **Native engine**: Rust (`sdocx2pdf` 0.4.0), prebuilt as a standalone arm64 binary and invoked as a child process
- **Packaging**: `build_native.sh` + `dmgbuild` with a HiDPI background and ad-hoc code signing
- **Finder integration**: bundled Quick Action workflow (`Convert SDOCX to PDF.workflow`)

---

## Credits & License

- **Core Converter Engine**: Based on the open-source project [squ1dd13/sdocx2pdf](https://github.com/squ1dd13/sdocx2pdf) by **squ1dd13**, licensed under the **MIT License**.
- **Embedded Font**: NanumBarunGothic, released under the SIL Open Font License.
- **macOS GUI & Packaging**: Developed by **FizzyHedgehog**.
- Distributed under the terms of the **MIT License**. See [LICENSE.txt](LICENSE.txt) for details.

---

<a name="한국어"></a>

## 한국어 버전

<p align="center"><a href="#english">English</a> | <b>한국어</b></p>

삼성노트(`.sdocx`) 파일을 무손실 벡터 PDF로 변환하는 macOS 네이티브 앱이자 Finder 퀵 액션입니다 — 손글씨, 타이핑 텍스트, 이미지를 한 번에 처리합니다.

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2011.0%2B-blue" alt="macOS 11.0+" />
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon%20(arm64)-orange" alt="Apple Silicon" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-F05138" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/core-Rust%20Native-red" alt="Rust Native" />
  <img src="https://img.shields.io/badge/content-handwriting%20%7C%20text%20%7C%20images-yellow" alt="Handwriting, Text and Images" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License" />
</p>

---

## 왜 SDOCX Converter인가? (진짜 벡터 PDF vs 래스터화 비트맵)

삼성노트 앱에서 노트를 직접 PDF로 내보내면 손글씨 획과 형광펜이 저해상도 비트맵 이미지로 래스터화되는 경우가 많습니다. 그 결과 확대하거나 인쇄할 때 눈에 띄게 픽셀화되고 흐려집니다.

**SDOCX Converter**는 이 문제를 근본부터 해결합니다. 원본 `.sdocx` 컨테이너를 직접 읽어 모든 펜 획과 수학적 곡선, 마커를 네이티브 벡터 엔진으로 재구성하므로, 출력 PDF에는 실제 수학적 벡터 경로가 담깁니다. 어떤 배율로 확대해도, 고해상도 Retina 디스플레이에서도 노트가 날카롭게 유지됩니다.

---

## 주요 기능

- **무손실 벡터 렌더링**: 손글씨, 형광펜, 수식, 도형, 타이핑 텍스트, 삽입 이미지가 모두 부드러운 벡터 곡선으로 변환됩니다. 확대해도 픽셀화되지 않습니다.
- **전체 타이핑 텍스트 레이아웃**: 타이핑 텍스트를 실제 글리프 폰트 메트릭, 블록 흐름 레이아웃, 한글 음절 단위 줄바꿈으로 배치합니다. 손글씨와 텍스트가 섞인 노트도 빠짐없이 올바른 위치에 렌더링됩니다.
- **내장 폰트 (한글 & 라틴)**: 엔진에 **나눔바른고딕**(Regular/Bold, SIL Open Font License)을 내장하여 모든 텍스트를 렌더링하므로, 어떤 Mac에서도 동일한 결과가 나옵니다. 단, 레이아웃 충실도는 노트를 작성한 폰트에 따라 다릅니다 — 삼성 기본 폰트로 작성한 노트가 가장 정확하고, 다른 폰트로 작성한 노트는 메트릭이 맞지 않아 줄바꿈이 밀리거나 글자 배치가 달라질 수 있습니다.
- **리치 텍스트 서식**: 볼드, 이탤릭, 밑줄, 취소선, 문단 정렬(왼쪽/가운데/오른쪽), 불릿·번호 목록이 모두 PDF에 반영됩니다.
- **파선·점선 획**: 파선과 점선 펜·도형 획이 실선이 아닌 실제 벡터 파선/점선 패턴으로 렌더링됩니다(간격은 삼성노트 자체 렌더링 기준으로 보정).
- **이미지 (JPEG & PNG)**: 삽입 이미지의 회전과 위치를 유지하고, 텍스트와 겹치지 않도록 배치하며, 페이지 배경 이미지도 지원합니다.
- **일괄 및 재귀 폴더 변환**: 여러 `.sdocx` 파일이나 폴더 전체를 드래그 앤 드롭하면, 하위 폴더까지 자동으로 탐색해 대기열에 추가합니다.
- **Finder 퀵 액션**: Finder에서 `.sdocx` 파일이나 폴더를 우클릭해 앱 창을 열지 않고 바로 PDF로 변환합니다.
- **획 두께 사용자 지정**: 설정에서 펜·마커 획 배율을 조절해 자신의 손글씨 굵기에 맞출 수 있습니다.
- **스마트 페이지 분할**: 넓은 연속 캔버스 노트를 분할할 수 있고, 페이지가 없는 문서는 포함된 PDF의 페이지 나눔을 그대로 따를 수 있습니다.
- **시스템 알림 & 메뉴 막대 모드**: 변환 완료를 네이티브 배너 알림으로 알려주며, 메뉴 막대에 상주해 백그라운드로 변환할 수 있습니다.
- **즉시 반영되는 UI & 테마**: 앱을 재시작하지 않고 영어/한국어를 즉시 전환할 수 있고, 시스템 외형을 따르거나 라이트/다크 모드를 고정할 수 있습니다.
- **인앱 자동 업데이트**: 백그라운드에서 GitHub Releases를 확인하고, 릴리즈 노트와 다운로드 진행률을 보여준 뒤 `/Applications`의 앱을 교체하고 재실행합니다.
- **원클릭 설치 & 자동 정리**: 첫 실행 시 `/Applications`로 이동할지 물어보고, 설치용 디스크 이미지를 자동으로 마운트 해제합니다.
- **100% 오프라인 & 개인정보 보호**: 모든 변환이 Mac 안에서 로컬로 실행됩니다. 업로드도, 텔레메트리도 없습니다.

---

## 요구 사항

- macOS 11.0 이상
- Apple Silicon Mac (arm64)

---

## 설치 및 첫 실행 (macOS Sequoia 15+)

SDOCX Converter는 유료 Apple Developer 인증서가 없는 오픈소스 프로젝트이므로, 첫 실행 시 macOS Gatekeeper가 보안 확인을 요청할 수 있습니다.

### 1단계: DMG 열기
다운로드한 **`SDOCX_Converter.dmg`**를 열면 Gatekeeper 대화상자(*"Apple에서 악성 소프트웨어 여부를 확인할 수 없습니다"*)가 표시될 수 있습니다.

**여는 방법 (둘 중 하나 선택):**
- **방법 A (시스템 설정)**: **완료**를 클릭 → **시스템 설정 > 개인정보 보호 및 보안** → 보안 항목에서 DMG 안내 옆의 **그래도 열기** 클릭 → Mac 암호 입력.
- **방법 B (터미널)**:
  ```bash
  xattr -cr ~/Downloads/SDOCX_Converter.dmg
  ```

### 2단계: 앱 실행
열린 DMG 창에서 앱 아이콘을 더블클릭하거나 Applications 폴더로 드래그합니다.
첫 실행에서 Gatekeeper가 다시 확인을 요청하면:

- **방법 A (시스템 설정)**: **완료** → **시스템 설정 > 개인정보 보호 및 보안** → **그래도 열기** → Mac 암호 입력.
- **방법 B (터미널)**:
  ```bash
  xattr -cr "/Applications/SDOCX Converter.app"
  ```

### 3단계: 원클릭 이동 & 자동 정리
1. **"Applications 폴더로 이동할까요?"** 안내가 나오면 **"Applications 폴더로 이동"**을 클릭합니다.
2. 앱이 `/Applications`로 이동해 실행되고, **설치용 디스크 이미지를 자동으로 마운트 해제**합니다.
3. 이후에는 안내 없이 정상적으로 실행됩니다.

---

## 업데이트

- **실행 시 자동 확인**: 새 버전이 있으면 GitHub Releases를 조용히 확인해 릴리즈 노트와 함께 원탭 다운로드 안내를 표시합니다.
- **수동 확인**: **설정 > 소프트웨어 업데이트 > 업데이트 확인**에서 언제든지 확인할 수 있습니다.
- **직접 재설치**: [Releases](https://github.com/FizzyHedgehog/sdocx-converter-macos/releases)에서 최신 `SDOCX_Converter.dmg`를 받아 `/Applications`의 앱을 교체해도 됩니다. 설정은 그대로 유지됩니다.

---

## 알려진 제한

현재 변환 엔진은 참조 문서 대비 검증을 완료했으나, 다음 항목은 아직 완성되지 않았습니다:

- **자유롭게(올가미) 자른 이미지와 스티커**는 삼성 고유 포맷 `.spi`로 저장되어 PDF에 나타나지 않습니다. 사각형 자르기는 정상 동작합니다.
- **형광펜 획**이 삼성노트 자체 PDF 내보내기보다 약 2배 진하게 렌더링됩니다.
- **회전된 여러 줄 텍스트 박스**: 회전된 텍스트 박스의 줄바꿈이 원본과 다르게 될 수 있습니다.
- **이미지 포맷**: JPEG와 PNG만 지원되며, 그 외 포맷은 지원되지 않는 포맷 오류가 발생합니다.
- **폰트 대체**: 모든 텍스트는 내장된 나눔바른고딕으로 렌더링됩니다. 삼성 기본 폰트 이외의 폰트를 사용한 노트는 줄바꿈이 밀리거나 글자 배치가 달라질 수 있습니다. (삼성 기본 폰트는 독점 폰트라 내장할 수 없습니다.)

---

## 소스에서 빌드하기

### 준비물
- macOS 11.0 이상, Xcode Command Line Tools (`xcode-select --install`)
- Rust 툴체인과 `aarch64-apple-darwin` 타깃 (변환 엔진을 다시 빌드할 때)
- `dmgbuild`와 `pillow`가 설치된 Python 3 (`pip3 install dmgbuild pillow`)

### 빌드 순서
```bash
git clone https://github.com/FizzyHedgehog/sdocx-converter-macos.git
cd sdocx-converter-macos

# 네이티브 macOS 앱 번들 빌드 (내장 엔진 바이너리 포함)
./build_native.sh

# 커스텀 레이아웃이 적용된 배포용 DMG 빌드
./build_dmg.sh
```
결과물은 `dist/SDOCX_Converter.dmg`에 생성됩니다. `build_dmg.sh`는 `dmgbuild`가 설치된 Python 인터프리터를 자동으로 찾습니다.

---

## 기술 아키텍처

```
[ UI 레이어 (Swift, AppKit / SwiftUI) ]
   ├── App.swift              (앱 생명주기, open-with 처리)
   ├── MainWindowController   (드롭 존, 변환 대기열, 일괄 요약)
   ├── MenuBarController      (메뉴 막대 모드, 백그라운드 변환)
   ├── Views / Models         (설정, 다국어, 대기열 상태)
   └── UpdateManager          (GitHub Releases 자체 업데이터)
                   │ (프로세스 실행: 번들 CLI)
                   ▼
[ 네이티브 코어 (Rust CLI: sdocx2pdf-macOS-arm64) ]
   ├── sdocx 파서               (ZIP 컨테이너 & 페이지 추출)
   ├── 획 & 도형 재구성기        (경로 & 베지어 보간)
   ├── 텍스트 레이아웃 엔진      (글리프 메트릭, 블록 흐름, 정렬)
   └── krilla 벡터 엔진         (PDF 1.7 무손실 벡터 생성)
```

- **UI**: Swift, AppKit / SwiftUI, PDFKit, UserNotifications
- **네이티브 엔진**: Rust (`sdocx2pdf` 0.4.0), arm64 단독 실행 바이너리로 미리 빌드되어 자식 프로세스로 호출
- **패키징**: `build_native.sh` + `dmgbuild` (HiDPI 배경, ad-hoc 코드 서명)
- **Finder 연동**: 번들에 포함된 퀵 액션 워크플로(`Convert SDOCX to PDF.workflow`)

---

## 크레딧 & 라이선스

- **코어 변환 엔진**: MIT License 하의 오픈소스 프로젝트 [squ1dd13/sdocx2pdf](https://github.com/squ1dd13/sdocx2pdf)(개발: **squ1dd13**)를 기반으로 합니다.
- **내장 폰트**: 나눔바른고딕, SIL Open Font License.
- **macOS GUI & 패키징**: **FizzyHedgehog** 개발.
- **MIT License**로 배포됩니다. 자세한 내용은 [LICENSE.txt](LICENSE.txt)를 참고하세요.
