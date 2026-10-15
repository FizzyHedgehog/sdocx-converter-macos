#!/bin/bash
# SDOCX Converter 배포용 DMG 빌드 스크립트 (Chrome 스타일 대칭 디자인)
# 개인정보 익명화(FizzyHedgehog) 및 라이선스 준수 적용
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="SDOCX Converter"
DMG_NAME="SDOCX_Converter"
OUTPUT_DIR="dist"
FINAL_DMG="$OUTPUT_DIR/${DMG_NAME}.dmg"

echo "==> 1. 최신 앱 빌드 확인 및 빌드 실행"
./build_native.sh

echo "==> 2. 메타데이터 및 확장 속성 정제 후 정밀 서명"
xattr -cr "$OUTPUT_DIR/$APP_NAME.app"
xattr -cr "LICENSE.txt"
codesign --force --deep --sign - --identifier "com.fizzyhedgehog.sdocx-converter" "$OUTPUT_DIR/$APP_NAME.app"
codesign --verify --deep --strict "$OUTPUT_DIR/$APP_NAME.app"

echo "==> 3. HiDPI 배경 TIFF 생성 확인"
/usr/bin/tiffutil -cathidpicheck assets/dmg_background_en.png assets/dmg_background_en@2x.png -out assets/dmg_background_en.tiff

echo "==> 4. dmgbuild를 통한 크롬 스타일 고화질 대칭 DMG 생성"
rm -f "$FINAL_DMG"
python3 -m dmgbuild -s dmg_settings.py "$APP_NAME" "$FINAL_DMG"

echo "==> 5. 생성된 DMG 자체 코드 서명"
codesign --force --sign - "$FINAL_DMG"

echo "==========================================="
echo "크롬 스타일 배포용 DMG 생성 완료!"
echo "1. 프로젝트 출력물: $FINAL_DMG"
echo "용량:"
du -sh "$FINAL_DMG"
echo "==========================================="

if [ -f "~/.sdocx_telegram_agent/notify_telegram.py" ]; then
    python3 -c "import sys; sys.path.append('~/.sdocx_telegram_agent'); import notify_telegram; notify_telegram.send_telegram_message('🍏 <b>SDOCX Converter</b> macOS 배포용 DMG 빌드가 완료되었습니다.'); notify_telegram.send_telegram_document('$FINAL_DMG', caption='🍎 SDOCX Converter (macOS DMG)')" || true
fi
