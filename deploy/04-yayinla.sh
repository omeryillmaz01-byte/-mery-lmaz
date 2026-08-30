#!/usr/bin/env bash
# 04-yayinla.sh — ~/gelen icine yuklenen panelleri yayin kokune tasir.
# Sunucuda panel kullanicisiyla:  ALAN=panel.alanadi.com bash 04-yayinla.sh
set -euo pipefail
: "${ALAN:?ALAN=panel.alanadi.com seklinde verin}"
GELEN="${GELEN:-$HOME/gelen}"
KOK="/var/www/$ALAN"
[[ -d "$GELEN" ]] || { echo "$GELEN yok"; exit 1; }

# Yayina cikmayacaklar (WEB-PAKET.bat filtresiyle ayni)
rsync -a --delete \
  --exclude='chrome_profil/' --exclude='GEREKLI_PROGRAMLAR/' \
  --exclude='battal_db_eklenti/' --exclude='banka_pos_panel/' \
  --exclude='beyanname-otomatik-kaydetme/' --exclude='MUSAVIR_PRO_ESKI/' \
  --exclude='node_modules/' --exclude='*_yedek_*' \
  --exclude='*.bat' --exclude='*.cmd' --exclude='*.ps1' --exclude='*.vbs' \
  --exclude='*.py' --exclude='*.exe' --exclude='*.msi' --exclude='*.zip' \
  --exclude='*.rar' --exclude='*.lnk' --exclude='*.log' --exclude='*.db' \
  --exclude='*.sqlite' --exclude='*.xlsx' --exclude='*.xls' \
  "$GELEN"/ "$KOK"/

find "$KOK" -type d -exec chmod 755 {} +
find "$KOK" -type f -exec chmod 644 {} +
echo "Yayinlandi: https://$ALAN  ($(find "$KOK" -type f | wc -l) dosya)"
