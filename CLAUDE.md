# Ömer Yılmaz — SMMM Panelleri

Muhasebe/SMMM işleri için tarayıcıda çalışan HTML panel koleksiyonu ve bunları
kullanıcının Windows makinesinde kurup onaran yardımcı scriptler.

**Kullanıcıyla iletişim Türkçe.**

---

## 1. Çalışma biçimi — en kritik kısıt

Bu oturum **uzak bir sunucuda** çalışıyor. **Kullanıcının diskine erişim yok.**

Kullanıcı sık sık yerel bir yol paylaşıp "bak bakalım" diyor. Bakılamaz.
Tek köprü: ona `.bat` script gönderip **çıktısını istemek**.

Sürtünmeyi azaltan kalıp: script raporu `Set-Clipboard` ile **panoya
kopyalasın**, kullanıcı sohbete Ctrl+V yapsın. Örnek:
`RAPORU-PANOYA-KOPYALA.bat`, `PANELLER-DOKUM.bat`.

Dosya alışverişi: kullanıcı dosyayı sohbete yükler, ben `SendUserFile` ile
geri gönderirim.

---

## 2. Paneller ve gerçek konumları

| Ne | Nerede | Not |
|---|---|---|
| **Asıl çalışma klasörü** | `Desktop\📂 PANELLER\` | 36.050 dosya, 159 HTML. Hiç silinmemişti; emoji adı yüzünden aylarca bulunamadı |
| **Aranan hub** | `📂 PANELLER\BATTAL-MUHASEBE.html` | **104 KB** — en gelişmiş sürüm (diğer kopyalar 70–76 KB) |
| `BATTAL-BANKA-POS.html` | bu repo, ~2,3 MB | Onarıldı, 35 firmalık hesap planı gömülü |
| `KOMUTA-MERKEZI/IS/KISISEL.html` | bu repo | Geri dönüşüm kutusundan kurtarıldı |
| `OMER-YILMAZ.html` | bu repo, 4.3 MB | KGK sınav çalışma paneli (8 panel gömülü) |

`battalpanel` **ayrı bir repo** — bu oturumun GitHub kapsamı dışındaydı
(`omeryillmaz01-byte/-mery-lmaz` ile sınırlı). `MUSAVIR_PRO_PANEL.html`,
`MusavirPro_DefterBeyanAPI.html`, `BATTAL_MUHASEBE_DB_PRO.html` yalnızca
kullanıcının diskinde, incelenemedi.

---

## 3. Depolama mimarisi (`BATTAL-BANKA-POS.html`)

| Fonksiyon | Satır |
|---|---|
| `IDB_ONLY` | 341 |
| `save` | 373 |
| `load` | 388 |
| `hydrate` | 396 |
| `stateYenile` | 413 |
| `yedekle` / `geriYukle` | 1415 / 1422 |

**IndexedDB birincil, localStorage yedek.** `battal_firma_plan` localStorage'a
**hiç** yazılmaz — tek başına 1–4 MB tutup 5 MB'lık kotayı yiyordu.

**Veri tarayıcıda, sunucuda değil.** Origin değişince (ör. `file://` →
`https://`) veri **görünmez**. Taşımadan önce mutlaka
💾 Yedek Al → 📥 Geri Yükle turu yapılmalı. Chromium'da tüm `file://` yolları
aynı depoyu paylaşır, yani klasör/dosya adı değişimi veriyi etkilemez.

---

## 4. Dört kusur sınıfı — herhangi bir panelde ÖNCE bunlara bak

1. **Kapanmamış `<script>`** — tarayıcı script'i **hiç** çalıştırmaz. Panel
   ölü görünür ama normal söz dizimi denetimi bunu yakalamaz. Ana paneli
   18 Tem 2026'dan beri öldüren buydu.
2. **Koda yapışmış yetim JSON** — büyük veri literalinin başı kesilip kuyruğu
   kodun ortasında kalmış olabilir (iki dosyada birden vardı).
3. **`try{localStorage.setItem(...)}catch(e){}`** — sessiz kota yutma; veri
   sessizce kaybolur.
4. **Kaçırılmamış Türkçe apostrof** — `alert('...ID'nin...')` tüm script
   bloğunu çökertir.

**Denetim yöntemi:** her `<script>` bloğunu, `</script>` yoksa **dosya sonuna
kadar** alıp `new vm.Script(kod)` ile derle. Kapanmamış blokları atlayan
denetim işe yaramaz.

**Bozulmayı bulma:** `git log --format=%H -- <dosya>` ile her sürümü çıkarıp
denetimden geçir, son sağlam commit'i bul. Bu yöntem kırılmanın gününü verdi
(`cf985d3a` kapanış etiketlerini sildi, `4acd83c` veri bloğunu parçaladı).

---

## 5. `.bat` script kalıpları (acıyla öğrenildi)

- **Gömülü PowerShell:** `#-PSBODY-` işaretçisi + `iex`. İşaretçi komut
  satırında **parçalı** yazılır (`'#'+'-PSBODY-'`) ki arama kendi satırıyla
  eşleşmesin; `LastIndexOf` kullan.
- **cmd bölümü saf ASCII**, dosya **CRLF** satır sonlu (cmd `^` devam
  karakterini LF-only dosyalarda doğru işlemiyor).
