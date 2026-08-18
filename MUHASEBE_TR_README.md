# Muhasebe TR - Günlük Otomatik Panel Sistemi

## 📋 Genel Bakış

Muhasebetr.com'dan günlük muhasebe yazılarını otomatik olarak çeken, kategorize eden ve web paneline dönüştüren sistem.

**Özellikler:**
- ✅ Günlük otomatik veri çekme
- ✅ Kategoriye göre otomatik sınıflandırma (Vergi, Amortisman, Ücret, vb.)
- ✅ Güzel HTML dashboard
- ✅ JSON veri depolama
- ✅ Cronjob entegrasyonu

---

## 🚀 Kurulum

### 1. Gerekli Kütüphaneler
```bash
pip install beautifulsoup4 requests
```

### 2. Cronjob Setup (Opsiyonel)
```bash
chmod +x setup_muhasebe_cron.sh
./setup_muhasebe_cron.sh
```

---

## 📁 Dosya Yapısı

```
/home/user/-mery-lmaz/
├── muhasebe_scraper.py              # Ana scraper (gerçek versiyon - muhasebetr.com'dan)
├── muhasebe_scraper_local.py        # Test versiyonu (mock data ile)
├── setup_muhasebe_cron.sh           # Cronjob kurulum scripti
├── muhasebe_data/
│   ├── panel.html                   # Üretilen HTML panel
│   ├── articles_2026-08-18.json     # Günlük makaleler (JSON)
│   └── ...
└── MUHASEBE_TR_README.md
```

---

## 💾 Veri Formatı

### JSON Makaleleri Formatı
```json
[
  {
    "title": "Köprü Kredilerin Finansman Gider Kısıtlaması",
    "description": "Birebir Aktarılan Köprü Kredilerin Finansman...",
    "date": "18.08.2026",
    "url": "https://www.muhasebetr.com/...",
    "source": "muhasebetr.com",
    "category": "Vergi",
    "processed_date": "2026-08-18T10:30:45.123456",
    "id": "kopru-krediler"
  }
]
```

---

## 🏃 Kullanım

### Manuel Çalıştırma (Test)
```bash
python3 muhasebe_scraper_local.py
```

### Gerçek Ortamda (Üretim)
```bash
python3 muhasebe_scraper.py
```

### Cronjob Kurulumu (Her gün 08:00)
```bash
./setup_muhasebe_cron.sh
```

---

## 📊 Kategoriler

Sistem makaleleri otomatik olarak şu kategorilere sınıflandırır:

1. **Vergi** - KDV, Gelir Vergisi, Kurumlar Vergisi
2. **Amortisman** - Demirbaş, Amortisman Oranları
3. **Asgari Ücret** - Ücret, Bordro, Ücret Güncellemeleri
4. **Sosyal** - Sigorta, SSK, Bağ-Kur
5. **Gümrük** - Dış Ticaret, İhracat, İthacat
6. **Muhasebe** - Muhasebe Kayıtları, Defter Tutma
7. **Diğer** - Diğer Konular

---

## 🔧 Özelleştirme

### Kategorileri Değiştirmek
`muhasebe_scraper_local.py` içinde `categories` dict'ini düzenle:

```python
self.categories = {
    "Vergi": ["vergi", "kdv", "gelir vergisi", ...],
    "Yeni Kategori": ["anahtar1", "anahtar2", ...],
}
```

### Cronjob Saatini Değiştirmek
`setup_muhasebe_cron.sh` içinde:

```bash
# Örnek: Her gün saat 10:00'da
CRON_JOB="0 10 * * * cd $PROJECT_DIR && /usr/bin/python3 $SCRIPT"
```

---

## 📊 Cronjob Zamanları (Cron Syntax)

```
┌───────────── dakika (0 - 59)
│ ┌───────────── saat (0 - 23)
│ │ ┌───────────── gün (1 - 31)
│ │ │ ┌───────────── ay (1 - 12)
│ │ │ │ ┌───────────── hafta günü (0 - 7, 0 ve 7 Pazar)
│ │ │ │ │
│ │ │ │ │
0 8 * * * ← Her gün saat 08:00'da
```

**Örnek Zamanlamalar:**
- `0 8 * * *` - Her gün 08:00
- `0 9 * * 1-5` - Hafta içi 09:00 (Pazartesi-Cuma)
- `0 */4 * * *` - Her 4 saatte bir (00:00, 04:00, 08:00, ...)
- `0 6,14,22 * * *` - Günde 3 kez (06:00, 14:00, 22:00)

---

## 📝 Log Dosyası

Cronjob çıktıları şurada kaydedilir:
```
/home/user/-mery-lmaz/muhasebe_cron.log
```

Log dosyasını görmek için:
```bash
tail -f muhasebe_cron.log
```

---

## 🌐 Panel Özellikleri

HTML panelde aşağıdakiler gösterilir:

- 📊 İstatistikler (Toplam yazı, kategori sayıları)
- 📑 Kategoriye göre sınıflandırılmış makaleler
- 🔗 Orijinal makale linklerine doğrudan erişim
- 📅 Yayın tarihleri
- ⏰ Son güncelleme zamanı

---

## 🔄 Veri Akışı

```
┌─────────────────┐
│ muhasebetr.com  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│ Scraper (Yazıları Çek)      │
│ (muhasebe_scraper.py)       │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ Kategorize Et               │
│ (Vergi, Ücret, vb.)         │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ JSON'a Kaydet               │
│ (articles_2026-08-18.json)  │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ HTML Panel Oluştur          │
│ (panel.html)                │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ 🎨 Görüntülemeye Hazır!     │
└─────────────────────────────┘
```

---

## 🚨 Sorun Giderme

### Cronjob çalışmıyor
```bash
# Cronjob'u kontrol et
crontab -l

# Daemon'u yeniden başlat
sudo service cron restart
```

### Yazılar çekmiyor
- İnternet bağlantısını kontrol et
- Proxy ayarlarını kontrol et
- muhasebetr.com'un erişilebilir olduğunu kontrol et

### Panel görüntülenmiyor
- HTML dosyasının mevcut olduğunu kontrol et: `ls muhasebe_data/panel.html`
- Tarayıcı cache'ini temizle

---

## 📞 İletişim & Destek

Sorunlar için github issues'a ekleyebilir ya da kodu kendi ihtiyaçlarına göre özelleştirebilirsin.

---

## 📄 Lisans

Açık kaynak - Geliştirmeler için PR'lar kabul ediliyor.

**Son Güncelleme:** 18.08.2026
