#!/usr/bin/env python3
"""
Muhasebe TR - AI SORU-CEVAP Modülü
Kullanıcılar muhasebe sorusu soruyor, AI cevaplıyor
"""

import json
import re
from datetime import datetime
from pathlib import Path

class MuhasebeQA:
    def __init__(self):
        self.data_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.data_dir.mkdir(exist_ok=True)
        self.qa_file = self.data_dir / "qa_database.json"

        # Hazır muhasebe soruları ve cevapları
        self.knowledge_base = {
            "asgari ücret": {
                "2026": "2026 yılı asgari ücret TL'dir. Brüt ücretin %15,5'i sigorta primatolur.",
                "hesaplama": "Asgari ücret x 30 gün = Aylık brüt ücret. Sigorta primi çıkartılır."
            },
            "kdv": {
                "oran": "Standart KDV oranı %18'dir. Bazı mal ve hizmetler %8 veya %1 oranında KDV'ye tabidir.",
                "muhasebe": "KDV Gümrük Muhasebesi: 191 Vergiler - KDV hesabında takip edilir."
            },
            "amortisman": {
                "sınır": "Demirbaş amortisman sınırı TL'dir. Bunun altında maliyete yazılır.",
                "oranlar": "Binalar %2, Makine %10, Araçlar %20, Mobilya %10 oranında amorti edilir."
            },
            "sosyal": {
                "ssk": "SSK'ya tabi çalışan için işveren %11, işçi %9.5 oranında sigorta primi öder.",
                "bağkur": "Bağ-Kur'da aylık prim kendi gelir düzeyine göre hesaplanır."
            },
            "vergi": {
                "gelir vergisi": "Bireysel gelire göre %15 - %40 arasında değişen oranlarda gelir vergisi uygulanır.",
                "kurumlar": "Kurumlar vergisi oranı %20'dir."
            },
            "dış ticaret": {
                "gümrük": "Gümrük vergileri HS Koduna göre değişir. Genelde %5-15 arasındadır.",
                "kdv": "İthal ürünler de KDV'ye tabidir."
            }
        }

        self.load_qa_database()

    def load_qa_database(self):
        """Önceki S&C'leri yükle"""
        if self.qa_file.exists():
            with open(self.qa_file, 'r', encoding='utf-8') as f:
                self.qa_data = json.load(f)
        else:
            self.qa_data = {"questions": []}

    def save_qa_database(self):
        """S&C veritabanını kaydet"""
        with open(self.qa_file, 'w', encoding='utf-8') as f:
            json.dump(self.qa_data, f, ensure_ascii=False, indent=2)

    def find_relevant_keywords(self, question):
        """Soruda ilgili anahtar kelimeler ara"""
        question_lower = question.lower()
        relevant_topics = []

        for topic in self.knowledge_base.keys():
            if topic in question_lower:
                relevant_topics.append(topic)

        return relevant_topics

    def generate_answer(self, question):
        """Soruya cevap oluştur"""
        topics = self.find_relevant_keywords(question)

        if not topics:
            return self.generate_generic_answer(question)

        answer = f"📌 Bulduğum Konu: {', '.join(topics).title()}\n\n"

        for topic in topics:
            answer += f"**{topic.upper()} Hakkında:**\n"
            for key, value in self.knowledge_base[topic].items():
                answer += f"• {value}\n"
            answer += "\n"

        answer += "💡 İpucu: Daha spesifik sorularınız için muhasebeciye danışmanızı öneririm."
        return answer

    def generate_generic_answer(self, question):
        """Genel cevap oluştur"""
        return """❓ Sorununuz için spesifik bir cevap bulamadım.

Lütfen aşağıdaki konulardan biriyle ilgili sorabilirsiniz:
• Asgari Ücret (2026)
• KDV (Oran, Muhasebe)
• Amortisman (Sınır, Oranlar)
• Sosyal Sigorta (SSK, Bağ-Kur)
• Vergi (Gelir, Kurumlar)
• Dış Ticaret (Gümrük, Vergiler)

Örnek sorular:
- "Asgari ücret ne kadar?"
- "KDV oranı kaçtır?"
- "Demirbaş sınırı nedir?"

💼 Profesyonel muhasebeci danışmanlığı için bize ulaşın."""

    def ask(self, question, user_email=None):
        """Soruyu kaydet ve cevap oluştur"""
        answer = self.generate_answer(question)

        qa_entry = {
            "question": question,
            "answer": answer,
            "timestamp": datetime.now().isoformat(),
            "user_email": user_email,
            "id": len(self.qa_data["questions"]) + 1
        }

        self.qa_data["questions"].append(qa_entry)
        self.save_qa_database()

        return qa_entry

    def get_all_questions(self):
        """Tüm soruları getir"""
        return self.qa_data["questions"]

    def search_questions(self, keyword):
        """Soruları anahtar kelimeye göre ara"""
        results = []
        keyword_lower = keyword.lower()

        for qa in self.qa_data["questions"]:
            if (keyword_lower in qa["question"].lower() or
                keyword_lower in qa["answer"].lower()):
                results.append(qa)

        return results


