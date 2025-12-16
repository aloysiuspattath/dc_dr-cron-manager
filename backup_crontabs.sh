#!/bin/bash
# ================= CONFIGURATION =================
BACKUP_DIR="/var/backups/cron_backups"
GATEKEEPER_SCRIPT="/usr/local/bin/run_on_primary_only.sh"
FLAG_FILE_LOCATION="/tmp/db_is_primary"
RETENTION_DAYS=30
LOG_FILE="/var/log/cron_dr_audit.log"
# =================================================

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_msg "[INFO] Starting Daily Cron Backup & Health Check..."

# --- 1. HEALTH CHECK & AUTO-HEAL ---
if [ ! -f "$GATEKEEPER_SCRIPT" ]; then
    log_msg "[WARNING] CRITICAL: Gatekeeper script was missing. Initiating Auto-Heal."
    
    # Rebuild the gatekeeper script
    cat << EOF > "$GATEKEEPER_SCRIPT"
#!/bin/bash
# Auto-restored Gatekeeper
FLAG_FILE="$FLAG_FILE_LOCATION"
if [ -f "\$FLAG_FILE" ]; then
    exec "\$@"
else
    exit 0
fi
EOF
    chmod +x "$GATEKEEPER_SCRIPT"
    log_msg "[INFO] Gatekeeper restored successfully."
fi

# --- 2. BACKUP LOGIC (Direct File Copy) ---
DATE_STAMP=$(date +%Y%m%d)
HOSTNAME=$(hostname)
mkdir -p "$BACKUP_DIR/$DATE_STAMP"

# Locate spool dir (AIX/Linux compatible)
if [ -d /var/spool/cron/crontabs ]; then
    SPOOL_DIR="/var/spool/cron/crontabs"  # AIX & Debian/Ubuntu
elif [ -d /var/spool/cron ]; then
    SPOOL_DIR="/var/spool/cron"           # RHEL/CentOS
else
    log_msg "[ERROR] Cron spool directory not found. Backup failed."
    exit 1
fi

COUNT=0
# Loop directly through the files on disk
for USER_CRON in "$SPOOL_DIR"/*; do
    # Get the filename (which is the username)
    USER=$(basename "$USER_CRON")
    
    # Skip if it's not a regular file or is hidden/system file
    [ -f "$USER_CRON" ] || continue
    [[ "$USER" == "."* ]] && continue 

    # METHOD: Direct Copy (Works on AIX and Linux reliably)
    # We use 'cat' to ensure the target file is owned by root and readable
    TARGET_FILE="$BACKUP_DIR/$DATE_STAMP/${USER}_${HOSTNAME}.cron"
    
    if cat "$USER_CRON" > "$TARGET_FILE" 2>/dev/null; then
        ((COUNT++))
    else
        log_msg "[ERROR] Failed to backup cron for user: $USER"
    fi
done

log_msg "[INFO] Backup complete. Backed up $COUNT users to $BACKUP_DIR/$DATE_STAMP"

# --- 3. CLEANUP (AIX Compatible) ---
if [ -d "$BACKUP_DIR" ]; then
    # Using /usr/bin/rm and \; to satisfy AIX find command requirements
    find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec /usr/bin/rm -rf {} \;
    log_msg "[INFO] Cleanup of old backups complete."
fi
