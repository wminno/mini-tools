#!/bin/bash
# delta-2 watchdog: keeps uds_server + cloudflared tunnel alive.
# If the tunnel URL changes, rewrites it into index.html + uds_server.py and restarts the app.
URL_FILE=/home/user/app/public_url.txt
LOG=/home/user/watchdog2.log
cd /home/user/app || exit 1
[ -f "$URL_FILE" ] || echo "https://goals-chips-asia-curtis.trycloudflare.com" > "$URL_FILE"
while true; do
  # 1) app server health over the unix socket
  if ! curl -s -m 4 --unix-socket /tmp/app.sock http://localhost/health | grep -q '"ok"'; then
    if ! pgrep -f "uds_[s]erver.py" >/dev/null; then
      setsid nohup python3 uds_server.py >> /home/user/uds.log 2>&1 < /dev/null &
      echo "$(date -u '+%F %T') restarted uds_server" >> "$LOG"
    fi
    sleep 2
  fi
  # 2) cloudflared tunnel process
  if ! pgrep -f "/path/to/cloudflared tunnel" >/dev/null; then
    setsid nohup /path/to/cloudflared tunnel --config cfg.yml --no-autoupdate --url http://localhost:1 >> cf3.log 2>&1 < /dev/null &
    sleep 12
    NEW=$(grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' cf3.log | tail -1)
    CUR=$(cat "$URL_FILE")
    if [ -n "$NEW" ] && [ "$NEW" != "$CUR" ]; then
      echo "$NEW" > "$URL_FILE"
      python3 - "$NEW" <<'PY'
import re, sys
new = sys.argv[1]
for f in ("index.html", "uds_server.py"):
    s = open(f).read()
    s = re.sub(r'https://[a-zA-Z0-9-]*\.trycloudflare\.com', new, s)
    open(f, "w").write(s)
print("rewrote urls")
PY
      pkill -f "uds_[s]erver.py"
      sleep 1
      setsid nohup python3 uds_server.py >> /home/user/uds.log 2>&1 < /dev/null &
      echo "$(date -u '+%F %T') URL changed -> $NEW (refs rewritten)" >> "$LOG"
    fi
  fi
  sleep 60
done
