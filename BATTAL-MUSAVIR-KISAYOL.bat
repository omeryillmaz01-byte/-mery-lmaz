@echo off
chcp 65001 >nul
title BATTAL MUSAVIR - Panel Kurulum
setlocal
set "GIRDI=%~1"
echo.
echo  ============================================
echo    BATTAL / MUSAVIR PANELLERI - KURULUM
echo  ============================================
echo.
echo   Ipucu: panel HTML dosyasini bu .bat uzerine surukleyip birakabilirsiniz.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $masa=[Environment]::GetFolderPath('Desktop'); $girdi='%GIRDI%'; $kaynak=$null; if($girdi -and (Test-Path -LiteralPath $girdi)){ $it=Get-Item -LiteralPath $girdi; if($it.PSIsContainer){ $kaynak=$it.FullName } else { $kaynak=$it.DirectoryName } }; if(-not $kaynak){ $indir=@((Join-Path $env:USERPROFILE 'Downloads')); if($env:OneDrive){ $indir += (Join-Path $env:OneDrive 'Downloads') }; $bul=@(); foreach($d in $indir){ if(Test-Path -LiteralPath $d){ $bul += (Get-ChildItem -LiteralPath $d -Recurse -Depth 3 -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'MUSAVIR_PRO_PANEL.html' -or $_.Name -eq 'BATTAL_MUHASEBE_DB_PRO.html' }) } }; $sec = $bul | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if($sec){ $kaynak=$sec.DirectoryName } }; if(-not $kaynak){ Write-Host '  [HATA] battalpanel klasoru bulunamadi.' -ForegroundColor Red; Write-Host '  Cozum: panel HTML dosyasini bu .bat dosyasinin UZERINE surukleyip birakin.'; exit 1 }; Write-Host ('  Kaynak klasor : ' + $kaynak); $hedef=Join-Path $masa 'BATTAL-MUSAVIR'; if(-not (Test-Path -LiteralPath $hedef)){ New-Item -ItemType Directory -Path $hedef | Out-Null }; Copy-Item -Path (Join-Path $kaynak '*') -Destination $hedef -Recurse -Force; Write-Host ('  Masaustune    : ' + $hedef); Write-Host ''; Write-Host '  Klasordeki paneller:'; $htmls = Get-ChildItem -LiteralPath $hedef -File | Where-Object { $_.Extension -match '^\.html?$' } | Sort-Object Length -Descending; foreach($f in $htmls){ Write-Host ('     ' + ([math]::Round($f.Length/1KB,0)).ToString().PadLeft(7) + ' KB   ' + $f.Name) }; Write-Host ''; $s=New-Object -ComObject WScript.Shell; $liste=@(@('MUSAVIR_PRO_PANEL.html',0x1F4D2,'MUSAVIR PRO PANEL'), @('BATTAL_MUHASEBE_DB_PRO.html',0x1F4D7,'BATTAL MUHASEBE DB'), @('BATTAL-MUHASEBE.html',0x1F4D3,'BATTAL MUHASEBE')); $n=0; foreach($it in $liste){ $f=Join-Path $hedef $it[0]; if(Test-Path -LiteralPath $f){ $ad=[char]::ConvertFromUtf32($it[1]) + ' ' + $it[2] + '.lnk'; $l=Join-Path $masa $ad; $k=$s.CreateShortcut($l); $k.TargetPath=$f; $k.WorkingDirectory=$hedef; $k.Description=('battalpanel - ' + $it[2]); $k.Save(); $n++; Write-Host ('  [OK] ' + $ad) } }; if($n -eq 0){ Write-Host '  [!] Bilinen panel adi bulunamadi; klasor yine de masaustune kopyalandi.' -ForegroundColor Yellow } else { Write-Host ''; Write-Host ('  ' + $n + ' kisayol olusturuldu.') -ForegroundColor Green }"
echo.
pause
