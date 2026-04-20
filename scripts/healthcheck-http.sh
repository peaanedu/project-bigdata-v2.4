#!/usr/bin/env bash
set -euo pipefail
URL="${1:?usage: healthcheck-http.sh <url>}"
python3 - <<'PY' "$URL"
import sys, urllib.request
urllib.request.urlopen(sys.argv[1], timeout=5)
PY
