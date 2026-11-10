#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1
mkdir -p "$HOME/.vnc" "$HOME/.config/autostart"

# GNOME Software talks to PackageKit over the system D-Bus. Containers do not
# boot systemd, so Codespaces must start the system bus explicitly. The
# devcontainer user has passwordless sudo for this system-level service.
if [ ! -S /run/dbus/system_bus_socket ]; then
  sudo -n mkdir -p /run/dbus
  sudo -n dbus-daemon --system --fork
fi

# Fail early with a useful message instead of showing an App Store window
# that cannot connect to PackageKit.
if [ ! -S /run/dbus/system_bus_socket ]; then
  echo "System D-Bus did not start; GNOME Software cannot connect to PackageKit." >&2
  exit 1
fi

cat > "$HOME/.vnc/xstartup" <<'XSTART'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
XSTART
chmod 0700 "$HOME/.vnc/xstartup"

cat > "$HOME/.config/autostart/browseros-session.desktop" <<'AUTOSTART'
[Desktop Entry]
Type=Application
Name=BrowserOS Desktop Setup
Comment=Apply BrowserOS theme and launch native Linux desktop tools
Exec=/usr/local/bin/browseros-session-setup
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
NoDisplay=true
AUTOSTART

# The VNC server listens only on localhost. The only browser entry point is
# the Codespaces-forwarded, private noVNC port (6080).
if ! tigervncserver -list 2>/dev/null | grep -qE '(^|[[:space:]])1([[:space:]]|$)|:1'; then
  tigervncserver :1 -localhost yes -SecurityTypes None \
    -geometry 1600x900 -depth 24 -xstartup "$HOME/.vnc/xstartup"
fi

if ! pgrep -u "$(id -u)" -f '[w]ebsockify.*6080' >/dev/null 2>&1; then
  nohup websockify --web=/usr/share/novnc 0.0.0.0:6080 127.0.0.1:5901 \
    > "$HOME/.vnc/websockify.log" 2>&1 &
fi

# Wait briefly for the web desktop endpoint to listen.
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:6080/vnc.html >/dev/null 2>&1; then
    echo "BrowserOS Linux desktop is ready on port 6080."
    exit 0
  fi
  sleep 1
done

echo "noVNC did not become ready. Check ~/.vnc/*.log and ~/.vnc/websockify.log." >&2
exit 1
