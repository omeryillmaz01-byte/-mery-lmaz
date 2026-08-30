@echo off
chcp 65001 >nul
title KURTARMA v2 - Cakismasiz
setlocal
echo.
echo  ==================================================
echo    GERI DONUSUM KURTARMA  v2
echo    Her oge KENDI alt klasorune kopyalanir,
echo    boylece isim cakismasi ve soru penceresi olmaz.
echo.
echo    Geri donusum kutusu BOSALTILMAZ.
echo  ==================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $masa=[Environment]::GetFolderPath('Desktop'); $hedef=Join-Path $masa 'KURTARILAN-PANELLER-2'; if(-not (Test-Path -LiteralPath $hedef)){ New-Item -ItemType Directory -Path $hedef | Out-Null }; $sh=New-Object -ComObject Shell.Application; $rb=$sh.Namespace(0xA); if(-not $rb){ Write-Host '  [HATA] Geri donusum kutusu okunamadi.' -ForegroundColor Red; exit 1 }; $desen='(?i)KOMUTA|KISISEL-MERKEZ|battal-yedek|battaltumhesapplanlari|Battal_Muhasebe_Kurulum|BATTAL_MUHASEBE_DB_PRO|EKSIKLIK|EKS.KL.K|PANEL_READY|yeni xxx panel'; $sat=@(); $sat += ('KURTARMA v2: ' + (Get-Date).ToString('dd.MM.yyyy HH:mm')); $sat += ''; $i=0; foreach($it in $rb.Items()){;   if($it.Name -notmatch $desen){ continue };   $i++;   $temizAd = ($it.Name -replace '[\\/:*?<>|]','-');   $altAd = ('{0:d2}-{1}' -f $i, $temizAd);   if($altAd.Length -gt 70){ $altAd = $altAd.Substring(0,70) };   $alt = Join-Path $hedef $altAd;   if(-not (Test-Path -LiteralPath $alt)){ New-Item -ItemType Directory -Path $alt | Out-Null };   $dh = $sh.Namespace($alt);   if($dh){ $dh.CopyHere($it, 16) };   $bilgi = ('   ' + ('{0:d2}' -f $i) + '  ' + $it.Name.PadRight(46) + ' silinme: ' + $rb.GetDetailsOf($it,2).PadRight(20) + '  <- ' + $rb.GetDetailsOf($it,1));   $sat += $bilgi;   Write-Host $bilgi; }; Write-Host ''; Write-Host '  Kopyalama tamamlaniyor, bekleyin...'; Start-Sleep -Seconds 6; $sat += ''; $sat += ('=== KOPYALANAN DOSYALAR (' + $hedef + ') ==='); $kop = @(Get-ChildItem -LiteralPath $hedef -Recurse -File -ErrorAction SilentlyContinue); if($kop.Count -eq 0){ $sat += '   (hicbir dosya kopyalanamadi)' }; foreach($f in $kop){ $sat += ('   ' + ([math]::Round($f.Length/1KB,0)).ToString().PadLeft(7) + ' KB  ' + $f.FullName.Substring($hedef.Length)) }; $cikti=Join-Path $masa 'KURTARMA-SONUC-2.txt'; $sat | Out-File -LiteralPath $cikti -Encoding UTF8; Write-Host ''; Write-Host ('  ' + $i + ' oge eslesti, ' + $kop.Count + ' dosya kopyalandi.') -ForegroundColor Green; Write-Host ('  Klasor: ' + $hedef); Write-Host ('  Rapor : ' + $cikti); Start-Process $hedef; Start-Process notepad.exe $cikti"
echo.
pause
