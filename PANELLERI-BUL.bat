@echo off
chcp 65001 >nul
title Panelleri Bul - SADECE LISTELER, HICBIR SEYI DEGISTIRMEZ
setlocal
echo.
echo  ============================================
echo    PANELLERI BUL  (salt-okunur tarama)
echo  ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $masa=[Environment]::GetFolderPath('Desktop'); $sat=@(); $sat += '=== MASAUSTUNDEKI KISAYOLLAR VE HEDEFLERI ==='; $s=New-Object -ComObject WScript.Shell; foreach($l in (Get-ChildItem -LiteralPath $masa -Filter '*.lnk' -File)){ $k=$s.CreateShortcut($l.FullName); $sat += ('  ' + $l.Name + '   ->   ' + $k.TargetPath) }; $sat += ''; $sat += '=== BULUNAN TUM HTML PANELLER (buyukten kucuge) ==='; $kokler=@($masa, (Join-Path $env:USERPROFILE 'Downloads'), (Join-Path $env:USERPROFILE 'Documents')); if($env:OneDrive){ $kokler += $env:OneDrive }; $kokler = $kokler | Select-Object -Unique; $bulunan=@(); foreach($r in $kokler){ if(Test-Path -LiteralPath $r){ $bulunan += (Get-ChildItem -LiteralPath $r -Recurse -Depth 2 -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '^\.html?$' }) } }; $bulunan = $bulunan | Sort-Object FullName -Unique | Sort-Object Length -Descending; if($bulunan.Count -eq 0){ $sat += '  (hic html dosyasi bulunamadi)' }; foreach($f in $bulunan){ $sat += ('  ' + ([math]::Round($f.Length/1MB,2)).ToString().PadLeft(7) + ' MB   ' + $f.LastWriteTime.ToString('dd.MM.yyyy HH:mm') + '   ' + $f.FullName) }; foreach($m in $sat){ Write-Host $m }; $cikti=Join-Path $masa 'PANEL-LISTESI.txt'; $sat | Out-File -LiteralPath $cikti -Encoding UTF8; Write-Host ''; Write-Host ('  Liste su dosyaya da kaydedildi: ' + $cikti) -ForegroundColor Green"
echo.
pause
