#!/usr/bin/env bash
# 01-sunucu-sertlestir.sh — Ubuntu 22.04/24.04 temel sertlestirme
# Sunucuda root olarak calistirilir:  sudo bash 01-sunucu-sertlestir.sh
set -euo pipefail

KULLANICI="${KULLANICI:-panel}"
SSH_PORT="${SSH_PORT:-22}"

if [[ $EUID -ne 0 ]]; then echo "root olarak calistirin (sudo)."; exit 1; fi

echo "==> Paketler guncelleniyor"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get -y -qq upgrade
apt-get -y -qq install ufw fail2ban unattended-upgrades nginx curl ca-certificates apache2-utils

echo "==> Kullanici: $KULLANICI"
if ! id -u "$KULLANICI" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$KULLANICI"
fi
usermod -aG sudo "$KULLANICI"

# root'un authorized_keys'ini yeni kullaniciya kopyala ki kilitlenme olmasin
if [[ -f /root/.ssh/authorized_keys ]]; then
  install -d -m 700 -o "$KULLANICI" -g "$KULLANICI" "/home/$KULLANICI/.ssh"
  install -m 600 -o "$KULLANICI" -g "$KULLANICI" /root/.ssh/authorized_keys "/home/$KULLANICI/.ssh/authorized_keys"
  echo "    root SSH anahtarlari $KULLANICI kullanicisina kopyalandi."
else
  echo "    !! /root/.ssh/authorized_keys yok. Devam etmeden once"
  echo "       kendi makinenizden: ssh-copy-id $KULLANICI@<sunucu-ip>"
  echo "       Aksi halde parola girisi kapatilinca sunucuya giremezsiniz."
fi

echo "==> Guvenlik duvari (ufw)"
ufw --force reset >/dev/null
ufw default deny incoming
ufw default allow outgoing
ufw allow "${SSH_PORT}/tcp" comment 'SSH'
ufw allow 80/tcp  comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable

echo "==> Otomatik guvenlik guncellemeleri"
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "==> fail2ban"
cat > /etc/fail2ban/jail.local <<'EOF'
[sshd]
enabled  = true
maxretry = 5
bantime  = 1h
findtime = 10m
EOF
systemctl enable --now fail2ban
systemctl restart fail2ban

echo
echo "TAMAM. Simdi SIRASIYLA:"
echo "  1) BASKA bir terminalden 'ssh $KULLANICI@<sunucu-ip>' ile girebildiginizi DOGRULAYIN."
echo "  2) Dogruladiktan SONRA parola girisini kapatmak icin:"
echo "     sudo bash 02-ssh-kilitle.sh"
