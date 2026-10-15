# SDOCX Converter for macOS

Fast, native macOS GUI app and Finder Quick Action to convert Samsung Notes (`.sdocx`) files to lossless vector PDFs.


<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2011.0%2B-blue" alt="macOS 11.0+" />
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon%20(arm64)-orange" alt="Apple Silicon" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-F05138" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License" />
</p>

---

## Why SDOCX Converter? (True Vector PDFs vs. Rasterized Bitmaps)

When exporting notes directly to PDF within the Samsung Notes application, handwritten strokes and highlights are frequently rasterized into low-resolution bitmap images, causing noticeable pixelation and blur when zooming in or printing.

**SDOCX Converter** solves this issue fundamentally: by reading the raw `.sdocx` container and reconstructing all pen strokes, mathematical curves, and markers through a native vector engine, the output PDF contains true mathematical vector paths. Your notes remain razor-sharp at any zoom level and on high-density Retina / 4K displays.

---

## Key Features

- **Infinitely Scalable Vector Quality**: Preserves vector accuracy for all handwritten strokes without raster blur.
- **Native Apple Silicon (ARM64) Performance**: Fast offline conversion powered by Swift and native binaries. Zero Electron or Python runtime dependencies for end users.
- **Batch & Recursive Folder Conversion**: Drag & drop multiple `.sdocx` files or entire folders. Nested subdirectories are automatically discovered and queued.
- **Finder Quick Action Integration**: Right-click any `.sdocx` file or folder in Finder and convert to PDF directly without launching the main window.
- **System Notifications**: Native macOS banner notifications alert you when conversions complete in the background.
- **1-Click Auto Install & Clean DMG Ejection**: On first launch, the app offers to move itself to `/Applications` and automatically unmounts the disk image cleanly.
- **100% Offline & Private**: Converts all documents locally on your Mac. No network connections or telemetry.

---

## Installation & First-Time Launch (macOS Sequoia 15+)

Because SDOCX Converter is an open-source project without a paid Apple Developer certificate, macOS Gatekeeper may prompt security confirmations on first launch.

Follow these standard steps:

---

### Step 1: Open the DMG
When opening the downloaded **`SDOCX_Converter.dmg`**, macOS may display a Gatekeeper dialog (*"Apple cannot check it for malicious software"*).

**How to open (Choose either option):**
- **Option A (System Settings)**: Click **Done** -> Go to **System Settings > Privacy & Security** -> Scroll to Security and click **Open Anyway** next to the DMG prompt -> Enter your Mac password.
- **Option B (Terminal)**: Open Terminal and run:
  ```bash
  xattr -cr ~/Downloads/SDOCX_Converter.dmg
  ```

---

### Step 2: Launch the App
Inside the opened DMG window, double-click the app icon or drag it to the Applications folder.  
If prompted by Gatekeeper on the first run:

**How to open (Choose either option):**
- **Option A (System Settings)**: Click **Done** -> Go to **System Settings > Privacy & Security** -> Click **Open Anyway** -> Enter your Mac password.
- **Option B (Terminal)**: Open Terminal and run:
  ```bash
  xattr -cr "/Applications/SDOCX Converter.app"
  ```

---

### Step 3: 1-Click Move & Automatic Cleanup
1. When prompted with **"Move to Applications Folder?"**, click **"Move to Applications Folder"**.
2. The app moves itself to `/Applications`, launches, and **automatically unmounts the installation disk image (DMG)**.
3. Subsequent launches will open normally without any prompts.

---

## Building from Source

### Prerequisites
- macOS 11.0 or newer
- Xcode Command Line Tools (`xcode-select --install`)
- Python 3 with `dmgbuild` and `pillow` (`pip3 install dmgbuild pillow`)

### Build Steps
```bash
git clone https://github.com/FizzyHedgehog/sdocx-converter.git
cd sdocx-converter

# Build the native macOS application bundle
./build_native.sh

# Build distribution DMG with custom layout
./build_dmg.sh
```
The output `.dmg` will be generated in `dist/SDOCX_Converter.dmg`.

---

## Credits & License

- **Core Converter Engine**: Based on the open-source project [squ1dd13/sdocx2pdf](https://github.com/squ1dd13/sdocx2pdf) by **squ1dd13**, licensed under the **MIT License**.
- **macOS GUI & Packaging**: Developed by **FizzyHedgehog**.
- Distributed under the terms of the **MIT License**. See [LICENSE.txt](LICENSE.txt) for details.
