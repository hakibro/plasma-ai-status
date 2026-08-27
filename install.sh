#!/usr/bin/env bash
# Install / upgrade / package the AI Status (9router) plasmoid.
set -euo pipefail
cd "$(dirname "$0")"

ID="com.wonocraft.aistatus"
TOOL="kpackagetool6"
TYPE="Plasma/Applet"
HELPER_DST="$HOME/.local/bin/9r-token"

cmd="${1:-install}"

case "$cmd" in
  install)
    "$TOOL" --type "$TYPE" -r "$ID" 2>/dev/null || true
    "$TOOL" --type "$TYPE" -i package
    mkdir -p "$HOME/.local/bin"
    install -m 0755 bin/9r-token "$HELPER_DST"
    echo
    echo "Installed: $ID"
    echo "Helper installed at: $HELPER_DST  (run '9r-token' anytime to print the token)"
    if tok="$(./bin/9r-token 2>/dev/null)"; then
      echo "Your CLI token: $tok"
    else
      echo "Could not auto-read token. Run: 9r-token"
    fi
    echo "Next: open 'Add Widgets', add 'AI Status (9router)', then paste the token in its settings."
    echo "If it does not appear, restart the shell:  kquitapp6 plasmashell && kstart6 plasmashell"
    ;;
  remove)
    "$TOOL" --type "$TYPE" -r "$ID"
    rm -f "$HELPER_DST"
    echo "Removed: $ID (and helper)"
    ;;
  package)
    rm -f plasma-ai-status.plasmoid
    python3 - "$ID" <<'PY'
import os, sys, zipfile
root = "package"
out = "plasma-ai-status.plasmoid"
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for dp, _, fns in os.walk(root):
        for fn in fns:
            p = os.path.join(dp, fn)
            z.write(p, os.path.relpath(p, root))
print("wrote", out)
PY
    ;;
  token)
    ./bin/9r-token
    ;;
  *)
    echo "usage: $0 [install|remove|package|token]" >&2
    exit 1
    ;;
esac
