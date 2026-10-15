# -*- coding: utf-8 -*-
# SDOCX Converter DMG Build Settings
# Chrome 스타일 대칭 레이아웃 (좌측 앱, 우측 Applications, 중앙 화살표 배경)

import os

# 볼륨 정보
volume_name = 'SDOCX Converter'
format = 'UDZO'
filesystem = 'HFS+'

# 볼륨 아이콘
badge_icon = None
icon = 'assets/app_icon.icns'

# 배경 이미지 (HiDPI Retina 지원 - 글로벌 영문 표준)
background = 'assets/dmg_background_en.tiff'

# Finder 윈도우 스타일 (깔끔한 무음/툴바 없는 Chrome 스타일)
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

# 윈도우 위치 및 크기 ((x, y), (width, height))
window_rect = ((200, 120), (640, 400))

# 뷰 옵션
default_view = 'icon-view'
icon_size = 110.0
text_size = 12.0
arrange_by = None
grid_offset = (0, 0)
grid_spacing = 100.0
scroll_position = (0.0, 0.0)

# 포함 파일
files = [
    ('dist/SDOCX Converter.app', 'SDOCX Converter.app'),
    ('LICENSE.txt', 'LICENSE.txt')
]

# Applications 바로가기 심볼릭 링크
symlinks = {
    'Applications': '/Applications'
}

# 대칭 아이콘 위치 (가운데 x=320 기준 정확한 좌우 대칭)
# 좌측: SDOCX Converter.app (x=160, y=205)
# 우측: Applications (x=480, y=205)
icon_locations = {
    'SDOCX Converter.app': (160, 205),
    'Applications': (480, 205)
}

# 파일 숨기기 (LICENSE.txt는 볼륨 루트에 포함하되 Finder GUI에서는 숨김 처리)
hide = ['LICENSE.txt']

# .app 확장자 숨기기
hide_extensions = ['SDOCX Converter.app']
