#!/usr/bin/env bash

OUT="ips.txt"
SNI="your.example.com"
ATTEMPTS=5
TIMEOUT=2
which masscan &>/dev/null || eval 'echo "please install masscan package first." && exit 1'
[[ -f good_ips ]] && rm good_ips
echo "[*] Masscan: scanning Cloudflare ranges..."

sudo masscan -p443 \
  104.16.0.0/13 104.24.0.0/14 173.245.48.0/20 \
  103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 \
  141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 \
  188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 \
  162.158.0.0/15 172.64.0.0/13 131.0.72.0/22 \
  --max-rate 5000 \
  --wait 5 \
  -oL "$OUT"

[[ ! -s "$OUT" ]] && { echo "no clean ip(s) found :-("; exit 1; }

awk '/open/ {print $4}' "$OUT" | sort -u | while read -r ip; do
  echo
  echo "[*] Initial TLS check: $ip"

  # ---- FIRST TLS CHECK (gate) ----
  if ! timeout 3 openssl s_client \
        -connect "$ip:443" \
        -servername "$SNI" \
        </dev/null >/dev/null 2>&1; then
    echo "[SKIP] TLS failed on first try: $ip"
    continue
  fi

  echo "[PASS] Initial TLS OK, running reliability test..."

  # ---- RELIABILITY TEST ----
  success=1   # first success already counted

  for ((i=2; i<=ATTEMPTS; i++)); do
    if timeout 3 openssl s_client \
          -connect "$ip:443" \
          -servername "$SNI" \
          </dev/null >/dev/null 2>&1; then
      ((success++))
      echo "  attempt $i: OK"
    else
      echo "  attempt $i: FAIL"
    fi
  done

  case $success in
    4|5)
      echo "[GOOD]   $ip ($success/$ATTEMPTS handshakes)"
      echo "$ip" >> good_ips
      ;;
    2|3)
      echo "[NORMAL] $ip ($success/$ATTEMPTS handshakes)"
      ;;
    *)
      echo "[BAD]    $ip ($success/$ATTEMPTS handshakes)"
      ;;
  esac

done
