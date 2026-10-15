#!/bin/bash
# SDOCX Converter (SwiftUI Native) 빌드 및 설치 스크립트
# 개인정보 익명화(FizzyHedgehog) 및 라이선스 준수 적용
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="SDOCX Converter"
BUNDLE_ID="com.fizzyhedgehog.sdocx-converter"
OUTPUT_DIR="dist"
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"

echo "==> 1. 이전 빌드 정리"
rm -rf "$OUTPUT_DIR" build
mkdir -p "$OUTPUT_DIR" build

echo "==> 2. Swift 소스 코드 컴파일 (arm64 네이티브 최적화 및 경로 익명화)"
swiftc -O -parse-as-library \
  -target arm64-apple-macos13.0 \
  -file-prefix-map "$HOME=/build" \
  -debug-prefix-map "$HOME=/build" \
  -file-prefix-map "$PWD=." \
  -debug-prefix-map "$PWD=." \
  -framework SwiftUI \
  -framework AppKit \
  -framework PDFKit \
  -framework UniformTypeIdentifiers \
  -framework UserNotifications \
  Sources/Models.swift \
  Sources/ConverterService.swift \
  Sources/NotificationManager.swift \
  Sources/MenuBarController.swift \
  Sources/LetsMoveManager.swift \
  Sources/Views.swift \
  Sources/App.swift \
  -o "build/$APP_NAME"

# 로컬 심볼 및 경로 제거 (Strip)
strip -u -r "build/$APP_NAME"

echo "==> 3. .app 번들 구조 생성"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "build/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "sdocx2pdf-macOS-arm64" "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/Resources/sdocx2pdf-macOS-arm64"
cp assets/app_icon.icns "$APP_BUNDLE/Contents/Resources/"
cp assets/notification_icon.png "$APP_BUNDLE/Contents/Resources/"
cp -R assets/*.workflow "$APP_BUNDLE/Contents/Resources/"
cp "LICENSE.txt" "$APP_BUNDLE/Contents/Resources/"

echo "==> 4. Info.plist 생성 (FizzyHedgehog 메타데이터 및 권한 설명)"
cat <<EOF > "$APP_BUNDLE/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>ko</string>
	<key>CFBundleDisplayName</key>
	<string>$APP_NAME</string>
	<key>CFBundleExecutable</key>
	<string>$APP_NAME</string>
	<key>CFBundleIconFile</key>
	<string>app_icon</string>
	<key>CFBundleIconName</key>
	<string>app_icon</string>
	<key>CFBundleIdentifier</key>
	<string>$BUNDLE_ID</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$APP_NAME</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleVersion</key>
	<string>1.0.0</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2026 FizzyHedgehog. All rights reserved.</string>
	<key>LSMinimumSystemVersion</key>
	<string>11.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Samsung Notes Document</string>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>Alternate</string>
			<key>CFBundleTypeIconFile</key>
			<string>app_icon.icns</string>
			<key>CFBundleTypeExtensions</key>
			<array>
				<string>sdocx</string>
			</array>
			<key>LSItemContentTypes</key>
			<array>
				<string>com.samsung.notes.sdocx</string>
				<string>public.sdocx</string>
			</array>
		</dict>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Folder</string>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>Alternate</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>public.folder</string>
			</array>
		</dict>
	</array>
	<key>UTImportedTypeDeclarations</key>
	<array>
		<dict>
			<key>UTTypeIdentifier</key>
			<string>com.samsung.notes.sdocx</string>
			<key>UTTypeDescription</key>
			<string>Samsung Notes Document</string>
			<key>UTTypeConformsTo</key>
			<array>
				<string>public.data</string>
				<string>public.content</string>
			</array>
			<key>UTTypeTagSpecification</key>
			<dict>
				<key>public.filename-extension</key>
				<array>
					<string>sdocx</string>
				</array>
			</dict>
		</dict>
	</array>
	<key>NSDesktopFolderUsageDescription</key>
	<string>SDOCX 파일을 불러오고 PDF로 변환하기 위해 데스크탑 폴더 접근 권한이 필요합니다.</string>
	<key>NSDocumentsFolderUsageDescription</key>
	<string>SDOCX 파일을 불러오고 PDF로 변환하기 위해 문서 폴더 접근 권한이 필요합니다.</string>
	<key>NSDownloadsFolderUsageDescription</key>
	<string>SDOCX 파일을 불러오고 PDF로 변환하기 위해 다운로드 폴더 접근 권한이 필요합니다.</string>
	<key>NSRemovableVolumesUsageDescription</key>
	<string>외장 드라이브의 SDOCX 파일을 불러오고 PDF로 변환하기 위해 접근 권한이 필요합니다.</string>
</dict>
</plist>
EOF

echo "==> 5. Ad-hoc 코드 서명 (개인 실명 비노출 -s -)"
xattr -cr "$APP_BUNDLE"
codesign --force --deep --sign - --identifier "$BUNDLE_ID" "$APP_BUNDLE"
codesign --verify --deep --strict "$APP_BUNDLE"

rm -rf build

echo "==========================================="
echo "빌드 및 설치 완료:"
echo "1. 로컬 빌드: $APP_BUNDLE"
echo "2. 애플리케이션: /Applications/$APP_NAME.app"
echo "앱 번들 전체 용량:"
du -sh "$APP_BUNDLE"
echo "==========================================="
