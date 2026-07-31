#!/bin/bash
# Starts LogiNook as a clean restart: gracefully closes a running instance first.
set -euo pipefail

BUNDLE_ID="com.logimox.loginook"
APP_PATH="${1:-$HOME/Applications/LogiNook.app}"

if ! [ -d "$APP_PATH" ]; then
  echo "LogiNook was not found at: $APP_PATH" >&2
  exit 1
fi

if pgrep -f '/LogiNook.app/Contents/MacOS/LogiNook' >/dev/null; then
  osascript -e "tell application id \"$BUNDLE_ID\" to quit" || true
  for _ in {1..50}; do
    pgrep -f '/LogiNook.app/Contents/MacOS/LogiNook' >/dev/null || break
    sleep 0.1
  done
fi

if pgrep -f '/LogiNook.app/Contents/MacOS/LogiNook' >/dev/null; then
  echo "LogiNook did not exit cleanly; refusing to start another instance." >&2
  exit 1
fi

open -n "$APP_PATH"
echo "Started LogiNook: $APP_PATH"