- PowerShell komutu içinde **çift tırnak yok**, **`%` yok** (batch genişletir).
  Uzun/karmaşık kod için tek satır yerine gömülü gövde kullan.
- Masaüstü **her zaman** `[Environment]::GetFolderPath('Desktop')` ile
  (OneDrive yönlendirmesi; `%USERPROFILE%\Desktop` yanlış yeri gösterir).
- Emoji kısayol adları kod noktasından üretilir:
  `[char]::ConvertFromUtf32(0x1F9FE)`.
- PowerShell here-string'inde `$` interpolasyon tetikler — üretilen JS'te
  `$` yardımcısını `q` gibi bir ada çevir.
- Mesajlarda `>` kullanma; `:etiket` içinde tırnak soyulunca yönlendirmeye
  döner. Log yazımı `>>"%LOG%" echo %~1` (yönlendirme önce).

---

## 6. İki tuzak

**`Get-ChildItem -Filter` emoji içeren klasör adlarında boş döner.**
`dir /b /s` aynı yolları sorunsuz listeler. Ad karşılaştırması kullan:
`Where-Object { $_.Name -eq '...' }`. Asıl çalışma klasörünün aylarca
bulunamamasının sebebi buydu.

**Python `str.replace` eşleşme bulamazsa sessizce hiçbir şey yapmaz.**
Bu oturumda iki kez bozuk script gönderilmesine yol açtı — biri yetim `catch`
bloğu bırakıp scripti tamamen öldürdü. **Her düzenlemeyi `assert` ile
doğrula**, dosyayı `newline=''` ile oku/yaz (satır sonlarını koru).

---

## 7. Ortam

Windows 11 · OneDrive'a yönlendirilmiş masaüstü (`C:\Users\omery\OneDrive\Desktop`)
· Chrome varsayılan tarayıcı · Python 3.14.3 kurulu.

Tarayıcı testi için: Chromium `/opt/pw-browsers/chromium-1194/chrome-linux/chrome`,
`npm install playwright --no-save` ile kur, iş bitince `rm -rf node_modules`.
Panelleri `file://` **ve** gerçek HTTP sunucusu üzerinden test et.

---

## 8. Hosting kararı (verildi)

**Paylaşımlı hosting yeterli, VPS gereksiz.** Ölçümler: ana panellerde
**0** `fetch`/`XHR` (saf statik), web'e gidecek boyut **8,8 MB**, `http://`
kaynak **0** (HTTPS'te karışık içerik sorunu yok).

VPS'in tek olası gerekçesi ileride `server.js` (Gmail API) sunucuda çalışsın
istenirse. Diğer otomasyonlar masaüstüne bağlı ve öyle kalmalı:
`banka_panel.py` (yerel Excel düzenler), `beyanname-otomatik-kaydetme`
(Chrome'u GİB oturumuyla sürer), `battal_db_eklenti` (Chrome eklentisi).

`WEB-PAKET.bat` yayın paketini hazırlıyor (`Masaüstü\WEB-YAYIN\` + `.htaccess`).

---

## 9. ⚠️ Gömülü müşteri verisi

`BATTAL-BANKA-POS.html` içinde **35 firmanın hesap planı gerçek banka hesap
numaralarıyla** (`102.01 GARANTİ VADESİZ TL HS. ( 288337 )`).
`BATTAL_MUHASEBE_DB_PRO.html` içinde **15 mükellefin adı, VKN'si, vergi
dairesi**.

**Kimlik doğrulaması olmadan yayına konamaz.** Alt alan adının tahmin
edilmesinin zor olması koruma değil. SMMM sır saklama yükümlülüğü + KVKK.

Sunucuya **asla** gitmeyecekler: `chrome_profil\` (oturum çerezleri),
`GEREKLI_PROGRAMLAR\`, `battal_db_eklenti\`, `banka_pos_panel\`,
`beyanname-otomatik-kaydetme\`, `MUSAVIR_PRO_ESKI\`, `_yedek_` dosyaları ve
`.bat/.py/.exe/.zip/.log` uzantıları.

---

## 10. Açık işler

- `PANEL-TEMIZLIK.bat` ve `WEB-PAKET.bat` gönderildi, çalıştırıldığına dair
  geri bildirim **yok**
- `banka_panel.py` çıkış kodu 0 ile sessizce sonlanıyor — çözülmedi
- Alan adı henüz alınmadı
- `battalpanel` reposu incelenemedi; gerekirse o repoyu kapsayan yeni oturum
  açılmalı

---

## 11. Bu oturumda üretilenler

Onarılan paneller: `BATTAL-BANKA-POS.html`, `BATTAL-BANKA-POS-STANDALONE.html`,
`BATTAL-FINAL-PRO.html` (veri saklama eklendi), `BATTAL-BANKA-POS-V5-FULL.html`,
`BATTAL-BANKA-POS-V6-CONNECTED.html`.

Başlıca scriptler: `GENEL-PANEL.bat` (tek dosya hub üretici),
`WEB-PAKET.bat`, `PANEL-TEMIZLIK.bat`, `PANELLER-DOKUM.bat`,
`BATTAL-DERIN-ARAMA.bat`, `ZIP-KURTARMA.bat`, `KURTARMA-PANELLER-2.bat`,
`RAPORU-PANOYA-KOPYALA.bat`, `BANKA-PANEL-TESHIS.bat`.

Dal: `claude/project-development-continue-dtncgc`
