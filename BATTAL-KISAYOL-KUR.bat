@echo off
chcp 65001 >nul
title BATTAL MUHASEBE - Masaustu Kurulum

echo.
echo  ============================================
echo    BATTAL MUHASEBE - Masaustu Kisayolu
echo  ============================================
echo.

set "KAYNAK=%~dp0BATTAL-BANKA-POS.html"
set "IKON=%~dp0OMER-YILMAZ.ico"

if not exist "%KAYNAK%" (
  echo  [HATA] BATTAL-BANKA-POS.html bu klasorde bulunamadi.
  echo         Bu .bat dosyasini HTML ile ayni klasore koyun.
  echo.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$masa=[Environment]::GetFolderPath('Desktop');" ^
  "Write-Host ('  Masaustu: ' + $masa);" ^
  "$hedef=Join-Path $masa 'BATTAL-BANKA-POS.html';" ^
  "Copy-Item -LiteralPath '%KAYNAK%' -Destination $hedef -Force;" ^
  "Write-Host '  HTML masaustune kopyalandi.';" ^
  "$eskiAd=Join-Path $masa 'BATTAL-BANKA-POS-STANDALONE.html';" ^
  "if(Test-Path -LiteralPath $eskiAd){ Copy-Item -LiteralPath '%KAYNAK%' -Destination $eskiAd -Force; Write-Host '  Eski STANDALONE kopyasi da tazelendi.' };" ^
  "$ad=[char]::ConvertFromUtf32(0x1F9FE) + ' BATTAL MUHASEBE.lnk';" ^
  "$lnk=Join-Path $masa $ad;" ^
  "$s=New-Object -ComObject WScript.Shell;" ^
  "$k=$s.CreateShortcut($lnk);" ^
  "$k.TargetPath=$hedef;" ^
  "$k.WorkingDirectory=$masa;" ^
  "$k.Description='Battal Muhasebe - Banka ve POS Merkezi';" ^
  "if(Test-Path '%IKON%'){ $k.IconLocation='%IKON%,0' };" ^
  "$k.Save();" ^
  "if(Test-Path -LiteralPath $lnk){ Write-Host '  [OK] Kisayol olusturuldu.' } else { Write-Host '  [HATA] Kisayol olusturulamadi.' }"

echo.
echo  Bittiginde masaustunde "BATTAL MUHASEBE" kisayoluna cift tiklayin.
echo.
pause
