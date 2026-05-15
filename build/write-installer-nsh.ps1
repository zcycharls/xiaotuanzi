# Writes installer.nsh as UTF-8 with BOM so NSIS Unicode compiler reads Chinese correctly.
# This file is intentionally pure ASCII -- PowerShell 5.1 reads .ps1 as ANSI by default.

function CN([string]$hex) {
  -join (($hex -split '\s+') | ForEach-Object { [char][Convert]::ToInt32($_, 16) })
}

$SPARKLE = [char]0x2726  # U+2726 BLACK FOUR POINTED STAR

# Welcome title: "Welcome to Naonao's home"
$WELCOME_TITLE = CN '6B22 8FCE 6765 5230 300C 5B6C 5B6C 300D 7684 5BB6'
# Welcome line 1: "Naonao is a koala that keeps you focused."
$WELCOME_L1 = CN '5B6C 5B6C 662F 4E00 53EA 966A 4F60 4E13 6CE8 7684 6811 888B 718A 3002'
# Welcome line 2: "It will quietly stay on your desktop -- not disturbing you, but always there to chat or jot down what you want to do today."
$WELCOME_L2 = CN '5B83 4F1A 5B89 5B89 9759 9759 5446 5728 4F60 7684 684C 9762 4E0A FF0C 4E0D 6253 6270 FF0C 4F46 968F 65F6 53EF 4EE5 804A 804A 5929 3001 5199 4E00 4E0B 4ECA 5929 60F3 505A 7684 4E8B 3002'
# Welcome line 3: "Click 'Next' and we can start together."
$WELCOME_L3 = CN '70B9 300C 4E0B 4E00 6B65 300D FF0C 6211 4EEC 5C31 80FD 4E00 8D77 5F00 59CB 4E86 3002'
# Joiners: NSIS has no native line-height control on wizard pages, so we
# inject blank lines between visible lines to give the text breathing room.
#   $LJ  -- line break with one blank line between (intra-paragraph)
#   $PJ  -- paragraph break: two blank lines between
$LJ = '$\r$\n$\r$\n'
$PJ = '$\r$\n$\r$\n$\r$\n'
$WELCOME_TEXT = $WELCOME_L1 + $LJ + $WELCOME_L2 + $PJ + $WELCOME_L3

# Finish title: "Installation Complete (sparkle)"
$FINISH_TITLE = (CN '5B89 88C5 5B8C 6210') + ' ' + $SPARKLE
# Finish line 1: "Naonao has settled in on your desktop."
$FINISH_L1 = CN '5B6C 5B6C 5DF2 7ECF 5B89 987F 5728 4F60 7684 684C 9762 4E0A 5566 3002'
# Finish line 2: "Double-click the desktop icon or open Naonao from the Start menu and it will come out."
$FINISH_L2 = CN '53CC 51FB 684C 9762 6216 5F00 59CB 83DC 5355 91CC 7684 300C 5B6C 5B6C 300D FF0C 5B83 5C31 4F1A 8DD1 51FA 6765 3002'
# Finish line 3: "Wishing you a happy, focused day."
$FINISH_L3 = CN '795D 4F60 4ECA 5929 4E5F 80FD 5F00 5F00 5FC3 5FC3 5730 4E13 6CE8 4E00 4F1A 513F 3002'
$FINISH_TEXT = $FINISH_L1 + $LJ + $FINISH_L2 + $PJ + $FINISH_L3

# Run text: "Wake up Naonao now"
$FINISH_RUN = CN '7ACB 5373 5524 9192 5B6C 5B6C'
# Header banner -- product name in the .nsh comment
$BANNER = CN '5B6C 5B6C'

# ============================================================
#   UNINSTALLER copy -- distinct, gentler farewell tone
# ============================================================

