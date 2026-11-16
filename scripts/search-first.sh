#!/bin/sh
# Search before you build: sh scripts/search-first.sh "keywords"
# our clones, our org, Apple open source, the projects we studied.  Prints candidates with licence.  (Needs gh logged in for the GitHub part.)
Q="$*"; [ -n "$Q" ] || { echo "usage: search-first.sh keywords"; exit 1; }; PEAR_DIR="${PEAR_DIR:-$HOME/pearOS}"
echo "== our clones ($PEAR_DIR)"; grep -rIl --exclude-dir=.git -i -- "$Q" "$PEAR_DIR" 2>/dev/null | head -15
echo "== our org (code)"; gh search code "$Q" --owner pearOS-bsd --limit 10 --json repository,path --jq '.[]|.repository.nameWithOwner+"  "+.path' 2>/dev/null
echo "== Apple open source"; gh search code "$Q" --owner apple-oss-distributions --limit 10 --json repository,path --jq '.[]|.repository.nameWithOwner+"  "+.path' 2>/dev/null
echo "== projects we studied"; for r in ravynsoft/ravynos nextbsd-redux/nextbsd NextBSD/NextBSD pkgdemon/freebsd-launchd-mach PureDarwin/XPC cjwl/cocotron swiftlang/swift-corelibs-foundation gnustep/libobjc2; do gh search code "$Q" --repo "$r" --limit 3 --json repository,path --jq '.[]|.repository.nameWithOwner+"  "+.path' 2>/dev/null; done
echo "== repositories on GitHub"; gh search repos "$Q" --limit 8 --json fullName,description,license,stargazersCount --jq '.[]|.fullName+" | "+(.license.key//"?")+" | *"+(.stargazersCount|tostring)+" | "+((.description//"")[0:80])' 2>/dev/null
echo "Licence rule: MIT/BSD/ISC/Apache/APSL may be copied into upstream/ with PROVENANCE.md; GPL/LGPL: read only."
