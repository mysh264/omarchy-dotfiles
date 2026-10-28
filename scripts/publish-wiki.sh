#!/usr/bin/env bash
# Publish wiki/ to the GitHub Wiki remote.
# First-time only: open https://github.com/mysh264/omarchy-dotfiles/wiki
# and click "Create the first page", save Home with any text, then re-run.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOKEN="${GITHUB_TOKEN:-$(gh auth token)}"
WIKI_URL="https://x-access-token:${TOKEN}@github.com/mysh264/omarchy-dotfiles.wiki.git"
TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

if ! git ls-remote "$WIKI_URL" &>/dev/null; then
  echo "Wiki git remote does not exist yet."
  echo "Open: https://github.com/mysh264/omarchy-dotfiles/wiki"
  echo "Click 'Create the first page', save, then re-run: $0"
  if command -v xdg-open >/dev/null; then xdg-open "https://github.com/mysh264/omarchy-dotfiles/wiki" || true; fi
  exit 1
fi

git clone "$WIKI_URL" "$TMP/wiki"
rsync -a --delete --exclude .git "$ROOT/wiki/" "$TMP/wiki/"
cd "$TMP/wiki"
git add -A
if git diff --cached --quiet; then
  echo "Wiki already up to date."
  exit 0
fi
git -c user.name="$(gh api user --jq '.name // .login')" \
    -c user.email="$(gh api user --jq '.login')@users.noreply.github.com" \
    commit -m "Sync wiki from repository wiki/ folder"
git push origin HEAD:master || git push origin HEAD:main
echo "Published: https://github.com/mysh264/omarchy-dotfiles/wiki"
