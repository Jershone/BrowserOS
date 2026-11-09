# BrowserOS

A KDE Plasma-inspired desktop shell built with React, TypeScript and Vite. It is designed to feel like a small desktop environment in a browser, with draggable app windows on laptop, touch-friendly full-screen windows on phone, a top app dock, a bottom panel and a session Task Manager.

## Deploy to GitHub Pages

The GitHub Actions workflow builds the Vite app and publishes `dist/` to GitHub Pages whenever `main` changes.

If Pages is not already configured, open **Repository → Settings → Pages** and set **Build and deployment → Source** to **GitHub Actions**.

## Run locally

```bash
npm install
npm run dev
```

## Included desktop windows

- Browser window with an in-window page frame (some websites block embedding).
- Spotify player using Spotify's embedded player.
- Word-style text editor with local browser storage and text export.
- PowerPoint-style slide editor with local browser storage.
- Terminal preview, file manager, desktop Settings and Task Manager.
- Window focus, drag, minimize, maximize, close and app launcher.

## Important runtime boundary

The GitHub Pages build is a **static browser desktop shell**. It does not host a Linux kernel, execute native Linux binaries, or expose the host computer's real processes. The current Terminal and Files windows are previews/local browser storage, and Task Manager lists BrowserOS windows only. Spotify playback is embedded; the Word and PowerPoint windows are built-in editors, not Microsoft's native Office applications.

A genuine Linux terminal, package manager, filesystem and native Linux desktop applications require a separate Linux VM/runtime or remote Linux host. GitHub Pages alone cannot run that server process. The app UI is structured so that a future Linux runtime can be connected without presenting preview data as real system processes.

## Technology

- React + TypeScript + Vite
- Lucide icons
- Responsive desktop window manager and CSS theme
- GitHub Actions + GitHub Pages
