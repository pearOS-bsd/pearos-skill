#!/bin/sh
# Where is this name defined, in ANY repository?  sh scripts/where-is.sh SYMBOL [more...]   (exact, then prefix; falls back to ripgrep over ~/pearOS)
OUT="$HOME/.pear/symbols.tsv"; [ -f "$OUT" ] || sh "$(dirname "$0")/symbols.sh" >/dev/null
for s in "$@"; do
	echo "== $s"; awk -F'\t' -v s="$s" '$1==s {print "  def  "$3"/"$4":"$5"  ("$2")"}' "$OUT" | head -20
	n=$(awk -F'\t' -v s="$s" 'index($1,s)==1 && $1!=s' "$OUT" | wc -l); [ "$n" -gt 0 ] && { echo "  similar names ($n):"; awk -F'\t' -v s="$s" 'index($1,s)==1 && $1!=s {print "    "$1"  "$3"/"$4":"$5}' "$OUT" | head -8; }
	rg -n --no-heading -m2 -g '!upstream' -g '!catalogs' -g '!.git' -w "$s" "${PEAR_DIR:-$HOME/pearOS}" 2>/dev/null | head -4 | sed 's/^/  use  /'
done
