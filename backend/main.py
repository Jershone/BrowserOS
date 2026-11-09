from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os, platform, shutil, psutil
app=FastAPI(title="BrowserOS API",version="0.1.0")
app.add_middleware(CORSMiddleware,allow_origins=["*"],allow_methods=["*"],allow_headers=["*"])
@app.get("/api/health")
def health(): return {"ok":True,"service":"BrowserOS API"}
@app.get("/api/system")
def system():
 d=shutil.disk_usage(os.getcwd())
 return {"platform":platform.platform(),"python":platform.python_version(),"cpu":psutil.cpu_percent(interval=.15),"memory":psutil.virtual_memory().percent,"memory_total":psutil.virtual_memory().total,"disk":d.total,"disk_used":d.used,"cwd":os.getcwd()}
@app.get("/api/files")
def files(path:str="."):
 root=os.path.realpath(os.getcwd()); target=os.path.realpath(os.path.join(root,path))
 if target!=root and not target.startswith(root+os.sep): return {"error":"Path outside workspace"}
 try: return {"path":os.path.relpath(target,root),"items":[{"name":n,"directory":os.path.isdir(os.path.join(target,n))} for n in sorted(os.listdir(target))]}
 except OSError as e: return {"error":str(e)}
