---
description: Start the overnight watchdog that resumes /work after a usage limit resets
---
Explain in two lines what `scripts/night.sh` does (runs outside Claude: `claude -p --continue "/work resume"` in a loop; on "usage limit" it sleeps until the reset time and tries again; stops when STATE.md says `ACTIVE: none`). Then start it in a detached `screen` (`screen -dmS pearnight sh scripts/night.sh`), print how to watch it (`screen -r pearnight`, `tail -f ~/.pear/night.log`) and how to stop it (`screen -S pearnight -X quit`). Ask first if the permission flags are not decided (STATE.md Questions).
