#!/usr/bin/env bash
# 02-ssh-kilitle.sh — SSH parola girisini ve root girisini kapatir.
# SADECE anahtarla giris yapabildiginizi DOGRULADIKTAN SONRA calistirin.
set -euo pipefail
if [[ $EUID -ne 0 ]]; then echo "root olarak calistirin (sudo)."; exit 1; fi

if ! ls /home/*/.ssh/authorized_keys >/dev/null 2>&1; then
  echo "HATA: hicbir kullanicida authorized_keys yok. Kilitlenirsiniz. Iptal."
  exit 1
fi

cat > /etc/ssh/sshd_config.d/99-sertlestirme.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
EOF

sshd -t
systemctl reload ssh || systemctl reload sshd
echo "TAMAM: parola girisi ve root girisi kapatildi."
