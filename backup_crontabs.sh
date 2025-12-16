#!/bin/bash
# ================= CONFIGURATION =================
BACKUP_DIR="/var/backups/cron_backups"
GATEKEEPER="/usr/local/bin/run_on_primary_only.sh"
FLAG_LOC="/tmp/db_is_primary"
LOG_FILE="/var/log/cron_dr_audit.log"
# =================================================

log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
log_msg "[INFO] Starting Daily Backup & Health Check..."

# 1. AUTO-HEAL GATEKEEPER
if [ ! -f "$GATEKEEPER" ]; then
    log_msg "[WARNING] Gatekeeper missing. Auto-healing..."
    cat << EOF > "$GATEKEEPER"
#!/bin/bash
if [ -f "$FLAG_LOC" ]; then exec "\$@"; else exit 0; fi
EOF
    chmod +x "$GATEKEEPER"
    log_msg "[INFO] Gatekeeper restored."
fi

# 2. BACKUP CRONTABS
DATE_STAMP=$(date +%Y%m%d)
mkdir -p "$BACKUP_DIR/$DATE_STAMP"
SPOOL_DIR=$( [ -d /var/spool/cron/crontabs ] && echo "/var/spool/cron/crontabs" || echo "/var/spool/cron" )

for USER_CRON in "$SPOOL_DIR"/*; do
    [ -f "$USER_CRON" ] || continue
    USER=$(basename "$USER_CRON")
    crontab -l -u "$USER" > "$BACKUP_DIR/$DATE_STAMP/${USER}_$(hostname).cron" 2>/dev/null
done

find "$BACKUP_DIR" -type d -mtime +30 -exec rm -rf {} +
log_msg "[INFO] Backup complete."
