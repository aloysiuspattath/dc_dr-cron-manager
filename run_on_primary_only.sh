#!/bin/bash
# ================= CONFIGURATION =================
FLAG_FILE="/tmp/db_is_primary"
# =================================================

if [ -f "$FLAG_FILE" ]; then
    # Flag exists -> We are Primary -> Run the command
    exec "$@"
else
    # Flag missing -> We are Standby -> Do nothing
    exit 0
fi
