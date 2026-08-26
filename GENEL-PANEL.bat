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
powershell -NoProfile -ExecutionPolicy Bypass -Command "$Girdi='%~1'; $s=[IO.File]::ReadAllText('%~f0',[Text.Encoding]::UTF8); $m='#'+'-PSBODY-'; $i=$s.LastIndexOf($m); iex $s.Substring($i+$m.Length)"
echo.
pause
exit /b
#-PSBODY-
# GENEL PANEL uretici - klasordeki tum panelleri tek bir hub dosyasinda toplar
$ErrorActionPreference = 'SilentlyContinue'
$masa = [Environment]::GetFolderPath('Desktop')

Write-Host ""
Write-Host "  GENEL PANEL olusturuluyor..." -ForegroundColor Cyan
Write-Host ""

# --- 1) Panel kokunu bul ---
$kok = $null
if ($Girdi -and (Test-Path -LiteralPath $Girdi)) {
    $it = Get-Item -LiteralPath $Girdi
    $kok = if ($it.PSIsContainer) { $it.FullName } else { $it.DirectoryName }
}
if (-not $kok) {
    $aramaYerleri = @(
        (Join-Path $masa 'BATTAL-MUHASEBE-PANEL'),
        (Join-Path $masa 'KURTARILAN-ZIP\_acilmis'),
        (Join-Path $masa 'PANELLER'),
        (Join-Path $masa 'BATTAL-MUSAVIR'),
        $masa
    )
    $adaylar = @()
    foreach ($y in $aramaYerleri) {
        if (Test-Path -LiteralPath $y) {
            $adaylar += Get-ChildItem -LiteralPath $y -Recurse -File -Filter 'BATTAL-MUHASEBE.html' -ErrorAction SilentlyContinue
        }
        if ($adaylar.Count -gt 0) { break }
    }
    if ($adaylar.Count -eq 0) {
        Write-Host "  [HATA] BATTAL-MUHASEBE.html bulunamadi." -ForegroundColor Red
        Write-Host "  Cozum: panel klasorunu bu .bat dosyasinin uzerine surukleyip birakin."
        exit
    }
    # kardes html sayisi en cok olani sec (eksiksiz paket)
    $enIyi = $null; $enCok = -1
    foreach ($a in $adaylar) {
        $n = @(Get-ChildItem -LiteralPath $a.DirectoryName -File | Where-Object { $_.Extension -match '^\.html?$' }).Count
        if ($n -gt $enCok) { $enCok = $n; $enIyi = $a }
    }
    $kok = $enIyi.DirectoryName
}
Write-Host "  Panel klasoru : $kok"

# --- 2) Panelleri topla ---
$dosyalar = Get-ChildItem -LiteralPath $kok -Recurse -Depth 2 -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '(?i)^\.(html?|bat)$' -and $_.Name -ne 'GENEL-PANEL.html' }

function Kategori($ad) {
    if ($ad -match '(?i)^(KOMUTA|GENEL-PANEL)' -or $ad -match '(?i)^BATTAL-MUHASEBE\.html$') { return 'MERKEZ' }
    if ($ad -match '(?i)musavir|defterbeyan|fatura|trendyol|DB_|MUHASEBE|BANKA|POS|beyanname|gider|battal') { return 'IS' }
    if ($ad -match '(?i)KGK|Soru|SAGLIK|SPOR|DIYET|KISISEL|GELISIM|INGILIZCE') { return 'KISISEL' }
    return 'DIGER'
}
function Simge($ad) {
    if ($ad -match '(?i)KOMUTA|GENEL-PANEL') { return [char]::ConvertFromUtf32(0x1F3AF) }
    if ($ad -match '(?i)musavir')      { return [char]::ConvertFromUtf32(0x1F34A) }
    if ($ad -match '(?i)defterbeyan|beyanname') { return [char]::ConvertFromUtf32(0x26A1) }
    if ($ad -match '(?i)fatura')       { return [char]::ConvertFromUtf32(0x1F9FE) }
    if ($ad -match '(?i)trendyol')     { return [char]::ConvertFromUtf32(0x1F6D2) }
    if ($ad -match '(?i)banka|POS')    { return [char]::ConvertFromUtf32(0x1F3E6) }
    if ($ad -match '(?i)gider|DB_')    { return [char]::ConvertFromUtf32(0x1F4B8) }
    if ($ad -match '(?i)KGK')          { return [char]::ConvertFromUtf32(0x1F393) }
    if ($ad -match '(?i)Soru')         { return [char]::ConvertFromUtf32(0x1F4DA) }
    if ($ad -match '(?i)SAGLIK|SPOR')  { return [char]::ConvertFromUtf32(0x1F4AA) }
    if ($ad -match '(?i)KISISEL|GELISIM') { return [char]::ConvertFromUtf32(0x1F331) }
    if ($ad -match '(?i)INGILIZCE')    { return [char]::ConvertFromUtf32(0x1F1EC) }
    if ($ad -match '(?i)KOMUTA')       { return [char]::ConvertFromUtf32(0x1F3AF) }
    if ($ad -match '(?i)MUHASEBE')     { return [char]::ConvertFromUtf32(0x1F4CA) }
    return [char]::ConvertFromUtf32(0x1F4C4)
}

