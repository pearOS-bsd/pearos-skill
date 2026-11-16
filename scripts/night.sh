#!/bin/bash
# Overnight watchdog: keeps /work going across Claude usage limits.  Run in screen/tmux:  screen -dmS pearnight sh scripts/night.sh
# It runs `claude -p --continue "/work resume"` (headless, the latest session of this directory) in a loop.  When the answer says the usage limit was reached it sleeps until the
# reset time (or 30 min when none is given) and tries again.  It stops when STATE.md says "ACTIVE: none", after MAX_ROUNDS, or when you remove ~/.pear/night.on.
# Permissions: headless runs use the allow-list of your settings; CLAUDE_FLAGS adds more (e.g. CLAUDE_FLAGS="--permission-mode acceptEdits").  Not "--dangerously-skip-permissions" unless you set it yourself.
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"; STATE="$SKILL_DIR/skills/pearos/STATE.md"; WORKDIR="${PEAR_DIR:-$HOME/pearOS}"; LOG="$HOME/.pear/night.log"
mkdir -p "$HOME/.pear"; touch "$HOME/.pear/night.on"; cd "$WORKDIR" 2>/dev/null || cd "$HOME" || exit 1
MAX_ROUNDS=${MAX_ROUNDS:-300}; PROMPT='/work resume'
for round in $(seq 1 "$MAX_ROUNDS"); do
	[ -f "$HOME/.pear/night.on" ] || { echo "$(date) switched off" >>"$LOG"; exit 0; }
	grep -q '^ACTIVE: none' "$STATE" 2>/dev/null && { echo "$(date) nothing active: done" >>"$LOG"; exit 0; }
	echo "$(date) round $round" >>"$LOG"
	out=$(claude -p --continue $CLAUDE_FLAGS "$PROMPT" 2>&1); rc=$?
	echo "$out" | tail -5 >>"$LOG"
	if echo "$out" | grep -qiE "usage limit|rate limit|limit reached|limit will reset|resets at"; then
		t=$(echo "$out" | grep -io -E "resets? (at )?[0-9]{1,2}(:[0-9]{2})? ?(am|pm)?" | head -1 | sed -E 's/resets? (at )?//')
		wait=1800
		if [ -n "$t" ]; then s=$(date -d "$t" +%s 2>/dev/null) && now=$(date +%s) && { [ "$s" -le "$now" ] && s=$((s + 86400)); wait=$((s - now + 120)); }; fi
		echo "$(date) limit reached, sleeping $wait s" >>"$LOG"; sleep "$wait"
	else
		sleep 60
	fi
done
