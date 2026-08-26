@echo off
chcp 65001 >nul
title PANELLER KLASORU - Dokum
setlocal
echo.
echo  ==================================================
echo    PANELLER KLASORU DOKUMU  (salt okunur)
echo  ==================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText('%~f0',[Text.Encoding]::UTF8); $m='#'+'-PSBODY-'; $i=$s.LastIndexOf($m); iex $s.Substring($i+$m.Length)"
echo.
pause
exit /b
#-PSBODY-

$ErrorActionPreference='SilentlyContinue'
$masa=[Environment]::GetFolderPath('Desktop')
$sat=@()
function Y($m){ $script:sat += $m; Write-Host $m }

Y "================================================"
Y "  PANELLER KLASORU DOKUMU"
Y "================================================"
Y ""

# Emoji/bosluk iceren klasor adlari -Filter ile atlanabiliyor; joker ile ara
$kokler = @()
foreach($d in (Get-ChildItem -LiteralPath $masa -Directory -Force)){
  if($d.Name -match '(?i)PANELLER|OFIS|BATTAL|MUHASEBE'){ $kokler += $d }
}
if($kokler.Count -eq 0){ Y "  [X] Masaustunde eslesen klasor yok."; }

foreach($k in $kokler){
  Y ("=== " + $k.Name + " ===")
  Y ("    " + $k.FullName)
  $dosyalar = @(Get-ChildItem -LiteralPath $k.FullName -Recurse -File -Force -ErrorAction SilentlyContinue)
  Y ("    toplam dosya: " + $dosyalar.Count)
  $htmls = @($dosyalar | Where-Object { $_.Extension -match '(?i)^\.html?$' })
  Y ("    html: " + $htmls.Count)
  Y ""
  if($htmls.Count -gt 0){
    Y "    --- HTML dosyalari (panel referans sayisina gore) ---"
    $liste=@()
    foreach($f in $htmls){
      $ic = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
      $n = 0
      if($ic){ $n = @([regex]::Matches($ic,'(?i)[A-Za-z0-9_.-]+\.html') | ForEach-Object { $_.Value.ToLower() } | Select-Object -Unique).Count }
      $liste += [pscustomobject]@{ S=$n; B=$f.Length; Y=$f.FullName.Substring($k.FullName.Length) }
    }
    foreach($x in ($liste | Sort-Object S -Descending)){
      Y ("     " + ([string]$x.S).PadLeft(3) + " ref  " + ([math]::Round($x.B/1KB,0)).ToString().PadLeft(7) + " KB  " + $x.Y)
    }
    Y ""
  }
  $klasorler = @(Get-ChildItem -LiteralPath $k.FullName -Directory -Force -ErrorAction SilentlyContinue)
  if($klasorler.Count -gt 0){
    Y "    --- alt klasorler ---"
    foreach($a in $klasorler){ Y ("     " + $a.Name) }
    Y ""
  }
}

$cikti=Join-Path $masa 'PANELLER-DOKUM.txt'
$sat | Out-File -LiteralPath $cikti -Encoding UTF8
$metin = ($sat -join [Environment]::NewLine)
if($metin.Length -gt 24000){ $metin = $metin.Substring(0,24000) + [Environment]::NewLine + '... (kisaltildi)' }
Set-Clipboard -Value $metin
Write-Host ""
Write-Host "  ================================================" -ForegroundColor Green
Write-Host "   RAPOR PANOYA KOPYALANDI - sohbete Ctrl+V" -ForegroundColor Green
Write-Host ("   Dosya: " + $cikti) -ForegroundColor Green
Write-Host "  ================================================" -ForegroundColor Green
