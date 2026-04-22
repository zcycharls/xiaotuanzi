const { app, BrowserWindow, shell, ipcMain, screen } = require('electron')
const path = require('path')

let win

function createWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize

  win = new BrowserWindow({
    width: 180,
    height: 260,
    x: Math.floor(width * 0.75),
    y: Math.floor(height * 0.6),
    // 桌宠关键设置
    frame: false,              // 无边框
    transparent: true,         // 透明背景
    alwaysOnTop: true,         // 始终置顶
    skipTaskbar: false,        // 任务栏显示
    resizable: false,
    hasShadow: false,
    backgroundColor: '#00000000',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  })

  win.loadFile(path.join(__dirname, 'app', 'index.html'))
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })

  // IPC: 拖动窗口
  ipcMain.on('move-window', (_, { dx, dy }) => {
    const [x, y] = win.getPosition()
    win.setPosition(x + dx, y + dy)
  })

  // IPC: 切换聊天面板（展开/收起整个窗口）
  ipcMain.on('expand', () => {
    win.setSize(420, 780)
  })
  ipcMain.on('collapse', () => {
    win.setSize(180, 260)
  })

  // IPC: 关闭 / 最小化
  ipcMain.on('close-app', () => app.quit())
  ipcMain.on('hide-app', () => win.hide())

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
