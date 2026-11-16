#!/bin/sh
# Keep the index (and the 3D map) in sync with the repositories: every 5 minutes, if a repo under ~/pearOS has new commits or uncommitted changes, reindex it, wait for the sync and republish the map.
#   screen -dmS pearindex sh scripts/qdrant-watch.sh        stop: screen -S pearindex -X quit
HERE="$(cd "$(dirname "$0")/.." && pwd)"; PEAR_DIR="${PEAR_DIR:-$HOME/pearOS}"; STATE="$HOME/.pear/watch.state"; mkdir -p "$HOME/.pear"; touch "$STATE"
while true; do
	changed=""
	for d in "$PEAR_DIR"/*/; do [ -d "$d/.git" ] || continue; r=$(basename "$d"); case ",${PEAR_INDEX_SKIP:-AppStore-Backend,virtio,clevo_wmi,kext,misc,pkgbuild,package-repo,codemap,.github}," in *",$r,"*) continue;; esac; h="$(git -C "$d" rev-parse HEAD 2>/dev/null)$(git -C "$d" status --porcelain 2>/dev/null | md5sum | cut -c1-8)"
		grep -q "^$r $h$" "$STATE" || { changed="$changed $d"; sed -i "/^$r /d" "$STATE"; echo "$r $h" >>"$STATE"; }; done
	if [ -n "$changed" ]; then echo "$(date) reindex:$changed"; python3 "$HERE/scripts/qdrant-index.py" $changed && python3 "$HERE/scripts/qdrant-wait.py" && sh "$HERE/scripts/map-publish.sh"; fi
	sleep 300
done
