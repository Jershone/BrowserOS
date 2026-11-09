# BrowserOS

BrowserOS now has two parts:

1. A React/TypeScript desktop control panel (port 5173).
2. A real Linux XFCE desktop running inside a GitHub Codespace and streamed to the browser with TigerVNC + noVNC (port 6080).

## Start the real Linux desktop

1. Open this repository in a GitHub Codespace.
2. When prompted, allow the dev container to rebuild. The custom image installs XFCE, Chromium, LibreOffice Writer/Impress, Thunar, XFCE Terminal and Task Manager.
3. Wait for the post-start script to finish.
4. Open the **Ports** tab and open **BrowserOS Linux Desktop (noVNC)** on port **6080**.
5. If needed, append `/vnc.html?autoconnect=true&resize=scale` to the forwarded URL and press **Connect**.

The forwarded port is configured as private. Keep it private; do not publish an unauthenticated remote desktop.

## Real Linux applications

The XFCE desktop has launchers for:
- Chromium browser
- LibreOffice Writer (Word-compatible document editor)
- LibreOffice Impress (PowerPoint-compatible presentation editor)
- XFCE Terminal
- Thunar file manager
- XFCE Task Manager
- Spotify Web Player (runs in Chromium)

These are actual Linux processes running in the Codespace container. Writer and Impress are Office-compatible alternatives, not Microsoft's proprietary Word/PowerPoint binaries. Spotify is the official web player in a Chromium app window.

## Codespaces runtime

A Codespace is a remote Linux development container, not a permanent personal cloud PC. It runs only while the Codespace is active and may stop after its configured idle timeout. Its compute/storage usage is subject to the user's GitHub Codespaces quota and plan. Files in the Codespace workspace persist across stop/start, but processes and the graphical session must be started again.

The Codespace desktop is accessed through GitHub's forwarded port. The React/Vite site on port 5173 and FastAPI API on port 8000 are separate from the noVNC Linux desktop on port 6080.

## GitHub Pages

GitHub Pages can host the static React control panel, but it cannot host or keep the Linux desktop process alive. The actual desktop must be accessed through the running Codespace's private forwarded port.

## Build locally

```bash
npm install
npm run dev
```
