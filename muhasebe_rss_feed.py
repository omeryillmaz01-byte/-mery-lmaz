#!/usr/bin/env python3
"""
Muhasebe TR - RSS Feed Üreticisi
Günlük muhasebe makalelerından RSS feed oluşturur
"""

import json
from pathlib import Path
from datetime import datetime
from xml.dom import minidom


class RSSFeedGenerator:
    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)
        self.rss_file = self.data_dir / "feed.rss"

    def generate_rss(self, articles):
        """Makalelerden RSS feed oluştur"""
        rss = """<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
    <channel>
        <title>Muhasebe TR - Günlük Panel</title>
        <link>https://www.muhasebetr.com</link>
        <description>Muhasebe, Vergi, Amortisman ve Finansal Haberleri</description>
        <language>tr</language>
        <lastBuildDate>""" + datetime.now().strftime("%a, %d %b %Y %H:%M:%S +0000") + """</lastBuildDate>
"""

        # Makaleleri kategoriye göre grupla
        by_category = {}
        for article in articles:
            cat = article.get('category', 'Diğer')
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(article)

        # Her makale için item ekle
        for category in sorted(by_category.keys()):
            articles_in_cat = by_category[category]
            for article in articles_in_cat:
                rss += f"""        <item>
            <title>{self.escape_xml(article.get('title', 'N/A'))}</title>
            <link>{article.get('url', '#')}</link>
            <description>{self.escape_xml(article.get('description', ''))}</description>
            <category>{category}</category>
            <pubDate>{self.parse_date_to_rfc822(article.get('date', ''))}</pubDate>
            <guid>{article.get('url', '#')}</guid>
            <source>{article.get('source', 'muhasebetr.com')}</source>
        </item>
"""

        rss += """    </channel>
</rss>
"""
        return rss

    def escape_xml(self, text):
        """XML karakterlerini escape et"""
        if not text:
            return ""
        return (text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace('"', "&quot;")
                .replace("'", "&apos;"))

    def parse_date_to_rfc822(self, date_str):
        """Türkçe tarih formatını RFC822 formatına çevir"""
        try:
            # dd.mm.yyyy formatı
            date_obj = datetime.strptime(date_str, "%d.%m.%Y")
            return date_obj.strftime("%a, %d %b %Y 12:00:00 +0000")
        except:
            return datetime.now().strftime("%a, %d %b %Y %H:%M:%S +0000")

    def save_rss(self, rss_content):
        """RSS feed'i dosyaya kaydet"""
        try:
            with open(self.rss_file, 'w', encoding='utf-8') as f:
                f.write(rss_content)
            print(f"✅ RSS feed kaydedildi: {self.rss_file}")
            return True
        except Exception as e:
            print(f"❌ RSS kaydedilme hatası: {e}")
            return False

    def format_rss_pretty(self, rss_content):
        """RSS'i güzel formatlama (opsiyonel)"""
        try:
            dom = minidom.parseString(rss_content)
            pretty = dom.toprettyxml(indent="    ")
            # XML deklarasyonu satırını kaldır ve baştan yeniden ekle
            lines = pretty.split('\n')[1:]
            return '<?xml version="1.0" encoding="UTF-8"?>\n' + '\n'.join(lines)
        except:
            return rss_content

    def generate_and_save(self, articles):
        """RSS oluştur ve kaydet"""
        rss_content = self.generate_rss(articles)
        return self.save_rss(rss_content)

    def get_feed_url(self):
        """Feed URL'sini döndür"""
        return f"file://{self.rss_file}"


