@echo off
chcp 65001 >nul
title BATTAL MUHASEBE - Masaustu Kurulum
setlocal
set "KLASOR=%~dp0"
echo.
echo  ============================================
echo    BATTAL MUHASEBE - Masaustu Kisayolu
echo  ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $masa=[Environment]::GetFolderPath('Desktop'); $ara=@('%KLASOR%', $masa, (Join-Path $env:USERPROFILE 'Downloads'), (Join-Path $env:USERPROFILE 'Desktop')); if($env:OneDrive){ $ara += (Join-Path $env:OneDrive 'Downloads'); $ara += (Join-Path $env:OneDrive 'Desktop') }; $ara=$ara | Select-Object -Unique; $bulunan=@(); foreach($d in $ara){ if(Test-Path -LiteralPath $d){ $bulunan += Get-ChildItem -LiteralPath $d -Filter 'BATTAL-BANKA-POS*.html' -File -ErrorAction SilentlyContinue } }; $kaynak = $bulunan | Where-Object { $_.Length -gt 1000000 } | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if(-not $kaynak){ Write-Host ''; Write-Host '  [HATA] Panel HTML dosyasi bulunamadi.' -ForegroundColor Red; Write-Host '  Su klasorlere bakildi:'; foreach($d in $ara){ Write-Host ('     - ' + $d) }; Write-Host ''; Write-Host '  BATTAL-BANKA-POS.html dosyasini bu klasorlerden birine indirip'; Write-Host '  bu .bat dosyasini tekrar calistirin.'; exit 1 }; Write-Host ('  Panel bulundu : ' + $kaynak.FullName); $hedef=Join-Path $masa 'BATTAL-BANKA-POS.html'; if($kaynak.FullName -ne $hedef){ Copy-Item -LiteralPath $kaynak.FullName -Destination $hedef -Force }; Write-Host ('  Masaustune    : ' + $hedef); $eski=Join-Path $masa 'BATTAL-BANKA-POS-STANDALONE.html'; if(Test-Path -LiteralPath $eski){ Copy-Item -LiteralPath $hedef -Destination $eski -Force; Write-Host '  Eski STANDALONE kopyasi da tazelendi.' }; $ad=[char]::ConvertFromUtf32(0x1F9FE) + ' BATTAL MUHASEBE.lnk'; $lnk=Join-Path $masa $ad; $s=New-Object -ComObject WScript.Shell; $k=$s.CreateShortcut($lnk); $k.TargetPath=$hedef; $k.WorkingDirectory=$masa; $k.Description='Battal Muhasebe - Banka ve POS Merkezi'; $ikon=Join-Path $masa 'OMER-YILMAZ.ico'; if(-not (Test-Path -LiteralPath $ikon)){ $ikon=Join-Path '%KLASOR%' 'OMER-YILMAZ.ico' }; if(Test-Path -LiteralPath $ikon){ $k.IconLocation=($ikon + ',0') }; $k.Save(); if(Test-Path -LiteralPath $lnk){ Write-Host ''; Write-Host '  [OK] Masaustunde kisayol hazir: BATTAL MUHASEBE' -ForegroundColor Green } else { Write-Host '  [HATA] Kisayol olusturulamadi.' -ForegroundColor Red }"
echo.
pause
