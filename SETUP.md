# shop-ops-lab: one-time setup (off camera)

This kit runs 5 separate tasks on one setup. Do this setup once.

## What's in the kit

```
shop-ops-kit/
  SETUP.md          this file (never show it on camera)
  task_files/       the ticket + policy for each task (the reset scripts copy them in)
  reset/            reset scripts, one per task (run from this folder)
  shop-ops-lab/     the project you open in VS Code (open ONLY this folder)
```

## 1. Unzip and start the database

1. Unzip `shop-ops-kit.zip` somewhere neutral, e.g. `~/Projects/shop-ops-kit`.
2. Start Docker Desktop.
3. In Terminal:
   ```bash
   cd ~/Projects/shop-ops-kit/shop-ops-lab
   docker compose up -d db
   ```
   The first start loads the data automatically (takes about 10 seconds).
   Postgres listens on port **5440**, so it won't clash with your other tasks' databases.

## 2. DBeaver connections (tasks 1 and 2)

Create two PostgreSQL connections (Database > New Database Connection > PostgreSQL):

| Connection name | Host | Port | Database | User | Password |
|---|---|---|---|---|---|
| `shop_db (admin)` | localhost | 5440 | shop_db | postgres | postgres |
| `shop_db (reporting)` | localhost | 5440 | shop_db | reporting_user | report_pw |

Tick "Save password". Click Test Connection once so the driver is downloaded. Then disconnect both.

## 3. GitHub repo (task 5 only)

1. On GitHub, create a **public** repo called `shop-ops-lab` (branch rules on private repos need a paid plan). Don't add a README.
2. In Terminal, from the `shop-ops-lab` folder:
   ```bash
   git init -b main
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/<you>/shop-ops-lab.git
   git push -u origin main
   ```
3. On GitHub, open the Actions tab and wait for the **CI / checks** run to go green. (The ruleset can only require a check that has run at least once.)
4. Check that VS Code can push (Source Control panel, Sync). Use a GitHub account with a neutral name and avatar, because it shows on camera.

## 4. Before EVERY recording (including after a practice run)

From the `shop-ops-kit` folder (not inside shop-ops-lab):

| Task | Run |
|---|---|
| 1. Audit log retention | `./reset/task1.sh` (then record within 11 hours) |
| 2. Read-only reporting user | `./reset/task2.sh` |
| 3. Docker disk cleanup | `./reset/task3.sh` (takes a minute or two; write down the numbers it prints) |
| 4. catalog-api restarting | `./reset/task4.sh` (after recording, run `./reset/stop_api.sh`) |
| 5. Branch protection | `./reset/task5.sh`, then delete the `protect-main` ruleset on GitHub if it exists |

If a reset says "permission denied", run `chmod +x reset/*.sh` once.

Each reset copies only that task's ticket and policy into `tickets/`, so VS Code shows nothing from the other tasks.

After each recording, move what you saved in `notes/` to your deliverables folder, so the next task starts clean.

## Screen hygiene

Close Terminal before recording (VS Code's own terminal is fine where the script uses it). Keep Docker Desktop closed unless the task uses it. Do Not Disturb on. Timer off screen.
