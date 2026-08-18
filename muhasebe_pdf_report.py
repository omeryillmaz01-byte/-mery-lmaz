#!/usr/bin/env python3
"""
Muhasebe TR - PDF Rapor Modülü
Haftalık/aylık özet raporları PDF formatında oluşturur
"""

import json
from pathlib import Path
from datetime import datetime, timedelta


class PDFReportGenerator:
    """PDF rapor oluşturucu"""

    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)

    def generate_html_report(self, articles, report_type="weekly", title=""):
        """HTML formatında rapor oluştur (PDF dönüşümü için)"""

        # Makale istatistikleri
        total_articles = len(articles)
        by_category = {}
        for article in articles:
            cat = article.get('category', 'Diğer')
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(article)

        # HTML raporu oluştur
        html = f"""<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Muhasebe TR - {report_type.title()} Raporu</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: 'Arial', sans-serif;
            color: #333;
            line-height: 1.6;
            background-color: #f9f9f9;
        }}

        .page {{
            background-color: white;
            margin: 20px;
            padding: 40px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 900px;
            margin-left: auto;
            margin-right: auto;
        }}

        .header {{
            border-bottom: 3px solid #667eea;
            padding-bottom: 20px;
            margin-bottom: 30px;
            text-align: center;
        }}

        .header h1 {{
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
        }}

        .header p {{
            color: #666;
            font-size: 14px;
        }}

        .report-meta {{
            background-color: #f0f0f0;
            padding: 15px;
            border-left: 4px solid #667eea;
            margin-bottom: 30px;
            font-size: 13px;
        }}

        .report-meta strong {{
            color: #667eea;
        }}

        .section {{
            margin-bottom: 40px;
        }}

        .section-title {{
            font-size: 22px;
            font-weight: bold;
            color: #333;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }}

        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 30px;
        }}

        .stat-box {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }}

        .stat-number {{
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 5px;
        }}

        .stat-label {{
            font-size: 12px;
            opacity: 0.9;
        }}

        .category-section {{
            margin-bottom: 30px;
            page-break-inside: avoid;
        }}

        .category-title {{
            font-size: 16px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 15px;
            background-color: #f5f5f5;
            padding: 10px;
            border-radius: 4px;
        }}

        .article {{
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }}

        .article:last-child {{
            border-bottom: none;
        }}

        .article-title {{
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
            font-size: 14px;
        }}

        .article-desc {{
            color: #666;
            font-size: 13px;
            margin-bottom: 5px;
            line-height: 1.5;
        }}

        .article-meta {{
            font-size: 12px;
            color: #999;
        }}

        .footer {{
            margin-top: 50px;
            padding-top: 20px;
            border-top: 2px solid #667eea;
            text-align: center;
            color: #666;
            font-size: 12px;
        }}

        .footer-line {{
            margin-bottom: 10px;
        }}

        @media print {{
            body {{
                background-color: white;
            }}

            .page {{
                margin: 0;
                padding: 40px;
                box-shadow: none;
            }}

            .category-section {{
                page-break-inside: avoid;
            }}
        }}
    </style>
</head>
<body>
    <div class="page">
        <div class="header">
            <h1>📊 Muhasebe TR</h1>
            <p>{report_type.title()} Muhasebe Haberleri Raporu</p>
        </div>

        <div class="report-meta">
            <strong>Rapor Tarihi:</strong> {datetime.now().strftime("%d.%m.%Y %H:%M")}<br>
            <strong>Rapor Türü:</strong> {report_type.title()}<br>
            <strong>Toplam Makale:</strong> {total_articles}
        </div>

        <div class="section">
            <div class="section-title">📈 İstatistikler</div>
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number">{total_articles}</div>
                    <div class="stat-label">Toplam Makale</div>
                </div>
"""

        # Kategori istatistikleri
        for category in sorted(by_category.keys()):
            count = len(by_category[category])
            html += f"""                <div class="stat-box">
                    <div class="stat-number">{count}</div>
                    <div class="stat-label">{category}</div>
                </div>
"""

        html += """            </div>
        </div>

        <div class="section">
            <div class="section-title">📰 Makaleler</div>
"""

        # Kategorilere göre makaleleri göster
        for category in sorted(by_category.keys()):
            articles_in_cat = by_category[category]
            html += f"""            <div class="category-section">
                <div class="category-title">{category} ({len(articles_in_cat)})</div>
"""

            for article in articles_in_cat:
                html += f"""                <div class="article">
                    <div class="article-title">{article.get('title', 'N/A')}</div>
                    <div class="article-desc">{article.get('description', '')}</div>
                    <div class="article-meta">📅 {article.get('date', '')} | Kaynak: {article.get('source', '')}</div>
                </div>
"""

            html += """            </div>
"""

        html += f"""        </div>

        <div class="footer">
            <div class="footer-line">Muhasebe TR - Otomatik Rapor Oluşturma Sistemi</div>
            <div class="footer-line">Bu rapor otomatik olarak oluşturulmuştur.</div>
            <div class="footer-line">Raporun doğruluğundan sorumlu değiliz.</div>
        </div>
    </div>
</body>
</html>
"""
        return html

    def save_html_report(self, articles, report_type="weekly", filename=""):
        """HTML raporu dosyaya kaydet"""
        try:
            if not filename:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"muhasebe_rapor_{report_type}_{timestamp}.html"

            html_content = self.generate_html_report(articles, report_type)

            output_path = self.data_dir / filename
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(html_content)

            print(f"✅ HTML rapor kaydedildi: {output_path}")
            return output_path

        except Exception as e:
            print(f"❌ Rapor kaydedilme hatası: {e}")
            return None

    def generate_weekly_report(self, articles):
        """Son 7 günün raporunu oluştur"""
        today = datetime.now()
        week_ago = today - timedelta(days=7)

        filtered = []
        for article in articles:
            try:
                article_date = datetime.strptime(article.get('date', ''), "%d.%m.%Y")
                if week_ago <= article_date <= today:
                    filtered.append(article)
            except:
                pass

        return self.save_html_report(filtered, "weekly")

    def generate_monthly_report(self, articles):
        """Son 30 günün raporunu oluştur"""
        today = datetime.now()
        month_ago = today - timedelta(days=30)

        filtered = []
        for article in articles:
            try:
                article_date = datetime.strptime(article.get('date', ''), "%d.%m.%Y")
                if month_ago <= article_date <= today:
                    filtered.append(article)
            except:
                pass

        return self.save_html_report(filtered, "monthly")

    def generate_daily_report(self, articles):
        """Günün raporunu oluştur"""
        today_str = datetime.now().strftime("%d.%m.%Y")

        filtered = [a for a in articles if a.get('date', '') == today_str]

        return self.save_html_report(filtered, "daily")

    def generate_full_report(self, articles):
        """Tüm makalelerin raporunu oluştur"""
        return self.save_html_report(articles, "full")


