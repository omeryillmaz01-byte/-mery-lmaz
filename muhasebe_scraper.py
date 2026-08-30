#!/usr/bin/env python3
"""
Muhasebe TR - Günlük Muhasebe Yazıları Scraper & Panel
Muhasebetr.com'dan günlük yazıları çeker, kategorize eder ve panel oluşturur
"""

import requests
from bs4 import BeautifulSoup
from datetime import datetime
import json
import os
from pathlib import Path

class MuhasebetrScraper:
    def __init__(self):
        self.base_url = "https://www.muhasebetr.com"
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)

        # Kategoriler ve anahtar kelimeler
        self.categories = {
            "Vergi": ["vergi", "kdv", "vat", "gelir vergisi", "kurumlar vergisi", "stopaj"],
            "Amortisman": ["amortisman", "değer kaybı", "amorti"],
            "Asgari Ücret": ["asgari ücret", "minimum wage", "ücret", "bordro"],
            "Sosyal": ["sigorta", "ssk", "bağ-kur", "işsizlik", "emeklilik"],
            "Gümrük": ["gümrük", "dış ticaret", "ihracat", "ithacat"],
            "Muhasebe": ["muhasebe", "defter", "rapor", "finansal"],
            "Diğer": []
        }

    def fetch_articles(self):
        """muhasebetr.com ana sayfasından yazıları çek"""
        try:
            print("📰 Muhasebetr.com'dan yazılar çekiliyor...")

            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }

            response = requests.get(self.base_url, headers=headers, timeout=10)
            response.encoding = 'utf-8'

            soup = BeautifulSoup(response.content, 'html.parser')
            articles = []

            # Ana yazı (header-left-author)
            author_section = soup.find('div', class_='header-left-author')
            if author_section:
                link = author_section.find('a')
                if link:
                    title = link.find('strong')
                    desc = link.find('span')
                    date = link.find('i')

                    article = {
                        'title': title.text if title else 'N/A',
                        'description': desc.text if desc else 'N/A',
                        'date': date.text if date else datetime.now().strftime("%d.%m.%Y"),
                        'url': link.get('href', '#'),
                        'source': 'muhasebetr.com'
                    }
                    articles.append(article)

            print(f"✅ {len(articles)} yazı bulundu")
            return articles

        except Exception as e:
            print(f"❌ Hata: {e}")
            return []

    def categorize_article(self, article):
        """Makaleyi kategorize et"""
        text = (article.get('title', '') + ' ' + article.get('description', '')).lower()

        for category, keywords in self.categories.items():
            if category == "Diğer":
                continue
            for keyword in keywords:
                if keyword.lower() in text:
                    return category

        return "Diğer"

    def process_articles(self, articles):
        """Makaleleri işle ve JSON'a kaydet"""
        processed = []

        for article in articles:
            category = self.categorize_article(article)
            processed.append({
                **article,
                'category': category,
                'processed_date': datetime.now().isoformat(),
                'id': article['url'].split('/')[-2] if '/' in article['url'] else 'unknown'
            })

        # Tarihe göre klasör oluştur
        today = datetime.now().strftime("%Y-%m-%d")
        file_path = self.data_dir / f"articles_{today}.json"

        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(processed, f, ensure_ascii=False, indent=2)

        print(f"💾 {file_path} kaydedildi")
        return processed

    def generate_panel_html(self, articles):
        """HTML panel oluştur"""

        # Kategoriye göre grupla
        by_category = {}
        for article in articles:
            cat = article['category']
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(article)

        html = f"""<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Muhasebe TR - Günlük Panel</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}

        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}

        .header {{
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }}

        .header h1 {{
            color: #333;
            margin-bottom: 10px;
        }}

        .header p {{
            color: #666;
            font-size: 14px;
        }}

        .grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}

        .category {{
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }}

        .category:hover {{
            transform: translateY(-5px);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
        }}

        .category-header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            font-weight: bold;
            font-size: 16px;
        }}

        .category-content {{
            padding: 20px;
        }}

        .article {{
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }}

        .article:last-child {{
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
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
            line-height: 1.4;
            margin-bottom: 5px;
        }}

        .article-meta {{
            font-size: 12px;
            color: #999;
        }}

        .article-link {{
            color: #667eea;
            text-decoration: none;
            font-size: 12px;
            margin-top: 5px;
            display: inline-block;
        }}

        .article-link:hover {{
            text-decoration: underline;
        }}

        .stats {{
            background: white;
            padding: 20px;
            border-radius: 10px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }}

        .stat {{
            text-align: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }}

        .stat-number {{
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
        }}

        .stat-label {{
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Muhasebe TR - Günlük Panel</h1>
            <p>Güncellenme: {datetime.now().strftime("%d.%m.%Y %H:%M")}</p>
        </div>

        <div class="stats">
            <div class="stat">
                <div class="stat-number">{len(articles)}</div>
                <div class="stat-label">Toplam Yazı</div>
            </div>
"""

        # Kategori istatistikleri
        for category in self.categories.keys():
            count = len(by_category.get(category, []))
            if count > 0:
                html += f"""            <div class="stat">
                <div class="stat-number">{count}</div>
                <div class="stat-label">{category}</div>
            </div>
"""

        html += """        </div>

        <div class="grid">
"""

        # Kategorileri göster
        for category in self.categories.keys():
            articles_in_cat = by_category.get(category, [])
            if not articles_in_cat:
                continue

            html += f"""            <div class="category">
                <div class="category-header">{category} ({len(articles_in_cat)})</div>
                <div class="category-content">
"""

            for article in articles_in_cat:
                html += f"""                    <div class="article">
                        <div class="article-title">{article['title']}</div>
                        <div class="article-desc">{article['description']}</div>
                        <div class="article-meta">{article['date']}</div>
                        <a href="{article['url']}" target="_blank" class="article-link">Devamını Oku →</a>
                    </div>
"""

            html += """                </div>
            </div>
"""

        html += """        </div>
    </div>
</body>
</html>
"""

        # HTML'i kaydet
        html_path = self.data_dir / "panel.html"
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html)

        print(f"🎨 Panel oluşturuldu: {html_path}")
        return html_path

    def run(self):
        """Tüm işlemi çalıştır"""
        print("\n" + "="*50)
        print("MUHASEBE TR - GÜNLÜK SCRAPER")
        print("="*50 + "\n")

        # 1. Yazıları çek
        articles = self.fetch_articles()

        if not articles:
            print("⚠️  Yazı bulunamadı")
            return

        # 2. İşle ve kategorize et
        processed = self.process_articles(articles)

        # 3. Panel oluştur
        self.generate_panel_html(processed)

        print("\n✅ İşlem tamamlandı!")

if __name__ == "__main__":
    scraper = MuhasebetrScraper()
    scraper.run()
