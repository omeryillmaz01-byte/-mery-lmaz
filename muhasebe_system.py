#!/usr/bin/env python3
"""
Muhasebe TR - Tüm Sistem Entegrasyonu
Tüm modülleri koordine ederek çalıştırır
"""

import json
from pathlib import Path
from datetime import datetime

# Modülleri import et
from muhasebe_scraper_local import MuhasebetrScraper
from muhasebe_qa_module import MuhasebeQA, QAPanel
from muhasebe_email_notifier import EmailNotifier
from muhasebe_rss_feed import RSSFeedGenerator, AtomFeedGenerator
from muhasebe_excel_export import ExcelExporter
from muhasebe_search_filter import SearchEngine, AdvancedSearch
from muhasebe_pdf_report import PDFReportGenerator


class MuhasebeSystem:
    """Muhasebe TR Tüm Sistem Yöneticisi"""

    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)

        # Modülleri başlat
        self.scraper = MuhasebetrScraper()
        self.qa = MuhasebeQA()
        self.notifier = EmailNotifier()
        self.rss = RSSFeedGenerator()
        self.atom = AtomFeedGenerator()
        self.excel = ExcelExporter()
        self.search = SearchEngine()
        self.advanced_search = AdvancedSearch(self.search)
        self.pdf = PDFReportGenerator()

    def run_daily_pipeline(self):
        """Günlük işlemleri çalıştır"""
        print("\n" + "="*70)
        print("MUHASEBE TR - GÜNLÜK PIPELINE")
        print("="*70 + "\n")

        # 1. Makaleleri çek
        print("📰 Adım 1: Makaleler çekiliyor...")
        articles = self.scraper.get_mock_articles()
        print(f"✅ {len(articles)} makale yüklendi\n")

        # 2. İşle ve kategorize et
        print("🏷️  Adım 2: Makaleler kategorize ediliyor...")
        processed = self.scraper.process_articles(articles)
        print(f"✅ Makaleler kategorize edildi\n")

        # 3. HTML panel oluştur
        print("🎨 Adım 3: HTML panel oluşturuluyor...")
        self.scraper.generate_panel_html(processed)
        print("✅ HTML panel oluşturuldu\n")

        # 4. RSS/Atom feed oluştur
        print("📡 Adım 4: RSS/Atom feed oluşturuluyor...")
        self.rss.generate_and_save(processed)
        self.atom.generate_and_save(processed)
        print("✅ RSS/Atom feed oluşturuldu\n")

        # 5. Excel'e aktar
        print("📊 Adım 5: Excel dosyaları oluşturuluyor...")
        self.excel.export_articles_to_excel(processed)
        print("✅ Excel dosyaları oluşturuldu\n")

        # 6. Raporları oluştur
        print("📄 Adım 6: PDF raporları oluşturuluyor...")
        self.pdf.generate_daily_report(processed)
        self.pdf.generate_weekly_report(processed)
        self.pdf.generate_monthly_report(processed)
        print("✅ PDF raporları oluşturuldu\n")

        # 7. E-postaları gönder (mock)
        print("📧 Adım 7: E-postalar gönderiliyor...")
        self.notifier.send_daily_digest(processed, use_mock=True)
        print("✅ E-postalar gönderildi\n")

        print("="*70)
        print("✅ GÜNLÜK PIPELINE TAMAMLANDI")
        print("="*70 + "\n")

        return processed

    def search_articles(self, keyword, category=None):
        """Makalelerda arama yap"""
        print(f"\n🔍 '{keyword}' aranıyor", end="")
        if category:
            print(f" (Kategori: {category})", end="")
        print("...\n")

        articles = self.scraper.get_mock_articles()
        results = self.search.search_articles(articles, keyword, category)

        print(f"✅ {len(results)} sonuç bulundu:\n")
        for r in results:
            print(f"  - {r['title']}")
            print(f"    {r['description'][:60]}...")
            print(f"    Kategori: {r['category']} | Tarih: {r['date']}\n")

        return results

    def get_system_stats(self, articles):
        """Sistem istatistiklerini göster"""
        print("\n" + "="*70)
        print("📊 SİSTEM İSTATİSTİKLERİ")
        print("="*70 + "\n")

        stats = self.search.get_statistics(articles)

        print(f"📰 Toplam Makale: {stats['total_articles']}")
        print(f"\n📁 Kategorilere Göre:")
        for cat, count in sorted(stats['by_category'].items()):
            print(f"   • {cat}: {count} makale")

        print(f"\n📡 Kaynaklara Göre:")
        for src, count in sorted(stats['by_source'].items()):
            print(f"   • {src}: {count} makale")

        if stats['date_range']['start']:
            print(f"\n📅 Tarih Aralığı: {stats['date_range']['start']} - {stats['date_range']['end']}")

        # S&C istatistikleri
        qa_count = len(self.qa.get_all_questions())
        print(f"\n❓ Toplam Soru-Cevap: {qa_count}")

        # E-posta abone sayısı
        subscribers = len(self.notifier.get_subscribers())
        print(f"📧 E-posta Aboneleri: {subscribers}")

        print("\n" + "="*70 + "\n")

    def generate_system_report(self, articles):
        """Sistem özet raporunu oluştur"""
        print("\n" + "="*70)
        print("📈 SİSTEM ÖZET RAPORU")
        print("="*70 + "\n")

        stats = self.search.get_statistics(articles)
        qa_count = len(self.qa.get_all_questions())
        subscribers = len(self.notifier.get_subscribers())

        report = f"""
╔════════════════════════════════════════════════════════════════════╗
║                  MUHASEBE TR - SİSTEM RAPORU                       ║
║                    {datetime.now().strftime("%d.%m.%Y %H:%M:%S")}                         ║
╚════════════════════════════════════════════════════════════════════╝

📊 MAKALE İSTATİSTİKLERİ
────────────────────────────────────────────────────────────────────
  • Toplam Makale: {stats['total_articles']}

  Kategorilere Göre:
"""
        for cat, count in sorted(stats['by_category'].items()):
            report += f"    ✓ {cat}: {count}\n"

        report += f"""
❓ SORU-CEVAP SİSTEMİ
────────────────────────────────────────────────────────────────────
  • Toplam Soru: {qa_count}
  • Veritabanı: /muhasebe_data/qa_database.json

📧 E-POSTA BİLDİRİM
────────────────────────────────────────────────────────────────────
  • Toplam Abone: {subscribers}
  • Abone Listesi: /muhasebe_data/subscribers.json

📁 OLUŞTURULAN DOSYALAR
────────────────────────────────────────────────────────────────────
  ✓ panel.html - Ana HTML Panel
  ✓ qa_panel.html - Soru-Cevap Paneli
  ✓ feed.rss - RSS Feed
  ✓ feed.atom - Atom Feed
  ✓ muhasebe_makaleler.xlsx - Makaleler (Excel)
  ✓ muhasebe_sorular.xlsx - Soru-Cevaplar (Excel)
  ✓ muhasebe_rapor_*.html - PDF Raporları (HTML)

🔗 FEED URL'LERİ
────────────────────────────────────────────────────────────────────
  RSS: file:///home/user/-mery-lmaz/muhasebe_data/feed.rss
  Atom: file:///home/user/-mery-lmaz/muhasebe_data/feed.atom

════════════════════════════════════════════════════════════════════
  Son Güncelleme: {datetime.now().strftime("%d.%m.%Y %H:%M:%S")}
════════════════════════════════════════════════════════════════════
"""

        print(report)
        return report

    def list_generated_files(self):
        """Oluşturulan dosyaları listele"""
        print("\n" + "="*70)
        print("📁 OLUŞTURULAN DOSYALAR")
        print("="*70 + "\n")

        files = list(self.data_dir.glob("*"))
        files.sort(key=lambda x: x.stat().st_mtime, reverse=True)

        for file in files:
            size = file.stat().st_size
            if size > 1024 * 1024:
                size_str = f"{size / (1024*1024):.2f} MB"
            elif size > 1024:
                size_str = f"{size / 1024:.2f} KB"
            else:
                size_str = f"{size} B"

            mtime = datetime.fromtimestamp(file.stat().st_mtime)
            mtime_str = mtime.strftime("%d.%m.%Y %H:%M")

            print(f"📄 {file.name:<40} {size_str:>12} {mtime_str}")

        print("\n" + "="*70 + "\n")


