const fs = require('fs');
const path = __dirname;

const panelFiles = [
  'KGK-Sinav-Paneli.html',
  'KGK-FuatHoca-Panel.html',
  'Soru-Paneli.html',
  'SAGLIK-SPOR-DIYET-PANEL_v3.html',
  'KISISEL-GELISIM-PANEL.html',
  'INGILIZCE-OGRENIYORUM.html',
  'MUHASEBE-PANEL.html',
  'KISISEL-BILGILER-PANEL.html',
];

function escapeForTemplateLiteral(s) {
  return s.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\$\{/g, '\\${').replace(/<\/script>/gi, '<\\/script>');
}

let template = fs.readFileSync(path + '/OMER-YILMAZ.template.html', 'utf8');

let srcdocEntries = panelFiles.map(f => {
  const content = fs.readFileSync(path + '/' + f, 'utf8');
  return `"${f}":\`${escapeForTemplateLiteral(content)}\``;
}).join(',\n');

const srcdocBlock = `const SRCDOC={\n${srcdocEntries}\n};\n`;

// Inject SRCDOC block right before the aç function definition, and switch
// the panel loader from src=file to srcdoc=embedded content.
const anchor = 'function aç(i){';
if (!template.includes(anchor)) {
  throw new Error('anchor "function aç(i){" not found in template');
}
if (!template.includes('$("frame").src=p.src;')) {
  throw new Error('panel loader "$("frame").src=p.src;" not found in template');
}
template = template.replace(anchor, srcdocBlock + anchor);
template = template.replace(
  '$("frame").src=p.src;',
  '$("frame").removeAttribute("src");$("frame").srcdoc=SRCDOC[p.src]||"Panel bulunamadi";'
);

const before = fs.existsSync(path + '/OMER-YILMAZ.html') ? fs.statSync(path + '/OMER-YILMAZ.html').size : 0;
if (!template.includes('const SRCDOC={')) throw new Error('SRCDOC injection failed');
if (template.length < 3000000) throw new Error('bundle suspiciously small: ' + template.length);
fs.writeFileSync(path + '/OMER-YILMAZ.html', template);
console.log('bundled OK, size:', template.length);
