@echo off
chcp 65001 >nul
echo Masaüstü kısayolu oluşturuluyor...

set "DOSYA=%~dp0OMER-YILMAZ.html"
set "MASAUSTU=%USERPROFILE%\Desktop"
set "KISAYOL=%MASAUSTU%\ÖMER YILMAZ.url"

(
echo [InternetShortcut]
echo URL=file:///%DOSYA:\=/%
echo IconFile=%SystemRoot%\System32\shell32.dll
echo IconIndex=14
) > "%KISAYOL%"

echo.
echo ✅ Kısayol oluşturuldu: %KISAYOL%
echo.
pause
