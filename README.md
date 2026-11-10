# BrowserOS

BrowserOS is a **real Linux desktop session** running inside a GitHub Codespaces development container and streamed to a browser with TigerVNC + noVNC. The desktop is XFCE, styled to match the supplied BrowserOS reference image.

This is not a JavaScript operating-system simulation:
- The visible windows are native Linux windows managed by XFCE.
- The terminal is a real shell in the Codespaces Linux container.
- Thunar browses the real container filesystem.
- Chromium, LibreOffice Writer, LibreOffice Impress and XFCE Task Manager are installed Linux programs.
- The XFCE task manager lists actual processes in the Codespaces container.

**Kernel note:** a Codespaces dev container is a Linux container and shares the host's Linux kernel. It is a real Linux userspace/desktop with real Linux processes, but it does not boot a separate VM kernel inside Codespaces.

## Open the real desktop

1. Open this repository: https://github.com/Jershone/BrowserOS
2. Create a Codespace on the `main` branch, or open your existing Codespace.
3. After pulling these changes, run **Codespaces: Rebuild Container** from the Command Palette. This is required because the desktop packages are installed in the Docker image.
4. Wait for the container rebuild and the post-start command. It launches XFCE, TigerVNC and noVNC.
5. Codespaces automatically forwards port **6080** and opens the browser desktop. If it does not, open the **Ports** tab and open **BrowserOS Linux Desktop**.
6. The noVNC page connects to the VNC desktop. If needed, use `/vnc.html?autoconnect=true&resize=scale` on the forwarded port URL.

Keep port 6080 **Private**. The VNC server itself listens only on localhost inside the container; the browser entry point is the Codespaces forwarded port. Do not change it to Public.

## Real installed programs

- **Chromium** — actual Linux browser process.
- **LibreOffice Writer** — actual Linux word processor; opens and saves common Word-compatible formats.
- **LibreOffice Impress** — actual Linux presentation editor; opens and saves common PowerPoint-compatible formats.
- **XFCE Terminal** — real bash shell; commands execute in the Codespaces Linux container.
- **Thunar** — real Linux file manager for the container filesystem.
- **XFCE Task Manager** — real process monitor for the Codespaces container.
- **Mousepad** — Linux text editor.

LibreOffice is not Microsoft's proprietary Word or PowerPoint, but it is a native Linux office suite.

The desktop starts with Thunar and Terminal open, a dark Arc window theme, Papirus icons, a custom teal/blue geometric wallpaper, a centered Plank dock and a bottom XFCE panel.

## Runtime and persistence

- The Linux desktop runs only while the Codespace is running. Codespaces can stop after an idle timeout.
- Files saved under the Codespaces workspace/home persist according to the Codespaces storage lifecycle; live graphical processes are restarted when the container starts again.
- The noVNC screen is a remote desktop stream, not an iframe for each app.
- GitHub Pages only hosts the static project/launcher page. It does not host the running Linux desktop.

## Local development

```bash
npm install
npm run dev
```

To build the container image locally:

```bash
docker build -f .devcontainer/Dockerfile .devcontainer
```
