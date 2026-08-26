@echo off
chcp 65001 >nul
title GENEL PANEL - Dogrulama ve Temizlik
setlocal
echo.
echo  ==================================================
echo    GENEL PANEL - DOGRULAMA ve TEMIZLIK
echo    Kisayol dogru panele baglanir,
echo    eski GENEL-PANEL.html kopyalari silinir.
echo  ==================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText('%~f0',[Text.Encoding]::UTF8); $m='#'+'-PSBODY-'; $i=$s.LastIndexOf($m); iex $s.Substring($i+$m.Length)"
echo.
pause
exit /b
#-PSBODY-

$ErrorActionPreference = 'Stop'
try {
$ErrorActionPreference = 'SilentlyContinue'
$masa = [Environment]::GetFolderPath('Desktop')
$rapor = @()
function Y($m){ $script:rapor += $m; Write-Host $m }

Y "================================================"
Y "  GENEL PANEL - DOGRULAMA ve TEMIZLIK"
Y "================================================"
Y ""

# --- 1) Tum GENEL-PANEL.html kopyalari ---
# Not: -Filter emoji iceren klasor adlarinda bos donuyor, ad karsilastirmasi kullaniliyor
$kopyalar = @()
foreach ($d in (Get-ChildItem -LiteralPath $masa -Directory -Force)) {
    $kopyalar += @(Get-ChildItem -LiteralPath $d.FullName -Recurse -Depth 4 -File -Force -ErrorAction SilentlyContinue |
                   Where-Object { $_.Name -eq 'GENEL-PANEL.html' })
}
$kopyalar += @(Get-ChildItem -LiteralPath $masa -File -Force -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -eq 'GENEL-PANEL.html' })
$kopyalar = @($kopyalar | Sort-Object FullName -Unique)

Y "--- 1) BULUNAN GENEL-PANEL.html KOPYALARI ---"
if ($kopyalar.Count -eq 0) { Y "   (yok)" }
foreach ($k in $kopyalar) { Y ("   " + $k.FullName) }
Y ""

# --- 2) Dogru klasor: en buyuk BATTAL-MUHASEBE.html nerede ---
$adaylar = @()
foreach ($d in (Get-ChildItem -LiteralPath $masa -Directory -Force)) {
    $adaylar += @(Get-ChildItem -LiteralPath $d.FullName -Recurse -Depth 3 -File -Force -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -eq 'BATTAL-MUHASEBE.html' -or $_.Name -eq 'BATTALMUHASEBE.html' })
}
Y "--- 2) GECERLI KLASOR ---"
if ($adaylar.Count -eq 0) {
    Y "   [HATA] BATTAL-MUHASEBE.html bulunamadi, islem yapilmadi."
} else {
    $enIyi = $adaylar | Sort-Object Length -Descending | Select-Object -First 1
    $dogruKok = $enIyi.DirectoryName
    $dogruPanel = Join-Path $dogruKok 'GENEL-PANEL.html'
    Y ("   panel  : " + $enIyi.Name + "   " + [math]::Round($enIyi.Length/1KB,0) + " KB")
    Y ("   klasor : " + $dogruKok)
    Y ""

    # --- 3) Kisayollari dogrula/duzelt ---
    Y "--- 3) KISAYOLLAR ---"
    $s = New-Object -ComObject WScript.Shell
    $lnkler = @(Get-ChildItem -LiteralPath $masa -File -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -eq '.lnk' -and $_.Name -match '(?i)GENEL PANEL|BATTAL MUHASEBE' })
    if ($lnkler.Count -eq 0) { Y "   (masaustunde ilgili kisayol yok)" }
    foreach ($l in $lnkler) {
        $k = $s.CreateShortcut($l.FullName)
        Y ("   " + $l.Name)
        Y ("      mevcut hedef : " + $k.TargetPath)
        if (Test-Path -LiteralPath $dogruPanel) {
            if ($k.TargetPath -ne $dogruPanel) {
                $k.TargetPath = $dogruPanel
                $k.WorkingDirectory = $dogruKok
                $k.Save()
                Y ("      DUZELTILDI   : " + $dogruPanel)
            } else {
                Y "      zaten dogru"
            }
        } else {
            Y "      [!] Gecerli klasorde GENEL-PANEL.html yok; once GENEL-PANEL.bat calistirin."
        }
    }
    Y ""

    # --- 4) Eski kopyalari sil ---
    Y "--- 4) ESKI KOPYALAR ---"
    $silinen = 0
    foreach ($k in $kopyalar) {
        if ($k.FullName -ne $dogruPanel) {
            Remove-Item -LiteralPath $k.FullName -Force -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $k.FullName) {
                Y ("   SILINEMEDI : " + $k.FullName)
            } else {
                $silinen++
                Y ("   silindi    : " + $k.FullName)
            }
        }
    }
    if ($silinen -eq 0) { Y "   (silinecek eski kopya yok)" }
    Y ""
    Y "================================================"
    Y ("  GECERLI PANEL: " + $dogruPanel)
    Y "================================================"
}

$cikti = Join-Path $masa 'GENEL-PANEL-TEMIZLIK.txt'
$rapor | Out-File -LiteralPath $cikti -Encoding UTF8
Set-Clipboard -Value ($rapor -join [Environment]::NewLine)
Write-Host ""
Write-Host "  Rapor panoya kopyalandi - sohbete Ctrl+V yapabilirsiniz." -ForegroundColor Green
Write-Host ("  Dosya: " + $cikti) -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host "  ================== HATA ==================" -ForegroundColor Red
    $h = @()
    $h += "MESAJ : " + $_.Exception.Message
    $h += "SATIR : " + $_.InvocationInfo.ScriptLineNumber
    $h += "KOMUT : " + $_.InvocationInfo.Line.Trim()
    foreach ($x in $h) { Write-Host ("  " + $x) -ForegroundColor Red }
    try { Set-Clipboard -Value ($h -join [Environment]::NewLine); Write-Host "  Hata panoya kopyalandi." -ForegroundColor Yellow } catch {}
}
