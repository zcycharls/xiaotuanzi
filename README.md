# 小团子 🐨 ADHD 陪伴宠物

一只毛茸茸的树袋熊陪你专注。

## 在线使用
👉 https://zcycharls.github.io/xiaotuanzi

## 桌面版（Windows）

### 前提
安装 [Node.js LTS](https://nodejs.org/)

### 直接运行
```bash
npm install
npm start
```

### 打包成安装包 (.exe)
```bash
npm install
npm run build
```
安装包在 `dist/` 目录。

## 功能
- 💬 AI 对话（支持 Anthropic / OpenAI 兼容接口）
- 🍅 番茄钟
- 📌 任务锚（走神后一眼找回）
- ⏰ 定时签到
- 💡 100+ ADHD 知识卡片
- ✨ 快捷短句

## 关于 API Key 存储
- **桌面版**：API Key 通过 Electron `safeStorage` 用操作系统密钥保护（Windows DPAPI / macOS Keychain / Linux libsecret），加密文件存放在 `%APPDATA%/小团子/apk.bin`。**不会**保存到 localStorage。
- **浏览器版（GitHub Pages / file://）**：受浏览器沙箱限制，Key 只能保存在 localStorage（明文）。请勿在公用电脑上输入。
- **CORS 代理**：浏览器版可选「通过 corsproxy.io 代理」用于绕开本地 CORS；勾选后 API Key 会经过第三方服务，仅建议测试用。桌面版不需要、也不会启用此选项。
