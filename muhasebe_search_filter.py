#!/usr/bin/env python3
"""
Muhasebe TR - Arama ve Filtreleme Modülü
Makaleler ve S&C verilerinde arama ve filtreleme yapar
"""

import json
from pathlib import Path
from datetime import datetime
from typing import List, Dict


class SearchEngine:
    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")

    def search_articles(self, articles: List[Dict], keyword: str, category: str = None) -> List[Dict]:
        """Makalelerda arama yap"""
        results = []
        keyword_lower = keyword.lower()

        for article in articles:
            # Başlık ve açıklamada ara
            title_match = keyword_lower in article.get('title', '').lower()
            desc_match = keyword_lower in article.get('description', '').lower()
            category_match = True

            # Kategoriye göre filtrele
            if category:
                category_match = article.get('category', '').lower() == category.lower()

            if (title_match or desc_match) and category_match:
                results.append(article)

        return results

    def search_qa(self, qa_data: Dict, keyword: str) -> List[Dict]:
        """S&C verilerinde arama yap"""
        results = []
        keyword_lower = keyword.lower()
        questions = qa_data.get("questions", [])

        for qa in questions:
            question_match = keyword_lower in qa.get('question', '').lower()
            answer_match = keyword_lower in qa.get('answer', '').lower()

            if question_match or answer_match:
                results.append(qa)

        return results

    def filter_articles_by_date(self, articles: List[Dict], start_date: str, end_date: str) -> List[Dict]:
        """Makaleleri tarih aralığına göre filtrele (dd.mm.yyyy)"""
        results = []

        try:
            start = datetime.strptime(start_date, "%d.%m.%Y")
            end = datetime.strptime(end_date, "%d.%m.%Y")

            for article in articles:
                article_date = datetime.strptime(article.get('date', ''), "%d.%m.%Y")
                if start <= article_date <= end:
                    results.append(article)
        except ValueError as e:
            print(f"⚠️  Tarih format hatası: {e}")
            return articles

        return results

    def filter_articles_by_category(self, articles: List[Dict], category: str) -> List[Dict]:
        """Makaleleri kategoriye göre filtrele"""
        return [a for a in articles if a.get('category', '').lower() == category.lower()]

    def filter_articles_by_source(self, articles: List[Dict], source: str) -> List[Dict]:
        """Makaleleri kaynağa göre filtrele"""
        return [a for a in articles if a.get('source', '').lower() == source.lower()]

    def sort_articles(self, articles: List[Dict], sort_by: str = "date", reverse: bool = True) -> List[Dict]:
        """Makaleleri sırala"""
        valid_keys = ['title', 'date', 'category']

        if sort_by not in valid_keys:
            sort_by = 'date'

        if sort_by == 'date':
            try:
                return sorted(
                    articles,
                    key=lambda x: datetime.strptime(x.get('date', ''), "%d.%m.%Y"),
                    reverse=reverse
                )
            except:
                return articles
        else:
            return sorted(articles, key=lambda x: x.get(sort_by, ''), reverse=reverse)

    def get_unique_categories(self, articles: List[Dict]) -> List[str]:
        """Tüm kategorileri getir"""
        categories = set()
        for article in articles:
            cat = article.get('category', 'Diğer')
            categories.add(cat)
        return sorted(list(categories))

    def get_unique_sources(self, articles: List[Dict]) -> List[str]:
        """Tüm kaynakları getir"""
        sources = set()
        for article in articles:
            src = article.get('source', '')
            if src:
                sources.add(src)
        return sorted(list(sources))

    def get_date_range(self, articles: List[Dict]) -> Dict:
        """Makale tarih aralığını getir"""
        if not articles:
            return {"start": None, "end": None}

        try:
            dates = []
            for article in articles:
                date_obj = datetime.strptime(article.get('date', ''), "%d.%m.%Y")
                dates.append(date_obj)

            dates.sort()
            return {
                "start": dates[0].strftime("%d.%m.%Y"),
                "end": dates[-1].strftime("%d.%m.%Y")
            }
        except:
            return {"start": None, "end": None}

    def get_statistics(self, articles: List[Dict]) -> Dict:
        """Makale istatistiklerini getir"""
        stats = {
            "total_articles": len(articles),
            "by_category": {},
            "by_source": {},
            "date_range": self.get_date_range(articles)
        }

        for article in articles:
            # Kategoriye göre
            cat = article.get('category', 'Diğer')
            stats["by_category"][cat] = stats["by_category"].get(cat, 0) + 1

            # Kaynağa göre
            src = article.get('source', 'Bilinmiyor')
            stats["by_source"][src] = stats["by_source"].get(src, 0) + 1

        return stats


