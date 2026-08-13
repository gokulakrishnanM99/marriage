# =====================================================================
#  Gallery image variants
# =====================================================================
#  Makes the small/medium copies the page serves to phones and tablets,
#  next to the full-size originals it serves to laptops. Uses only the
#  imaging that ships with Windows — no install, no toolchain.
#
#  Run it after adding or replacing anything in this folder:
#      pwsh -File gallery/build-variants.ps1
#
#  Originals are never touched; output goes to gallery/opt/.
# =====================================================================

Add-Type -AssemblyName System.Drawing

$src = $PSScriptRoot
$out = Join-Path $src "opt"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$widths = 400, 760           # matches the srcset in index.html
$quality = 82L               # visually clean, well past the point of diminishing returns

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
  Where-Object { $_.MimeType -eq "image/jpeg" }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality, $quality)

$manifest = @()

Get-ChildItem (Join-Path $src "*.jpeg"), (Join-Path $src "*.jpg") | Sort-Object Name | ForEach-Object {
  $file = $_
  $img = [System.Drawing.Image]::FromFile($file.FullName)
  $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

  foreach ($w in $widths) {
    if ($img.Width -le $w) { continue }        # never upscale
    $h = [math]::Round($img.Height * ($w / $img.Width))
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($img, 0, 0, $w, $h)
    $bmp.Save((Join-Path $out "$base-$w.jpg"), $jpegCodec, $encParams)
    $g.Dispose(); $bmp.Dispose()
  }

  $manifest += [PSCustomObject]@{ file = $file.Name; w = $img.Width; h = $img.Height }
  $img.Dispose()
}

$manifest | ConvertTo-Json -Compress | Set-Content (Join-Path $out "manifest.json")

Write-Host "`nSource:"
Get-ChildItem (Join-Path $src "*.jpeg") | ForEach-Object { "{0,-28} {1,6} KB" -f $_.Name, [math]::Round($_.Length / 1KB) }
Write-Host "`nGenerated:"
Get-ChildItem (Join-Path $out "*.jpg") | ForEach-Object { "{0,-28} {1,6} KB" -f $_.Name, [math]::Round($_.Length / 1KB) }
$tot = (Get-ChildItem (Join-Path $out "*-400.jpg") | Measure-Object Length -Sum).Sum
Write-Host ("`nPhone payload (all 400w): {0} KB" -f [math]::Round($tot / 1KB))
