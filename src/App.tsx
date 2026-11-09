import { useEffect, useMemo, useRef, useState, type FormEvent, type PointerEvent } from 'react';
import { Activity, BatteryFull, Bold, ChevronLeft, ChevronRight, Command, FileText, Folder, Globe, HardDrive, Italic, LayoutGrid, List, Maximize2, Menu, Minimize2, Music2, Plus, Presentation, RefreshCw, Search, Settings, ShieldCheck, Terminal, Underline, Wifi, Volume2, X, Download, Play, Trash2, Monitor, type LucideIcon } from 'lucide-react';

type AppId = 'browser' | 'spotify' | 'word' | 'powerpoint' | 'terminal' | 'files' | 'taskmgr' | 'settings';
type Win = { id: AppId; x: number; y: number; width: number; height: number; z: number; minimized?: boolean; maximized?: boolean };
type AppDef = { id: AppId; name: string; icon: LucideIcon; color: string; subtitle: string };
const APPS: AppDef[] = [
 {id:'browser',name:'Chrome',icon:Globe,color:'#65b6ef',subtitle:'Web browser'},
 {id:'spotify',name:'Spotify',icon:Music2,color:'#55d58a',subtitle:'Music player'},
 {id:'word',name:'Word',icon:FileText,color:'#63a5f5',subtitle:'Documents'},
 {id:'powerpoint',name:'PowerPoint',icon:Presentation,color:'#f39a75',subtitle:'Presentations'},
 {id:'terminal',name:'Terminal',icon:Terminal,color:'#b8b7ff',subtitle:'Command line preview'},
 {id:'files',name:'Dolphin Files',icon:Folder,color:'#7fa8e9',subtitle:'File manager'},
 {id:'taskmgr',name:'Task Manager',icon:Activity,color:'#e5bd76',subtitle:'Running apps'},
 {id:'settings',name:'Settings',icon:Settings,color:'#adb6c9',subtitle:'Desktop preferences'}
];
const initialText = 'Welcome to BrowserOS Word.\n\nCreate something great. Your document is stored in this browser on this device.';
const defaultSlides = ['Welcome to BrowserOS','Your ideas, beautifully presented','Thank you!'];

