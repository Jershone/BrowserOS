#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"
HOME_DIR="${HOME:?HOME is not set}"
APP_DIR="$HOME_DIR/.local/share/applications"
DOCK_DIR="$HOME_DIR/.config/plank/dock1/launchers"
AUTO_DIR="$HOME_DIR/.config/autostart"
WALLPAPER="/usr/share/backgrounds/browseros-wallpaper.svg"

mkdir -p "$APP_DIR" "$DOCK_DIR" "$AUTO_DIR" "$HOME_DIR/.config/picom" \
         "$HOME_DIR/Desktop" "$HOME_DIR/Documents" "$HOME_DIR/Downloads" \
         "$HOME_DIR/Music" "$HOME_DIR/Pictures" "$HOME_DIR/Public" \
         "$HOME_DIR/Templates" "$HOME_DIR/Videos" "$HOME_DIR/.config/xfce4/terminal"

write_app() {
  local id="$1" name="$2" exec_line="$3" icon="$4" comment="$5"
  cat > "$APP_DIR/$id.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
Icon=$icon
Terminal=false
Categories=Utility;
StartupNotify=true
EOF
  chmod 0755 "$APP_DIR/$id.desktop"
  cat > "$DOCK_DIR/$id.dockitem" <<EOF
[PlankItemsDockItemPreferences]
Launcher=file://$APP_DIR/$id.desktop
EOF
}

write_app "browseros-chromium" "Chromium Browser" "chromium --no-sandbox --disable-dev-shm-usage %U" "chromium" "Real Chromium browser running in Linux"
write_app "browseros-writer" "LibreOffice Writer" "libreoffice --writer %U" "libreoffice-writer" "Linux word processor"
write_app "browseros-impress" "LibreOffice Impress" "libreoffice --impress %U" "libreoffice-impress" "Linux presentation editor"
write_app "browseros-terminal" "Terminal" "xfce4-terminal" "utilities-terminal" "Real Linux terminal"
write_app "browseros-files" "Files" "thunar" "system-file-manager" "Linux file manager"
write_app "browseros-task-manager" "Task Manager" "xfce4-taskmanager" "utilities-system-monitor" "Linux process manager"
write_app "browseros-settings" "Settings" "xfce4-settings-manager" "preferences-system" "Desktop settings"
write_app "browseros-editor" "Text Editor" "mousepad" "accessories-text-editor" "Linux text editor"

# Put launchers on the real XFCE desktop as well as in the dock.
for id in browseros-chromium browseros-writer browseros-impress browseros-terminal browseros-files browseros-task-manager browseros-settings; do
  ln -sf "$APP_DIR/$id.desktop" "$HOME_DIR/Desktop/$id.desktop"
done

# Use a dark, low-contrast desktop chrome and matching icons.
set_xfconf() {
  local channel="$1" property="$2" type="$3" value="$4"
  xfconf-query -c "$channel" -p "$property" --create -t "$type" -s "$value" >/dev/null 2>&1 || true
}
for attempt in $(seq 1 25); do
  if xfconf-query -c xsettings -p /Net/ThemeName >/dev/null 2>&1; then break; fi
  sleep 1
done

set_xfconf xsettings /Net/ThemeName string "Arc-Dark"
set_xfconf xsettings /Net/IconThemeName string "Papirus-Dark"
set_xfconf xsettings /Gtk/FontName string "Noto Sans 10"
set_xfconf xfwm4 /general/theme string "Arc-Dark"
set_xfconf xfwm4 /general/title_font string "Noto Sans Bold 9"
set_xfconf xfwm4 /general/use_compositing bool "false"

# Set the same custom wallpaper on every detected XFCE workspace/monitor.
if [ -f "$WALLPAPER" ]; then
  for property in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep '/last-image$' || true); do
    set_xfconf xfce4-desktop "$property" string "$WALLPAPER"
  done
  set_xfconf xfce4-desktop /backdrop/screen0/monitor0/workspace0/last-image string "$WALLPAPER"
  set_xfconf xfce4-desktop /backdrop/screen0/monitor0/workspace0/image-style int "5"
fi

# A dark translucent terminal, not a browser imitation.
cat > "$HOME_DIR/.config/xfce4/terminal/terminalrc" <<'TERM'
[Configuration]
FontName=DejaVu Sans Mono 10
MiscDefaultGeometry=92x28
MiscAlwaysShowTabs=TRUE
ColorForeground=#d7edf0
ColorBackground=#142e36
ColorCursor=#9ee4d4
ColorPalette=#26343d;#ed6a68;#8fcf9a;#e5c77b;#77b9e8;#b69de0;#71d2ce;#d8e5e8;#596a73;#f27b78;#a8e0ad;#f3d995;#92c9f1;#c6b1ed;#8be0dc;#f3fbfb
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=0.88
TERM

# XRender compositor supports the software-rendered Codespaces display.
cat > "$HOME_DIR/.config/picom.conf" <<'PICOM'
backend = "xrender";
vsync = true;
shadow = true;
shadow-radius = 18;
shadow-opacity = 0.46;
shadow-offset-x = -10;
shadow-offset-y = -10;
fading = true;
fade-in-step = 0.04;
fade-out-step = 0.04;
inactive-opacity = 0.94;
active-opacity = 0.97;
frame-opacity = 0.94;
detect-client-opacity = true;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
wintypes: { tooltip = { fade = true; shadow = true; opacity = 0.96; }; };
PICOM

# Make the dock a centered launcher bar. Ignore settings unavailable in an older Plank build.
if gsettings list-schemas 2>/dev/null | grep -q '^net.launchpad.plank.docks.dock1$'; then
  gsettings set net.launchpad.plank.docks.dock1 position "'bottom'" || true
  gsettings set net.launchpad.plank.docks.dock1 alignment "'center'" || true
  gsettings set net.launchpad.plank.docks.dock1 icon-size 42 || true
  gsettings set net.launchpad.plank.docks.dock1 hide-mode "'intelligent'" || true
  gsettings set net.launchpad.plank.docks.dock1 theme "'Transparent'" || true
fi

# Start visual effects and dock only once per desktop session.
if ! pgrep -u "$(id -u)" -x picom >/dev/null 2>&1; then
  picom --config "$HOME_DIR/.config/picom.conf" --daemon || true
fi
if ! pgrep -u "$(id -u)" -x plank >/dev/null 2>&1; then
  plank >/tmp/browseros-plank.log 2>&1 &
fi

# The reference layout opens the real file manager and terminal as desktop windows.
sleep 2
if ! pgrep -u "$(id -u)" -x thunar >/dev/null 2>&1; then thunar "$HOME_DIR" >/tmp/browseros-thunar.log 2>&1 & fi
sleep 2
wmctrl -r "Home" -e 0,75,90,660,420 >/dev/null 2>&1 || true
if ! pgrep -u "$(id -u)" -f '[x]fce4-terminal' >/dev/null 2>&1; then
  xfce4-terminal --disable-server --title="BrowserOS Terminal" --geometry=88x27+800+185 >/tmp/browseros-terminal.log 2>&1 &
fi

echo "BrowserOS desktop session configured."
