# 🎯 Muhasebe TR - Tüm Sistem Dokümantasyonu

## 📋 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Özellikler](#özellikler)
3. [Kurulum](#kurulum)
4. [Dosya Yapısı](#dosya-yapısı)
5. [Modüller](#modüller)
6. [Kullanım](#kullanım)
7. [API Referansı](#api-referansı)
8. [Veri Formatları](#veri-formatları)
9. [Cronjob Entegrasyonu](#cronjob-entegrasyonu)
10. [Sorun Giderme](#sorun-giderme)

---

## Genel Bakış

Muhasebe TR, Türkiye'deki muhasebe profesyonelleri için tasarlanmış kapsamlı bir sistem. Günlük muhasebe makalelerini otomatik olarak çeker, kategorize eder, web panellerine dönüştürür ve birden fazla formatta (HTML, PDF, Excel, RSS) sunar. Ayrıca AI-powered bir soru-cevap modülü ile kullanıcıların muhasebe sorularına akıllı cevaplar almasını sağlar.

---

## Özellikler

### ✅ Çekirdek Özellikler

- **📰 Otomatik Makale Çekme**: Muhasebetr.com'dan günlük makaleleri otomatik çeker
- **🏷️ Otomatik Kategorize**: Makaleleri Vergi, Amortisman, Ücret, Sosyal vs. kategorilere ayırır
- **🎨 Web Panelleri**: Güzel HTML dashboard'lar oluşturur
- **📡 Feed Desteği**: RSS ve Atom feed formatlarında çıktı verir
- **📊 Excel Export**: Tüm verileri Excel formatına aktarır
- **📧 E-Posta Bildirimleri**: Abone kullanıcılara günlük özet gönderir
- **🔍 Arama ve Filtreleme**: Makalelerda gelişmiş arama ve filtreleme
- **📄 PDF Raporlar**: Günlük, haftalık, aylık ve tam raporlar
- **❓ AI Soru-Cevap**: Kullanıcıların muhasebe sorularına akıllı cevaplar
- **💾 Otomatik Veri Kaydı**: JSON formatında veri saklama
- **⏰ Cronjob Desteği**: Otomatik günlük çalışma planlama

---

## Kurulum

### 1. Gerekli Kütüphaneler

```bash
pip install beautifulsoup4 requests openpyxl
```

### 2. Dosya Yüklemesi

Tüm Python dosyalarının `/home/user/-mery-lmaz/` dizininde olduğundan emin olun:

```
muhasebe_system.py              (Ana sistem)
muhasebe_scraper.py             (Web scraper)
muhasebe_scraper_local.py       (Test versiyonu)
muhasebe_qa_module.py           (Soru-Cevap)
muhasebe_email_notifier.py      (E-Posta bildirimi)
muhasebe_rss_feed.py            (RSS/Atom feed)
muhasebe_excel_export.py        (Excel export)
muhasebe_search_filter.py       (Arama/Filtreleme)
muhasebe_pdf_report.py          (PDF raporlar)
setup_muhasebe_cron.sh          (Cronjob kurulum)
```

### 3. Veri Dizini Oluşturma

```bash
mkdir -p muhasebe_data
```

---

## Dosya Yapısı

```
/home/user/-mery-lmaz/
│
├── muhasebe_system.py                    # Ana entegrasyon sistemi
├── muhasebe_scraper.py                   # Muhasebetr.com scraper
├── muhasebe_scraper_local.py             # Test versiyonu (mock data)
├── muhasebe_qa_module.py                 # AI Soru-Cevap modülü
├── muhasebe_email_notifier.py            # E-Posta bildirimleri
├── muhasebe_rss_feed.py                  # RSS/Atom feed üreticisi
├── muhasebe_excel_export.py              # Excel export
├── muhasebe_search_filter.py             # Arama ve filtreleme
├── muhasebe_pdf_report.py                # PDF rapor üreticisi
├── setup_muhasebe_cron.sh                # Cronjob kurulum
│
└── muhasebe_data/                        # Veri dizini
    ├── panel.html                        # Ana HTML panel
    ├── qa_panel.html                     # Soru-Cevap paneli
    ├── feed.rss                          # RSS feed
    ├── feed.atom                         # Atom feed
    ├── muhasebe_makaleler.xlsx           # Makaleler (Excel)
    ├── muhasebe_sorular.xlsx             # Soru-Cevaplar (Excel)
    ├── muhasebe_rapor_*.html             # Raporlar (HTML)
    ├── articles_*.json                   # Günlük makaleler (JSON)
    ├── qa_database.json                  # Soru-Cevap veritabanı (JSON)
    ├── subscribers.json                  # E-Posta aboneleri (JSON)
    └── email_*.html                      # Gönderilen e-postalar (HTML)
```

---

## Modüller

### 1. **muhasebe_scraper.py** - Web Scraper (Üretim)
```python
from muhasebe_scraper import MuhasebetrScraper

scraper = MuhasebetrScraper()
articles = scraper.fetch_articles()  # muhasebetr.com'dan çeker
processed = scraper.process_articles(articles)  # Kategorize eder
scraper.generate_panel_html(processed)  # Panel oluşturur
```

### 2. **muhasebe_scraper_local.py** - Test Scraper
```python
from muhasebe_scraper_local import MuhasebetrScraper

scraper = MuhasebetrScraper()
articles = scraper.get_mock_articles()  # Mock data döndürür
processed = scraper.process_articles(articles)
scraper.generate_panel_html(processed)
```

### 3. **muhasebe_qa_module.py** - AI Soru-Cevap
```python
from muhasebe_qa_module import MuhasebeQA

qa = MuhasebeQA()
result = qa.ask("Asgari ücret ne kadar?", "user@example.com")
# Sonuç: question, answer, timestamp, user_email, id

# Arama
results = qa.search_questions("ücret")
```

### 4. **muhasebe_email_notifier.py** - E-Posta Bildirimleri
```python
from muhasebe_email_notifier import EmailNotifier

notifier = EmailNotifier()
notifier.add_subscriber("user@example.com")
notifier.send_daily_digest(articles)  # Tüm abonelere gönder
```

### 5. **muhasebe_rss_feed.py** - RSS/Atom Feed
```python
from muhasebe_rss_feed import RSSFeedGenerator, AtomFeedGenerator

rss = RSSFeedGenerator()
rss.generate_and_save(articles)  # feed.rss oluşturur

atom = AtomFeedGenerator()
atom.generate_and_save(articles)  # feed.atom oluşturur
```

### 6. **muhasebe_excel_export.py** - Excel Export
```python
from muhasebe_excel_export import ExcelExporter

exporter = ExcelExporter()
exporter.export_articles_to_excel(articles)  # muhasebe_makaleler.xlsx
exporter.export_qa_to_excel(qa_data)  # muhasebe_sorular.xlsx
```

### 7. **muhasebe_search_filter.py** - Arama ve Filtreleme
```python
from muhasebe_search_filter import SearchEngine

engine = SearchEngine()

# Basit arama
results = engine.search_articles(articles, "ücret")

# Kategori filtresi
results = engine.filter_articles_by_category(articles, "Vergi")

# Tarih aralığı filtresi
results = engine.filter_articles_by_date(articles, "15.08.2026", "18.08.2026")

# İstatistikler
stats = engine.get_statistics(articles)
```

### 8. **muhasebe_pdf_report.py** - PDF Raporlar
```python
from muhasebe_pdf_report import PDFReportGenerator

pdf = PDFReportGenerator()
pdf.generate_daily_report(articles)  # Günlük rapor
pdf.generate_weekly_report(articles)  # Haftalık rapor
pdf.generate_monthly_report(articles)  # Aylık rapor
```

### 9. **muhasebe_system.py** - Ana Entegrasyon
```python
from muhasebe_system import MuhasebeSystem

system = MuhasebeSystem()
system.run_daily_pipeline()  # Tüm işlemleri çalıştır
system.get_system_stats(articles)  # İstatistikleri göster
system.search_articles("ücret")  # Ara
```

---

## Kullanım

### Hızlı Başlangıç

```bash
# Ana menüyü başlat
python3 muhasebe_system.py

# Veya otomatik günlük pipeline
python3 muhasebe_scraper_local.py
```

### Günlük Pipeline Çalıştırma

```bash
python3 -c "
from muhasebe_system import MuhasebeSystem
system = MuhasebeSystem()
system.run_daily_pipeline()
"
```

### Soru Soruşturma

```bash
python3 -c "
from muhasebe_qa_module import MuhasebeQA
qa = MuhasebeQA()
result = qa.ask('Asgari ücret ne kadar?', 'user@example.com')
print(result['answer'])
"
```

### E-Posta Bildirimi Gönderme

```bash
python3 -c "
from muhasebe_system import MuhasebeSystem
system = MuhasebeSystem()

# Abone ekle
system.notifier.add_subscriber('user@example.com')

# Bildirim gönder
articles = system.scraper.get_mock_articles()
system.notifier.send_daily_digest(articles)
"
```

### Excel'e Aktarma

```bash
python3 -c "
from muhasebe_system import MuhasebeSystem
system = MuhasebeSystem()
articles = system.scraper.get_mock_articles()
system.excel.export_articles_to_excel(articles)
"
```

### Arama Yapma

```bash
python3 -c "
from muhasebe_system import MuhasebeSystem
system = MuhasebeSystem()
results = system.search_articles('vergi', 'Vergi')
"
```

---

## API Referansı

### MuhasebeQA

```python
qa = MuhasebeQA()

# Soru sor
qa_entry = qa.ask(question, user_email=None)

# Tüm soruları getir
all_questions = qa.get_all_questions()

# Soruları ara
search_results = qa.search_questions(keyword)

# Anahtar kelimeleri bul
topics = qa.find_relevant_keywords(question)

# Cevap oluştur
answer = qa.generate_answer(question)
```

### EmailNotifier

```python
notifier = EmailNotifier()

# Abone ekle/kaldır
notifier.add_subscriber(email)
notifier.remove_subscriber(email)

# Abone listesi
subscribers = notifier.get_subscribers()

# Bildirimleri gönder
notifier.send_daily_digest(articles, use_mock=True)
```

### SearchEngine

```python
engine = SearchEngine()

# Basit arama
results = engine.search_articles(articles, keyword, category=None)

# Filtreleme
by_category = engine.filter_articles_by_category(articles, category)
by_date = engine.filter_articles_by_date(articles, start_date, end_date)
by_source = engine.filter_articles_by_source(articles, source)

# Sıralama
sorted_articles = engine.sort_articles(articles, sort_by="date", reverse=True)

# İstatistikler
stats = engine.get_statistics(articles)
categories = engine.get_unique_categories(articles)
sources = engine.get_unique_sources(articles)
date_range = engine.get_date_range(articles)
```

---

## Veri Formatları

### Makale Formatı (JSON)

```json
{
  "title": "Asgari Ücret Güncellemesi 2026",
  "description": "Yeni asgari ücret oranları açıklandı",
  "date": "18.08.2026",
  "url": "https://www.muhasebetr.com/asgari-ucret/",
  "source": "muhasebetr.com",
  "category": "Asgari Ücret",
  "processed_date": "2026-08-18T10:30:45.123456",
  "id": "asgari-ucret-2026"
}
```

### Soru-Cevap Formatı (JSON)

```json
{
  "questions": [
    {
      "id": 1,
      "question": "Asgari ücret ne kadar?",
      "answer": "📌 Bulduğum Konu: Asgari Ücret\n\n**ASGARI ÜCRET Hakkında:**\n...",
      "timestamp": "2026-08-18T10:30:45.123456",
      "user_email": "user@example.com"
    }
  ]
}
```

### Abone Formatı (JSON)

```json
{
  "emails": [
    "user1@example.com",
    "user2@example.com"
  ]
}
```

---

## Cronjob Entegrasyonu

### Kurulum

```bash
chmod +x setup_muhasebe_cron.sh
./setup_muhasebe_cron.sh
```

### Manuel Kurulum

```bash
# Her gün saat 08:00'de çalışacak şekilde ekle
crontab -e

# Şu satırı ekle:
0 8 * * * cd /home/user/-mery-lmaz && /usr/bin/python3 muhasebe_scraper_local.py >> muhasebe_cron.log 2>&1
```

### Cronjob Kontrolü

```bash
# Mevcut cronjob'ları listele
crontab -l

# Log dosyasını izle
tail -f muhasebe_cron.log
```

### Cron Syntax Örnekleri

```
0 8 * * *        ← Her gün saat 08:00
0 9 * * 1-5      ← Hafta içi saat 09:00
0 */4 * * *      ← Her 4 saatte bir
0 6,14,22 * * *  ← Günde 3 kez (06:00, 14:00, 22:00)
0 0 * * 0        ← Her Pazar saat 00:00
```

---

## Kategoriler

Sistem makaleleri otomatik olarak şu kategorilere ayırır:

| Kategori | Anahtar Kelimeler | Örnek |
|----------|------------------|--------|
| **Vergi** | vergi, kdv, gelir vergisi, kurumlar vergisi | KDV Oranlarında Değişiklikler |
| **Amortisman** | amortisman, değer kaybı, amorti | Demirbaş Amortisman Sınırları |
| **Asgari Ücret** | asgari ücret, ücret, bordro | 2026 Asgari Ücret Güncellemesi |
| **Sosyal** | sigorta, ssk, bağ-kur | SSK Sigorta Primleri |
| **Gümrük** | gümrük, dış ticaret, ihracat | İhracat Gümrük Vergileri |
| **Muhasebe** | muhasebe, defter, rapor | Muhasebe Kayıtları |
| **Diğer** | Uyumsuz tüm içerik | Diğer Konular |

---

## Sorun Giderme

### Makale Çekme Hatası

**Problem**: "❌ Yazı bulunamadı"

**Çözüm**:
```bash
# Test versiyonunu kullan (mock data ile)
python3 muhasebe_scraper_local.py

# Proxy ayarlarını kontrol et
curl -I https://www.muhasebetr.com
```

### Cronjob Çalışmıyor

**Problem**: Cronjob çalışmıyor, log dosyası boş

**Çözüm**:
```bash
# Daemon'u yeniden başlat
sudo service cron restart

# Cronjob'u kontrol et
crontab -l

# Manuel test çalıştır
python3 /home/user/-mery-lmaz/muhasebe_scraper_local.py
```

### E-Posta Gönderme Hatası

**Problem**: "❌ E-posta gönderme hatası"

**Çözüm**:
- Şu anda mock mod kullanılıyor (dosyaya kaydediliyor)
- Gerçek e-posta göndermek için `muhasebe_email_notifier.py` dosyasında SMTP ayarlarını yaplandırın

### Panel Görüntülenmiyor

**Problem**: HTML dosyası açılmıyor

**Çözüm**:
```bash
# Dosya mevcut mu kontrol et
ls -la muhasebe_data/panel.html

# Dosya boyutu kontrol et
du -h muhasebe_data/panel.html

# Tarayıcı cache'ini temizle
# Chrome: Ctrl+Shift+Delete
```

### Excel Hatası

**Problem**: "❌ Excel export hatası"

**Çözüm**:
```bash
# openpyxl kütüphanesini yükle
pip install openpyxl

# Excel dosyasını kontrol et
python3 -c "from openpyxl import load_workbook; load_workbook('muhasebe_data/muhasebe_makaleler.xlsx')"
```

---

## 📞 İletişim & Destek

Sorunlar için:
1. Log dosyasını kontrol edin: `/home/user/-mery-lmaz/muhasebe_cron.log`
2. Kodun ilgili kısmına bakın
3. Kodu ihtiyaçlarınız doğrultusunda özelleştirin

---

## 📄 Lisans

Açık kaynak - Geliştirmeler için PR'lar kabul ediliyor.

---

## Versiyon Tarihi

- **v1.0** - 18.08.2026
  - ✅ Temel scraper sistemi
  - ✅ AI Soru-Cevap modülü
  - ✅ E-Posta bildirimleri
  - ✅ RSS/Atom feed
  - ✅ Excel export
  - ✅ Arama ve filtreleme
  - ✅ PDF raporları
  - ✅ Cronjob entegrasyonu

---

**Son Güncelleme:** 18.08.2026 08:09

Tüm dosyalar `/home/user/-mery-lmaz/muhasebe_data/` dizininde saklanır.
