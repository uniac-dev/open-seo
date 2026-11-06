#!/bin/bash
set -Eeuo pipefail
umask 077

if [ "$(id -u)" -eq 0 ]; then
  install -d -o node -g node /state /state/config /state/data /state/web-config
  exec gosu node bash "$0"
fi

children=()
cleanup() {
  trap - EXIT
  if [ "${#children[@]}" -gt 0 ]; then
    kill -TERM "${children[@]}" 2>/dev/null || true
    wait "${children[@]}" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'exit 0' TERM INT

sh /opt/standalone/run.sh &
children+=("$!")
sh /opt/standalone/init.sh
node /opt/standalone/crawl-gateway.mjs &
children+=("$!")

# Restart the whole application if either long-lived process exits.
set +e
wait -n "${children[@]}"
result=$?
exit "$((result == 0 ? 1 : result))"
