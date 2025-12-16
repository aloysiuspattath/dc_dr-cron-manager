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
That is a great idea. Storing this in GitHub (or your internal Bitbucket/GitLab) is the best way to handle version control, especially for banking infrastructure code.

Here is the **GitHub-Ready Package**. I have organized the scripts into a clean folder structure and written a professional `README.md` that acts as the front page of your repository.

### 1\. Recommended Repository Structure

Create a folder named `oracle-dr-cron-manager` and organize the files like this:

```text
oracle-dr-cron-manager/
│
├── README.md                  <-- The documentation (SOP)
├── .gitignore                 <-- Ignores logs and temp files
│
├── scripts/                   <-- The actual code
│   ├── run_on_primary_only.sh
│   ├── set_cron_role.sh
│   ├── backup_crontabs.sh
│   └── remove_cron_wrapper.sh
│
└── docs/                      <-- Detailed SOP Document
    └── DR_SOP_v3.md
```

-----

### 2\. The `README.md` File

Create a file named `README.md` in the root folder and paste this content. This provides immediate context to anyone viewing the repo.

````markdown
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
````

3.  **Configuration:**
    Update your crontab to use the wrapper:
    ```bash
    # Before
    00 22 * * * /home/oracle/daily_backup.sh

    # After
    00 22 * * * /usr/local/bin/run_on_primary_only.sh /home/oracle/daily_backup.sh
    ```

## 🕹️ Usage (DR Drill)

### Phase 1: Failover (DC -\> DR)

1.  **On DC (Old Primary):** Run `set_cron_role.sh STANDBY`
2.  **On DR (New Primary):** Run `set_cron_role.sh PRIMARY`

### Phase 2: Switchback

1.  **On DR:** Run `set_cron_role.sh STANDBY`
2.  **On DC:** Run `set_cron_role.sh PRIMARY`

## 📝 Logs

Audit logs are stored at: `/var/log/cron_dr_audit.log`

-----

**Maintained by:** Database Administration Team

````

---

### 3. The `.gitignore` File
Create a file named `.gitignore` in the root folder. This ensures you don't accidentally upload local log files or temporary system files to GitHub.

```text
# Ignore system logs
*.log
*.tmp

# Ignore OS generated files
.DS_Store
Thumbs.db

# Ignore backup folders created by the scripts
cron_backups/
rollback_*/
````

-----

### 4\. Commands to Push to GitHub

If you have the files ready on your local machine, open your terminal/command prompt in that folder and run:

```bash
# 1. Initialize Git
git init

# 2. Add your files
git add .

# 3. Commit the files
git commit -m "Initial commit of DR Cron Manager scripts v3.0"

# 4. Link to your GitHub Repo (Replace URL with your actual repo URL)
git remote add origin https://github.com/YOUR_USERNAME/oracle-dr-cron-manager.git

# 5. Push to GitHub
git branch -M main
git push -u origin main
```
