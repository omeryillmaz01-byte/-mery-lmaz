@echo off
chcp 65001 >nul
title BATTAL ADAYLARI - Hepsini Kisayol Yap
setlocal
set "KLASOR=%~dp0"
echo.
echo  ============================================
echo    BATTAL / MUSAVIR ADAYLARI
echo    Her kopya icin AYRI kisayol olusturulur
echo  ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $masa=[Environment]::GetFolderPath('Desktop'); $kokler=@((Join-Path $env:USERPROFILE 'Downloads'), (Join-Path $env:USERPROFILE 'Documents'), $masa, '%KLASOR%'); if($env:OneDrive){ $kokler += (Join-Path $env:OneDrive 'Downloads'); $kokler += (Join-Path $env:OneDrive 'Belgeler') }; $kokler = $kokler | Select-Object -Unique; $bulunan=@(); foreach($d in $kokler){ if(Test-Path -LiteralPath $d){ $bulunan += (Get-ChildItem -LiteralPath $d -Recurse -Depth 3 -File -ErrorAction SilentlyContinue | Where-Object { ($_.Extension -match '^\.html?$') -and (($_.FullName -match 'battal') -or ($_.FullName -match 'musavir') -or ($_.FullName -match 'MUSAVIR') -or ($_.Name -match 'DB_')) }) } }; $bulunan = $bulunan | Sort-Object FullName -Unique | Sort-Object LastWriteTime -Descending; if($bulunan.Count -eq 0){ Write-Host '  [HATA] Hicbir aday bulunamadi.' -ForegroundColor Red; exit 1 }; $klasor=Join-Path $masa 'BATTAL-ADAYLAR'; if(-not (Test-Path -LiteralPath $klasor)){ New-Item -ItemType Directory -Path $klasor | Out-Null }; Get-ChildItem -LiteralPath $klasor -Filter '*.lnk' -File | Remove-Item -Force; $s=New-Object -ComObject WScript.Shell; $sat=@(); $i=0; foreach($f in $bulunan){;   $i++;   $ust=Split-Path (Split-Path $f.FullName -Parent) -Leaf;   if($ust.Length -gt 26){ $ust=$ust.Substring(0,26) };   $etiket=('{0:d2}  {1}  [{2}]  {3}' -f $i, $f.BaseName, $f.LastWriteTime.ToString('dd.MM HH:mm'), $ust);   $temiz=($etiket -replace '[\\/:*?<>|]','-');   $l=Join-Path $klasor ($temiz + '.lnk');   $k=$s.CreateShortcut($l); $k.TargetPath=$f.FullName; $k.WorkingDirectory=$f.DirectoryName; $k.Description=$f.FullName; $k.Save();   $bilgi=('{0:d2}  {1,6} KB  {2}  {3}' -f $i, [math]::Round($f.Length/1KB,0), $f.LastWriteTime.ToString('dd.MM.yyyy HH:mm'), $f.FullName);   $sat += $bilgi;   Write-Host ('  ' + $bilgi); }; $sat | Out-File -LiteralPath (Join-Path $klasor '00-LISTE.txt') -Encoding UTF8; Write-Host ''; Write-Host ('  ' + $i + ' aday icin kisayol olusturuldu.') -ForegroundColor Green; Write-Host ('  Klasor: ' + $klasor); Write-Host '  Sirayla acip hangisinin aradiginiz panel oldugunu bulun.'; Start-Process $klasor"
echo.
pause
