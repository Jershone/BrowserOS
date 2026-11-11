#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1
mkdir -p "$HOME/.vnc" "$HOME/.config/autostart" "$HOME/.local/share/flatpak"

# Flatpak is installed per-user, so the Software Manager can install apps
# without requiring system-wide administrator access.
if command -v flatpak >/dev/null 2>&1; then
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
fi

cat > "$HOME/.vnc/xstartup" <<'XSTART'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session cinnamon-session
XSTART
chmod 0700 "$HOME/.vnc/xstartup"

if ! tigervncserver -list 2>/dev/null | grep -qE '(^|[[:space:]])1([[:space:]]|$)|:1'; then
  tigervncserver :1 -localhost yes -SecurityTypes None \
    -geometry 1600x900 -depth 24 -xstartup "$HOME/.vnc/xstartup"
fi

if ! pgrep -u "$(id -u)" -f '[w]ebsockify.*6080' >/dev/null 2>&1; then
  nohup websockify --web=/usr/share/novnc 0.0.0.0:6080 127.0.0.1:5901 \
    > "$HOME/.vnc/websockify.log" 2>&1 &
fi

for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:6080/vnc.html >/dev/null 2>&1; then
    echo "Cinnamon desktop is ready on port 6080."
    exit 0
  fi
  sleep 1
done

echo "noVNC did not become ready. Check ~/.vnc/*.log and ~/.vnc/websockify.log." >&2
exit 1
