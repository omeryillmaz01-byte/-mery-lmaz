// ==================== BATTAL PANEL - COMPLETE (Gmail + 35 Firma + Export) ====================
// muhasebe@bilpark.com hesabında deploy edilecek
// TEK PANEL - Gmail, Toplu Seçim, Export, Validasyon, hepsi bir yerde

const MONTHS = ['Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const OUTPUT_FOLDER_NAME = 'Battal-BankaEstresi-Otomatik';

// 35 Firma Veri Tabanı (embed)
const HESAP_PLANLARI = {
  "AKÇA AĞIZ": [{"kod":"102.01","ad":"GARANTİ VADESİZ TL HS."},{"kod":"102.02","ad":"AKBANK VADESİZ TL"},{"kod":"102.03","ad":"T.İŞ BANKASI VADESİZ TL"},{"kod":"102.04","ad":"VAKIFBANK VADESİZ TL HS."},{"kod":"102.05","ad":"GARANTİ VADESİZ TL HS."}],
  "2AA": [{"kod":"102.01","ad":"GARANTİ"},{"kod":"102.02","ad":"AKBANK"},{"kod":"102.03","ad":"T.İŞ"}],
  "BESA GIDA": Array(64).fill(0).map((_, i) => ({kod: `102.${String(i+1).padStart(2,'0')}`, ad: `BANKA ${i+1}`})),
  "BİLPARK BİLİŞİM": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"},{"kod":"102.03","ad":"BANKA3"}],
  "BILPARK YAZILIM": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "BODUR": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "BURAK CET ADİ ORT.": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"},{"kod":"102.03","ad":"BANKA3"}],
  "CET ENERJİ": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "DECOR PEOPLE": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "DTB YAZILIM": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"},{"kod":"102.03","ad":"BANKA3"}],
  "ERDA GÜMRÜK": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "ERDEM ÖZŞEN": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "ERLAMER": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "ESNI BİLİŞİM": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"},{"kod":"102.03","ad":"BANKA3"}],
  "GIZEM GÖKER ADİ ORT.": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "HACIKERIMOĞLU GIDA": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "HÜLYA HATUN": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "İSTANBUL PLASTİK": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "KARIYERKÜRE": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "KARMAKENT": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "KIRPI": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "KNA": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "MARMARAGES": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "MD": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "NEN": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "NES GÜZELLIK": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "OGUTMEN": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "OSNAK": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "SAMBAZ SUKUSU": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "SCF BİLİŞİM": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "SINAN YILMAZ": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "SSC GÜVENLİK": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "STS": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "SVI": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}],
  "İSIK PETROL": [{"kod":"102.01","ad":"BANKA1"},{"kod":"102.02","ad":"BANKA2"}]
};

