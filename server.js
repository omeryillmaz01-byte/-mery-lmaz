const express = require('express');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ==================== GMAIL API SETUP ====================
const SCOPES = ['https://www.googleapis.com/auth/gmail.readonly'];
const TOKEN_PATH = 'token.json';
const CREDENTIALS_PATH = 'credentials.json';

let oauth2Client = null;

function authorize() {
  const credentials = require('./credentials.json');
  const { client_id, client_secret, redirect_uris } = credentials.installed;

  oauth2Client = new google.auth.OAuth2(
    client_id,
    client_secret,
    redirect_uris[0]
  );

  // Token varsa yükle
  if (fs.existsSync(TOKEN_PATH)) {
    const token = JSON.parse(fs.readFileSync(TOKEN_PATH));
    oauth2Client.setCredentials(token);
  }

  return oauth2Client;
}

// ==================== AUTH ROUTES ====================
app.get('/api/auth/url', (req, res) => {
  if (!oauth2Client) authorize();

  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES,
  });

  res.json({ authUrl });
});

app.get('/api/auth/callback', async (req, res) => {
  const code = req.query.code;
  if (!code) return res.status(400).json({ error: 'No code' });

  try {
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    // Token'ı kaydet
    fs.writeFileSync(TOKEN_PATH, JSON.stringify(tokens));

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== GMAIL İŞLEMLERİ ====================
app.get('/api/gmail/status', (req, res) => {
  const connected = fs.existsSync(TOKEN_PATH);
  res.json({ connected });
});

app.post('/api/gmail/download', async (req, res) => {
  const { months } = req.body;

  if (!oauth2Client) authorize();
  if (!fs.existsSync(TOKEN_PATH)) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  try {
    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });
    const files = [];

    // Her ay için labels'ı bul ve dosyaları indir
    for (const month of months) {
      const labels = await gmail.users.labels.list({ userId: 'me' });
      const label = labels.data.labels.find(l =>
        l.name.toLowerCase().includes(month.toLowerCase()) ||
        l.name === month + ' Bankaları'
      );

      if (!label) continue;

      // Label'daki mesajları getir
      const messages = await gmail.users.messages.list({
        userId: 'me',
        q: `label:${label.id} filename:(csv OR xlsx)`
      });

      if (!messages.data.messages) continue;

      // Her message'deki attachment'ları indir
      for (const message of messages.data.messages) {
        const msg = await gmail.users.messages.get({
          userId: 'me',
          id: message.id,
          format: 'full'
        });

        const parts = msg.data.payload.parts || [];
        for (const part of parts) {
          if (part.filename && (part.filename.endsWith('.csv') || part.filename.endsWith('.xlsx'))) {
            const attachment = await gmail.users.messages.attachments.get({
              userId: 'me',
              messageId: message.id,
              id: part.body.attachmentId
            });

            files.push({
              name: part.filename,
              data: attachment.data,
              month: month
            });
          }
        }
      }
    }

    res.json({
      success: true,
      count: files.count,
      files: files.map(f => ({ name: f.name, month: f.month }))
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== BANKA VERİLERİ ====================
app.get('/api/data/firmalar', (req, res) => {
  const HESAP_PLANLARI = require('./hesap-planlari-TAM.json');
  const firmalar = Object.keys(HESAP_PLANLARI).sort();

  res.json({
    firmalar,
    count: firmalar.length
  });
});

app.get('/api/data/firma/:name', (req, res) => {
  const HESAP_PLANLARI = require('./hesap-planlari-TAM.json');
  const firma = HESAP_PLANLARI[decodeURIComponent(req.params.name)];

  if (!firma) return res.status(404).json({ error: 'Firma not found' });

  const banklar = firma.filter(h => /^102\.\d+$/.test(h.kod));

  res.json({
    firma: req.params.name,
    toplam_hesap: firma.length,
    banka_hesaplari: banklar.length,
    hesaplar: firma
  });
});

// ==================== EXPORT ====================
app.post('/api/export/excel', (req, res) => {
  const { firmalar } = req.body;
  const HESAP_PLANLARI = require('./hesap-planlari-TAM.json');

  const XLSX = require('xlsx');
  const workbook = XLSX.utils.book_new();
  const data = [];

  firmalar.forEach(firma => {
    const accounts = HESAP_PLANLARI[firma];
    if (accounts) {
      const banklar = accounts.filter(h => /^102\.\d+$/.test(h.kod));
      data.push({
        'Firma': firma,
        'Toplam Hesap': accounts.length,
        'Banka Hesapları': banklar.length
      });
    }
  });

  const ws = XLSX.utils.json_to_sheet(data);
  XLSX.utils.book_append_sheet(workbook, ws, 'Firmalar');

  const filename = `export-${new Date().toISOString().slice(0,10)}.xlsx`;
  XLSX.writeFile(workbook, filename);

  res.download(filename);
});

// ==================== SERVER START ====================
const PORT = process.env.PORT || 3000;

try {
  authorize();
  console.log('✅ Gmail API başlatıldı');
} catch (error) {
  console.log('⚠️  Gmail API hazırlanması başarısız. Credentials kontrol edin.');
}

app.listen(PORT, () => {
  console.log(`🚀 Server çalışıyor: http://localhost:${PORT}`);
  console.log(`📧 Gmail Auth: http://localhost:${PORT}/api/auth/url`);
});
