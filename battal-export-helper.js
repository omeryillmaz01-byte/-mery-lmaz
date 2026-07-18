#!/usr/bin/env node
/**
 * 🚀 BATTAL EXPORT HELPER
 * Desktop/battal-export klasörüne indirilmiş Excel dosyalarını otomatik hareket ettirir
 *
 * Kullanım:
 *   node battal-export-helper.js
 *
 * Bu script:
 * 1. Downloads klasörünü izler (mikro-*.xlsx ve mikro-*.csv dosyaları)
 * 2. Desktop/battal-export klasörünü oluşturur (yoksa)
 * 3. Yeni dosyaları otomatik olarak taşır
 * 4. Konsolda ilerleme gösterir
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const HOME = os.homedir();
const DOWNLOADS = path.join(HOME, 'Downloads');
const DESKTOP = path.join(HOME, 'Desktop');
const EXPORT_FOLDER = path.join(DESKTOP, 'battal-export');

// Renkli konsol çıktısı
const log = {
  info: msg => console.log('ℹ️  ' + msg),
  ok: msg => console.log('✅ ' + msg),
  warn: msg => console.log('⚠️  ' + msg),
  err: msg => console.log('❌ ' + msg),
  title: msg => console.log('\n📂 ' + msg + '\n' + '═'.repeat(60))
};

// battal-export klasörünü oluştur
function ensureFolder() {
  if (!fs.existsSync(EXPORT_FOLDER)) {
    try {
      fs.mkdirSync(EXPORT_FOLDER, { recursive: true });
      log.ok(`Klasör oluşturuldu: ${EXPORT_FOLDER}`);
    } catch (err) {
      log.err(`Klasör oluşturulamadı: ${err.message}`);
      process.exit(1);
    }
  } else {
    log.info(`Klasör zaten var: ${EXPORT_FOLDER}`);
  }
}

// Dosya taşı
function moveFile(filename, src, dest) {
  try {
    const srcPath = path.join(src, filename);
    const destPath = path.join(dest, filename);

    // Hedef dosya varsa yeniden adlandır
    let finalPath = destPath;
    if (fs.existsSync(destPath)) {
      const ext = path.extname(filename);
      const base = path.basename(filename, ext);
      const timestamp = new Date().toISOString().slice(0, 19).replace(/:/g, '-');
      finalPath = path.join(dest, `${base}-${timestamp}${ext}`);
      log.warn(`Aynı ad var, yeniden adlandırıldı: ${path.basename(finalPath)}`);
    }

    fs.renameSync(srcPath, finalPath);
    log.ok(`Taşındı: ${filename}`);
    return true;
  } catch (err) {
    log.err(`Taşınamadı (${filename}): ${err.message}`);
    return false;
  }
}

// Downloads klasörünü izle
function watchDownloads() {
  log.title('📥 Downloads izleniyor...');
  log.info(`Klasör: ${DOWNLOADS}`);
  log.info(`Hedef: ${EXPORT_FOLDER}`);
  log.info(`Arayan: mikro-*.xlsx, mikro-*.csv`);
  log.info('Durumu kontrol etmek için Ctrl+C tuşu ile çık\n');

  const watcher = fs.watch(DOWNLOADS, (eventType, filename) => {
    if (!filename) return;

    // Sadece mikro- ile başlayanları al
    if (!filename.startsWith('mikro-')) return;
    if (!filename.match(/\.(xlsx|xls|csv)$/i)) return;

    const srcPath = path.join(DOWNLOADS, filename);

    // Dosya tamamen yazıldığını kontrol et (500ms sonra)
    setTimeout(() => {
      try {
        const stat = fs.statSync(srcPath);
        if (stat.isFile() && stat.size > 0) {
          log.info(`Bulundu: ${filename} (${formatSize(stat.size)})`);
          moveFile(filename, DOWNLOADS, EXPORT_FOLDER);
        }
      } catch (err) {
        // Dosya silinmiş veya hareket ettirilmiş
      }
    }, 500);
  });

  watcher.on('error', err => {
    log.err(`İzleme hatası: ${err.message}`);
  });

  // Başlangıçta mevcut dosyaları kontrol et
  try {
    const files = fs.readdirSync(DOWNLOADS);
    const existing = files.filter(
      f => f.startsWith('mikro-') && f.match(/\.(xlsx|xls|csv)$/i)
    );

    if (existing.length > 0) {
      log.info(`Mevcut dosyalar bulundu (${existing.length}), taşınıyor...`);
      existing.forEach(filename => {
        const srcPath = path.join(DOWNLOADS, filename);
        const stat = fs.statSync(srcPath);
        if (stat.isFile()) {
          log.info(`Bulundu: ${filename} (${formatSize(stat.size)})`);
          moveFile(filename, DOWNLOADS, EXPORT_FOLDER);
        }
      });
    } else {
      log.info('Mevcut dosya yok, yeni dosyalar bekleniyor...');
    }
  } catch (err) {
    log.err(`Klasör okunamadı: ${err.message}`);
  }

  return watcher;
}

function formatSize(bytes) {
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// Başlat
log.title('🚀 BATTAL EXPORT HELPER');
log.info(`Sistem: ${os.platform()} ${os.arch()}`);
log.info(`Node: ${process.version}`);
log.info(`Kullanıcı: ${process.env.USER || process.env.USERNAME || 'bilinmiyor'}`);

ensureFolder();
const watcher = watchDownloads();

// Graceful shutdown
process.on('SIGINT', () => {
  log.title('Durdurma...');
  watcher.close();
  log.ok('Helper durduruldu.');
  process.exit(0);
});

process.on('SIGTERM', () => {
  watcher.close();
  process.exit(0);
});
