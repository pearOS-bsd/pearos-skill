#!/bin/sh
# Export the Qdrant index as a 3D map and publish it to GitHub Pages (https://pearos-bsd.github.io/codemap/).  sh scripts/map-publish.sh
# Each publish is ONE orphan commit force-pushed to pearOS-bsd/codemap (no history growth).  The page reloads points.json every minute, so it updates by itself.
set -e
HERE="$(cd "$(dirname "$0")/.." && pwd)"; W="$HOME/.pear/tmp/codemap"; PY="$HOME/.pear/venv/bin/python"; [ -x "$PY" ] || PY=python3
rm -rf "$W"; mkdir -p "$W"; "$PY" "$HERE/scripts/qdrant-map.py" "$W"
cp "$HERE/site/index.html" "$W/index.html"; cp "$HERE/LICENSE" "$W/LICENSE"
cp "$HERE/site/README.md" "$W/README.md"; touch "$W/.nojekyll"
cd "$W" && git init -q -b main && git add -A && git -c user.name="Alexandru Balan" -c user.email="alxb421@gmail.com" commit -q -m "code map $(date -u +%Y-%m-%dT%H:%MZ)" && git remote add origin https://github.com/pearOS-bsd/codemap.git && git push -q --force origin main
echo "published: https://pearos-bsd.github.io/codemap/"
