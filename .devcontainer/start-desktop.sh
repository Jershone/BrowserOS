#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1
mkdir -p "$HOME/.vnc" "$HOME/Desktop"

cat > "$HOME/.vnc/xstartup" <<'XSTART'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
XSTART
chmod +x "$HOME/.vnc/xstartup"

# Create useful launchers on the Linux desktop.
make_launcher() {
  local filename="$1" name="$2" exec_cmd="$3" icon="$4"
  cat > "$HOME/Desktop/$filename.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Exec=$exec_cmd
Icon=$icon
Terminal=false
Categories=Utility;
EOF
  chmod +x "$HOME/Desktop/$filename.desktop"
}
make_launcher browseros-browser "Browser (Chromium)" "chromium --no-sandbox --disable-dev-shm-usage" chromium
make_launcher browseros-writer "Writer" "libreoffice --writer" libreoffice-writer
make_launcher browseros-impress "Impress" "libreoffice --impress" libreoffice-impress
make_launcher browseros-terminal "Terminal" "xfce4-terminal" utilities-terminal
make_launcher browseros-files "Files" "thunar" system-file-manager
make_launcher browseros-taskmgr "Task Manager" "xfce4-taskmanager" utilities-system-monitor
make_launcher browseros-spotify "Spotify Web Player" "chromium --no-sandbox --app=https://open.spotify.com" multimedia-audio-player

# Apply a dark, clean desktop theme and a consistent icon set.
xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark" --create -t string 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" --create -t string 2>/dev/null || true
xfconf-query -c xfwm4 -p /general/theme -s "Arc-Dark" --create -t string 2>/dev/null || true

# Start a real XFCE desktop in a virtual display.
if ! pgrep -f "Xtigervnc :1" >/dev/null 2>&1; then
  vncserver :1 -localhost yes -geometry 1600x900 -depth 24 -SecurityTypes None
fi

# Expose the VNC framebuffer through a browser-compatible WebSocket endpoint.
if ! pgrep -f "websockify.*6080" >/dev/null 2>&1; then
  nohup websockify --web=/usr/share/novnc 6080 localhost:5901 > "$HOME/.vnc/websockify.log" 2>&1 &
fi

echo "BrowserOS Linux desktop started."
echo "Open forwarded port 6080 and choose /vnc.html?autoconnect=true&resize=scale."
