FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Cinnamon desktop with a familiar Linux Mint-style desktop experience.
# Codespaces remains Debian Bookworm underneath; this installs Cinnamon,
# not the complete Linux Mint distribution.
RUN rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.sources \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    cinnamon-core cinnamon-session cinnamon-control-center cinnamon-settings-daemon \
    nemo nemo-fileroller gnome-terminal gnome-system-monitor \
    firefox-esr libreoffice-writer libreoffice-impress mousepad \
    flatpak gnome-software gnome-software-plugin-flatpak \
    tigervnc-standalone-server tigervnc-common novnc websockify \
    dbus-x11 x11-xserver-utils x11-utils xauth curl ca-certificates \
    fonts-noto-core fonts-noto-color-emoji fonts-dejavu-core \
    file-roller xdg-utils desktop-file-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY browser-os /usr/local/bin/browser-os
COPY browseros-app-store /usr/local/bin/browseros-app-store
RUN chmod 0755 /usr/local/bin/browser-os /usr/local/bin/browseros-app-store
