@echo off
chcp 65001 >nul
title BATTAL - Iki Kisayol Kur
setlocal
set "KLASOR=%~dp0"
echo.
echo  ============================================
echo    BATTAL - IKI AYRI KISAYOL KURULUYOR
echo  ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $masa=[Environment]::GetFolderPath('Desktop'); $kokler=@($masa, '%KLASOR%', (Join-Path $env:USERPROFILE 'Downloads')); if($env:OneDrive){ $kokler += (Join-Path $env:OneDrive 'Downloads') }; $kokler = $kokler | Select-Object -Unique; $hepsi=@(); foreach($r in $kokler){ if(Test-Path -LiteralPath $r){ $hepsi += (Get-ChildItem -LiteralPath $r -Recurse -Depth 1 -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '^\.html?$' -and $_.Length -gt 200000 }) } }; $hepsi = $hepsi | Sort-Object FullName -Unique | Sort-Object Length -Descending; $veri=$null; $pro=$null; foreach($f in $hepsi){ $ic=Get-Content -LiteralPath $f.FullName -Raw; if((-not $veri) -and ($ic -match 'FIRMA_HESAP_PLANI_INIT')){ $veri=$f }; if((-not $pro) -and ($ic -match 'Battal Panel Pro')){ $pro=$f }; if($veri -and $pro){ break } }; $s=New-Object -ComObject WScript.Shell; if($veri){ $hedef=Join-Path $masa 'BATTAL-BANKA-POS.html'; if($veri.FullName -ne $hedef){ Copy-Item -LiteralPath $veri.FullName -Destination $hedef -Force }; $ad=[char]::ConvertFromUtf32(0x1F9FE) + ' BATTAL MUHASEBE.lnk'; $l=Join-Path $masa $ad; $k=$s.CreateShortcut($l); $k.TargetPath=$hedef; $k.WorkingDirectory=$masa; $k.Description='Ekstre - Mikro Excel, POS gunluk, banka kodlari. VERI SAKLAR.'; $k.Save(); Write-Host ('  [OK] ' + $ad); Write-Host ('       -> ' + $hedef) } else { Write-Host '  [!] Veri paneli bulunamadi.' -ForegroundColor Red }; Write-Host ''; if($pro){ $ad2=[char]::ConvertFromUtf32(0x1F4CA) + ' BATTAL PANEL PRO.lnk'; $l2=Join-Path $masa $ad2; $k2=$s.CreateShortcut($l2); $k2.TargetPath=$pro.FullName; $k2.WorkingDirectory=(Split-Path $pro.FullName); $k2.Description='Gmail indir, PDF-Excel, toplu export, validasyon. Veri saklamaz, internet ister.'; $k2.Save(); Write-Host ('  [OK] ' + $ad2); Write-Host ('       -> ' + $pro.FullName) } else { Write-Host '  [!] Battal Panel Pro bulunamadi.' -ForegroundColor Red }; Write-Host ''; Write-Host '  Masaustunde artik iki kisayol var.' -ForegroundColor Green"
echo.
pause