class AdvancedSearch:
    """İleri arama özellikleri"""

    def __init__(self, search_engine: SearchEngine):
        self.search = search_engine

    def complex_search(self, articles: List[Dict], params: Dict) -> List[Dict]:
        """Karmaşık arama parametreleri ile arama yap"""
        results = articles

        # Anahtar kelime araması
        if params.get('keyword'):
            results = self.search.search_articles(results, params['keyword'])

        # Kategori filtresi
        if params.get('category'):
            results = self.search.filter_articles_by_category(results, params['category'])

        # Kaynağa göre filtresi
        if params.get('source'):
            results = self.search.filter_articles_by_source(results, params['source'])

        # Tarih aralığı filtresi
        if params.get('start_date') and params.get('end_date'):
            results = self.search.filter_articles_by_date(
                results,
                params['start_date'],
                params['end_date']
            )

        # Sıralama
        if params.get('sort_by'):
            reverse = params.get('sort_reverse', True)
            results = self.search.sort_articles(results, params['sort_by'], reverse)

        return results


# Test
if __name__ == "__main__":
    print("\n" + "="*60)
    print("MUHASEBE TR - ARAMA VE FİLTRELEME MODÜLÜ")
    print("="*60 + "\n")

    engine = SearchEngine()

    # Test makaleler
    test_articles = [
        {
            'title': 'Asgari Ücret Güncellemesi 2026',
            'description': 'Yeni asgari ücret oranları açıklandı',
            'date': '18.08.2026',
            'url': 'https://www.muhasebetr.com/asgari-ucret/',
            'source': 'muhasebetr.com',
            'category': 'Asgari Ücret'
        },
        {
            'title': 'KDV Oranlarında Değişiklikler',
            'description': 'KDV oranlarında yeni düzenlemeler',
            'date': '17.08.2026',
            'url': 'https://www.muhasebetr.com/kdv/',
            'source': 'muhasebetr.com',
            'category': 'Vergi'
        },
        {
            'title': 'Demirbaş Amortisman',
            'description': 'Demirbaş ve amortisman oranları 2026',
            'date': '16.08.2026',
            'url': 'https://www.muhasebetr.com/amortisman/',
            'source': 'muhasebetr.com',
            'category': 'Amortisman'
        },
        {
            'title': 'SSK Sigorta Primleri',
            'description': 'Sosyal sigorta prim oranları',
            'date': '15.08.2026',
            'url': 'https://www.muhasebetr.com/ssk/',
            'source': 'muhasebetr.com',
            'category': 'Sosyal'
        }
    ]

    # Test 1: Basit arama
    print("🔍 Test 1: Basit Arama\n")
    results = engine.search_articles(test_articles, "ücret")
    print(f"'ücret' aranıyor: {len(results)} sonuç bulundu")
    for r in results:
        print(f"  - {r['title']}")

    # Test 2: Kategori filtresi
    print("\n🔍 Test 2: Kategori Filtresi\n")
    results = engine.filter_articles_by_category(test_articles, "Vergi")
    print(f"'Vergi' kategorisi: {len(results)} makale")
    for r in results:
        print(f"  - {r['title']}")

    # Test 3: Tarih aralığı filtresi
    print("\n🔍 Test 3: Tarih Aralığı Filtresi\n")
    results = engine.filter_articles_by_date(test_articles, "15.08.2026", "17.08.2026")
    print(f"15-17 Ağustos: {len(results)} makale")
    for r in results:
        print(f"  - {r['title']} ({r['date']})")

    # Test 4: İstatistikler
    print("\n📊 Test 4: İstatistikler\n")
    stats = engine.get_statistics(test_articles)
    print(f"Toplam makale: {stats['total_articles']}")
    print(f"Kategoriler: {stats['by_category']}")
    print(f"Kaynaklar: {stats['by_source']}")
    print(f"Tarih aralığı: {stats['date_range']}")

    # Test 5: İleri arama
    print("\n🔍 Test 5: İleri Arama\n")
    advanced = AdvancedSearch(engine)
    results = advanced.complex_search(test_articles, {
        'keyword': 'oranları',
        'category': 'Sosyal',
        'sort_by': 'date',
        'sort_reverse': False
    })
    print(f"'oranları' + 'Sosyal' kategorisi: {len(results)} sonuç")
    for r in results:
        print(f"  - {r['title']}")

    print("\n✅ Arama ve filtreleme testleri tamamlandı!")
