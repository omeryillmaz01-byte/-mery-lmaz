@echo off
chcp 65001 >nul
title WEB YAYIN PAKETI
setlocal
echo.
echo  ==================================================
echo    WEB YAYIN PAKETI HAZIRLA
echo    Sunucuya yuklenecek dosyalar ayiklanir.
echo    Masaustune ozel dosyalar DISARIDA birakilir.
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
Y "  WEB YAYIN PAKETI HAZIRLANIYOR"
Y "================================================"
Y ""

# --- Panel kokunu bul (en buyuk BATTAL-MUHASEBE.html) ---
$adaylar = @()
foreach ($d in (Get-ChildItem -LiteralPath $masa -Directory -Force)) {
    $adaylar += @(Get-ChildItem -LiteralPath $d.FullName -Recurse -Depth 3 -File -Force -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -eq 'BATTAL-MUHASEBE.html' -or $_.Name -eq 'BATTALMUHASEBE.html' })
}
if ($adaylar.Count -eq 0) {
    Y "  [HATA] BATTAL-MUHASEBE.html bulunamadi."
    Y "  Cozum: panel klasorunu bu .bat uzerine surukleyip birakin."
} else {
    $enIyi = $adaylar | Sort-Object Length -Descending | Select-Object -First 1
    $kok = $enIyi.DirectoryName
    Y ("  Kaynak klasor : " + $kok)
    Y ("  Ana panel     : " + $enIyi.Name + "   " + [math]::Round($enIyi.Length/1KB,0) + " KB")
    Y ""

    $hedef = Join-Path $masa 'WEB-YAYIN'
    if (Test-Path -LiteralPath $hedef) {
        $yedekAd = 'WEB-YAYIN-onceki-' + (Get-Date).ToString('yyyyMMdd-HHmmss')
        Rename-Item -LiteralPath $hedef -NewName $yedekAd
        Y ("  Eski WEB-YAYIN yedeklendi: " + $yedekAd)
    }
    New-Item -ItemType Directory -Path $hedef | Out-Null

    # Web'e ASLA gitmeyecek klasorler ve uzantilar
    $yasakKlasor = 'chrome_profil|\\Extensions\\|WasmTtsEngine|GEREKLI_PROGRAMLAR|battal_db_eklenti|banka_pos_panel|beyanname-otomatik-kaydetme|node_modules|MUSAVIR_PRO_ESKI|_yedek_'
    $yasakUzanti = '(?i)^\.(bat|cmd|ps1|vbs|py|exe|msi|zip|rar|lnk|log|db|sqlite)$'
    $izinUzanti  = '(?i)^\.(html?|css|js|json|png|jpe?g|gif|svg|ico|woff2?|ttf)$'

    $tumu = @(Get-ChildItem -LiteralPath $kok -Recurse -Depth 3 -File -Force -ErrorAction SilentlyContinue)
    $alinan = 0; $atilan = 0
    $atilanOrnek = @()

    foreach ($f in $tumu) {
        $gorece = $f.FullName.Substring($kok.Length).TrimStart('\')
        if ($f.FullName -match $yasakKlasor -or $f.Extension -match $yasakUzanti -or $f.Extension -notmatch $izinUzanti) {
            $atilan++
            if ($atilanOrnek.Count -lt 12) { $atilanOrnek += $gorece }
            continue
        }
        $vardigi = Join-Path $hedef $gorece
        $ustDizin = Split-Path $vardigi -Parent
        if (-not (Test-Path -LiteralPath $ustDizin)) { New-Item -ItemType Directory -Path $ustDizin -Force | Out-Null }
        Copy-Item -LiteralPath $f.FullName -Destination $vardigi -Force
        $alinan++
    }

    Y "--- ALINAN DOSYALAR ---"
    foreach ($f in (Get-ChildItem -LiteralPath $hedef -Recurse -File | Sort-Object Length -Descending)) {
        Y ("   " + ([math]::Round($f.Length/1KB,0)).ToString().PadLeft(7) + " KB  " + $f.FullName.Substring($hedef.Length).TrimStart('\'))
    }
    Y ""
    Y ("--- DISARIDA BIRAKILAN: " + $atilan + " dosya ---")
    Y "   (masaustune ozel; sunucuda calismaz ya da gizli veri icerir)"
    foreach ($x in $atilanOrnek) { Y ("   " + $x) }
    if ($atilan -gt $atilanOrnek.Count) { Y ("   ... ve " + ($atilan - $atilanOrnek.Count) + " dosya daha") }
    Y ""

    # --- .htaccess ---
    $ht = @'
Options -Indexes
DirectoryIndex GENEL-PANEL.html

<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteCond %{HTTPS} off
  RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

<IfModule mod_headers.c>
  Header set X-Content-Type-Options nosniff
  Header set X-Frame-Options SAMEORIGIN
  Header set Referrer-Policy no-referrer
</IfModule>
'@
    $ht | Out-File -LiteralPath (Join-Path $hedef '.htaccess') -Encoding ASCII
    Y "  .htaccess olusturuldu (HTTPS zorlama + dizin listeleme kapali)"
    Y ""

    $mb = [math]::Round((( Get-ChildItem -LiteralPath $hedef -Recurse -File | Measure-Object Length -Sum ).Sum / 1MB), 2)
    Y "================================================"
    Y ("  HAZIR: " + $hedef)
    Y ("  " + $alinan + " dosya, " + $mb + " MB")
    Y "================================================"
    Y ""
    Y "  SIRADAKI ADIMLAR:"
    Y "   1. Hosting panelinde alt alan adi olustur (ornek: panel.alanadin.com)"
    Y "   2. WEB-YAYIN icerigini o alt alan adinin klasorune yukle"
    Y "   3. SSL sertifikasini etkinlestir (Let's Encrypt)"
    Y "   4. cPanel > Directory Privacy ile klasore kullanici adi + sifre koy"
    Y "      ONEMLI: sifresiz birakma, paneller musteri verisi iceriyor"
    Y "   5. file:// paneldeki verini Yedek Al ile indir,"
    Y "      yeni adreste paneli acip Geri Yukle ile aktar"

    Start-Process $hedef
}

$cikti = Join-Path $masa 'WEB-PAKET-RAPOR.txt'
$rapor | Out-File -LiteralPath $cikti -Encoding UTF8
$metin = ($rapor -join [Environment]::NewLine)
if ($metin.Length -gt 24000) { $metin = $metin.Substring(0,24000) }
Set-Clipboard -Value $metin
Write-Host ""
Write-Host "  Rapor panoya kopyalandi." -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host "  ================== HATA ==================" -ForegroundColor Red
    $h = @()
    $h += "MESAJ : " + $_.Exception.Message
    $h += "SATIR : " + $_.InvocationInfo.ScriptLineNumber
    $h += "KOMUT : " + $_.InvocationInfo.Line.Trim()
    foreach ($x in $h) { Write-Host ("  " + $x) -ForegroundColor Red }
    try { Set-Clipboard -Value ($h -join [Environment]::NewLine) } catch {}
}
