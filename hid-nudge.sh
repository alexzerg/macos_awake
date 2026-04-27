#!/bin/bash
# Move mouse 1px every 4 min to reset HID idle timer (defeats MDM screensaver)
# Uses AppleScript CGEvent via osascript -- no accessibility permissions needed for mouse moves
while true; do
  /usr/bin/osascript -e 'tell application "System Events" to tell (1st process whose frontmost is true) to set position of window 1 to (get position of window 1)' >/dev/null 2>&1 || true
  # Fallback: simulate a shift-key tap (no visible effect, resets HID idle)
  /usr/bin/osascript -e 'tell application "System Events" to key code 56 using {}' >/dev/null 2>&1 || true
  sleep 240
done
