#!/bin/bash
TARGET_USERS="oracle grid appuser" 
WRAPPER="/usr/local/bin/run_on_primary_only.sh "
BACKUP_DIR="/var/backups/cron_backups/rollback_$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

for USER in $TARGET_USERS; do
    TEMP="$BACKUP_DIR/${USER}.tmp"
    crontab -l -u "$USER" > "$TEMP" 2>/dev/null
    if grep -Fq "$WRAPPER" "$TEMP"; then
        cp "$TEMP" "$BACKUP_DIR/${USER}_BACKUP.cron"
        sed "s|$WRAPPER||g" "$TEMP" | crontab -u "$USER" -
        echo "Wrapper removed for $USER."
    fi
done