# Uninstall welcome title: "Sending Naonao home?"
$UN_WELCOME_TITLE = CN '8981 9001 5B6C 5B6C 56DE 5BB6 4E86 5417 FF1F'
# Uninstall welcome line 1: "Once removed, Naonao will no longer appear on your desktop."
$UN_WELCOME_L1 = CN '5378 8F7D 540E FF0C 5B6C 5B6C 5C31 4E0D 4F1A 518D 51FA 73B0 5728 4F60 7684 684C 9762 4E0A 4E86 3002'
# Uninstall welcome line 2: "The time it spent with you -- pomodoros, chat history, settings -- will be carried away together."
$UN_WELCOME_L2 = CN '5B83 966A 4F60 7684 8FD9 6BB5 65F6 95F4 2014 2014 756A 8304 949F 3001 804A 5929 8BB0 5F55 3001 8BBE 7F6E 2014 2014 90FD 4F1A 88AB 4E00 8D77 5E26 8D70 3002'
# Uninstall welcome line 3: "If you just want it to be quiet for a while, the settings panel has a 'Quiet mode' switch -- it doesn't have to leave."
$UN_WELCOME_L3 = CN '5982 679C 53EA 662F 60F3 8BA9 5B83 5B89 9759 4E00 4F1A 513F FF0C 8BBE 7F6E 91CC 6709 300C 5B89 9759 6A21 5F0F 300D FF0C 4E0D 4E00 5B9A 8981 8D70 3002'
# Uninstall welcome line 4: "Click 'Next' when you're sure."
$UN_WELCOME_L4 = CN '60F3 6E05 695A 4E86 5C31 70B9 300C 4E0B 4E00 6B65 300D 5427 3002'
$UN_WELCOME_TEXT = $UN_WELCOME_L1 + $LJ + $UN_WELCOME_L2 + $PJ + $UN_WELCOME_L3 + $LJ + $UN_WELCOME_L4

# Uninstall finish title: "Naonao has left (sparkle)"
$UN_FINISH_TITLE = (CN '5B6C 5B6C 5DF2 7ECF 8D70 4E86') + ' ' + $SPARKLE
# Uninstall finish line 1: "Today's desktop is quiet again."
$UN_FINISH_L1 = CN '4ECA 5929 7684 684C 9762 6062 590D 5B89 9759 5566 3002'
# Uninstall finish line 2: "Thank you for keeping it company for a while -- I hope it also brought you a little bit of focused, good time."
$UN_FINISH_L2 = CN '8C22 8C22 4F60 966A 4E86 5B83 4E00 6BB5 65F6 95F4 FF0C 5E0C 671B 5B83 4E5F 5E26 7ED9 8FC7 4F60 4E00 70B9 70B9 4E13 6CE8 7684 597D 65F6 5149 3002'
# Uninstall finish line 3: "If you ever miss it, you can always bring it back."
$UN_FINISH_L3 = CN '60F3 5FF5 7684 8BDD FF0C 968F 65F6 53EF 4EE5 518D 628A 5B83 63A5 56DE 6765 3002'
$UN_FINISH_TEXT = $UN_FINISH_L1 + $LJ + $UN_FINISH_L2 + $PJ + $UN_FINISH_L3

# ============================================================
#   DIRECTORY PAGE -- override default verbose, single-line text
# ============================================================
# "Setup will install Naonao in the folder below."
$DIR_L1 = CN '5C06 628A 5B6C 5B6C 5B89 88C5 5230 4E0B 9762 7684 6587 4EF6 5939 91CC 3002'
# "Want to change location? Click [Browse] to pick another folder."
$DIR_L2 = CN '60F3 6362 5230 522B 5904 FF1F 70B9 300C 6D4F 89C8 300D 9009 522B 7684 6587 4EF6 5939 3002'
# "Ready? Click [Install] to begin."
$DIR_L3 = CN '51C6 5907 597D 5C31 70B9 300C 5B89 88C5 300D 5F00 59CB 3002'
$DIRECTORY_TEXT = $DIR_L1 + $LJ + $DIR_L2 + $LJ + $DIR_L3

# --- Part A: interpolated portion (defines, copy) ---
$nshTop = @"
; ============================================================
;  $BANNER -- Lavender Stationery installer skin
;  Generated by build/write-installer-nsh.ps1 -- do not hand-edit
; ============================================================

; ---- Page chrome colors (lavender wash, ink-plum text) -----
!define MUI_BGCOLOR              "F3EEFB"
!define MUI_TEXTCOLOR            "4A3868"
!define MUI_LICENSEPAGE_BGCOLOR  "FFFAFD"

; ---- Match the in-app font (chat / settings use Microsoft YaHei UI) ----
!define MUI_FONT     "Microsoft YaHei UI"
!define MUI_FONTSIZE "9"

