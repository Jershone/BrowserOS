# BrowserOS Mint

BrowserOS Mint is a real Cinnamon Linux desktop running in GitHub Codespaces and streamed to your browser with TigerVNC + noVNC.

**Important:** Codespaces dev containers run on Debian Linux. This project installs the genuine Cinnamon desktop environment and a familiar Mint-style app experience on Debian; it is not the full Linux Mint distribution or a separate Linux kernel.

## Desktop

- Cinnamon desktop, panels, menu and settings
- Nemo file manager
- GNOME Terminal
- Firefox ESR browser
- LibreOffice Writer and Impress
- GNOME System Monitor
- Mousepad text editor
- GNOME Software with Flatpak support
- Flatpak + Flathub configured for the Codespaces user

This is a standard desktop environment, not a custom BrowserOS skin.

## Install applications

Open **Software** from the Cinnamon menu to browse applications. Flatpak and Flathub are enabled for the current user. Linux desktop apps distributed on Flathub can be installed and updated there.

Other common Linux formats:
- `.deb`: Debian package installers (system package installation may require administrator access).
- `.AppImage`: portable application bundles; some require marking the file executable.
- Flatpak: install through GNOME Software or the Flatpak command.

Windows `.exe` installers are not native Linux applications and generally do not install directly.

## Start in Codespaces

1. Open [Create BrowserOS Mint Codespace](https://github.com/codespaces/new?repo=Jershone/BrowserOS&ref=linux-mint).
2. Create the Codespace. The devcontainer builds the desktop image.
3. Wait for the post-start command. Codespaces forwards port **6080** and opens the noVNC page.
4. If it does not open automatically, open the **Ports** tab and open **Cinnamon Desktop**. Keep the port **Private**.

For an existing Codespace on this branch, pull the latest changes and run **Codespaces: Rebuild Container**.

## One-command start

After the container has been built, run this in the Codespaces terminal:

```bash
browser-os run
```

Useful commands:

```bash
browser-os status
browser-os help
```

## Runtime and persistence

The desktop runs while the Codespace is running. Codespaces can stop after an idle timeout. Treat open windows and unsaved work as temporary. Files stored in the repository workspace persist according to normal Codespaces storage, but this is not a permanently running personal PC.

## References

- [Linux Mint desktop editions](https://linuxmint-installation-guide.readthedocs.io/en/latest/choose.html)
- [Flathub setup for Linux Mint](https://flathub.org/en/setup/Linux%20Mint)
- [Flathub installation guide](https://docs.flathub.org/docs/for-users/installation)
