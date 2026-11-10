import { useMemo } from 'react';
import { ArrowUpRight, Monitor, Terminal, Folder, Globe, FileText, Presentation, Activity, ExternalLink, Info } from 'lucide-react';

function getDesktopUrl() {
  const current = new URL(window.location.href);
  const host = current.hostname;
  if (host.includes('-5173.')) {
    current.hostname = host.replace('-5173.', '-6080.');
    current.port = '';
  } else if (host === 'localhost' || host === '127.0.0.1') {
    current.port = '6080';
  }
  current.pathname = '/vnc.html';
  current.search = '?autoconnect=true&resize=scale';
  current.hash = '';
  return current.toString();
}

export default function App() {
  const desktopUrl = useMemo(getDesktopUrl, []);
  const onCodespaces = /app\.github\.dev$/.test(window.location.hostname);
  const local = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

  return (
    <main className="portal">
      <div className="portal-wallpaper"/>
      <header className="portal-header">
        <div className="portal-brand"><span className="brand-mark"><Monitor size={19}/></span><span>BrowserOS</span><small>LINUX DESKTOP</small></div>
        <a href="https://github.com/Jershone/BrowserOS" target="_blank" rel="noreferrer">Source code <ExternalLink size={14}/></a>
      </header>

      <section className="portal-main">
        <div className="eyebrow"><span/> REAL LINUX SESSION</div>
        <h1>Your Linux desktop.<br/><em>Inside your browser.</em></h1>
        <p className="portal-lede">BrowserOS streams a real XFCE desktop running in your GitHub Codespace. The terminal, file manager, browser and office applications are Linux programs running in the remote environment.</p>
        <a className="launch-desktop" href={desktopUrl}><Monitor size={18}/> Open Linux desktop <ArrowUpRight size={17}/></a>
        {!onCodespaces && !local && <div className="portal-warning"><Info size={16}/> This is the static project page. Start the Codespace and open its private port 6080 to connect to Linux.</div>}
        <div className="portal-note">When the Codespace is running, this opens the remote desktop stream — not a set of simulated application windows.</div>
      </section>

      <section className="native-apps">
        <div className="apps-heading"><span>INSTALLED IN THE LINUX CONTAINER</span><small>REAL DESKTOP APPLICATIONS</small></div>
        <div className="native-grid">
          <div><Globe/><b>Chromium</b><small>Linux browser</small></div>
          <div><FileText/><b>LibreOffice Writer</b><small>Document editor</small></div>
          <div><Presentation/><b>LibreOffice Impress</b><small>Presentation editor</small></div>
          <div><Terminal/><b>XFCE Terminal</b><small>Real shell</small></div>
          <div><Folder/><b>Thunar</b><small>Linux filesystem</small></div>
          <div><Activity/><b>Task Manager</b><small>Linux processes</small></div>
        </div>
      </section>
      <footer className="portal-footer"><span>XFCE · TigerVNC · noVNC</span><span>Codespaces provides the Linux container; this page is only its launcher.</span></footer>
    </main>
  );
}