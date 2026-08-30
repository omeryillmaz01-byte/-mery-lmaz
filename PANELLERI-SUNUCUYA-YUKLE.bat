@echo off
setlocal
title PANELLERI SUNUCUYA YUKLE
set "PS=powershell -NoProfile -ExecutionPolicy Bypass"
%PS% -Command "$m='#'+'-PSBODY-'; $t=Get-Content -LiteralPath '%~f0' -Raw; $i=$t.LastIndexOf($m); $b=$t.Substring($i+$m.Length); iex $b"
echo.
pause
exit /b
#-PSBODY-
$ErrorActionPreference = 'Stop'
function Y($s){ Write-Host $s }

$SUNUCU  = 'SUNUCU_IP'
$KULLANICI = 'panel'

$masa = [Environment]::GetFolderPath('Desktop')
$kaynak = Join-Path $masa 'WEB-YAYIN'

Y ''
Y '=== PANELLERI SUNUCUYA YUKLE ==='
Y ''

if (-not (Test-Path -LiteralPath $kaynak)) {
    Y ('  Bulunamadi: ' + $kaynak)
    Y '  Once WEB-PAKET.bat calistirin; o script WEB-YAYIN klasorunu hazirlar.'
    return
}

$adet = @(Get-ChildItem -LiteralPath $kaynak -Recurse -File -Force -ErrorAction SilentlyContinue).Count
Y ('  Kaynak : ' + $kaynak)
Y ('  Dosya  : ' + $adet)
Y ('  Hedef  : ' + $KULLANICI + '@' + $SUNUCU + ':~/gelen/')
Y ''

if ($SUNUCU -eq 'SUNUCU_IP') {
    Y '  !! Bu dosyanin icindeki $SUNUCU satirini sunucu IP adresiyle degistirin.'
    return
}

$scp = (Get-Command scp -ErrorAction SilentlyContinue)
if (-not $scp) {
    Y '  scp bulunamadi. Windows Ayarlar > Uygulamalar > Istege bagli ozellikler'
    Y '  bolumunden OpenSSH Client kurun.'
    return
}

Y '  Yukleniyor... (ilk seferde uzun surebilir)'
& ssh ($KULLANICI + '@' + $SUNUCU) 'mkdir -p ~/gelen'
& scp -r -q ($kaynak + '\*') ($KULLANICI + '@' + $SUNUCU + ':~/gelen/')
if ($LASTEXITCODE -ne 0) { Y '  Yukleme basarisiz. Yukaridaki hatayi sohbete yapistirin.'; return }

Y '  Yukleme tamam. Sunucuda yayinlaniyor...'
& ssh ($KULLANICI + '@' + $SUNUCU) 'ALAN=PANEL_ALAN bash ~/deploy/04-yayinla.sh'

Y ''
Y '  BITTI. Tarayicidan https://PANEL_ALAN adresini acin.'
