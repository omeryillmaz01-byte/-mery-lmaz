#!/usr/bin/env node
/**
 * 📧 GMAIL BANKA EKSTRELERI HELPER
 * Desktop/banka-haziran'daki dosyaları organize eder
 * Panele yüklemek için hazırlar
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const HOME = os.homedir();
const BANKA_DIR = path.join(HOME, 'Desktop', 'banka-haziran');
const OUTPUT_DIR = path.join(HOME, 'Desktop', 'banka-ready');

const log = {
  info: msg => console.log('ℹ️  ' + msg),
  ok: msg => console.log('✅ ' + msg),
  err: msg => console.log('❌ ' + msg),
  title: msg => console.log('\n📧 ' + msg + '\n' + '═'.repeat(60))
};

// Firmalar listesi
const FIRMALAR = ['ISIK_PETROL','2AA','AKÇA AĞIZ','BESA GIDA','BILPARK BILIŞIM','BİLPARK YAZILIM','BODUR','BURAK CET ADİ ORT.','CET ENERJİ','DECOR PEOPLE','DTB YAZILIM','ERDA GÜMRÜK','ERDEM ÖZŞEN','ERLAMER','ESNI BILIŞIM','GIZEM GÖKER ADİ ORT.','HACIKERIMOĞLU GIDA','HÜLYA HATUN','İSTANBUL PLASTİK','KARIYERKÜRE','KARMAKENT','KIRPI','KNA','MARMARAGES','MD','NEN','NES GÜZELLIK','OGUTMEN','OSNAK','SAMBAZ SUKUSU','SCF BILIŞIM','SINAN YILMAZ','SSC GÜVENLİK','STS','SVI'];

const BANKALAR = {
  'GARANTI': '130009445',
  'AKBANK': '148415',
  'ISHBANK': '3003 86',
  'VAKIFBANK': '674408',
  'ZIRAAT': '1234567',
  'SEKERBANK': '130009445',
  'DENIZBANK': '999999'
};

function bulFirma(filename) {
  const fn = filename.toLocaleUpperCase('tr');
  for(let firma of FIRMALAR) {
    const norm = firma.toLocaleUpperCase('tr').replace(/[^\w]/g, '');
    if(fn.includes(norm)) return firma;
  }
  return null;
}

function bulBanka(filename) {
  const fn = filename.toLocaleUpperCase('tr');
  for(let [banka, hesap] of Object.entries(BANKALAR)) {
    if(fn.includes(banka)) return {banka, hesap};
  }
  return {banka: 'BANKA', hesap: '000000'};
}

function organize() {
  log.title('GMAIL BANKA EKSTRELERI ORGANIZE');

  if(!fs.existsSync(BANKA_DIR)) {
    log.err(`${BANKA_DIR} klasörü yok!`);
    log.info('Gmail\'den indir: Desktop/banka-haziran/ klasörüne koy');
    process.exit(1);
  }

  if(!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, {recursive: true});
  }

  const files = fs.readdirSync(BANKA_DIR).filter(f => /\.(xlsx|xls|pdf|csv)$/i.test(f));

  if(!files.length) {
    log.err('Dosya bulunamadı!');
    return;
  }

  log.ok(`${files.length} dosya bulundu`);

  const byFirma = {};

  for(let file of files) {
    const firma = bulFirma(file) || 'BILINMEYEN';
    const {banka, hesap} = bulBanka(file);
    const newName = `${firma}-${banka}(${hesap})${path.extname(file)}`;

    if(!byFirma[firma]) byFirma[firma] = [];
    byFirma[firma].push({old: file, new: newName});

    const src = path.join(BANKA_DIR, file);
    const dst = path.join(OUTPUT_DIR, newName);
    fs.copyFileSync(src, dst);

    log.ok(`${file} → ${newName}`);
  }

  log.title('ÖZET');
  for(let [firma, dosyalar] of Object.entries(byFirma)) {
    console.log(`\n📄 ${firma}: ${dosyalar.length} dosya`);
    dosyalar.forEach(d => console.log(`   ├─ ${d.new}`));
  }

  log.title('SONUÇ');
  log.ok(`Tüm dosyalar ${OUTPUT_DIR} klasörüne kopyalandı`);
  log.info('Şimdi paneli aç ve bu dosyaları "Ekstre Yükle" alanına sürükle-bırak yap!');
  log.info('Panel otomatik hepsini kodlayıp Export edecek.');
}

organize();