# Test
if __name__ == "__main__":
    print("\n" + "="*60)
    print("MUHASEBE TR - PDF RAPOR MODÜLÜ")
    print("="*60 + "\n")

    generator = PDFReportGenerator()

    # Test makaleler (farklı tarihler ile)
    test_articles = [
        {
            'title': 'Asgari Ücret Güncellemesi 2026',
            'description': 'Yeni asgari ücret oranları açıklandı. İşçiler için önemli bir haber.',
            'date': '18.08.2026',
            'url': 'https://www.muhasebetr.com/asgari-ucret/',
            'source': 'muhasebetr.com',
            'category': 'Asgari Ücret'
        },
        {
            'title': 'KDV Oranlarında Değişiklikler',
            'description': 'Vergi Müfettişleri Derneği tarafından yayınlanan KDV oranı değişiklikleri. Bazı sektörler etkilenecek.',
            'date': '17.08.2026',
            'url': 'https://www.muhasebetr.com/kdv/',
            'source': 'muhasebetr.com',
            'category': 'Vergi'
        },
        {
            'title': 'Demirbaş Amortisman',
            'description': '2026 amortisman oranları ve demirbaş sınırları resmi olarak belirlendi.',
            'date': '16.08.2026',
            'url': 'https://www.muhasebetr.com/amortisman/',
            'source': 'muhasebetr.com',
            'category': 'Amortisman'
        },
        {
            'title': 'SSK Sigorta Primleri',
            'description': 'Sosyal sigorta prim oranları 2026 için güncellendi.',
            'date': '15.08.2026',
            'url': 'https://www.muhasebetr.com/ssk/',
            'source': 'muhasebetr.com',
            'category': 'Sosyal'
        },
        {
            'title': 'Gümrük Vergi Düzenlemeleri',
            'description': 'Dış ticaret işlemleri için gümrük vergi oranları güncellendi.',
            'date': '14.08.2026',
            'url': 'https://www.muhasebetr.com/gumruk/',
            'source': 'muhasebetr.com',
            'category': 'Gümrük'
        }
    ]

    print("📄 Günlük rapor oluşturuluyor...\n")
    generator.generate_daily_report(test_articles)

    print("📄 Haftalık rapor oluşturuluyor...\n")
    generator.generate_weekly_report(test_articles)

    print("📄 Aylık rapor oluşturuluyor...\n")
    generator.generate_monthly_report(test_articles)

    print("📄 Tam rapor oluşturuluyor...\n")
    generator.generate_full_report(test_articles)

    print("\n✅ Rapor oluşturma işlemi tamamlandı!")
    print(f"📂 Raporlar şurada kaydedildi: {generator.data_dir}/")
