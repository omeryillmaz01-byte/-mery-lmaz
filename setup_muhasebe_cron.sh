#!/bin/bash
# Muhasebe TR - Cronjob Setup Script
# Bu script günlük otomatik panel oluşturma işini kurar

PROJECT_DIR="/home/user/-mery-lmaz"
SCRIPT="$PROJECT_DIR/muhasebe_scraper_local.py"
LOG_FILE="$PROJECT_DIR/muhasebe_cron.log"

echo "🔧 Muhasebe TR - Cronjob Kuruluyor..."
echo ""

# Cronjob: Her gün 08:00'de çalış
CRON_JOB="0 8 * * * cd $PROJECT_DIR && /usr/bin/python3 $SCRIPT >> $LOG_FILE 2>&1"

# Mevcut cronjob'ları kontrol et
if crontab -l 2>/dev/null | grep -q "$SCRIPT"; then
    echo "⚠️  Bu cron job zaten mevcut"
else
    # Yeni cronjob ekle
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cronjob başarıyla eklendi!"
    echo ""
    echo "📅 Zaman Çizelgesi:"
    echo "   Her gün saat 08:00'de otomatik çalışacak"
    echo ""
    echo "📂 Log Dosyası: $LOG_FILE"
fi

echo ""
echo "📋 Mevcut Cronjob'lar:"
crontab -l 2>/dev/null | grep -E "muhasebe|muhasebetr" || echo "Muhasebe cronjob bulunamadı"

echo ""
echo "✨ Kurulum tamamlandı!"
