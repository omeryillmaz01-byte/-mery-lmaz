# Ubuntu production kurulumu — panel.<alanadi>

Sıra önemli. Her adımın çıktısını sohbete yapıştırın.

## 0. Ön koşul — DNS
`panel.<alanadi>` için **A kaydı** sunucunun IP'sine yönlendirilmiş olmalı.
Yayılması 5 dk – 2 saat sürebilir. Kontrol: `nslookup panel.<alanadi>`

## 1. Sunucu sertleştirme
Sunucuya (şimdilik root ile) girip:
```
sudo bash 01-sunucu-sertlestir.sh
```
Yapar: paket güncelleme, `panel` kullanıcısı (sudo'lu), ufw (22/80/443),
`unattended-upgrades`, `fail2ban`.

## 2. SSH kilitleme — dikkat
**Önce** başka bir terminalden `ssh panel@<ip>` ile anahtarla girebildiğinizi
doğrulayın. Giremiyorsanız kendi makinenizden:
```
ssh-keygen -t ed25519        (anahtarınız yoksa)
ssh-copy-id panel@<ip>
```
Doğruladıktan **sonra**:
```
sudo bash 02-ssh-kilitle.sh
```
Parola girişi ve root girişi kapanır.

## 3. nginx + TLS + parola koruması
```
sudo ALAN=panel.<alanadi> EPOSTA=omer.yillmaz01@gmail.com bash 03-nginx-tls-auth.sh
```
Panel giriş parolasını sorar (kullanıcı adı `omer`). Let's Encrypt sertifikası
alır, HTTP→HTTPS yönlendirmesi ve güvenlik başlıklarını kurar.

**Basic Auth pazarlık konusu değil** — paneller 35 firmanın banka hesap
numaralarını içeriyor (SMMM sır saklama + KVKK).

## 4. Panelleri yükleme
Windows'ta sırayla:
1. `WEB-PAKET.bat` — `Masaüstü\WEB-YAYIN\` paketini hazırlar
   (`.bat/.py/.exe/.zip`, `chrome_profil\`, eklentiler hariç).
2. `PANELLERI-SUNUCUYA-YUKLE.bat` — içindeki `$SUNUCU` ve `PANEL_ALAN`
   satırlarını doldurup çalıştırın. scp ile `~/gelen/` altına atar,
   sonra sunucuda `04-yayinla.sh` çağırır.

Sunucu tarafında elle yayınlamak isterseniz:
```
ALAN=panel.<alanadi> bash ~/deploy/04-yayinla.sh
```

## 5. Veri taşıma — atlanırsa veri kaybolur
Paneller veriyi **tarayıcıda** (IndexedDB) tutuyor. Origin `file://` → `https://`
değiştiği için sunucudaki panel **boş** açılır. Geçiş:
1. Yerel `file://` panelde **💾 Yedek Al** → dosyayı indirin
2. `https://panel.<alanadi>` panelinde **📥 Geri Yükle** → o dosyayı seçin

## 6. Sonraki çatal — karar gerekiyor
Veri tarayıcıda kalırsa: her cihaz kendi verisini tutar, ofis ve ev
**senkronlanmaz**. Cihazlar arası gerçek senkron isteniyorsa backend +
veritabanı gerekir ve panellerin veri katmanı yeniden yazılmalı. Bu, projenin
boyutunu belirleyen ana çatal (CLAUDE.md §8).
