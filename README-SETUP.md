# 🏦 Battal Panel Backend Setup

## 1️⃣ Google OAuth2 Credentials Oluştur

1. [Google Cloud Console](https://console.cloud.google.com) aç
2. **Yeni Proje** → "Battal Panel Backend"
3. **APIs & Services** → **Enable APIs** → **Gmail API** ekle
4. **Credentials** → **OAuth 2.0 Client ID** → **Desktop Application**
5. **credentials.json** dosyasını indir
6. Bu klasöre kopyala

## 2️⃣ Kurulum

```bash
npm install
```

## 3️⃣ Çalıştırma

```bash
npm start
```

Server açılıyor: `http://localhost:3000`

## 4️⃣ Gmail Bağlantı

1. Panel açılınca: **📧 Gmail'e Bağlan**
2. Tarayıcıda Google login → İzin Ver
3. Token kaydediliyor, hazır!

## 5️⃣ Dosyaları İndir

1. **📧 Gmail & İndirme** → Aylar seç
2. **İndir** → ZIP dosya inecek
3. Panel'de: **✓ Toplu Seçim → Manuel Dosya Yükle**
4. **💾 Export**

---

## API Endpoints

- `GET /api/auth/url` - Gmail auth URL
- `GET /api/auth/callback?code=...` - OAuth callback
- `GET /api/gmail/status` - Bağlantı durumu
- `POST /api/gmail/download` - Dosyaları indir
- `GET /api/data/firmalar` - 35 firma listesi
- `GET /api/data/firma/:name` - Firma detayları
- `POST /api/export/excel` - Excel export

