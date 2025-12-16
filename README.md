# Oracle DR Cron Job Manager

## 📖 Overview
This repository contains a set of shell scripts designed to manage cron job execution in an Oracle Data Guard environment (Active/Passive). 

It solves the problem of cron jobs running on the Standby server during DR drills or failovers. Instead of manually commenting/uncommenting crontabs, a "Gatekeeper" wrapper script checks the server role before execution.

## 🚀 Components

| Script | Path (Server) | Frequency | Description |
| :--- | :--- | :--- | :--- |
| **Gatekeeper** | `/usr/local/bin/run_on_primary_only.sh` | Every Minute | Wraps critical cron jobs. Checks if the flag file exists. |
| **Controller** | `/usr/local/bin/set_cron_role.sh` | On Demand | Manually toggles the server role (PRIMARY vs STANDBY). |
| **Healer** | `/usr/local/bin/backup_crontabs.sh` | Daily | Backs up user crontabs and auto-repairs the Gatekeeper if deleted. |
| **Uninstaller** | `/usr/local/bin/remove_cron_wrapper.sh` | Emergency | Strips the wrapper from all user crontabs. |

## 🛠️ Installation

1. **Deploy:** Copy all files from `scripts/` to `/usr/local/bin/` on both DC and DR servers.
2. **Permissions:**
   ```bash
   chmod +x /usr/local/bin/*.sh
