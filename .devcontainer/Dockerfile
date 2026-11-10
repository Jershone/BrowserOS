FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# A real Linux desktop session and real Linux applications.
RUN rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.sources \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal xfce4-taskmanager thunar thunar-archive-plugin tumbler \
    chromium libreoffice-writer libreoffice-impress mousepad \
    tigervnc-standalone-server tigervnc-common novnc websockify \
    plank picom wmctrl \
    papirus-icon-theme arc-theme gtk2-engines-murrine \
    dbus-x11 x11-xserver-utils x11-utils xauth curl \
    fonts-noto-core fonts-noto-color-emoji fonts-liberation fonts-dejavu-core \
    librsvg2-common desktop-file-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY wallpaper.svg /usr/share/backgrounds/browseros-wallpaper.svg
COPY browseros-session-setup.sh /usr/local/bin/browseros-session-setup
RUN chmod 0755 /usr/local/bin/browseros-session-setup