export default function App() {
 const [windows,setWindows]=useState<Win[]>([]);
 const [zTop,setZTop]=useState(10);
 const [clock,setClock]=useState(new Date());
 const [launcher,setLauncher]=useState(false);
 const drag=useRef<{id:AppId;x:number;y:number;sx:number;sy:number}|null>(null);
 const visibleWindows=windows.filter(w=>!w.minimized).sort((a,b)=>a.z-b.z);
 const active=visibleWindows[visibleWindows.length-1]?.id;
 useEffect(()=>{const t=window.setInterval(()=>setClock(new Date()),1000);return()=>window.clearInterval(t)},[]);
 const openApp=(id:AppId)=>{
  setWindows(current=>{
   const nextZ=zTop+1;setZTop(nextZ);
   const existing=current.find(w=>w.id===id);
   if(existing)return current.map(w=>w.id===id?{...w,minimized:false,z:nextZ}:w);
   const width=Math.min(900,window.innerWidth-48),height=Math.min(620,window.innerHeight-150),offset=current.length*26;
   return [...current,{id,x:Math.max(14,(window.innerWidth-width)/2+offset-70),y:Math.max(76,94+offset),width,height,z:nextZ}];
  });
  setLauncher(false);
 };
 const closeApp=(id:AppId)=>setWindows(v=>v.filter(w=>w.id!==id));
 const minimizeApp=(id:AppId)=>setWindows(v=>v.map(w=>w.id===id?{...w,minimized:true}:w));
 const focusApp=(id:AppId)=>{const z=zTop+1;setZTop(z);setWindows(v=>v.map(w=>w.id===id?{...w,minimized:false,z}:w))};
 const toggleMaximize=(id:AppId)=>{const z=zTop+1;setZTop(z);setWindows(v=>v.map(w=>w.id===id?{...w,maximized:!w.maximized,z}:w))};
 const startDrag=(id:AppId,e:PointerEvent<HTMLDivElement>)=>{
  if((e.target as HTMLElement).closest('button')||window.innerWidth<700)return;
  const w=windows.find(v=>v.id===id);if(!w||w.maximized)return;
  drag.current={id,x:w.x,y:w.y,sx:e.clientX,sy:e.clientY};e.currentTarget.setPointerCapture(e.pointerId);focusApp(id);
 };
 const moveDrag=(e:PointerEvent<HTMLDivElement>)=>{
  if(!drag.current)return;const d=drag.current;
  setWindows(v=>v.map(w=>w.id===d.id?{...w,x:Math.max(-w.width+120,Math.min(window.innerWidth-120,d.x+e.clientX-d.sx)),y:Math.max(48,Math.min(window.innerHeight-100,d.y+e.clientY-d.sy))}:w));
 };
 const topClock=clock.toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});
 return <div className="desktop">
  <div className="wallpaper-glow"/><header className="top-dock">
   <button className="launcher-key" title="Applications" onClick={()=>setLauncher(v=>!v)}><Command size={21}/></button><div className="top-dock-divider"/>
   {APPS.map(a=><button key={a.id} className={'dock-icon '+(active===a.id?'active':'')} title={a.name} onClick={()=>openApp(a.id)}><a.icon size={22} style={{color:a.color}}/></button>)}
  </header>
  <div className="desktop-hint"><span className="hint-dot"/> BrowserOS workspace <span className="hint-sep">/</span> {windows.length} open {windows.length===1?'window':'windows'}</div>
  {windows.map(w=>{
   const app=APPS.find(a=>a.id===w.id)!;if(w.minimized)return null;
   return <section key={w.id} className={'app-window '+(w.maximized?'maximized':'')} style={w.maximized?undefined:{left:w.x,top:w.y,width:w.width,height:w.height,zIndex:w.z}} onPointerDown={()=>focusApp(w.id)}>
    <div className="window-titlebar" onPointerDown={e=>startDrag(w.id,e)} onPointerMove={moveDrag} onPointerUp={()=>{drag.current=null}} onPointerCancel={()=>{drag.current=null}}>
     <div className="window-app-icon" style={{color:app.color}}><app.icon size={15}/></div><span className="window-title">{app.name}</span>
     <div className="window-controls"><button title="Minimize" onClick={()=>minimizeApp(w.id)}><Minimize2 size={13}/></button><button title="Maximize" onClick={()=>toggleMaximize(w.id)}><Maximize2 size={13}/></button><button title="Close" className="close-control" onClick={()=>closeApp(w.id)}><X size={14}/></button></div>
    </div>
    <div className="window-content">
     {w.id==='browser'&&<BrowserApp/>}{w.id==='spotify'&&<SpotifyApp/>}{w.id==='word'&&<WordApp/>}{w.id==='powerpoint'&&<PowerPointApp/>}
     {w.id==='terminal'&&<TerminalApp/>}{w.id==='files'&&<FilesApp/>}{w.id==='taskmgr'&&<TaskManager windows={windows} openApp={openApp} closeApp={closeApp} />}{w.id==='settings'&&<SettingsApp/>}
    </div>
   </section>;
  })}
  {launcher&&<div className="launcher-panel"><div className="launcher-title"><div><small>WORKSPACE</small><h2>Applications</h2></div><button onClick={()=>setLauncher(false)}><X size={17}/></button></div><div className="launcher-search"><Search size={17}/><span>Find an application</span></div><div className="launcher-grid">{APPS.map(a=><button key={a.id} onClick={()=>openApp(a.id)}><span style={{color:a.color}}><a.icon size={25}/></span><b>{a.name}</b><small>{a.subtitle}</small></button>)}</div></div>}
  <footer className="system-panel"><div className="panel-left"><button onClick={()=>setLauncher(v=>!v)} title="Applications"><LayoutGrid size={18}/></button><span className="panel-divider"/><span className="workspace-label">BrowserOS</span></div>
   <div className="task-pins">{APPS.filter(a=>windows.some(w=>w.id===a.id)).map(a=>{const w=windows.find(w=>w.id===a.id)!;return <button key={a.id} className={'task-pin '+(!w.minimized&&active===a.id?'selected':'')} title={a.name} onClick={()=>w.minimized?openApp(a.id):active===a.id?minimizeApp(a.id):focusApp(a.id)}><a.icon size={16}/></button>})}</div>
   <div className="panel-right"><Wifi size={14}/><Volume2 size={14}/><BatteryFull size={15}/><span className="panel-time">{topClock}</span><span className="panel-date">{clock.toLocaleDateString([],{weekday:'short',day:'numeric',month:'short'})}</span></div>
  </footer>
 </div>;
}