// ==================== WEB APP ====================
function doGet(e) {
  return HtmlService.createHtmlOutput(getCompleteHTML()).setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

// ==================== COMPLETE HTML INTERFACE ====================
function getCompleteHTML() {
  return `
    <!DOCTYPE html>
    <html lang="tr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>🏦 Battal Panel - Complete</title>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { background: #0b1220; color: #e8eef5; font-family: system-ui; font-size: 14px; line-height: 1.6; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        header { background: linear-gradient(135deg, #111a2e, #1c2740); padding: 25px; border-radius: 12px; margin-bottom: 20px; border: 1px solid #26324a; }
        h1 { font-size: 28px; color: #60a5fa; margin-bottom: 5px; }
        .subtitle { color: #8fa0b8; font-size: 13px; }
        .badge { background: #22c55e; color: white; padding: 3px 8px; border-radius: 12px; font-size: 11px; display: inline-block; margin-left: 10px; }

        .tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #26324a; flex-wrap: wrap; }
        .tab-btn { background: transparent; border: none; color: #8fa0b8; padding: 12px 16px; cursor: pointer; font-size: 13px; font-weight: 600; border-bottom: 3px solid transparent; }
        .tab-btn.active { color: #60a5fa; border-bottom-color: #60a5fa; }

        .tab-content { display: none; }
        .tab-content.active { display: block; }

        .card { background: #131c2e; border: 1px solid #26324a; border-radius: 12px; padding: 20px; margin-bottom: 20px; }
        .card h2 { font-size: 16px; color: #60a5fa; margin-bottom: 15px; }
        .card h3 { font-size: 14px; color: #a0afc8; margin-top: 15px; margin-bottom: 10px; }

        .row { display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end; margin-bottom: 15px; }
        .field { flex: 1; min-width: 150px; }
        label { display: block; font-size: 11px; font-weight: 700; color: #8fa0b8; text-transform: uppercase; margin-bottom: 6px; }
        input, select { width: 100%; background: #1c2740; border: 1px solid #26324a; color: #e8eef5; border-radius: 6px; padding: 10px; font-size: 13px; }
        input:focus, select:focus { outline: none; border-color: #3b82f6; }

        button { background: #3b82f6; border: none; color: white; padding: 10px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 13px; }
        button:hover { background: #2563eb; }
        button.success { background: #22c55e; }
        button.success:hover { background: #16a34a; }
        button.danger { background: #ef4444; }

        .status { padding: 12px; border-radius: 8px; margin-bottom: 15px; font-size: 12px; }
        .status.ok { background: rgba(34,197,94,0.1); border-left: 3px solid #22c55e; color: #22c55e; }
        .status.error { background: rgba(239,68,68,0.1); border-left: 3px solid #ef4444; color: #ef4444; }

        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #26324a; }
        th { background: #1c2740; color: #8fa0b8; font-weight: 700; text-transform: uppercase; }
        tr:hover { background: #1f2d42; }

        .checkbox-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 8px; margin: 15px 0; }
        .checkbox-item { display: flex; align-items: center; padding: 8px; background: #1c2740; border-radius: 6px; border: 1px solid #26324a; cursor: pointer; font-size: 12px; }
        .checkbox-item:hover { border-color: #3b82f6; }
        .checkbox-item input { margin-right: 6px; }

        .progress-bar { width: 100%; background: #1c2740; height: 6px; border-radius: 6px; margin: 10px 0; overflow: hidden; }
        .progress-fill { background: #22c55e; height: 100%; width: 0%; transition: width 0.3s; }

        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 10px; margin: 15px 0; }
        .stat-box { background: #1c2740; border: 1px solid #26324a; border-radius: 6px; padding: 12px; text-align: center; }
        .stat-value { font-size: 20px; font-weight: 700; color: #60a5fa; }
        .stat-label { font-size: 10px; color: #8fa0b8; text-transform: uppercase; margin-top: 5px; }
      </style>
    </head>
    <body>
      <div class="container">
        <header>
          <h1>🏦 Battal Panel Complete <span class="badge">✓ ALL-IN-ONE</span></h1>
          <div class="subtitle">Gmail otomatik + 35 Firma + Export + Toplu İşlem — Tüm özellikler BİR panel'de</div>
        </header>

        <div class="tabs">
          <button class="tab-btn active" onclick="switchTab(event, 'gmail')">📧 Gmail İndir</button>
          <button class="tab-btn" onclick="switchTab(event, 'firmalar')">✓ Firmalar</button>
          <button class="tab-btn" onclick="switchTab(event, 'export')">📊 Export</button>
          <button class="tab-btn" onclick="switchTab(event, 'ayarlar')">⚙️ Ayarlar</button>
        </div>

        <!-- TAB 1: Gmail İndir -->
        <div id="gmail" class="tab-content active">
          <div class="card">
            <h2>📧 Gmail'den Dosyaları İndir</h2>

            <div class="status ok">
              ✅ Sistem hazır - muhasebe@bilpark.com'dan dosyaları otomatik çek
            </div>

            <h3>📅 İndirilecek Aylar</h3>
            <div class="checkbox-grid" id="monthGrid"></div>

            <button onclick="downloadAllFiles()" class="success" style="width: 100%; padding: 15px; font-size: 14px; margin-top: 20px;">
              ⬇️ BAŞLAT: Tüm Dosyaları İndir
            </button>

            <div id="progress" style="display: none; margin-top: 20px;">
              <div style="color: #8fa0b8; margin-bottom: 10px;"><strong>İndirme devam ediyor...</strong></div>
              <div class="progress-bar">
                <div class="progress-fill" id="progressBar"></div>
              </div>
              <div id="progressText" style="font-size: 12px; color: #8fa0b8; margin-top: 5px;">-</div>
            </div>

            <h3 style="margin-top: 30px;">📥 İndirilen Dosyalar</h3>
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
                <tr><td colspan="5" style="text-align: center; color: #8fa0b8;">Henüz dosya yüklenmedi</td></tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- TAB 2: Firmalar -->
        <div id="firmalar" class="tab-content">
          <div class="card">
            <h2>✓ Firma Seçimi & Toplu İşlem</h2>

            <div class="row">
              <button onclick="selectAllFirmas()" class="success">✓ Tümünü Seç</button>
              <button onclick="clearAllFirmas()" class="danger">✗ Temizle</button>
            </div>

            <div style="margin: 15px 0;">
              <input type="text" placeholder="🔍 Firma ara..." onkeyup="filterFirmas(this.value)">
            </div>

            <div class="checkbox-grid" id="firmaGrid"></div>

            <div class="stats-grid">
              <div class="stat-box">
                <div class="stat-value" id="selectedCount">0</div>
                <div class="stat-label">Seçili</div>
              </div>
              <div class="stat-box">
                <div class="stat-value" id="totalAccounts">0</div>
                <div class="stat-label">Hesap</div>
              </div>
              <div class="stat-box">
                <div class="stat-value" id="totalBanks">0</div>
                <div class="stat-label">Banka</div>
              </div>
            </div>
          </div>
        </div>

        <!-- TAB 3: Export -->
        <div id="export" class="tab-content">
          <div class="card">
            <h2>📊 Export - Excel / PDF / CSV</h2>

            <div class="row">
              <div class="field">
                <label>Format Seç</label>
                <select id="exportFormat">
                  <option value="excel">📊 Excel Dosyası</option>
                  <option value="csv">📋 CSV Dosyası</option>
                  <option value="json">⚙️ JSON Veri</option>
                </select>
              </div>
            </div>

            <button onclick="exportData()" class="success" style="width: 100%; padding: 12px; margin-top: 15px;">
              💾 Export Yap
            </button>

            <div id="exportStatus" style="display: none; margin-top: 15px; padding: 12px; background: #1c2740; border-left: 3px solid #22c55e; border-radius: 6px; color: #22c55e;">
              ✅ Export tamamlandı! Dosya indirildi.
            </div>
          </div>
        </div>

        <!-- TAB 4: Ayarlar -->
        <div id="ayarlar" class="tab-content">
          <div class="card">
            <h2>⚙️ Ayarlar & Bilgiler</h2>

            <table>
              <tr>
                <td style="color: #8fa0b8; font-weight: 700;">Versiyon</td>
                <td><strong>Complete (All-in-One)</strong></td>
              </tr>
              <tr>
                <td style="color: #8fa0b8; font-weight: 700;">Gmail Hesabı</td>
                <td><strong>muhasebe@bilpark.com</strong></td>
              </tr>
              <tr>
                <td style="color: #8fa0b8; font-weight: 700;">Firmalar</td>
                <td><strong id="totalFirmas">35</strong></td>
              </tr>
              <tr>
                <td style="color: #8fa0b8; font-weight: 700;">Özellikler</td>
                <td><strong>✅ Gmail + Firmalar + Export + Toplu</strong></td>
              </tr>
            </table>

            <div style="margin-top: 20px; padding: 12px; background: #1c2740; border-left: 3px solid #60a5fa; border-radius: 6px; color: #8fa0b8; font-size: 12px;">
              <strong>ℹ️ TEK PANEL:</strong><br>
              ✓ Gmail'den 26+ dosya otomatik indir<br>
              ✓ 35 firma veritabanı<br>
              ✓ Toplu seçim & yönetim<br>
              ✓ Excel/CSV export<br>
              ✓ Arama filtreleme
            </div>
          </div>
        </div>
      </div>

      <script>
        const HESAP_PLANLARI = ${JSON.stringify(HESAP_PLANLARI)};
        const MONTHS = ['Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
        let selectedFirmas = new Set();
        let downloadedFiles = [];

        function switchTab(event, tab) {
          event.target.classList.add('active');
          document.querySelectorAll('.tab-btn').forEach(btn => {
            if (btn !== event.target) btn.classList.remove('active');
          });
          document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
          document.getElementById(tab).classList.add('active');
        }

        // ==================== GMAIL ====================
        function initMonths() {
          const grid = document.getElementById('monthGrid');
          MONTHS.forEach(month => {
            const label = document.createElement('label');
            label.className = 'checkbox-item';
            label.innerHTML = \`<input type="checkbox" value="\${month}" checked> \${month}\`;
            grid.appendChild(label);
          });
        }

        function downloadAllFiles() {
          const selected = Array.from(document.querySelectorAll('#monthGrid input:checked')).map(cb => cb.value);
          if (selected.length === 0) {
            alert('En az bir ay seçin');
            return;
          }

          document.getElementById('progress').style.display = 'block';
          google.script.run.withSuccessHandler(showDownloadResults).downloadAllFilesServer(selected);
        }

        function showDownloadResults(result) {
          document.getElementById('progress').style.display = 'none';

          if (result.success) {
            const tbody = document.getElementById('filesList');
            tbody.innerHTML = result.files.map(f => \`
              <tr>
                <td>\${f.month}</td>
                <td>\${f.name}</td>
                <td>\${f.size}</td>
                <td>\${f.date}</td>
                <td style="color: #22c55e;">✓</td>
              </tr>
            \`).join('');
          } else {
            alert('Hata: ' + result.error);
          }
        }

        // ==================== FIRMALAR ====================
        function initFirmas() {
          const grid = document.getElementById('firmaGrid');
          const firmas = Object.keys(HESAP_PLANLARI).sort();

          grid.innerHTML = firmas.map(f => \`
            <label class="checkbox-item">
              <input type="checkbox" value="\${f}" onchange="updateStats()">
              \${f}
            </label>
          \`).join('');

          document.getElementById('totalFirmas').textContent = firmas.length;
        }

        function filterFirmas(search) {
          document.querySelectorAll('#firmaGrid .checkbox-item').forEach(item => {
            item.style.display = item.textContent.toLowerCase().includes(search.toLowerCase()) ? 'flex' : 'none';
          });
        }

        function selectAllFirmas() {
          document.querySelectorAll('#firmaGrid input').forEach(cb => cb.checked = true);
          updateStats();
        }

        function clearAllFirmas() {
          document.querySelectorAll('#firmaGrid input').forEach(cb => cb.checked = false);
          updateStats();
        }

        function updateStats() {
          const checked = document.querySelectorAll('#firmaGrid input:checked');
          selectedFirmas.clear();
          let totalAccounts = 0;
          let totalBanks = 0;

          checked.forEach(cb => {
            const firma = cb.value;
            selectedFirmas.add(firma);
            const accounts = HESAP_PLANLARI[firma];
            if (accounts) {
              totalAccounts += accounts.length;
              totalBanks += accounts.filter(h => /^102\\.\\d+$/.test(h.kod)).length;
            }
          });

          document.getElementById('selectedCount').textContent = checked.length;
          document.getElementById('totalAccounts').textContent = totalAccounts;
          document.getElementById('totalBanks').textContent = totalBanks;
        }

        // ==================== EXPORT ====================
        function exportData() {
          const format = document.getElementById('exportFormat').value;

          if (selectedFirmas.size === 0) {
            alert('En az bir firma seç');
            return;
          }

          const data = [];
          selectedFirmas.forEach(firma => {
            const accounts = HESAP_PLANLARI[firma];
            const banks = accounts.filter(h => /^102\\.\\d+$/.test(h.kod)).length;
            data.push({ firma, hesaplar: accounts.length, bankalar: banks });
          });

          if (format === 'excel') {
            const ws = XLSX.utils.json_to_sheet(data);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Firmalar');
            XLSX.writeFile(wb, \`export-\${new Date().toISOString().slice(0,10)}.xlsx\`);
          } else if (format === 'csv') {
            let csv = 'Firma,Hesap,Banka\\n';
            data.forEach(item => csv += \`"\${item.firma}",\${item.hesaplar},\${item.bankalar}\\n\`);
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = \`export-\${new Date().toISOString().slice(0,10)}.csv\`;
            a.click();
          } else if (format === 'json') {
            const json = {};
            selectedFirmas.forEach(f => json[f] = HESAP_PLANLARI[f]);
            const blob = new Blob([JSON.stringify(json, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = \`export-\${new Date().toISOString().slice(0,10)}.json\`;
            a.click();
          }

          document.getElementById('exportStatus').style.display = 'block';
          setTimeout(() => document.getElementById('exportStatus').style.display = 'none', 3000);
        }

        // ==================== INIT ====================
        window.addEventListener('load', () => {
          initMonths();
          initFirmas();
        });
      </script>
    </body>
    </html>
  `;
}

// ==================== SERVER FUNCTIONS ====================
function downloadAllFilesServer(months) {
  try {
    let outputFolder = findOrCreateFolder(OUTPUT_FOLDER_NAME);
    const files = [];
    let totalCount = 0;

    months.forEach(monthName => {
      const gmail = GmailApp;
      const labels = gmail.getUserLabels();
      let label = null;

      labels.forEach(l => {
        const name = l.getName().toLowerCase();
        if (name.includes(monthName.toLowerCase()) || name === monthName + ' Bankaları') {
          label = l;
        }
      });

      if (!label) return;

      const threads = gmail.search(\`label:\${label.getName()}\`);

      threads.forEach(thread => {
        const messages = thread.getMessages();
        messages.forEach(message => {
          const attachments = message.getAttachments();
          attachments.forEach(attachment => {
            const fileName = attachment.getName();
            if (fileName.endsWith('.csv') || fileName.endsWith('.xlsx')) {
              try {
                const blob = attachment;
                const size = blob.getBytes().length;
                const newFile = outputFolder.createFile(blob);
                newFile.setName(\`\${monthName}_\${fileName}\`);

                files.push({
                  month: monthName,
                  name: fileName,
                  size: formatBytes(size),
                  date: new Date().toLocaleDateString('tr-TR')
                });

                totalCount++;
              } catch (e) {
                Logger.log('Hata: ' + e.message);
              }
            }
          });
        });
      });
    });

    return { success: true, total: totalCount, files: files };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

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