def main():
    """Ana menü"""
    print("\n" + "="*70)
    print("MUHASEBE TR - ANA MENÜ")
    print("="*70)
    print("\n1. 📅 Günlük Pipeline Çalıştır")
    print("2. 🔍 Makalelerda Ara")
    print("3. 📊 İstatistikleri Göster")
    print("4. 📈 Sistem Raporunu Oluştur")
    print("5. 📁 Dosyaları Listele")
    print("6. 🎯 Soru Sor")
    print("7. 📧 Abone Ekle/Kaldır")
    print("8. ❌ Çık\n")

    system = MuhasebeSystem()

    while True:
        choice = input("Seçiminiz (1-8): ").strip()

        if choice == "1":
            articles = system.run_daily_pipeline()
            system.get_system_stats(articles)

        elif choice == "2":
            keyword = input("Arama terimi: ").strip()
            category = input("Kategori (opsiyonel): ").strip() or None
            system.search_articles(keyword, category)

        elif choice == "3":
            articles = system.scraper.get_mock_articles()
            system.get_system_stats(articles)

        elif choice == "4":
            articles = system.scraper.get_mock_articles()
            system.generate_system_report(articles)

        elif choice == "5":
            system.list_generated_files()

        elif choice == "6":
            question = input("\nSorunuz: ").strip()
            email = input("E-mail (opsiyonel): ").strip() or None
            if question:
                result = system.qa.ask(question, email)
                print(f"\n✅ Soru kaydedildi!")
                print(f"ID: {result['id']}")
                print(f"Cevap:\n{result['answer']}\n")

        elif choice == "7":
            print("\n1. Abone Ekle")
            print("2. Abone Listesi")
            print("3. Abone Kaldır\n")
            sub_choice = input("Seçiminiz (1-3): ").strip()

            if sub_choice == "1":
                email = input("E-mail: ").strip()
                if system.notifier.add_subscriber(email):
                    print("✅ Abone eklendi!")
                else:
                    print("⚠️  Abone zaten mevcut!")

            elif sub_choice == "2":
                subscribers = system.notifier.get_subscribers()
                print(f"\n📧 Toplam Abone: {len(subscribers)}\n")
                for sub in subscribers:
                    print(f"  • {sub}")

            elif sub_choice == "3":
                email = input("E-mail: ").strip()
                if system.notifier.remove_subscriber(email):
                    print("✅ Abone kaldırıldı!")
                else:
                    print("⚠️  Abone bulunamadı!")

        elif choice == "8":
            print("\n👋 Hoşça kalın!\n")
            break

        else:
            print("❌ Geçersiz seçim!\n")


if __name__ == "__main__":
    print("""
╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║              🎯 MUHASEBE TR - ENTEGRE PANEL SİSTEMİ 🎯            ║
║                                                                    ║
║   Günlük Muhasebe Makaleleri + AI Soru-Cevap + E-Posta + RSS      ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
""")

    main()
