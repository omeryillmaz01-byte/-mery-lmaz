@echo off
chcp 65001 >nul
cls

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         🚀 BATTAL PANEL - OTOMATIK BAŞLAT                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

setlocal enabledelayedexpansion
cd /d "%~dp0"

REM Kontrol: Node.js yüklü mü?
node --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ Node.js yüklü değil!
    echo.
    echo Node.js v16+ indir: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo ✅ Node.js bulundu
echo.

REM Desktop klasörünü bul
set DESKTOP=%USERPROFILE%\Desktop

if not exist "%DESKTOP%" (
    echo ❌ Desktop klasörü bulunamadı!
    pause
    exit /b 1
)

echo ✅ Desktop bulundu: %DESKTOP%
echo.

REM Gerekli klasörleri oluştur
if not exist "%DESKTOP%\banka-haziran" (
    mkdir "%DESKTOP%\banka-haziran"
    echo ✅ Oluşturuldu: Desktop\banka-haziran
)

if not exist "%DESKTOP%\banka-ready" (
    mkdir "%DESKTOP%\banka-ready"
    echo ✅ Oluşturuldu: Desktop\banka-ready
)

echo.
echo ════════════════════════════════════════════════════════════
echo.
echo 📋 YAPILACAKLAR:
echo.
echo 1. Gmail'den indir (10 dakika)
echo    └─ Gmail aç → banka haziran dosyaları
echo    └─ Desktop\banka-haziran\ klasörüne taşı
echo.
echo 2. Organize Et (5 dakika)
echo    └─ Şu komutu çalıştırıyor:
echo    └─ node gmail-helper.js
echo.
echo 3. Panel Aç (otomatik)
echo    └─ Tarayıcıda: file:///...BATTAL-BANKA-POS.html
echo.
echo 4. Helper Başlat (arka planda)
echo    └─ node battal-export-helper.js
echo.
echo 5. Dosya işle
echo    └─ Panel'de: Firma → Dosya → DÖNÜŞTÜR → İhraç
echo.
echo ════════════════════════════════════════════════════════════
echo.
echo.
pause
cls

echo.
echo 📥 ADIM 1: GMAIL'DEN İNDİR
echo ════════════════════════════════════════════════════════════
echo.
echo 👉 Gmail aç: https://gmail.com
echo.
echo 🔍 Ara: "banka haziran" veya "ekstreleri"
echo.
echo 💾 Hepsini indir ve taşı:
echo    Desktop\banka-haziran\ klasörüne
echo.
echo ✏️  Not: Banka dosyaları (XLSX) önemli!
echo.
echo.
pause

REM Başlat düğmesi: Gmail'i tarayıcıda aç
start https://gmail.com
timeout /t 2 /nobreak

cls
echo.
echo.
echo 📝 ADIM 2: GMAIL DOSYALARINI KONTROLEt
echo ════════════════════════════════════════════════════════════
echo.
echo ✅ Dosyalar Desktop\banka-haziran\ klasörüne taşındı mı?
echo.
echo Lütfen kontrol et:
echo   → %DESKTOP%\banka-haziran\
echo.
set /p DEVAM="Dosyalar hazır mı? (E/H): "
if /i not "%DEVAM%"=="e" (
    echo.
    echo Gmail açık kal, dosyaları taşı, sonra aç.
    echo.
    pause
    goto :EOF
)

cls
echo.
echo 🔄 ADIM 3: DOSYALARI ORGANIZE ET
echo ════════════════════════════════════════════════════════════
echo.
echo Çalışıyor: gmail-helper.js
echo.

node gmail-helper.js

echo.
echo.
echo ✅ Dosyalar organize edildi!
echo.
echo Kontrol et:
echo   → %DESKTOP%\banka-ready\
echo.
echo (Firma-Banka(HesapNo).xlsx formatında)
echo.
pause

cls
echo.
echo 🎨 ADIM 4: PANEL AÇ
echo ════════════════════════════════════════════════════════════
echo.
echo Tarayıcıda açılıyor...
echo.

start file:///%CD:~0,1%:|%CD:\=/%/BATTAL-BANKA-POS.html

timeout /t 3 /nobreak

cls
echo.
echo ✅ Panel açıldı!
echo.
echo 🏦 Panel'de yapacakların:
echo.
echo   1. "🏦 Banka Hesap Kodları" sekmesine git
echo   2. "📂 Dosya Yükle" tıkla
echo   3. "battal-tum-hesap-planlari.json" seç
echo   4. Bekle (35 firma ve 1600+ hesap yüklenir)
echo.
pause

cls
echo.
echo 💾 ADIM 5: HELPER BAŞLAT
echo ════════════════════════════════════════════════════════════
echo.
echo Yeni terminal penceresinde helper başlatılıyor...
echo.
echo (Downloads klasörünü izler, Excel dosyaları otomatik Desktop'a taşır)
echo.

start cmd /k "cd /d "%CD%" && echo 🚀 BATTAL EXPORT HELPER && node battal-export-helper.js"

timeout /t 2 /nobreak

cls
echo.
echo ════════════════════════════════════════════════════════════
echo ✅ HAZIR!
echo ════════════════════════════════════════════════════════════
echo.
echo Panel'de şimdi yapacakların:
echo.
echo   1️⃣  Firma seç (dropdown)
echo       → 2AA
echo.
echo   2️⃣  Banka seç (dropdown)
echo       → GARANTI veya başka
echo.
echo   3️⃣  "📁 Dosya Yükle" tıkla
echo       → Desktop\banka-ready\ → Dosya seç
echo.
echo   4️⃣  [🔄 DÖNÜŞTÜR] tıkla
echo       → Kodlar otomatik atanır
echo.
echo   5️⃣  [📊 Toplu İhraç] tıkla
echo       → ⚡ Minimal seç → [📥 İndir]
echo.
echo   6️⃣  Helper otomatik Desktop\battal-export\'e taşır
echo.
echo   7️⃣  Sonraki firma → 1️⃣'den başla
echo.
echo.
echo ════════════════════════════════════════════════════════════
echo.
echo 📂 Dosyaların konumu:
echo.
echo    Panel:    %CD%\BATTAL-BANKA-POS.html
echo    İndir:    %DESKTOP%\banka-haziran\
echo    Organize: %DESKTOP%\banka-ready\
echo    Sonuç:    %DESKTOP%\battal-export\
echo.
echo ════════════════════════════════════════════════════════════
echo.
echo ✨ Hepsi bitti! Panel ve Helper çalışıyor.
echo.
echo 💡 Terminal pencereleri açık kal (kapatma).
echo.
pause
