#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"
HOME_DIR="${HOME:?HOME is not set}"
mkdir -p "$HOME_DIR/.cache"
exec >> "$HOME_DIR/.cache/browseros-session-setup.log" 2>&1

APP_DIR="$HOME_DIR/.local/share/applications"
DOCK_DIR="$HOME_DIR/.config/plank/dock1/launchers"
WALLPAPER="/usr/share/backgrounds/browseros-wallpaper.svg"

mkdir -p "$APP_DIR" "$DOCK_DIR" "$HOME_DIR/Desktop" "$HOME_DIR/Documents" \
  "$HOME_DIR/Downloads" "$HOME_DIR/Music" "$HOME_DIR/Pictures" \
  "$HOME_DIR/Public" "$HOME_DIR/Templates" "$HOME_DIR/Videos" \
  "$HOME_DIR/.config/xfce4/terminal"

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
write_app "browseros-app-store" "App Store" "gnome-software" "org.gnome.Software" "Browse and install applications from Debian repositories"
write_app "browseros-software" "Synaptic Package Manager" "xfce4-terminal --title=Synaptic\ Package\ Manager --command='sudo synaptic'" "synaptic" "Advanced Debian package manager"

for id in browseros-chromium browseros-writer browseros-impress browseros-terminal browseros-files browseros-task-manager browseros-settings browseros-app-store browseros-software; do
  ln -sf "$APP_DIR/$id.desktop" "$HOME_DIR/Desktop/$id.desktop"
done

set_xfconf() {
  local channel="$1" property="$2" type="$3" value="$4"
  xfconf-query -c "$channel" -p "$property" --create -t "$type" -s "$value" >/dev/null 2>&1 || true
}

# Let XFCE create its display/workspace properties first.
for attempt in $(seq 1 30); do
  if xrandr --query 2>/dev/null | grep -q ' connected'; then break; fi
  sleep 1
done

set_xfconf xsettings /Net/ThemeName string "Arc-Dark"
set_xfconf xsettings /Net/IconThemeName string "Papirus-Dark"
set_xfconf xsettings /Gtk/FontName string "Noto Sans 10"
set_xfconf xfwm4 /general/theme string "Arc-Dark"
set_xfconf xfwm4 /general/title_font string "Noto Sans Bold 9"
# XFCE's own compositor handles the translucent native windows.
set_xfconf xfwm4 /general/use_compositing bool "true"

# XFCE uses the XRandR connector name in the wallpaper property. A VNC
# display is normally VNC-0, not monitor0; create the exact property on every
# workspace so switching workspaces keeps the BrowserOS wallpaper.
if [ -f "$WALLPAPER" ]; then
  while read -r monitor; do
    [ -n "$monitor" ] || continue
    for workspace in 0 1 2 3; do
      set_xfconf xfce4-desktop "/backdrop/screen0/monitor${monitor}/workspace${workspace}/last-image" string "$WALLPAPER"
      set_xfconf xfce4-desktop "/backdrop/screen0/monitor${monitor}/workspace${workspace}/image-style" int "5"
      set_xfconf xfce4-desktop "/backdrop/screen0/monitor${monitor}/workspace${workspace}/rgba1" int "0"
    done
  done < <(xrandr --query 2>/dev/null | awk '$2 == "connected" {print $1}')
  xfdesktop --reload >/dev/null 2>&1 || true
fi

# Keep the desktop itself clear, like the reference image.
set_xfconf xfce4-desktop /desktop-icons/style int "0"

# Put the main XFCE system panel at the bottom edge.
set_xfconf xfce4-panel /panels/panel-1/position string "p=12;x=800;y=0"
set_xfconf xfce4-panel /panels/panel-1/length int "100"
set_xfconf xfce4-panel /panels/panel-1/length-adjust bool "false"
set_xfconf xfce4-panel /panels/panel-1/size int "26"
set_xfconf xfce4-panel /panels/panel-1/position-locked bool "true"
# Keep XFCE's system panel available but hidden; Plank is the visible Dock.
set_xfconf xfce4-panel /panels/panel-1/autohide-behavior int "2"

# The base devcontainer has an inherited second mini-panel. Remove it so
# Plank is the only centered dock and XFCE panel-1 is the bottom system bar.
xfconf-query -c xfce4-panel -p /panels --force-array -t int -s 1 >/dev/null 2>&1 || true
xfconf-query -c xfce4-panel -p /panels/panel-2 -rR >/dev/null 2>&1 || true
xfce4-panel --restart >/tmp/browseros-panel.log 2>&1 || true

# Native terminal colors.
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

# Configure Plank as the centered floating application dock, just above
# the bottom XFCE system panel.
PLANK_SCHEMA="net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/"
if gsettings list-schemas 2>/dev/null | grep -q '^net.launchpad.plank.dock.settings$'; then
  gsettings set "$PLANK_SCHEMA" position "'bottom'" || true
  gsettings set "$PLANK_SCHEMA" alignment "'center'" || true
  gsettings set "$PLANK_SCHEMA" items-alignment "'center'" || true
  # macOS-inspired floating Dock: larger icons, magnification and a glass-like
  # transparent background, with a small gap from the screen edge.
  gsettings set "$PLANK_SCHEMA" icon-size "54" || true
  gsettings set "$PLANK_SCHEMA" zoom-enabled "true" || true
  gsettings set "$PLANK_SCHEMA" zoom-percent "155" || true
  gsettings set "$PLANK_SCHEMA" offset "12" || true
  gsettings set "$PLANK_SCHEMA" hide-mode "'intelligent'" || true
  gsettings set "$PLANK_SCHEMA" theme "'Transparent'" || true
  gsettings set "$PLANK_SCHEMA" show-dock-item "false" || true
fi
if ! pgrep -u "$(id -u)" -x plank >/dev/null 2>&1; then
  plank >/tmp/browseros-plank.log 2>&1 &
fi

# Open and place actual Linux desktop windows like the reference image.
sleep 3
thunar "$HOME_DIR" >/tmp/browseros-thunar.log 2>&1 &
sleep 3

# Thunar's title is "vscode - Thunar"; use WM_CLASS rather than a guessed title.
thunar_window="$(wmctrl -lx | awk 'tolower($0) ~ /thunar/ {print $1; exit}')"
if [ -n "$thunar_window" ]; then
  wmctrl -ir "$thunar_window" -e 0,90,100,660,445 || true
fi

# The terminal is a real interactive XFCE Terminal window on the right.
xfce4-terminal --disable-server --title="BrowserOS Terminal" --geometry=88x27+800+240 >/tmp/browseros-terminal.log 2>&1 &
sleep 3
terminal_window="$(wmctrl -l | awk 'tolower($0) ~ /browseros terminal/ {print $1; exit}')"
if [ -n "$terminal_window" ]; then
  wmctrl -ir "$terminal_window" -e 0,810,318,730,445 || true
fi

# Record the effective settings and window list for the CI verification artifact.
xrandr --query > "$HOME_DIR/.cache/browseros-xrandr.txt" 2>&1 || true
xfconf-query -c xfce4-desktop -lv > "$HOME_DIR/.cache/browseros-wallpaper-settings.txt" 2>&1 || true
xfconf-query -c xfce4-panel -lv > "$HOME_DIR/.cache/browseros-panel-settings.txt" 2>&1 || true
wmctrl -lG > "$HOME_DIR/.cache/browseros-windows.txt" 2>&1 || true
echo "BrowserOS desktop session configured."
