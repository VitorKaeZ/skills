#!/usr/bin/env bash
# agent-browser with a desktop Chrome user agent, so Google Maps shows the full place panel.
# Usage: browser.sh [--headed] [--profile DIR] <agent-browser command...>
# The session name comes from AB_SESSION (default: lp-research).
set -euo pipefail
extra=()
while [[ $# -gt 0 && "$1" == --* ]]; do
  case "$1" in
    --headed) extra+=(--headed); shift ;;
    --profile) extra+=(--profile "$2"); shift 2 ;;
    *) break ;;
  esac
done
exec agent-browser --session "${AB_SESSION:-lp-research}" "${extra[@]}" \
  --user-agent 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
  --args --disable-blink-features=AutomationControlled "$@"