function BrowserApp(){
 const [address,setAddress]=useState('https://example.com'),[url,setUrl]=useState('https://example.com'),[message,setMessage]=useState('');
 const navigate=(e:FormEvent)=>{e.preventDefault();let next=address.trim();if(!next)return;if(!/^https?:\/\//i.test(next))next='https://'+next;try{new URL(next);setUrl(next);setMessage('Some sites block being displayed inside another page.')}catch{setMessage('Enter a valid website address.')}};
 return <div className="browser-app"><div className="browser-toolbar"><button title="Back" onClick={()=>setUrl('https://example.com')}><ChevronLeft size={17}/></button><button title="Refresh" onClick={()=>setUrl(url)}><RefreshCw size={15}/></button><form onSubmit={navigate}><ShieldCheck size={14}/><input value={address} onChange={e=>setAddress(e.target.value)} aria-label="Website address"/><button type="submit">Go</button></form><button title="New tab" onClick={()=>{setAddress('https://example.com');setUrl('https://example.com')}}><Plus size={16}/></button></div>{message&&<div className="browser-note">{message}</div>}<iframe className="browser-frame" src={url} title="BrowserOS browser" referrerPolicy="no-referrer" sandbox="allow-forms allow-scripts allow-same-origin allow-popups"/></div>;
}
function SpotifyApp(){return <div className="spotify-app"><aside className="spotify-side"><div className="spotify-brand"><Music2 size={22}/> Spotify</div><b>Home</b><span>Search</span><span>Your Library</span><hr/><small>YOUR PLAYLISTS</small><span>Liked Songs</span><span>Focus Flow</span><span>Discover Weekly</span></aside><main className="spotify-main"><div className="spotify-greeting">Good evening</div><div className="spotify-feature"><div className="spotify-disc"><Music2 size={45}/></div><div><small>YOUR MUSIC</small><h2>Music for your day</h2><p>Player embedded in this desktop window.</p></div></div><h3>Made for you</h3><div className="spotify-card-row"><div className="spotify-card"><div className="album album-one">♫</div><b>Daily Mix</b><small>A mix picked for you</small></div><div className="spotify-card"><div className="album album-two">♪</div><b>Focus</b><small>Music to concentrate</small></div><div className="spotify-card"><div className="album album-three">✦</div><b>Discover</b><small>Find something new</small></div></div><div className="spotify-embed"><iframe title="Spotify player" src="https://open.spotify.com/embed/playlist/37i9dQZF1DXcBWIGoYBM5M?utm_source=generator" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"/></div></main></div>}

function WordApp(){
 const [text,setText]=useState(()=>localStorage.getItem('browseros-word')||initialText);
 useEffect(()=>{localStorage.setItem('browseros-word',text)},[text]);
 const exportText=()=>{const blob=new Blob([text],{type:'text/plain;charset=utf-8'});const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='BrowserOS-document.txt';a.click();URL.revokeObjectURL(a.href)};
 return <div className="office-app"><div className="office-ribbon"><div className="office-brand word-brand">W</div><div className="office-file-name">Document1 <small>• Saved on this device</small></div><button onClick={exportText}><Download size={15}/> Export</button></div><div className="office-toolbar"><button onClick={()=>document.execCommand('bold')} title="Bold"><Bold size={16}/></button><button onClick={()=>document.execCommand('italic')} title="Italic"><Italic size={16}/></button><button onClick={()=>document.execCommand('underline')} title="Underline"><Underline size={16}/></button><span/><button onClick={()=>document.execCommand('insertUnorderedList')} title="Bullet list"><List size={16}/></button></div><div className="word-canvas"><div className="paper" contentEditable suppressContentEditableWarning onInput={e=>setText(e.currentTarget.innerText)}>{text}</div></div><div className="office-status">Page 1 <span>Local document editor · stored in this browser</span><span>English</span></div></div>;
}
function PowerPointApp(){
 const [slides,setSlides]=useState<string[]>(()=>{try{return JSON.parse(localStorage.getItem('browseros-slides')||'null')||defaultSlides}catch{return defaultSlides}});
 const [selected,setSelected]=useState(0),[title,setTitle]=useState(slides[0]||'New slide');
 useEffect(()=>{localStorage.setItem('browseros-slides',JSON.stringify(slides))},[slides]);
 const update=(v:string)=>{setTitle(v);setSlides(s=>s.map((x,i)=>i===selected?v:x))};
 const add=()=>{const n=[...slides,'New slide'];setSlides(n);setSelected(n.length-1);setTitle('New slide')};
 const remove=()=>{if(slides.length<=1)return;const n=slides.filter((_,i)=>i!==selected);const i=Math.max(0,selected-1);setSlides(n);setSelected(i);setTitle(n[i])};
 return <div className="ppt-app"><div className="ppt-ribbon"><div className="office-brand ppt-brand">P</div><b>Presentation1</b><div className="ppt-actions"><button onClick={add}><Plus size={15}/> New slide</button><button onClick={remove}><Trash2 size={15}/></button><button onClick={()=>window.print()}><Play size={15}/> Present</button></div></div><div className="ppt-workspace"><aside className="slide-list">{slides.map((s,i)=><button key={i} className={selected===i?'chosen':''} onClick={()=>{setSelected(i);setTitle(s)}}><small>{i+1}</small><span>{s}</span></button>)}</aside><div className="slide-stage"><div className="slide-paper"><input value={title} onChange={e=>update(e.target.value)} aria-label="Slide title"/><p>Click the title to edit this slide.</p><div className="slide-decoration"/></div></div></div></div>;
}
function TerminalApp(){
 const [line,setLine]=useState(''),[history,setHistory]=useState<string[]>(['BrowserOS Terminal','A Linux VM is not connected to this Pages deployment yet.','Type help to see preview commands.']);
 const run=(e:FormEvent)=>{e.preventDefault();const cmd=line.trim();if(!cmd)return;const out:Record<string,string>={help:'help  clear  date  whoami  pwd  ls  uname',date:new Date().toString(),whoami:'browseros-user',pwd:'/home/browseros',ls:'Desktop  Documents  Downloads  Music  Pictures  Videos',uname:'Linux guest kernel is not connected — preview shell only'};if(cmd==='clear')setHistory([]);else setHistory(v=>[...v,'$ '+cmd,out[cmd]||'Command not available in preview shell: '+cmd]);setLine('')};
 return <div className="terminal-app"><div className="terminal-toolbar"><span className="terminal-light"/><span className="terminal-light"/><span className="terminal-light"/> bash — BrowserOS Terminal <small>preview</small></div><div className="terminal-body">{history.map((x,i)=><div key={i} className={x.startsWith('$')?'terminal-command':''}>{x}</div>)}<form onSubmit={run}><b>browseros@desktop:~$</b><input value={line} onChange={e=>setLine(e.target.value)} autoFocus aria-label="Terminal command"/></form></div></div>;
}
function FilesApp(){
 const files=useMemo(()=>[{name:'Desktop',type:'Folder'},{name:'Documents',type:'Folder'},{name:'Downloads',type:'Folder'},{name:'Music',type:'Folder'},{name:'Pictures',type:'Folder'},{name:'Presentations',type:'Folder'},{name:'BrowserOS-document.txt',type:localStorage.getItem('browseros-word')?'Saved document':'Example file'}],[]);
 return <div className="files-app"><aside><b>Places</b>{['Home','Desktop','Documents','Downloads','Music','Pictures','Trash'].map(x=><span key={x}><Folder size={15}/>{x}</span>)}</aside><main><div className="files-toolbar"><ChevronLeft size={16}/><ChevronRight size={16}/><span>⌂　 Home</span><Search size={16}/><Menu size={18}/></div><div className="files-grid">{files.map(f=><div key={f.name}><Folder size={42}/><b>{f.name}</b><small>{f.type}</small></div>)}</div><p className="storage-note">Browser storage view · Not connected to a Linux virtual disk.</p></main></div>;
}
function TaskManager({windows,openApp,closeApp}:{windows:Win[];openApp:(id:AppId)=>void;closeApp:(id:AppId)=>void}){
 return <div className="taskmgr-app"><div className="taskmgr-head"><div><small>APPLICATIONS</small><h2>Task Manager</h2><p>Manage BrowserOS desktop windows.</p></div><div className="taskmgr-count"><strong>{windows.filter(w=>!w.minimized).length}</strong><small>ACTIVE WINDOWS</small></div></div><div className="taskmgr-table"><div className="taskmgr-row taskmgr-header"><span>APP</span><span>STATUS</span><span>TYPE</span><span>ACTION</span></div>{windows.map(w=>{const a=APPS.find(a=>a.id===w.id)!;return <div className="taskmgr-row" key={w.id}><span className="taskmgr-name"><a.icon size={17} style={{color:a.color}}/>{a.name}</span><span><i className={w.minimized?'status-paused':'status-running'}/>{w.minimized?'Minimized':'Running'}</span><span>Desktop window</span><span className="taskmgr-actions"><button onClick={()=>openApp(w.id)}>{w.minimized?'Restore':'Focus'}</button><button className="end-task" onClick={()=>closeApp(w.id)}>End task</button></span></div>})}{windows.length===0&&<div className="taskmgr-empty">No desktop apps are currently open.</div>}</div><div className="taskmgr-foot"><Activity size={15}/> BrowserOS session manager · Does not list host or Linux VM processes.</div></div>;
}
function SettingsApp(){return <div className="settings-app"><div className="settings-intro"><div className="settings-symbol"><Settings size={26}/></div><div><h2>Desktop preferences</h2><p>BrowserOS · KDE-inspired workspace theme</p></div></div><div className="setting-row"><Monitor/><div><b>Display</b><small>Responsive desktop layout for laptop and phone.</small></div><span>Auto</span></div><div className="setting-row"><HardDrive/><div><b>Storage</b><small>Documents and slides stored in browser storage.</small></div><span>Local</span></div><div className="setting-row"><ShieldCheck/><div><b>Runtime status</b><small>Static GitHub Pages desktop. Linux VM integration is not connected.</small></div><span className="pending">Pending</span></div><div className="settings-disclaimer">Native Linux applications need a real VM or remote Linux host. A static website cannot execute installed desktop binaries.</div></div>;}