class AtomFeedGenerator:
    """Atom feed formatı için generator"""

    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)
        self.atom_file = self.data_dir / "feed.atom"

    def generate_atom(self, articles):
        """Makalelerden Atom feed oluştur"""
        atom = """<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="tr">
    <title>Muhasebe TR - Günlük Panel</title>
    <subtitle>Muhasebe, Vergi, Amortisman ve Finansal Haberleri</subtitle>
    <link href="https://www.muhasebetr.com" rel="alternate"/>
    <link href="file://muhasebe_data/feed.atom" rel="self"/>
    <id>urn:uuid:muhasebetr-feed</id>
    <updated>""" + datetime.now().isoformat() + """</updated>
"""

        for article in articles:
            atom += f"""    <entry>
        <title>{self.escape_xml(article.get('title', 'N/A'))}</title>
        <link href="{article.get('url', '#')}"/>
        <id>{article.get('url', '#')}</id>
        <published>{self.parse_date_to_iso(article.get('date', ''))}</published>
        <updated>{self.parse_date_to_iso(article.get('date', ''))}</updated>
        <summary>{self.escape_xml(article.get('description', ''))}</summary>
        <category term="{article.get('category', 'Diğer')}"/>
        <author>
            <name>Muhasebe TR</name>
            <email>info@muhasebetr.local</email>
        </author>
    </entry>
"""

        atom += """</feed>
"""
        return atom

    def escape_xml(self, text):
        """XML karakterlerini escape et"""
        if not text:
            return ""
        return (text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace('"', "&quot;")
                .replace("'", "&apos;"))

    def parse_date_to_iso(self, date_str):
        """Türkçe tarih formatını ISO8601 formatına çevir"""
        try:
            date_obj = datetime.strptime(date_str, "%d.%m.%Y")
            return date_obj.isoformat() + "Z"
        except:
            return datetime.now().isoformat() + "Z"

    def save_atom(self, atom_content):
        """Atom feed'i dosyaya kaydet"""
        try:
            with open(self.atom_file, 'w', encoding='utf-8') as f:
                f.write(atom_content)
            print(f"✅ Atom feed kaydedildi: {self.atom_file}")
            return True
        except Exception as e:
            print(f"❌ Atom kaydedilme hatası: {e}")
            return False

    def generate_and_save(self, articles):
        """Atom oluştur ve kaydet"""
        atom_content = self.generate_atom(articles)
        return self.save_atom(atom_content)


# Test
if __name__ == "__main__":
    print("\n" + "="*60)
    print("MUHASEBE TR - RSS/ATOM FEED ÜRETICISI")
    print("="*60 + "\n")

    # Test makaleler
    test_articles = [
        {
            'title': 'Asgari Ücret Güncellemesi 2026',
            'description': 'Yeni asgari ücret oranları açıklandı ve bordro hesaplamaları etkilenecektir',
            'date': '18.08.2026',
            'url': 'https://www.muhasebetr.com/asgari-ucret-2026/',
            'source': 'muhasebetr.com',
            'category': 'Asgari Ücret'
        },
        {
            'title': 'KDV Oranlarında Değişiklikler',
            'description': 'Vergi Müfettişleri Derneği tarafından yayınlanan KDV oranı değişiklikleri',
            'date': '17.08.2026',
            'url': 'https://www.muhasebetr.com/kdv-degisiklikleri/',
            'source': 'muhasebetr.com',
            'category': 'Vergi'
        },
        {
            'title': 'Demirbaş Amortisman Sınırları',
            'description': '2026 yılı için demirbaş ve amortisman oranları resmi olarak belirlendi',
            'date': '16.08.2026',
            'url': 'https://www.muhasebetr.com/amortisman-2026/',
            'source': 'muhasebetr.com',
            'category': 'Amortisman'
        }
    ]

    # RSS Feed oluştur
    print("📰 RSS Feed oluşturuluyor...\n")
    rss_gen = RSSFeedGenerator()
    rss_gen.generate_and_save(test_articles)
    print(f"🔗 RSS Feed URL: {rss_gen.get_feed_url()}\n")

    # Atom Feed oluştur
    print("📰 Atom Feed oluşturuluyor...\n")
    atom_gen = AtomFeedGenerator()
    atom_gen.generate_and_save(test_articles)

    print(f"\n✅ Her iki feed formatı da oluşturuldu!")
