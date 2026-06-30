@echo off
chcp 65001 >nul
title ÖMER YILMAZ — Masaüstü Kurulum

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   ⚡  ÖMER YILMAZ KOMUT MERKEZİ v100    ║
echo  ║        Masaüstü kısayolu kuruluyor...    ║
echo  ╚══════════════════════════════════════════╝
echo.

set "KAYNAK=%~dp0OMER-YILMAZ.html"
set "IKON=%~dp0OMER-YILMAZ.ico"
set "MASAUSTU=%USERPROFILE%\Desktop"

powershell -NoProfile -Command ^
  "$s=New-Object -ComObject WScript.Shell;" ^
  "$k=$s.CreateShortcut('%MASAUSTU%\OMER YILMAZ.lnk');" ^
  "$k.TargetPath='%KAYNAK%';" ^
  "$k.Description='Omer Yilmaz Komut Merkezi v100';" ^
  "$k.IconLocation='%IKON%,0';" ^
  "$k.WindowStyle=3;" ^
  "$k.Save();"

if exist "%MASAUSTU%\OMER YILMAZ.lnk" (
  echo  ✅ Masaüstünde "OMER YILMAZ" kısayolu hazır!
) else (
  echo  ⚠️  Hata olustu.
)
echo.
pause
