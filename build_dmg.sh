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
# dmgbuild가 설치된 python3 인터프리터를 찾는다 (PATH의 python3에 없을 수 있음).
PYTHON_BIN=""
for candidate in python3 /Library/Frameworks/Python.framework/Versions/3.14/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c "import dmgbuild" >/dev/null 2>&1; then
    PYTHON_BIN="$candidate"
    break
  fi
done
if [ -z "$PYTHON_BIN" ]; then
  echo "ERROR: dmgbuild를 사용할 수 있는 python3를 찾지 못했습니다. 'pip3 install dmgbuild pillow'로 설치하세요." >&2
  exit 1
fi
echo "    사용 인터프리터: $PYTHON_BIN"
rm -f "$FINAL_DMG"
"$PYTHON_BIN" -m dmgbuild -s dmg_settings.py "$APP_NAME" "$FINAL_DMG"

echo "==> 5. 생성된 DMG 자체 코드 서명"
codesign --force --sign - "$FINAL_DMG"

echo "==> 6. Spotlight 중복 노출 방지를 위해 dist 폴더 내 앱 번들 정리"
rm -rf "$OUTPUT_DIR/$APP_NAME.app"

echo "==========================================="
echo "크롬 스타일 배포용 DMG 생성 완료!"
echo "1. 프로젝트 출력물: $FINAL_DMG"
echo "용량:"
du -sh "$FINAL_DMG"
echo "==========================================="
