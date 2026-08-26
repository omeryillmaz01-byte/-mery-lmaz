@echo off
chcp 65001 >nul
title GENEL PANEL - Olustur
setlocal
echo.
echo  ==================================================
echo    GENEL PANEL OLUSTURULUYOR
echo    Klasordeki tum paneller tek girise toplanir.
echo  ==================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0GENEL-PANEL-OLUSTUR.ps1" %1
echo.
pause
