#!/usr/bin/env bash
set -euo pipefail
HOST="${1:?host required}"
PORT="${2:?port required}"
bash -c "exec 3<>/dev/tcp/${HOST}/${PORT}" >/dev/null 2>&1