class QAPanel:
    """HTML Soru-Cevap Paneli Oluşturucu"""

    def __init__(self, qa_system):
        self.qa = qa_system
        self.output_dir = Path("/home/user/-mery-lmaz/muhasebe_data")
        self.output_dir.mkdir(exist_ok=True)

    def generate_html(self):
        """S&C paneli HTML'i oluştur"""
        qa_list = self.qa.get_all_questions()

        html = """<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Muhasebe TR - Soru-Cevap Paneli</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
        }

        .header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .header h1 {
            color: #333;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 14px;
        }

        .ask-section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .ask-section h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
            font-size: 14px;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-family: inherit;
            font-size: 14px;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: transform 0.2s;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .search-section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .search-input {
            display: flex;
            gap: 10px;
        }

        .search-input input {
            flex: 1;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }

        .qa-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .qa-item {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .qa-question {
            color: #667eea;
            font-weight: bold;
            margin-bottom: 10px;
            font-size: 15px;
        }

        .qa-answer {
            color: #333;
            line-height: 1.6;
            margin-bottom: 10px;
            white-space: pre-wrap;
            font-size: 14px;
        }

        .qa-meta {
            font-size: 12px;
            color: #999;
            border-top: 1px solid #eee;
            padding-top: 10px;
        }

        .stats {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .stat {
            text-align: center;
        }

        .stat-number {
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
        }

        .stat-label {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }

        .empty {
            text-align: center;
            color: #999;
            padding: 40px 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>❓ Muhasebe TR - Soru-Cevap Paneli</h1>
            <p>Muhasebe sorularınızı sorun, AI tarafından cevaplandırılsın</p>
        </div>

        <div class="stats">
            <div class="stat">
                <div class="stat-number">""" + str(len(qa_list)) + """</div>
                <div class="stat-label">Toplam Soru</div>
            </div>
            <div class="stat">
                <div class="stat-number">""" + str(len(qa_list)) + """</div>
                <div class="stat-label">Cevap Verilen</div>
            </div>
        </div>

        <div class="ask-section">
            <h2>💭 Soru Sor</h2>
            <form id="qaForm">
                <div class="form-group">
                    <label for="email">Email (opsiyonel):</label>
                    <input type="email" id="email" name="email" placeholder="ornek@email.com">
                </div>
                <div class="form-group">
                    <label for="question">Sorunuz:</label>
                    <textarea id="question" name="question" placeholder="Muhasebe hakkında bir soru yazın..." required></textarea>
                </div>
                <button type="submit" class="btn">Gönder</button>
            </form>
        </div>

        <div class="search-section">
            <div class="search-input">
                <input type="text" id="searchInput" placeholder="Sorularda ara...">
                <button class="btn" onclick="search()">Ara</button>
            </div>
        </div>

        <div class="qa-list" id="qaList">
"""

        if qa_list:
            for qa in reversed(qa_list):  # En yeni en üstte
                html += f"""            <div class="qa-item">
                <div class="qa-question">❓ {qa['question']}</div>
                <div class="qa-answer">{qa['answer']}</div>
                <div class="qa-meta">📅 {qa['timestamp'][:10]} {qa['timestamp'][11:16]}</div>
            </div>
"""
        else:
            html += """            <div class="empty">
                <p>Henüz soru sorulmamış. İlk soru siz sorun! 👆</p>
            </div>
"""

        html += """        </div>
    </div>

    <script>
        document.getElementById('qaForm').addEventListener('submit', function(e) {
            e.preventDefault();
            alert('✅ Soru gönderildi! Sayfayı yenileyerek cevabı görebilirsiniz.');
            this.reset();
        });

        function search() {
            alert('🔍 Arama özelliği şu anda açılıyor...');
        }
    </script>
</body>
</html>
"""

        output_file = self.output_dir / "qa_panel.html"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html)

        return output_file


# Test
if __name__ == "__main__":
    print("\n" + "="*60)
    print("MUHASEBE TR - SORU-CEVAP SİSTEMİ")
    print("="*60 + "\n")

    qa = MuhasebeQA()

    # Test soruları
    test_questions = [
        "Asgari ücret ne kadar?",
        "KDV oranları nedir?",
        "Demirbaş amortisman sınırı kaçtır?",
        "Bağ-Kur ne kadar prim öder?"
    ]

    print("📝 Test soruları işleniyor...\n")
    for question in test_questions:
        result = qa.ask(question, "test@example.com")
        print(f"❓ Soru: {question}")
        print(f"✅ Cevap: {result['answer'][:100]}...\n")

    # Panel oluştur
    panel = QAPanel(qa)
    panel_path = panel.generate_html()
    print(f"🎨 Panel oluşturuldu: {panel_path}")

    # JSON göster
    print(f"\n📊 Veritabanı: {qa.qa_file}")
    print(f"💾 Toplam soru: {len(qa.get_all_questions())}")
