#!/bin/bash
APP=~/Applications/Max.app
# поменяйте на /Applications/Max.app, если нужно
PLIST="$APP/Contents/Info.plist"

# на MBP 11,5 metal-бэкенд Qt RHI ломается о драйвер AMD R9 M370X — пустое окно;
# единственно рабочий вариант — opengl (с известным ограничением: не работают превью)
case "$(sysctl -n hw.model)" in
  MacBookPro11,5) BACKEND=opengl ;;
  *)              BACKEND=metal  ;;
esac

# 1) гарантируем наличие секции LSEnvironment и ключа QSG_RHI_BACKEND
/usr/libexec/PlistBuddy -c 'Add :LSEnvironment dict' "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :LSEnvironment:QSG_RHI_BACKEND $BACKEND" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :LSEnvironment:QSG_RHI_BACKEND string $BACKEND" "$PLIST"

# 2) снимаем карантин и переподписываем (м.б. запрос к Связке ключей — это нормально)
xattr -dr com.apple.quarantine "$APP"
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"

# 3) запускаем
open "$APP"
