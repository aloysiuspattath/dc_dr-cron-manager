#!/bin/bash
# ================= CONFIGURATION =================
FLAG_FILE="/tmp/db_is_primary"
LOG_FILE="/var/log/cron_dr_audit.log"
# =================================================

log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

ACTION=$1
USER_RUNNING=$(whoami)

if [ "$ACTION" == "PRIMARY" ]; then
    touch "$FLAG_FILE"
    chmod 644 "$FLAG_FILE"
    log_msg "[INFO] User '$USER_RUNNING' set role to PRIMARY. Jobs enabled."

elif [ "$ACTION" == "STANDBY" ]; then
    rm -f "$FLAG_FILE"
    log_msg "[INFO] User '$USER_RUNNING' set role to STANDBY. Jobs disabled."

else
    echo "Usage: $0 [PRIMARY|STANDBY]"
    log_msg "[ERROR] Invalid action attempted by '$USER_RUNNING'."
    exit 1
fi
