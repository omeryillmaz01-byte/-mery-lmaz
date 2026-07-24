// ==================== BATTAL PANEL - GMAIL OTOMATIK ÇEKİCİ ====================
// muhasebe@bilpark.com hesabında deploy edilecek
// Gmail'deki Haziran, Temmuz, vb klasörlerden dosyaları otomatik indir
// Her ay 1. günü 00:00'de otomatik çalışır

const MONTHS = ['Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const OUTPUT_FOLDER_NAME = 'Battal-BankaEstresi-Otomatik';

// ==================== WEB APP INTERFACE ====================
function doGet(e) {
  const action = e.parameter.action || 'main';

  if (action === 'download') {
    return downloadFilesWebApp(e.parameter.months);
  } else if (action === 'status') {
    return getStatusWebApp();
  } else if (action === 'list') {
    return getFileListWebApp(e.parameter.month);
  } else {
    return HtmlService.createHtmlOutput(getMainHTML());
  }
}

// ==================== ANA INTERFACE ====================
function getMainHTML() {
  return `
    <!DOCTYPE html>
    <html lang="tr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>🏦 Battal - Gmail Otomatik Çekici</title>
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { background: #0b1220; color: #e8eef5; font-family: system-ui; padding: 20px; }
        .container { max-width: 900px; margin: 0 auto; }
        header { background: linear-gradient(135deg, #111a2e, #1c2740); padding: 20px; border-radius: 12px; margin-bottom: 20px; border: 1px solid #26324a; }
        h1 { color: #60a5fa; margin-bottom: 5px; }
        .subtitle { color: #8fa0b8; font-size: 13px; }
        .card { background: #131c2e; border: 1px solid #26324a; border-radius: 12px; padding: 20px; margin-bottom: 20px; }
        .card h2 { color: #60a5fa; margin-bottom: 15px; font-size: 16px; }
        button { background: #3b82f6; color: white; border: none; padding: 12px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }
        button:hover { background: #2563eb; }
        button.success { background: #22c55e; }
        button.success:hover { background: #16a34a; }
        .status { padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 13px; }
        .status.ok { background: rgba(34,197,94,0.1); border: 1px solid #22c55e; color: #22c55e; }
        .status.error { background: rgba(239,68,68,0.1); border: 1px solid #ef4444; color: #ef4444; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #26324a; }
        th { background: #1c2740; color: #8fa0b8; font-weight: 700; text-transform: uppercase; font-size: 11px; }
        .checkbox-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin: 15px 0; }
        .checkbox-item { display: flex; align-items: center; padding: 10px; background: #1c2740; border-radius: 6px; border: 1px solid #26324a; cursor: pointer; }
        .checkbox-item input { margin-right: 8px; }
        .progress-bar { width: 100%; background: #1c2740; height: 6px; border-radius: 6px; margin: 10px 0; overflow: hidden; }
        .progress-fill { background: #22c55e; height: 100%; width: 0%; transition: width 0.3s; }
        .info { background: #1c2740; border-left: 3px solid #60a5fa; padding: 12px; border-radius: 6px; margin: 10px 0; color: #8fa0b8; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <header>
          <h1>🏦 Battal - Gmail Otomatik Çekici</h1>
          <div class="subtitle">muhasebe@bilpark.com'dan Haziran-Aralık dosyalarını otomatik çek</div>
        </header>

        <div class="card">
          <h2>⚡ Dosyaları İndir</h2>

          <div id="status" class="status ok">
            ✅ Sistem hazır. İndirilecek ayları seç.
          </div>

          <h3 style="margin-bottom: 10px;">📅 Aylar</h3>
          <div class="checkbox-grid" id="monthsGrid"></div>

          <button onclick="downloadAll()" class="success" style="width: 100%; padding: 15px; font-size: 14px; margin-top: 20px;">
            ⬇️ BAŞLAT: Tüm Dosyaları İndir
          </button>

          <div id="progress" style="display: none; margin-top: 20px;">
            <div style="color: #8fa0b8; margin-bottom: 10px;">İndirme devam ediyor...</div>
            <div class="progress-bar">
              <div class="progress-fill" id="progressBar"></div>
            </div>
            <div id="progressText" style="font-size: 12px; color: #8fa0b8; margin-top: 5px;">-</div>
          </div>
        </div>

        <div class="card">
          <h2>📥 İndirilen Dosyalar</h2>
          <table>
            <thead>
              <tr>
                <th>Ay</th>
                <th>Dosya Adı</th>
                <th>Boyut</th>
                <th>Tarih</th>
                <th>Durum</th>
              </tr>
            </thead>
            <tbody id="filesList">
              <tr>
                <td colspan="5" style="text-align: center; color: #8fa0b8;">Henüz dosya yüklenmedi</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="info">
          <strong>💡 Nasıl Çalışıyor:</strong><br>
          1. İndirilecek ayları seç<br>
          2. BAŞLAT butonuna tıkla<br>
          3. Gmail'deki klasörlerden CSV/XLSX dosyaları otomatik indir<br>
          4. Google Drive'a kaydet<br>
          5. Tabloda göster<br>
          6. Panel'de kullan
        </div>

        <div class="info" style="border-left-color: #ef4444; color: #ef4444;">
          <strong>⚠️ Önemli:</strong><br>
          - Gmail klasörleri "Haziran", "Temmuz" vb isimlerinde olmalı<br>
          - CSV ve XLSX dosyaları otomatik algılanır<br>
          - Sonuç Google Drive'da kaydedilir
        </div>
      </div>

      <script>
        // Ayları göster
        const months = ['Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
        const grid = document.getElementById('monthsGrid');
        months.forEach(month => {
          const label = document.createElement('label');
          label.className = 'checkbox-item';
          label.innerHTML = \`<input type="checkbox" value="\${month}" checked> \${month}\`;
          grid.appendChild(label);
        });

        function downloadAll() {
          const selected = Array.from(document.querySelectorAll('input:checked')).map(cb => cb.value);
          if (selected.length === 0) {
            alert('En az bir ay seç');
            return;
          }

          document.getElementById('progress').style.display = 'block';

          google.script.run.withSuccessHandler(showResults).downloadAllFiles(selected);
        }

        function showResults(result) {
          document.getElementById('progress').style.display = 'none';

          if (result.success) {
            document.getElementById('status').className = 'status ok';
            document.getElementById('status').innerHTML = \`✅ Tamamlandı! <strong>\${result.total}</strong> dosya indirildi.\`;

            const tbody = document.getElementById('filesList');
            tbody.innerHTML = result.files.map(file => \`
              <tr>
                <td>\${file.month}</td>
                <td>\${file.name}</td>
                <td>\${file.size}</td>
                <td>\${file.date}</td>
                <td style="color: #22c55e;">✓</td>
              </tr>
            \`).join('');
          } else {
            document.getElementById('status').className = 'status error';
            document.getElementById('status').innerHTML = \`❌ Hata: \${result.error}\`;
          }
        }
      </script>
    </body>
    </html>
  `;
}

// ==================== DOSYA İNDİRME FONKSİYONU ====================
function downloadAllFiles(months) {
  try {
    let outputFolder = findOrCreateFolder(OUTPUT_FOLDER_NAME);
    const files = [];
    let totalCount = 0;

    // Her ay için
    months.forEach(monthName => {
      const gmail = GmailApp;

      // Gmail'de klasörü bul (Label)
      const labels = gmail.getUserLabels();
      let label = null;

      labels.forEach(l => {
        const name = l.getName().toLowerCase();
        if (name.includes(monthName.toLowerCase()) || name === monthName + ' Bankaları') {
          label = l;
        }
      });

      if (!label) {
        Logger.log(`⚠️  Label bulunamadı: ${monthName}`);
        return;
      }

      // Label'daki thread'leri al
      const threads = gmail.search(`label:${label.getName()}`);
      Logger.log(`📧 ${monthName}: ${threads.length} thread bulundu`);

      threads.forEach(thread => {
        const messages = thread.getMessages();

        messages.forEach(message => {
          const attachments = message.getAttachments();

          attachments.forEach(attachment => {
            const fileName = attachment.getName();

            // CSV ve XLSX dosyalarını indir
            if (fileName.endsWith('.csv') || fileName.endsWith('.xlsx')) {
              try {
                const blob = attachment;
                const size = blob.getBytes().length;

                // Google Drive'a kaydet
                const newFile = outputFolder.createFile(blob);
                newFile.setName(`${monthName}_${fileName}`);

                files.push({
                  month: monthName,
                  name: fileName,
                  size: formatBytes(size),
                  date: new Date().toLocaleDateString('tr-TR'),
                  file: newFile
                });

                totalCount++;
                Logger.log(`✅ ${monthName}_${fileName} indirildi`);
              } catch (e) {
                Logger.log(`❌ Dosya indirilemedi: ${e.message}`);
              }
            }
          });
        });
      });
    });

    return {
      success: true,
      total: totalCount,
      files: files
    };

  } catch (error) {
    Logger.log(`❌ Hata: ${error.message}`);
    return {
      success: false,
      error: error.message
    };
  }
}

// ==================== YARDIMCI FONKSİYONLAR ====================
function findOrCreateFolder(folderName) {
  const folders = DriveApp.getFoldersByName(folderName);
  return folders.hasNext() ? folders.next() : DriveApp.getRootFolder().createFolder(folderName);
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

// ==================== SCHEDULED TRIGGER ====================
function setupAutoDownload() {
  // Mevcut trigger'ları sil
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach(t => {
    if (t.getHandlerFunction() === 'autoDownloadMonthly') {
      ScriptApp.deleteTrigger(t);
    }
  });

  // Her ayın 1. günü 00:00'da çalış
  ScriptApp.newTrigger('autoDownloadMonthly')
    .timeBased()
    .onMonthDay(1)
    .atHour(0)
    .create();

  Logger.log('✅ Otomatik trigger kuruldu: Ayın 1. günü 00:00');
}

function autoDownloadMonthly() {
  const today = new Date();
  // Sadece ayın 1-2. günü çalışsın
  if (today.getDate() <= 2) {
    downloadAllFiles(MONTHS);
  }
}

// ==================== MANUAL TEST ====================
function testDownload() {
  const result = downloadAllFiles(['Haziran', 'Temmuz']);
  Logger.log('Test Sonucu:');
  Logger.log(result);
}