; ---- Welcome / Finish page copy ----
; NOTE: NSIS MUI2 only has ONE set of MUI_*PAGE_TITLE/TEXT defines that
; are shared between installer and uninstaller pages. The MUI_UN*PAGE_*
; names do NOT exist. electron-builder builds the installer and
; uninstaller in two separate compilation passes, predefining
; BUILD_UNINSTALLER on the uninstaller pass -- so we branch on it here
; to swap copy.

!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES

!ifdef BUILD_UNINSTALLER
  ; Uninstaller -- gentler farewell
  !define MUI_WELCOMEPAGE_TITLE  "$UN_WELCOME_TITLE"
  !define MUI_WELCOMEPAGE_TEXT   "$UN_WELCOME_TEXT"
  !define MUI_FINISHPAGE_TITLE   "$UN_FINISH_TITLE"
  !define MUI_FINISHPAGE_TEXT    "$UN_FINISH_TEXT"
!else
  ; Installer -- friendly welcome
  !define MUI_WELCOMEPAGE_TITLE  "$WELCOME_TITLE"
  !define MUI_WELCOMEPAGE_TEXT   "$WELCOME_TEXT"
  !define MUI_FINISHPAGE_TITLE   "$FINISH_TITLE"
  !define MUI_FINISHPAGE_TEXT    "$FINISH_TEXT"
  !define MUI_FINISHPAGE_RUN_TEXT "$FINISH_RUN"
  ; Directory page -- shorter, breathable copy instead of NSIS default
  !define MUI_DIRECTORYPAGE_TEXT_TOP "$DIRECTORY_TEXT"
!endif

"@

# --- Part B: literal NSIS code (no PowerShell interpolation) ---
$nshBottom = @'
; ============================================================
;  Rounded outer window (chat / settings use 18px CSS radius;
;  here we use 22px window-region for a slightly softer feel).
;  Implemented via Win32 SetWindowRgn after the dialog is up.
; ============================================================

!macro XtzRoundCornersBody
  ; allocate a RECT (4 ints = 16 bytes)
  System::Call '*(i, i, i, i) p .r0'
  System::Call 'user32::GetWindowRect(p $HWNDPARENT, p r0)'
  System::Call '*$0(i .r1, i .r2, i .r3, i .r4)'
  System::Free $0
  IntOp $3 $3 - $1   ; width  = right - left
  IntOp $4 $4 - $2   ; height = bottom - top
  ; CreateRoundRectRgn(0, 0, w, h, 22, 22)
  System::Call 'gdi32::CreateRoundRectRgn(i 0, i 0, i r3, i r4, i 22, i 22) p .r5'
  ; SetWindowRgn(hwnd, hRgn, bRedraw=1) -- system owns hRgn after this call
  System::Call 'user32::SetWindowRgn(p $HWNDPARENT, p r5, i 1)'
!macroend

; electron-builder compiles the installer and the uninstaller stub in two
; separate NSIS passes. BUILD_UNINSTALLER is only defined during the
; uninstaller pass, so we have to gate un. functions to avoid NSIS warning
; "Uninstaller script code found but WriteUninstaller never used".
!ifdef BUILD_UNINSTALLER
  !define MUI_CUSTOMFUNCTION_UNGUIINIT un.xtzRoundCorners
  Function un.xtzRoundCorners
    !insertmacro XtzRoundCornersBody
  FunctionEnd
!else
  !define MUI_CUSTOMFUNCTION_GUIINIT xtzRoundCorners
  Function xtzRoundCorners
    !insertmacro XtzRoundCornersBody
  FunctionEnd
!endif
'@

$nsh = $nshTop + $nshBottom + "`r`n"

$outPath = 'C:\Users\Administrator\Desktop\xiaotuanzi\.claude\worktrees\competent-volhard-a4dff8\build\installer.nsh'
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($outPath, $nsh, $utf8Bom)

Write-Output ('installer.nsh written: ' + $outPath)
Write-Output ('size = ' + (Get-Item $outPath).Length + ' bytes')
Write-Output ('WELCOME_TITLE chars: ' + $WELCOME_TITLE.Length)
Write-Output ('FINISH_TEXT chars: ' + $FINISH_TEXT.Length)
