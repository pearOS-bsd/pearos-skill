#!/bin/sh
# One-time setup on a laptop:  git clone https://github.com/pearOS-bsd/pearos-skill && sh pearos-skill/scripts/install.sh
# - links the skill and the commands into ~/.claude so that /work, /status, /sync ... work everywhere (no plugin namespace)
# - installs caveman (terse mode) if `claude` is available
# - creates ~/.pear (secrets stay there, never in git) and clones every repository (scripts/clone-all.sh)
HERE="$(cd "$(dirname "$0")/.." && pwd)"; mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands" "$HOME/.pear"
ln -sfn "$HERE/skills/pearos" "$HOME/.claude/skills/pearos"
for c in "$HERE"/commands/*.md; do ln -sf "$c" "$HOME/.claude/commands/$(basename "$c")"; done
# git: strip every trace of Claude from commit messages, in every repository of this laptop
mkdir -p "$HOME/.pear/githooks"; cp "$HERE/scripts/githooks/commit-msg" "$HOME/.pear/githooks/commit-msg"; chmod +x "$HOME/.pear/githooks/commit-msg"
[ -z "$(git config --global core.hooksPath)" ] && git config --global core.hooksPath "$HOME/.pear/githooks" && echo "git hooks: commit-msg guard installed"
# REA (Reverse Engineer Anything: MCP for Ghidra/IDA/Hopper), by its own guide: github.com/morluto/rea
if command -v npx >/dev/null 2>&1; then npx -y rea-agents setup --client claude_code >/dev/null 2>&1 && echo "REA configured (rea doctor to check)" || echo "REA: run  npx -y rea-agents setup --client claude_code  (dry run: rea setup --client claude_code --dry-run --json), then  rea doctor"; else echo "REA needs node/npm: install node, then  npx -y rea-agents setup --client claude_code"; fi
if command -v claude >/dev/null 2>&1; then claude plugin marketplace add JuliusBrussee/caveman >/dev/null 2>&1 && claude plugin install caveman@caveman >/dev/null 2>&1 && echo "caveman installed" || echo "caveman: install it by hand: claude plugin marketplace add JuliusBrussee/caveman && claude plugin install caveman@caveman"; fi
command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 || echo "gh is not logged in: run  gh auth login  (needed for repos and CI)"
sh "$HERE/scripts/clone-all.sh"
echo "Done. Start claude in ~/pearOS and type /status (or /work <task>)."
echo "Plugin alternative (namespaced commands): /plugin marketplace add pearOS-bsd/pearos-skill  then  /plugin install pearos@pearos-skill"
