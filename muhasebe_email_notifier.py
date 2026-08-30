#!/usr/bin/env python3
"""
Muhasebe TR - Email Bildirim Modülü
Günlük muhasebe makalelerini e-posta ile gönderir
"""

import json
import smtplib
from pathlib import Path
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class EmailNotifier:
    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)
        self.subscribers_file = self.data_dir / "subscribers.json"
        self.load_subscribers()

    def load_subscribers(self):
        """Abone listesini yükle"""
        if self.subscribers_file.exists():
            with open(self.subscribers_file, 'r', encoding='utf-8') as f:
                self.subscribers = json.load(f)
        else:
            self.subscribers = {"emails": []}

    def save_subscribers(self):
        """Abone listesini kaydet"""
        with open(self.subscribers_file, 'w', encoding='utf-8') as f:
            json.dump(self.subscribers, f, ensure_ascii=False, indent=2)

    def add_subscriber(self, email):
        """Yeni abone ekle"""
        if email not in self.subscribers["emails"]:
            self.subscribers["emails"].append(email)
            self.save_subscribers()
            return True
        return False

    def remove_subscriber(self, email):
        """Abonelikten çıkar"""
        if email in self.subscribers["emails"]:
            self.subscribers["emails"].remove(email)
            self.save_subscribers()
            return True
        return False

    def get_subscribers(self):
        """Aboneleri getir"""
        return self.subscribers["emails"]

    def generate_email_html(self, articles):
        """E-posta HTML'i oluştur"""
        by_category = {}
        for article in articles:
            cat = article.get('category', 'Diğer')
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(article)

        html = f"""<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {{
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            color: #333;
        }}
        .container {{
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: center;
        }}
        .header h1 {{
            margin: 0;
            font-size: 24px;
        }}
        .header p {{
            margin: 5px 0 0 0;
            font-size: 14px;
            opacity: 0.9;
        }}
        .category {{
            margin-bottom: 25px;
            border-left: 4px solid #667eea;
            padding-left: 20px;
        }}
        .category-title {{
            font-size: 18px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 15px;
        }}
        .article {{
            margin-bottom: 15px;
            padding: 12px;
            background-color: #f9f9f9;
            border-radius: 4px;
            border: 1px solid #eee;
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
            line-height: 1.5;
            margin-bottom: 8px;
        }}
        .article-meta {{
            font-size: 12px;
            color: #999;
        }}
        .article-link {{
            display: inline-block;
            margin-top: 8px;
            color: #667eea;
            text-decoration: none;
            font-size: 12px;
            font-weight: bold;
        }}
        .article-link:hover {{
            text-decoration: underline;
        }}
        .footer {{
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #999;
        }}
        .unsubscribe {{
            text-align: center;
            margin-top: 10px;
            font-size: 11px;
        }}
        .unsubscribe a {{
            color: #667eea;
            text-decoration: none;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Muhasebe TR</h1>
            <p>Günlük Muhasebe Haberleri - {datetime.now().strftime("%d.%m.%Y")}</p>
        </div>
"""

        for category in sorted(by_category.keys()):
            articles_in_cat = by_category[category]
            html += f"""        <div class="category">
            <div class="category-title">📌 {category}</div>
"""

            for article in articles_in_cat:
                html += f"""            <div class="article">
                <div class="article-title">{article.get('title', 'N/A')}</div>
                <div class="article-desc">{article.get('description', '')}</div>
                <div class="article-meta">📅 {article.get('date', '')}</div>
                <a href="{article.get('url', '#')}" target="_blank" class="article-link">Devamını Oku →</a>
            </div>
"""

            html += """        </div>
"""

        html += f"""        <div class="footer">
            <p>Muhasebe TR - Günlük Otomatik Haber Sistemi</p>
            <div class="unsubscribe">
                <a href="mailto:info@muhasebetr.local?subject=unsubscribe">Abonelikten Çık</a>
            </div>
        </div>
    </div>
</body>
</html>
"""
        return html

    def send_email(self, recipient_email, subject, articles, use_mock=True):
        """E-posta gönder (mock mod)"""
        try:
            email_body = self.generate_email_html(articles)

            if use_mock:
                # Mock mod - dosyaya kaydet
                mock_file = self.data_dir / f"email_{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
                with open(mock_file, 'w', encoding='utf-8') as f:
                    f.write(email_body)
                print(f"📧 Mock e-posta kaydedildi: {mock_file}")
                return True
            else:
                # Gerçek SMTP gönderimi (ayarlanması gerekir)
                print(f"📧 E-posta gönderiliyor: {recipient_email}")
                # SMTP ayarları burada yapılacak
                return True

        except Exception as e:
            print(f"❌ E-posta gönderme hatası: {e}")
            return False

    def send_daily_digest(self, articles, use_mock=True):
        """Tüm abonelere günlük özet gönder"""
        subscribers = self.get_subscribers()

        if not subscribers:
            print("⚠️  Abone bulunamadı")
            return False

        success_count = 0
        for email in subscribers:
            if self.send_email(email, "Günlük Muhasebe Haberleri", articles, use_mock):
                success_count += 1

        print(f"✅ {success_count}/{len(subscribers)} aboneye e-posta gönderildi")
        return success_count == len(subscribers)


# Test
if __name__ == "__main__":
    print("\n" + "="*60)
    print("MUHASEBE TR - EMAIL BİLDİRİM SİSTEMİ")
    print("="*60 + "\n")

    notifier = EmailNotifier()

    # Test - abone ekle
    test_emails = [
        "user1@example.com",
        "user2@example.com",
        "user3@example.com"
    ]

    print("📝 Test aboneleri ekleniyor...\n")
    for email in test_emails:
        if notifier.add_subscriber(email):
            print(f"✅ {email} eklendi")
        else:
            print(f"⚠️  {email} zaten mevcut")

    print(f"\n📊 Toplam abone: {len(notifier.get_subscribers())}")

    # Test makaleler
    test_articles = [
        {
            'title': 'Asgari Ücret Güncellemesi 2026',
            'description': 'Yeni asgari ücret oranları açıklandı',
            'date': '18.08.2026',
            'url': 'https://www.muhasebetr.com/asgari-ucret/',
            'category': 'Asgari Ücret'
        },
        {
            'title': 'KDV Düzenlemeleri',
            'description': 'KDV oranlarında değişiklikler',
            'date': '18.08.2026',
            'url': 'https://www.muhasebetr.com/kdv/',
            'category': 'Vergi'
        }
    ]

    print("\n📧 Günlük özet gönderiliyor...\n")
    notifier.send_daily_digest(test_articles, use_mock=True)

    print(f"\n📂 Abone dosyası: {notifier.subscribers_file}")
