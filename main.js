const { app, BrowserWindow, shell, ipcMain, screen } = require('electron')
const path = require('path')

// Disable DPI scaling so window size = actual pixels
app.commandLine.appendSwitch('high-dpi-support', '1')
app.commandLine.appendSwitch('force-device-scale-factor', '1')

let win

function createWindow() {
  const { width: sw, height: sh } = screen.getPrimaryDisplay().workAreaSize

  // Image is 240x286 — use exactly this as window size
  const W = 240, H = 286

  win = new BrowserWindow({
    width: W,
    height: H,
    x: Math.floor(sw * 0.6),
    y: Math.floor(sh * 0.5),
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    skipTaskbar: false,
    focusable: false,
    resizable: false,
    hasShadow: false,
    backgroundColor: '#00000001',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  })

  win.loadFile(path.join(__dirname, 'app', 'index.html'))
  win.webContents.on('did-finish-load', () => {
    win.setBackgroundColor('#00000000')
  })
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })
  win.setAlwaysOnTop(true, 'screen-saver')

  ipcMain.on('move-window', (_, { dx, dy }) => {
    const [x, y] = win.getPosition()
    const [w, h] = win.getSize()
    const nx = Math.max(0, Math.min(sw - w, x + Math.round(dx)))
    const ny = Math.max(0, Math.min(sh - h, y + Math.round(dy)))
    win.setPosition(nx, ny)
  })

  let chatWin = null

  ipcMain.on('expand', () => {
    if (chatWin && !chatWin.isDestroyed()) {
      chatWin.focus()
      return
    }
    const [x, y] = win.getPosition()
    const chatW = 380, chatH = 680
    // Place chat window to the left of pet, or right if not enough space
    let cx = x - chatW - 8
    if (cx < 0) cx = x + W + 8
    cx = Math.max(0, Math.min(cx, sw - chatW))
    const cy = Math.max(0, Math.min(y, sh - chatH))

    chatWin = new BrowserWindow({
      width: chatW,
      height: chatH,
      x: cx, y: cy,
      frame: false,
      alwaysOnTop: true,
      backgroundColor: '#f5f0ff',
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        preload: path.join(__dirname, 'preload.js'),
      },
    })
    chatWin.loadFile(path.join(__dirname, 'app', 'index.html'), {
      query: { mode: 'chat' }
    })
    chatWin.on('closed', () => { chatWin = null })
  })

  ipcMain.on('collapse', () => {
    if (chatWin && !chatWin.isDestroyed()) chatWin.close()
  })

  ipcMain.on('set-ignore-mouse', (_, ignore) => {
    win.setIgnoreMouseEvents(ignore, { forward: true })
  })

  let settingsWin = null
  ipcMain.on('open-settings', () => {
    if (settingsWin && !settingsWin.isDestroyed()) {
      settingsWin.focus(); return
    }
    const [x, y] = win.getPosition()
    settingsWin = new BrowserWindow({
      width: 360,
      height: 580,
      x: Math.max(0, x - 368),
      y: y,
      frame: false,
      alwaysOnTop: true,
      backgroundColor: '#f5f0ff',
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        preload: path.join(__dirname, 'preload.js'),
      },
    })
    settingsWin.loadFile(path.join(__dirname, 'app', 'index.html'), {
      query: { mode: 'settings' }
    })
    settingsWin.on('closed', () => { settingsWin = null })
  })

  ipcMain.on('close-app', () => app.quit())
  ipcMain.on('hide-app', () => win.minimize())

  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })
}

app.whenReady().then(() => {
  createWindow()
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})
