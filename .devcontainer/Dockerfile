FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xfce4-terminal xfce4-taskmanager thunar \
    tigervnc-standalone-server tigervnc-common novnc websockify \
    chromium libreoffice-writer libreoffice-impress \
    papirus-icon-theme arc-theme dbus-x11 x11-xserver-utils \
    fonts-noto fonts-liberation fonts-dejavu-core \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV DISPLAY=:1
