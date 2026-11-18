#!/bin/sh
# Clone / update every repository of github.com/pearOS-bsd into $PEAR_DIR (default ~/pearOS).  sh scripts/clone-all.sh [--status]
# Never forces: `git pull --rebase --autostash`; reports repos with unpushed commits.
PEAR_DIR="${PEAR_DIR:-$HOME/pearOS}"; ORG=pearOS-bsd; mkdir -p "$PEAR_DIR"
REPOS="darwinator dyld macdeps IOKit d WindowServer SkyLight AppKit open QuartzCore CoreUI SDK LaunchServices apps iso tests docs research pearos-skill .github libsystem libdispatch libobjc libcxx libxpc CoreFoundation Foundation CoreGraphics CoreText ImageIO UIFoundation IconServices CoreAudio DisplayServices IOPS CoreWLAN IOBluetooth DoNotDisturb CoreServices Security SystemConfiguration CFNetwork HIToolbox PrivateFrameworks swift-runtime thirdparty ploader clevo_wmi virtio package-repo pkgbuild AppStore-Backend"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then LIVE=$(gh repo list "$ORG" --limit 200 --json name --jq '.[].name' 2>/dev/null); [ -n "$LIVE" ] && REPOS="$REPOS $LIVE"; fi
for r in $(printf '%s\n' $REPOS | sort -u); do
	d="$PEAR_DIR/$r"
	if [ -d "$d/.git" ]; then
		if [ "$1" = "--status" ]; then printf '%-22s %s %s\n' "$r" "$(git -C "$d" status -sb | head -1)" "$(git -C "$d" status --porcelain | wc -l | tr -d ' ') changed"; continue; fi
		git -C "$d" pull -q --rebase --autostash 2>&1 | tail -1
		a=$(git -C "$d" rev-list --count '@{u}..HEAD' 2>/dev/null); [ "${a:-0}" -gt 0 ] && echo "$r: $a commits not pushed"
	else
		[ "$1" = "--status" ] && continue
		git clone -q "https://github.com/$ORG/$r.git" "$d" 2>/dev/null && echo "cloned $r" || echo "skip $r (not found / no access)"
	fi
done
echo "repositories in $PEAR_DIR"