$kayitlar = @()
foreach ($f in $dosyalar) {
    $gorece = $f.FullName.Substring($kok.Length).TrimStart('\')
    $kayitlar += [pscustomobject]@{
        Ad   = [IO.Path]::GetFileNameWithoutExtension($f.Name) -replace '[_-]+',' '
        Yol  = $gorece -replace '\\','/'
        Kat  = Kategori $f.Name
        Sim  = Simge $f.Name
        Bat  = ($f.Extension -match '(?i)^\.bat$')
        KB   = [math]::Round($f.Length/1KB,0)
    }
}
$kayitlar = $kayitlar | Sort-Object Kat, Ad
Write-Host "  Bulunan panel : $($kayitlar.Count)"

# --- 3) HTML uret ---
function Esc($s) { $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;' }

$js = ($kayitlar | ForEach-Object {
    "{ad:`"$(Esc $_.Ad)`",yol:`"$(Esc $_.Yol)`",kat:`"$($_.Kat)`",sim:`"$($_.Sim)`",bat:$(if($_.Bat){'true'}else{'false'}),kb:$($_.KB)}"
}) -join ",`n "

$html = @"
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🎛️ Genel Panel</title>
<style>
:root{--bg:#0f1419;--panel:#1a2230;--panel2:#222d3d;--line:#2d3a4d;--txt:#e6edf3;--mut:#8b9bb0;--acc:#4cc2ff;--is:#ff9800;--ki:#9c27b0}
[data-theme="light"]{--bg:#eef2f7;--panel:#fff;--panel2:#f4f7fb;--line:#dde5ef;--txt:#15202b;--mut:#5d6b7d}
*{box-sizing:border-box}html,body{height:100%}
body{margin:0;background:var(--bg);color:var(--txt);font-family:'Segoe UI',system-ui,Arial,sans-serif;display:flex;flex-direction:column}
header{display:flex;align-items:center;gap:12px;padding:12px 16px;background:linear-gradient(135deg,var(--panel),var(--panel2));border-bottom:1px solid var(--line);flex-wrap:wrap}
header h1{margin:0;font-size:18px;white-space:nowrap}
.ara{flex:1;min-width:160px;background:var(--panel2);border:1px solid var(--line);color:var(--txt);padding:8px 12px;border-radius:999px;font-size:13px}
.ikon{background:var(--panel2);border:1px solid var(--line);color:var(--txt);width:38px;height:38px;border-radius:10px;cursor:pointer;font-size:16px}
#wrap{flex:1;position:relative;overflow:auto}
#frame{width:100%;height:100%;border:none;display:none;background:#fff}
#giris{padding:22px;max-width:1100px;margin:0 auto}
.grp{margin-bottom:26px}
.grp h2{font-size:13px;letter-spacing:.12em;color:var(--mut);margin:0 0 12px;text-transform:uppercase}
.grid{display:grid;gap:14px;grid-template-columns:repeat(auto-fill,minmax(210px,1fr))}
.kart{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:16px;cursor:pointer;transition:.16s;text-align:left}
.kart:hover{transform:translateY(-3px);border-color:var(--acc)}
.kart .s{font-size:30px;display:block;margin-bottom:8px}
.kart .a{font-weight:700;font-size:14px;line-height:1.3}
.kart .m{font-size:11px;color:var(--mut);margin-top:5px}
.kart.is{border-left:4px solid var(--is)}.kart.ki{border-left:4px solid var(--ki)}.kart.mz{border-left:4px solid var(--acc)}
.geri{display:none;align-items:center;gap:8px}
.bos{color:var(--mut);text-align:center;padding:40px}
</style>
</head>
<body data-theme="dark">
<header>
  <h1>🎛️ Genel Panel</h1>
  <div class="geri" id="geri"><button class="ikon" id="geriBtn">←</button><span id="acikAd"></span></div>
  <input class="ara" id="ara" placeholder="🔍 panel ara...">
  <button class="ikon" id="temaBtn">🌙</button>
</header>
<div id="wrap">
  <iframe id="frame" allow="clipboard-write; clipboard-read; fullscreen"></iframe>
  <div id="giris"></div>
</div>
<script>
const PANELLER=[
 $js
];
const KAT={MERKEZ:{ad:"Merkez",c:"mz"},IS:{ad:"İş · Muhasebe",c:"is"},KISISEL:{ad:"Kişisel",c:"ki"},DIGER:{ad:"Diğer",c:""}};
const q=id=>document.getElementById(id);
function tema(t){document.body.dataset.theme=t;q("temaBtn").textContent=t==="dark"?"🌙":"☀️";try{localStorage.setItem("genel_tema",t)}catch(e){}}
q("temaBtn").onclick=()=>tema(document.body.dataset.theme==="dark"?"light":"dark");
try{tema(localStorage.getItem("genel_tema")||"dark")}catch(e){tema("dark")}
function ciz(filtre){
  const f=(filtre||"").toLocaleLowerCase("tr");
  const liste=PANELLER.filter(p=>!f||p.ad.toLocaleLowerCase("tr").includes(f));
  let h="";
  for(const k of ["MERKEZ","IS","KISISEL","DIGER"]){
    const grup=liste.filter(p=>p.kat===k);
    if(!grup.length)continue;
    h+='<div class="grp"><h2>'+KAT[k].ad+' · '+grup.length+'</h2><div class="grid">';
    for(const p of grup){
      h+='<div class="kart '+KAT[k].c+'" data-yol="'+p.yol+'" data-ad="'+p.ad+'" data-bat="'+p.bat+'">'
       +'<span class="s">'+p.sim+'</span><div class="a">'+p.ad+'</div>'
       +'<div class="m">'+(p.bat?'Windows programı ↗':p.kb+' KB')+'</div></div>';
    }
    h+='</div></div>';
  }
  q("giris").innerHTML=h||'<div class="bos">Eşleşen panel yok.</div>';
  document.querySelectorAll(".kart").forEach(k=>k.onclick=()=>ac(k.dataset.yol,k.dataset.ad,k.dataset.bat==="true"));
}
function ac(yol,ad,bat){
  if(bat){window.open(yol,"_blank");return;}
  q("giris").style.display="none";q("frame").style.display="block";q("frame").src=yol;
  q("geri").style.display="flex";q("acikAd").textContent=ad;
}
q("geriBtn").onclick=()=>{q("frame").style.display="none";q("frame").src="about:blank";q("giris").style.display="block";q("geri").style.display="none";};
q("ara").oninput=e=>ciz(e.target.value);
ciz("");
</script>
</body>
</html>
"@

$hedefDosya = Join-Path $kok 'GENEL-PANEL.html'
$html | Out-File -LiteralPath $hedefDosya -Encoding UTF8
Write-Host "  Olusturuldu   : $hedefDosya" -ForegroundColor Green

# --- 4) Kisayol ---
$s = New-Object -ComObject WScript.Shell
$ad = [char]::ConvertFromUtf32(0x1F39B) + ' GENEL PANEL.lnk'
$lnk = Join-Path $masa $ad
$k = $s.CreateShortcut($lnk)
$k.TargetPath = $hedefDosya
$k.WorkingDirectory = $kok
$k.Description = 'Genel Panel - tum paneller tek girişte'
$k.Save()

Write-Host ""
if (Test-Path -LiteralPath $lnk) {
    Write-Host "  [OK] Masaustu kisayolu: $ad" -ForegroundColor Green
} else {
    Write-Host "  [HATA] Kisayol olusturulamadi." -ForegroundColor Red
}
Write-Host ""
foreach ($k2 in ($kayitlar | Group-Object Kat)) {
    Write-Host ("     " + $k2.Name.PadRight(9) + $k2.Count + " panel")
}
Write-Host ""
Start-Process $hedefDosya
