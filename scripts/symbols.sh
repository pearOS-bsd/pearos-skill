#!/bin/sh
# Exact-name index of our code: every function / class / macro / struct of every repository (ctags), in ~/.pear/symbols.tsv:  symbol  kind  repo  file  line
#   sh scripts/symbols.sh          (re)build, ~1 minute          sh scripts/where-is.sh mach_port_allocate      look up
PEAR_DIR="${PEAR_DIR:-$HOME/pearOS}"; OUT="$HOME/.pear/symbols.tsv"; mkdir -p "$HOME/.pear"; : >"$OUT.tmp"
for d in "$PEAR_DIR"/*/; do [ -d "$d/.git" ] || continue; r=$(basename "$d")
	(cd "$d" && ctags -R --languages=C,C++,ObjectiveC,Python,Sh --exclude=upstream --exclude=catalogs --exclude=build --exclude=.git --exclude='*_Generated.*' --exclude='*golden*' --fields=+nK --extras=-F -f - . 2>/dev/null | awk -F'\t' -v r="$r" 'NF>=4 && $1 !~ /^!/ {ln=""; for(i=4;i<=NF;i++) if($i ~ /^line:/){ln=substr($i,6)} k=$4; sub(/^kind:/,"",k); f=$2; sub(/^\.\//,"",f); print $1"\t"k"\t"r"\t"f"\t"ln}') >>"$OUT.tmp"
done
mv "$OUT.tmp" "$OUT"; echo "$(wc -l <"$OUT") symbols in $OUT"
