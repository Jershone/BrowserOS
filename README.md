# BrowserOS

Obsidian Glass browser desktop running in GitHub Codespaces.

## Run
Open the Codespace terminal and run:

    npm run dev:all

Open forwarded port **5173**. The FastAPI backend runs on port **8000**. Keep both Codespaces ports private.

## Stack
- React + TypeScript + Vite
- FastAPI system-information and workspace API
- Lucide icons and custom Obsidian Glass styling

## Current status
The desktop shell, app launcher, dock, responsive layout, health indicator, system metrics and workspace file listing are implemented. Terminal is currently a safe command-preview UI, not arbitrary remote shell execution. AI Studio is a placeholder until a private Ollama endpoint is configured. Spotify opens the official Spotify web player.

Do not expose the API publicly without authentication. Do not expose an unauthenticated Ollama endpoint to the internet.
