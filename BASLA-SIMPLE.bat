@echo off
chcp 65001 >nul
cls

cd /d "%~dp0"

echo.
echo 🚀 BATTAL PANEL BAŞLIYOR...
echo.

REM Helper 1: Organize
if exist gmail-helper.js (
    echo 🔄 Gmail dosyaları organize ediliyor...
    start cmd /k "node gmail-helper.js && pause"
    timeout /t 3 /nobreak
)

REM Panel aç
echo 🎨 Panel açılıyor...
start file:///%CD:~0,1%:|%CD:\=/%/BATTAL-BANKA-POS.html
timeout /t 2 /nobreak

REM Helper 2: Export
echo 💾 Export helper başlatılıyor...
start cmd /k "node battal-export-helper.js"

cls
echo.
echo ════════════════════════════════════════════════════════════
echo ✅ BAŞLANDI!
echo ════════════════════════════════════════════════════════════
echo.
echo Panel açılmış, Helper çalışıyor
echo.
echo Panel'de yapacakların:
echo   1. "🏦 Banka Hesap Kodları" → battal-tum-hesap-planlari.json aç
echo   2. "Firma seç" → Banka seç → Dosya yükle
echo   3. DÖNÜŞTÜR → Toplu İhraç → İndir (Minimal)
echo   4. Tekrarla (35 firma)
echo.
echo Tüm Excel dosyalar Desktop\battal-export\ klasörüne kaydedilir.
echo.
pause
