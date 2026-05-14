const { app, BrowserWindow, shell, ipcMain, screen, safeStorage } = require('electron')
const path = require('path')
const fs = require('fs')

// Disable DPI scaling so window size = actual pixels
app.commandLine.appendSwitch('high-dpi-support', '1')
app.commandLine.appendSwitch('force-device-scale-factor', '1')

let win
const PRELOAD = path.join(__dirname, 'preload.js')
const APP_HTML = path.join(__dirname, 'app', 'index.html')

function makeWindow(opts) {
  return new BrowserWindow({
    frame: false,
    alwaysOnTop: true,
    ...opts,
    webPreferences: {
      preload: PRELOAD,
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
      webSecurity: true,
      ...(opts.webPreferences || {}),
    },
  })
}

function createWindow() {
  const { width: sw, height: sh } = screen.getPrimaryDisplay().workAreaSize

  // Koala wrapper is 240px wide (left-aligned, see app/index.html .pet-img-wrap).
  // Right gutter holds the bubble (width:200) + tray buttons (right:18, ~22px).
  const W = 500, H = 320

  win = makeWindow({
    width: W,
    height: H,
    x: Math.floor(sw * 0.6),
    y: Math.floor(sh * 0.5),
    transparent: true,
    skipTaskbar: false,
    focusable: false,
    thickFrame: false,
    resizable: false,
    hasShadow: false,
    backgroundColor: '#00000001',
  })

  win.loadFile(APP_HTML)
  win.webContents.on('did-finish-load', () => {
    win.setBackgroundColor('#00000000')
  })
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })
  win.setAlwaysOnTop(true, 'screen-saver')

  ipcMain.on('move-window', (event, { dx, dy }) => {
    const sender = BrowserWindow.fromWebContents(event.sender) || win
    const [x, y] = sender.getPosition()
    const [w, h] = sender.getSize()
    const nx = Math.max(0, Math.min(sw - w, x + Math.round(dx)))
    const ny = Math.max(0, Math.min(sh - h, y + Math.round(dy)))
    sender.setPosition(nx, ny)
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

    chatWin = makeWindow({
      width: chatW,
      height: chatH,
      x: cx, y: cy,
      transparent: true,
      backgroundColor: '#00000000',
      thickFrame: false,
      hasShadow: false,
      resizable: false,
    })
    chatWin.loadFile(APP_HTML, { query: { mode: 'chat' } })
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
    settingsWin = makeWindow({
      width: 360,
      height: 580,
      x: Math.max(0, x - 368),
      y: y,
      transparent: true,
      backgroundColor: '#00000000',
      thickFrame: false,
      hasShadow: false,
      resizable: false,
    })
    settingsWin.loadFile(APP_HTML, { query: { mode: 'settings' } })
    settingsWin.on('closed', () => { settingsWin = null })
  })

  ipcMain.on('close-app', () => app.quit())
  ipcMain.on('close-self', (evt) => {
    const w = BrowserWindow.fromWebContents(evt.sender)
    if (w && !w.isDestroyed()) w.close()
  })
  ipcMain.on('minimize-self', (evt) => {
    const w = BrowserWindow.fromWebContents(evt.sender)
    if (w && !w.isDestroyed()) w.minimize()
  })
  // Minimize the pet window to the taskbar.
  // The pet window normally has `focusable: false`, which on Windows implies skipTaskbar:true ―
  // i.e. once minimized it disappears from the taskbar and can't be restored (looks "closed").
  // Workaround: flip focusable on for the minimize, then flip it back when restored.
  ipcMain.on('hide-app', () => {
    if (!win || win.isDestroyed()) return
    win.setFocusable(true)
    win.setSkipTaskbar(false)
    win.minimize()
    win.once('restore', () => {
      win.setFocusable(false)
    })
  })

  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })
}

// ── Encrypted storage for the API key (DPAPI on Windows / Keychain on macOS) ──
const SECRET_FILE = () => path.join(app.getPath('userData'), 'apk.bin')

ipcMain.handle('secret:get', () => {
  try {
    const f = SECRET_FILE()
    if (!fs.existsSync(f)) return ''
    if (!safeStorage.isEncryptionAvailable()) return ''
    return safeStorage.decryptString(fs.readFileSync(f))
  } catch {
    return ''
  }
})

ipcMain.handle('secret:set', (_evt, value) => {
  try {
    const f = SECRET_FILE()
    if (!value) {
      try { fs.unlinkSync(f) } catch {}
      return true
    }
    if (!safeStorage.isEncryptionAvailable()) return false
    fs.writeFileSync(f, safeStorage.encryptString(String(value)), { mode: 0o600 })
    return true
  } catch {
    return false
  }
})

app.whenReady().then(() => {
  createWindow()
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})
