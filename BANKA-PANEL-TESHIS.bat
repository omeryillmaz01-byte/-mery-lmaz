@echo off
chcp 65001 >nul
title BANKA PANEL - Teshis
setlocal enabledelayedexpansion

set "MASA=%USERPROFILE%\OneDrive\Desktop"
if not exist "%MASA%" set "MASA=%USERPROFILE%\Desktop"
set "LOG=%MASA%\BANKA-TESHIS.txt"
break > "%LOG%"

call :y "================================================"
call :y "  BANKA PANEL TESHIS"
call :y "================================================"
call :y ""

call :y "--- 1) PYTHON KONTROLU ---"
set "PYEXE="
python --version >nul 2>&1
if !errorlevel! equ 0 set "PYEXE=python"
if not defined PYEXE (
  py --version >nul 2>&1
  if !errorlevel! equ 0 set "PYEXE=py"
)
if not defined PYEXE (
  python3 --version >nul 2>&1
  if !errorlevel! equ 0 set "PYEXE=python3"
)
if defined PYEXE (
  for /f "delims=" %%V in ('!PYEXE! --version 2^>^&1') do call :y "  BULUNDU: !PYEXE!   surum: %%V"
) else (
  call :y "  [X] PYTHON KURULU DEGIL"
  call :y "      Sorun buyuk ihtimalle bu. Kurulum: python.org"
)
call :y ""

call :y "--- 2) banka_panel.py ARANIYOR ---"
set "SCRIPT="
set "SAYI=0"
for /f "delims=" %%F in ('dir /b /s /a-d "%MASA%\banka_panel.py" 2^>nul') do (
  set /a SAYI+=1
  if not defined SCRIPT set "SCRIPT=%%F"
  call :y "  %%F"
)
for /f "delims=" %%F in ('dir /b /s /a-d "%USERPROFILE%\Downloads\banka_panel.py" 2^>nul') do (
  set /a SAYI+=1
  if not defined SCRIPT set "SCRIPT=%%F"
  call :y "  %%F"
)
if !SAYI! equ 0 call :y "  [X] banka_panel.py bulunamadi"
call :y ""

call :y "--- 3) CALISTIRMA DENEMESI ---"
if not defined PYEXE (
  call :y "  Python olmadigi icin denenmedi."
  goto :bitir
)
if not defined SCRIPT (
  call :y "  Script bulunamadigi icin denenmedi."
  goto :bitir
)
call :y "  Calistirilan: !SCRIPT!"
call :y "  ---- cikti ----"
pushd "!SCRIPT!\.."
!PYEXE! "!SCRIPT!" >>"%LOG%" 2>&1
set "RC=!errorlevel!"
popd
call :y "  ---- bitti, cikis kodu: !RC! ----"

:bitir
call :y ""
call :y "================================================"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Clipboard -Value ([IO.File]::ReadAllText('%LOG%'))" >nul 2>&1
cls
type "%LOG%"
echo.
echo  ================================================
echo    RAPOR PANOYA KOPYALANDI  --  sohbete Ctrl+V
echo    Dosya: %LOG%
echo  ================================================
echo.
pause
exit /b

:y
echo %~1
>>"%LOG%" echo %~1
exit /b
