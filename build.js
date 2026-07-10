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

if (!template.includes('function aç(i)')) {
  throw new Error('anchor function aç(i) not found in template');
}

template = template.replace(
  'function aç(i){const p=PANELS[i];$("vtitle").textContent=p.ic+"  "+p.nm;$("frame").src=p.src;$("home").style.display="none";$("viewer").style.display="flex";}',
  srcdocBlock + 'function aç(i){const p=PANELS[i];$("vtitle").textContent=p.ic+"  "+p.nm;$("frame").removeAttribute("src");$("frame").srcdoc=SRCDOC[p.src]||"Panel bulunamadi";$("home").style.display="none";$("viewer").style.display="flex";}'
);

fs.writeFileSync(path + '/OMER-YILMAZ.html', template);
console.log('bundled OK, size:', template.length);
