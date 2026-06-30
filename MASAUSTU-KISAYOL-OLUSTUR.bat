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
set "MASAUSTU=%USERPROFILE%\Desktop"
set "KISAYOL=%MASAUSTU%\⚡ ÖMER YILMAZ.url"

powershell -NoProfile -Command ^
  "$s=New-Object -ComObject WScript.Shell;" ^
  "$k=$s.CreateShortcut('%MASAUSTU%\OMER YILMAZ.lnk');" ^
  "$k.TargetPath='%KAYNAK%';" ^
  "$k.Description='Omer Yilmaz Komut Merkezi v100';" ^
  "$k.IconLocation='%SystemRoot%\System32\imageres.dll,97';" ^
  "$k.WindowStyle=1;" ^
  "$k.Save();"

if exist "%MASAUSTU%\OMER YILMAZ.lnk" (
  echo  ✅ Başarılı! Masaüstünde "OMER YILMAZ" kısayolu hazır.
  echo.
  echo  Çift tıkla → tarayıcıda açılır 🚀
) else (
  echo  ⚠️  Kısayol oluşturulamadı, URL yöntemi deneniyor...
  (
    echo [InternetShortcut]
    echo URL=file:///%KAYNAK:\=/%
    echo IconFile=%SystemRoot%\System32\imageres.dll
    echo IconIndex=97
  ) > "%KISAYOL%"
  echo  ✅ Masaüstünde "ÖMER YILMAZ.url" hazır.
)

echo.
pause
