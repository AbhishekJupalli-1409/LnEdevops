#!/usr/bin/env bash
# Patch a fresh clone of dockersamples/example-voting-app.
# This repo is the Git root (the lne2 folder pushed on its own).
# Usage: patch-voting-app.sh <clone-dir> <repo-root> [vote|worker|result|all]
set -euo pipefail

CLONE="${1:?clone dir}"
ROOT="${2:?repo root}"
ONLY="${3:-all}"

patch_vote() {
  python3 - "$CLONE" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
app = root / "vote" / "app.py"
text = app.read_text()
old = 'g.redis = Redis(host="redis", db=0, socket_timeout=5)'
new = 'g.redis = Redis(host=os.getenv("REDIS_HOST", "redis"), db=0, socket_timeout=5)'
if old not in text:
    raise SystemExit("vote Redis host line not found")
app.write_text(text.replace(old, new, 1))
html = root / "vote" / "templates" / "index.html"
html_text = html.read_text()
old_action = 'action="/"'
new_action = 'action="/vote/"'
if old_action not in html_text:
    raise SystemExit("vote form action not found")
html.write_text(html_text.replace(old_action, new_action, 1))
print("patched vote")
PY
}

patch_worker() {
  cp "$ROOT/patches/worker/Program.cs" "$CLONE/worker/Program.cs"
  cp "$ROOT/patches/worker/Worker.csproj" "$CLONE/worker/Worker.csproj"
  echo "patched worker"
}

patch_result() {
  cp "$ROOT/patches/result/server.js" "$CLONE/result/server.js"
  python3 - "$CLONE" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1]) / "result" / "views"
html = (root / "index.html").read_text()
old_css = "href='/stylesheets/style.css'"
new_css = "href='/result/stylesheets/style.css'"
if old_css not in html:
    raise SystemExit("result stylesheet link not found")
(root / "index.html").write_text(html.replace(old_css, new_css, 1))
js = (root / "app.js").read_text()
old_io = "var socket = io.connect();"
new_io = "var socket = io.connect({ path: '/result/socket.io' });"
if old_io not in js:
    raise SystemExit("result socket.io connect not found")
(root / "app.js").write_text(js.replace(old_io, new_io, 1))
print("patched result paths")
PY
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm is required to add mysql2 before the result image build" >&2
    exit 1
  fi
  (cd "$CLONE/result" && npm install mysql2@3.11.5 --save)
  echo "patched result"
}

case "$ONLY" in
  vote) patch_vote ;;
  worker) patch_worker ;;
  result) patch_result ;;
  all) patch_vote; patch_worker; patch_result ;;
  *) echo "unknown component: $ONLY" >&2; exit 1 ;;
esac
