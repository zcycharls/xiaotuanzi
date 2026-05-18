const { app, BrowserWindow, shell, ipcMain, screen, safeStorage } = require('electron')
const path = require('path')
const fs = require('fs')

// ═══ 本地 AI 模型（内置到安装包，完全离线）═══
let localModelPipeline = null
let localModelLoading = false
let localModelReady = false

// 兼容开发环境和生产环境的模型目录
function getModelDir() {
  // 生产环境：extraResources 把 app/models 复制到 resources/models/
  const prodDir = path.join(process.resourcesPath, 'models', 'Xenova', 'Qwen1.5-0.5B-Chat')
  if (fs.existsSync(path.join(prodDir, 'config.json'))) return prodDir
  // 开发环境：直接从项目目录加载
  const devDir = path.join(__dirname, 'app', 'models', 'Xenova', 'Qwen1.5-0.5B-Chat')
  if (fs.existsSync(path.join(devDir, 'config.json'))) return devDir
  return null
}

function hasBuiltInModel() {
  const dir = getModelDir()
  return dir !== null && fs.existsSync(path.join(dir, 'onnx', 'decoder_model_merged_quantized.onnx'))
}

async function loadLocalModel() {
  if (localModelLoading || localModelReady) return localModelReady
  const modelDir = getModelDir()
  if (!modelDir) return false
  localModelLoading = true
  try {
    const { pipeline } = require('@xenova/transformers')
    localModelPipeline = await pipeline('text-generation', modelDir, {
      local_files_only: true,
    })
    localModelReady = true
    console.log('[孬孬] 本地模型加载成功')
    return true
  } catch (e) {
    console.error('[孬孬] 本地模型加载失败:', e)
    localModelReady = false
    return false
  } finally {
    localModelLoading = false
  }
}

async function runLocalInference(text) {
  if (!localModelReady) {
    const ok = await loadLocalModel()
    if (!ok) return null
  }
  try {
    const prompt = `<|im_start|>system\n你是一只叫"孬孬"的数字陪伴宠物，专门陪伴有ADHD的用户。风格：每次回复极简短（最多2-3句话），温柔、接纳、非评判；帮用户聚焦当下；偶尔用1-2个emoji；用中文回复。\n<|im_end|>\n<|im_start|>user\n${text}\n<|im_end|>\n<|im_start|>assistant\n`
    const result = await localModelPipeline(prompt, {
      max_new_tokens: 80,
      temperature: 0.7,
      top_p: 0.9,
      do_sample: true,
    })
    // 提取回复
    let full = ''
    if (Array.isArray(result) && result.length > 0) {
      full = result[0]?.generated_text || result[0]?.text || ''
    } else if (typeof result === 'object' && result !== null) {
      full = result.generated_text || result.text || ''
    } else if (typeof result === 'string') {
      full = result
    }
    const marker = '<|im_start|>assistant\n'
    const idx = full.lastIndexOf(marker)
    let response = idx !== -1 ? full.substring(idx + marker.length) : full
    response = response.replace(/<\|im_end\|>/g, '').replace(/<\|im_start\|>/g, '').trim()
    return response || null
  } catch (e) {
    console.error('[孬孬] 本地推理失败:', e)
    return null
  }
}

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
    // Match the chat window's dimensions (380x680) so the two side panels feel like a pair.
    const setW = 380, setH = 680
    settingsWin = makeWindow({
      width: setW,
      height: setH,
      x: Math.max(0, x - (setW + 8)),
      y: Math.max(0, Math.min(y, screen.getPrimaryDisplay().workAreaSize.height - setH)),
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

// ═══ 本地模型 IPC 接口 ═══
ipcMain.handle('local-model:status', () => {
  return {
    hasModel: hasBuiltInModel(),
    ready: localModelReady,
    loading: localModelLoading,
    modelDir: getModelDir(),
  }
})

ipcMain.handle('local-model:load', async () => {
  return await loadLocalModel()
})

ipcMain.handle('local-model:inference', async (_event, text) => {
  return await runLocalInference(text)
})
