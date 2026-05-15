Add-Type -AssemblyName System.Drawing
$root = 'C:\Users\Administrator\Desktop\xiaotuanzi\.claude\worktrees\competent-volhard-a4dff8\build'

# Chinese strings as unicode escapes (avoids ANSI encoding pitfalls)
$WORDMARK = -join ([char]0x5B6C, [char]0x5B6C)  # 孬孬
$TAGLINE  = -join ([char]0x966A, [char]0x4F60, [char]0x4E13, [char]0x6CE8, [char]0x7684, [char]0x5C0F, [char]0x53EF, [char]0x7231)  # 陪你专注的小可爱

function MakeKoala($size) {
  $src = [System.Drawing.Image]::FromFile("$root\koala-original.png")
  $bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $scale = ($size * 0.94) / [Math]::Max($src.Width, $src.Height)
  $dw = [int]($src.Width * $scale)
  $dh = [int]($src.Height * $scale)
  $g.DrawImage($src, [int](($size - $dw) / 2), [int](($size - $dh) / 2), $dw, $dh)
  $g.Dispose()
  $src.Dispose()
  return $bmp
}

# ============ SIDEBAR 164x314 (welcome / finish pages) ============
$w = 164; $h = 314
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Vertical lavender gradient
$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.Color]::FromArgb(232, 220, 250)), ([System.Drawing.Color]::FromArgb(85, 55, 145)), 90
$g.FillRectangle($grad, $rect)
$grad.Dispose()

# Top-left soft highlight
$path1 = New-Object System.Drawing.Drawing2D.GraphicsPath
$path1.AddEllipse(-30, -30, 180, 180)
$pgb1 = New-Object System.Drawing.Drawing2D.PathGradientBrush $path1
$pgb1.CenterPoint = New-Object System.Drawing.PointF 60, 60
$pgb1.CenterColor = [System.Drawing.Color]::FromArgb(120, 255, 255, 255)
$pgb1.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 255, 255))
$g.FillPath($pgb1, $path1)
$pgb1.Dispose(); $path1.Dispose()

# Bottom-right glow
$path2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$path2.AddEllipse(40, 220, 180, 180)
$pgb2 = New-Object System.Drawing.Drawing2D.PathGradientBrush $path2
$pgb2.CenterPoint = New-Object System.Drawing.PointF 130, 310
$pgb2.CenterColor = [System.Drawing.Color]::FromArgb(80, 200, 181, 245)
$pgb2.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 200, 181, 245))
$g.FillPath($pgb2, $path2)
$pgb2.Dispose(); $path2.Dispose()

# Subtle dot grain (12px grid) for paper texture
$dotBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(28, 255, 255, 255))
for ($y = 0; $y -lt $h; $y += 12) {
  for ($x = 0; $x -lt $w; $x += 12) {
    $g.FillEllipse($dotBrush, $x, $y, 1.5, 1.5)
  }
}
$dotBrush.Dispose()

# Hairline under koala area
$linePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(80, 255, 255, 255)), 1
$g.DrawLine($linePen, 28, 196, $w - 28, 196)
$linePen.Dispose()

# Koala (centered, upper-third)
$koala = MakeKoala 130
$g.DrawImage($koala, [int](($w - 130) / 2), 38, 130, 130)
$koala.Dispose()

# Sparkle accent above wordmark
$starBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$starFont = New-Object System.Drawing.Font -ArgumentList @('Segoe UI Symbol', [single]9, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Near
$g.DrawString([string][char]0x2726, $starFont, $starBrush, [single]($w / 2), [single]207, $sf)
$starFont.Dispose(); $starBrush.Dispose()

# Wordmark -- naonao
$titleFont = $null
try { $titleFont = New-Object System.Drawing.Font -ArgumentList @('Microsoft YaHei', [single]22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel) } catch { Write-Output ('Bold err: ' + $_.Exception.Message) }
if ($titleFont -eq $null) { try { $titleFont = New-Object System.Drawing.Font -ArgumentList @('SimHei', [single]22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel) } catch { Write-Output ('SimHei err: ' + $_.Exception.Message) } }
if ($titleFont -eq $null) { $titleFont = New-Object System.Drawing.Font -ArgumentList @('Microsoft YaHei', [single]22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel) }
Write-Output ('titleFont ok: ' + ($titleFont -ne $null) + ' name=' + $titleFont.Name + ' bold=' + $titleFont.Bold)
$shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(80, 30, 10, 60))
$titleBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g.DrawString($WORDMARK, $titleFont, $shadowBrush, [single]($w / 2 + 1), [single]218, $sf)
$g.DrawString($WORDMARK, $titleFont, $titleBrush, [single]($w / 2), [single]217, $sf)
$titleFont.Dispose(); $shadowBrush.Dispose(); $titleBrush.Dispose()

# Tagline
$tagFont = New-Object System.Drawing.Font -ArgumentList @('Microsoft YaHei UI', [single]10, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$tagBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 255, 255, 255))
$g.DrawString($TAGLINE, $tagFont, $tagBrush, [single]($w / 2), [single]250, $sf)
$tagFont.Dispose(); $tagBrush.Dispose()

# Bottom signature line
$versionFont = New-Object System.Drawing.Font -ArgumentList @('Consolas', [single]8, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$versionBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 255, 255, 255))
$signature = ([char]0x00B7) + ' LAVENDER STUDIO ' + ([char]0x00B7)
$g.DrawString($signature, $versionFont, $versionBrush, [single]($w / 2), [single]285, $sf)
$versionFont.Dispose(); $versionBrush.Dispose()

$g.Dispose()
$bmp.Save("$root\installerSidebar.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
$bmp.Dispose()
Write-Output 'sidebar 164x314 saved'

# ============ HEADER 150x57 (top-right of every page) ============
$hw = 150; $hh = 57
$hbmp = New-Object System.Drawing.Bitmap $hw, $hh, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$hg = [System.Drawing.Graphics]::FromImage($hbmp)
$hg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$hg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$hg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Soft horizontal lavender wash
$hrect = New-Object System.Drawing.Rectangle 0, 0, $hw, $hh
$hgrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush $hrect, ([System.Drawing.Color]::FromArgb(243, 238, 251)), ([System.Drawing.Color]::FromArgb(220, 200, 245)), 0
$hg.FillRectangle($hgrad, $hrect)
$hgrad.Dispose()

# Tiny dot grain
$hdotBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 124, 92, 191))
for ($y = 0; $y -lt $hh; $y += 8) {
  for ($x = 0; $x -lt $hw; $x += 8) {
    $hg.FillEllipse($hdotBrush, $x, $y, 1, 1)
  }
}
$hdotBrush.Dispose()

# Koala on the right side (header bitmap is right-aligned in MUI2)
$hkoala = MakeKoala 48
$hg.DrawImage($hkoala, $hw - 53, 4, 48, 48)
$hkoala.Dispose()

$hg.Dispose()
$hbmp.Save("$root\installerHeader.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
$hbmp.Dispose()
Write-Output 'header 150x57 saved'
