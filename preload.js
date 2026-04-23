const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('petBridge', {
  moveWindow: (dx, dy) => ipcRenderer.send('move-window', { dx, dy }),
  expand:     ()       => ipcRenderer.send('expand'),
  collapse:   ()       => ipcRenderer.send('collapse'),
  closeApp:   ()       => ipcRenderer.send('close-app'),
  hideApp:          ()       => ipcRenderer.send('hide-app'),
  setIgnoreMouse:   (v)      => ipcRenderer.send('set-ignore-mouse', v),
  openSettings:     ()       => ipcRenderer.send('open-settings'),
  closeSelf:        ()       => ipcRenderer.send('close-self'),
})
