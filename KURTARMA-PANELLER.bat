@echo off
chcp 65001 >nul
title KURTARMA - Geri Donusum Kutusundan Panelleri Al
setlocal
echo.
echo  ==================================================
echo    GERI DONUSUM KUTUSUNDAN KURTARMA
echo    KOMUTA-MERKEZI, KOMUTA-IS, KOMUTA-KISISEL,
echo    KISISEL-MERKEZ, battal-yedek json, hesap planlari
echo.
echo    Geri donusum kutusu BOSALTILMAZ - sadece KOPYALANIR.
echo  ==================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $masa=[Environment]::GetFolderPath('Desktop'); $hedef=Join-Path $masa 'KURTARILAN-PANELLER'; if(-not (Test-Path -LiteralPath $hedef)){ New-Item -ItemType Directory -Path $hedef | Out-Null }; $sh=New-Object -ComObject Shell.Application; $rb=$sh.Namespace(0xA); $hd=$sh.Namespace($hedef); if(-not $rb){ Write-Host '  [HATA] Geri donusum kutusu okunamadi.' -ForegroundColor Red; exit 1 }; $desen='(?i)KOMUTA|KISISEL-MERKEZ|battal-yedek|battaltumhesapplanlari|Battal_Muhasebe_Kurulum|BATTAL_MUHASEBE_DB_PRO|EKSIKLIK|EKS.KL.K|PANEL'; $sat=@(); $sat += ('KURTARMA: ' + (Get-Date).ToString('dd.MM.yyyy HH:mm')); $sat += ''; $n=0; foreach($it in $rb.Items()){;   if($it.Name -notmatch $desen){ continue };   $konum=$rb.GetDetailsOf($it,1);   $silTarih=$rb.GetDetailsOf($it,2);   $bilgi=('   ' + $it.Name.PadRight(46) + ' silinme: ' + $silTarih + '   <- ' + $konum);   $sat += $bilgi;   Write-Host $bilgi;   $hd.CopyHere($it);   $n++; }; Start-Sleep -Seconds 3; $sat += ''; $sat += ('Eslesen oge: ' + $n); $sat += ''; $sat += '=== KURTARILAN KLASORE KOPYALANANLAR ==='; $kop = Get-ChildItem -LiteralPath $hedef -Recurse -ErrorAction SilentlyContinue; if($kop.Count -eq 0){ $sat += '   (kopyalama tamamlanmadi - asagidaki ELLE YONTEM bolumune bakin)' }; foreach($f in $kop){ if(-not $f.PSIsContainer){ $sat += ('   ' + ([math]::Round($f.Length/1KB,0)).ToString().PadLeft(7) + ' KB  ' + $f.FullName.Replace($hedef,'')) } }; $cikti=Join-Path $masa 'KURTARMA-SONUC.txt'; $sat | Out-File -LiteralPath $cikti -Encoding UTF8; Write-Host ''; Write-Host ('  ' + $n + ' oge eslesti. Hedef klasor: ' + $hedef) -ForegroundColor Green; Write-Host ('  Rapor: ' + $cikti); Start-Process $hedef"
echo.
pause
