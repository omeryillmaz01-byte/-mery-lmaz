#!/usr/bin/env bash
# 03-nginx-tls-auth.sh — panel.<alanadi> icin nginx vhost + Let's Encrypt + Basic Auth
# Kullanim (sunucuda):
#   sudo ALAN=panel.alanadi.com EPOSTA=omer.yillmaz01@gmail.com KULLANICI=panel bash 03-nginx-tls-auth.sh
set -euo pipefail
if [[ $EUID -ne 0 ]]; then echo "root olarak calistirin (sudo)."; exit 1; fi
: "${ALAN:?ALAN=panel.alanadi.com seklinde verin}"
: "${EPOSTA:?EPOSTA=... seklinde verin}"
KULLANICI="${KULLANICI:-panel}"
KOK="/var/www/$ALAN"

apt-get update -qq
apt-get -y -qq install nginx certbot python3-certbot-nginx apache2-utils rsync

install -d -o "$KULLANICI" -g "$KULLANICI" "$KOK"
install -d -o "$KULLANICI" -g "$KULLANICI" "/home/$KULLANICI/gelen"
[[ -f "$KOK/index.html" ]] || echo '<!doctype html><title>panel</title><p>Kurulum tamam.</p>' > "$KOK/index.html"

# --- Basic Auth kullanicisi ---
if [[ ! -f /etc/nginx/.htpasswd ]]; then
  echo "==> Panel giris parolasi belirleyin (kullanici adi: omer)"
  htpasswd -c /etc/nginx/.htpasswd omer
  chown root:www-data /etc/nginx/.htpasswd
  chmod 640 /etc/nginx/.htpasswd
fi

# --- vhost (once sadece HTTP; certbot TLS'i kendisi ekler) ---
cat > "/etc/nginx/sites-available/$ALAN" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $ALAN;
    root $KOK;
    index index.html BATTAL-MUHASEBE.html;

    auth_basic "Panel";
    auth_basic_user_file /etc/nginx/.htpasswd;

    add_header X-Content-Type-Options  "nosniff"        always;
    add_header X-Frame-Options         "SAMEORIGIN"     always;
    add_header Referrer-Policy         "no-referrer"    always;
    add_header X-Robots-Tag            "noindex, nofollow, noarchive" always;

    # Paneller buyuk tek dosya HTML — sikistirma sart
    gzip on;
    gzip_types text/html text/css application/javascript application/json image/svg+xml;
    gzip_min_length 1024;

    client_max_body_size 32m;

    location = /robots.txt { auth_basic off; default_type text/plain; return 200 "User-agent: *\nDisallow: /\n"; }
    location /.well-known/acme-challenge/ { auth_basic off; root $KOK; }

    # Sunucuya sizmis olabilecek yerel dosyalar asla servis edilmesin
    location ~* \\.(bat|cmd|ps1|vbs|py|exe|msi|zip|rar|log|db|sqlite|xlsx?)\$ { deny all; }
    location ~ /\\.            { deny all; }

    location / { try_files \$uri \$uri/ =404; }
}
EOF

ln -sf "/etc/nginx/sites-available/$ALAN" "/etc/nginx/sites-enabled/$ALAN"
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "==> Let's Encrypt sertifikasi ($ALAN)"
echo "    DNS A kaydi bu sunucuya yonlendirilmis olmali, yoksa bu adim basarisiz olur."
certbot --nginx -d "$ALAN" --non-interactive --agree-tos -m "$EPOSTA" --redirect

# HSTS ancak TLS calisirken eklenmeli
if ! grep -q Strict-Transport-Security "/etc/nginx/sites-available/$ALAN"; then
  sed -i "s|add_header Referrer-Policy         \"no-referrer\"    always;|add_header Referrer-Policy         \"no-referrer\"    always;\n    add_header Strict-Transport-Security \"max-age=31536000\" always;|" "/etc/nginx/sites-available/$ALAN"
  nginx -t && systemctl reload nginx
fi

systemctl list-timers certbot.timer --no-pager || true
echo
echo "TAMAM. https://$ALAN  (kullanici: omer)"
echo "Yayin kok dizini: $KOK"
