# Cloudflare TLS Reliability Scanner

A Bash-based tool to **discover Cloudflare edge IPs with open port 443** and **evaluate their TLS handshake reliability** against a specific SNI.

This script is useful in environments where:

* Direct outbound access is restricted
* Only ports **80/443** are allowed
* Traffic must be proxied through Cloudflare IPs
* Stable and repeatable TLS connectivity is critical (e.g. ProxyPass, reverse proxies, tunneling)

---

## ✨ Features

* Scans official Cloudflare IP ranges using **masscan**
* Filters IPs with port **443 open**
* Performs an **initial TLS gate check** (fast reject of bad IPs)
* Runs **multiple TLS handshake attempts** to measure reliability
* Categorizes IPs as **GOOD / NORMAL / BAD**
* Saves reliable IPs into a reusable file (`good_ips`)

---

## 📦 Requirements

* Linux
* `bash`
* `masscan`
* `openssl`
* `timeout` (usually from `coreutils`)
* `sudo` privileges (required by masscan)

Install masscan (example):

```bash
sudo apt install masscan
```

---

## ⚙️ Configuration

Edit the variables at the top of the script:

```bash
OUT="ips.txt"                 # masscan output file
SNI="your.example.com"        # Server Name Indication (IMPORTANT)
ATTEMPTS=10                    # Total TLS handshake attempts per IP
TIMEOUT=2                      # Timeout per handshake (seconds)
```

⚠️ **SNI must match a valid hostname served behind Cloudflare**, otherwise TLS checks will fail.

---

## 🚀 Usage

```bash
chmod +x scan.sh
./scan.sh
```

The script will:

1. Scan Cloudflare IP ranges on port 443
2. Perform an initial TLS handshake test
3. Run reliability checks on passing IPs
4. Output results to the console
5. Save GOOD IPs into `good_ips`

---

## 📊 Result Classification

| Status | Condition                         |
| ------ | --------------------------------- |
| GOOD   | 4–5 successful TLS handshakes     |
| NORMAL | 2–3 successful TLS handshakes     |
| BAD    | Less than 2 successful handshakes |

Only **GOOD** IPs are written to `good_ips`.

---

## 📁 Output Files

* `ips.txt` — raw masscan output
* `good_ips` — Cloudflare IPs with stable TLS connectivity

---

## 🔐 Why This Exists

In restricted or filtered networks, **not all Cloudflare IPs behave equally**.
Some edges:

* Drop TLS handshakes
* Reset connections
* Are unstable over time

This tool helps you **select only reliable Cloudflare IPs** for:

* Reverse proxies
* ProxyPass setups
* Tunnels
* Whitelisted outbound access

---

## ⚠️ Notes

* Scanning large IP ranges may trigger IDS/IPS systems
* Adjust `--max-rate` if you experience packet loss
* Cloudflare IP ranges may change over time

---

## 📜 License

MIT License

---

## 🤝 Contributing

PRs and improvements are welcome:

* Better TLS validation
* IPv6 support
* Parallel TLS checks
* JSON / CSV output

---

Happy scanning ☁️
