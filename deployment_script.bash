#!/bin/bash

# ==============================================================================
# PROJECT AETHER-SHIELD: MASTER RANGE PROVISIONING PIPELINE
# Focus: Active Session Hijacking (Pass-the-Cookie) & Threat Telemetry Lab
# Framework: Docker Compose, Nginx Reverse Proxy, Node.js Core Backend
# Architecture: Dual-Container Isolation with Structured JSON Forensics Logs
# Target Base: Ubuntu Server / Debian Minimal (VirtualBox or Proxmox Host)
# ==============================================================================

set -euo pipefail

# Define enterprise-aligned directory paths
BASE_DIR="/opt/aether-shield"
LOG_DIR="$BASE_DIR/telemetry"
APP_DIR="$BASE_DIR/src/gateway-service"
PROXY_DIR="$BASE_DIR/src/proxy-service"

echo "======================================================================"
echo "[*] INITIALIZING ENTERPRISE THREAT SIMULATION RANGE: AETHER-SHIELD"
echo "======================================================================"

# 1. System Dependencies & Baseline Verification
echo "[*] Resolving host system dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl git openssh-server python3 gnupg lsb-release jq

# 2. Docker & Docker Compose Check
if ! command -v docker &> /dev/null; then
    echo "[*] Docker engine not detected. Provisioning official docker platform..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# 3. Create Custom SecOps Analyst User (SSH Access Layer)
# Rebranded away from assessment defaults to fit real corporate profiles
ANALYST_USER="secops_analyst"
ANALYST_PASS="AetherShieldSecOps2026!"
SSH_PORT="2288" # Pivot away from CTF ports to clean corporate custom ports

echo "[*] Configuring SecOps Analyst execution space..."
if ! id "$ANALYST_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$ANALYST_USER"
    echo "$ANALYST_USER:$ANALYST_PASS" | chpasswd
    usermod -aG sudo "$ANALYST_USER"
    echo "[+] Established security credential set for: $ANALYST_USER"
fi

echo "[*] Standardizing Secure Shell configuration (Custom Port $SSH_PORT)..."
if ! grep -q "Port $SSH_PORT" /etc/ssh/sshd_config; then
    echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
    systemctl restart sshd || service ssh restart
    echo "[+] Daemon updated. SSH accessible on Port $SSH_PORT."
fi

# 4. Construct Workspace Layout
echo "[*] Structuring internal folders under $BASE_DIR..."
mkdir -p "$LOG_DIR" "$APP_DIR" "$PROXY_DIR"

# 5. Compile Rebranded Vulnerable Gateway Service (Node.js)
echo "[*] Generating containerized backend service code..."

cat << 'EOF' > "$APP_DIR/package.json"
{
  "name": "aether-gateway-portal",
  "version": "2.1.0",
  "description": "Production-grade core gateway mimicking legacy session validation vulnerabilities",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "cookie-parser": "^1.4.6",
    "express": "^4.19.2"
  }
}
EOF

cat << 'EOF' > "$APP_DIR/server.js"
const express = require('express');
const cookieParser = require('cookie-parser');
const app = express();
const PORT = 3000;

app.use(cookieParser());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Set customized server fingerprinting
app.use((req, res, next) => {
    res.setHeader('X-Platform-Engine', 'Aether-Core-V2');
    next();
});

let systemReviewStore = "No active network management logs submitted.";

app.get('/', (req, res) => {
    // Generate vulnerable pre-auth cookie tracking the user state
    if (!req.cookies['aether_session_state']) {
        res.cookie('aether_session_state', 'auth_handshake_pending', { 
            httpOnly: false, // Intentional security flaw: script accessible
            path: '/' 
        });
    }

    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Aether Industries - Internal Operations Portal</title>
            <style>
                body { font-family: sans-serif; background: #0f172a; color: #f1f5f9; padding: 40px; }
                .card { background: #1e293b; padding: 25px; border-radius: 8px; border: 1px solid #334155; max-width: 600px; margin: auto; }
                textarea { width: 100%; background: #0f172a; color: #fff; border: 1px solid #475569; border-radius: 4px; padding: 10px; box-sizing: border-box; }
                button { background: #0284c7; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; }
                button:hover { background: #0369a1; }
                .notice { color: #94a3b8; font-size: 0.85em; margin-top: 15px; }
            </style>
        </head>
        <body>
            <div class="card">
                <h2>Administrative Incident Reporting Gateway</h2>
                <p>Submit diagnostic logs or operational issues to System Engineering below.</p>
                <form action="/api/v1/telemetry/submit" method="POST">
                    <label for="feedback">Incident Details:</label><br><br>
                    <textarea id="feedback" name="feedback" rows="5" placeholder="Paste traceroute or service stacktrace..."></textarea><br><br>
                    <button type="submit">Route Diagnostic Payload</button>
                </form>
                <div class="notice">
                    Note: All inbound diagnostics are automatically parsed for sanitization checks. Refer to system robots.txt for routing definitions.
                </div>
            </div>
        </body>
        </html>
    `);
});

app.get('/robots.txt', (req, res) => {
    res.type('text/plain');
    res.send("User-agent: *\nDisallow: /api/v1/auth/mfa-handshake\nDisallow: /console/dashboard");
});

app.get('/api/v1/auth/mfa-handshake', (req, res) => {
    res.status(200).json({ status: "MFA challenge receiver online." });
});

// Rudimentary Web Application Firewall implementation
app.post('/api/v1/telemetry/submit', (req, res) => {
    const payload = req.body.feedback || "";
    
    // Rudimentary signature analysis (Blocks classic script injection)
    if (payload.toLowerCase().includes('<script>')) {
        return res.status(403).send("<h1>403 Forbidden - Security Signature Blocked</h1>");
    }
    
    systemReviewStore = payload;
    res.send(`<h3>Diagnostics Received. Routing to admin queue.</h3><br><a href="/">Return</a>`);
});

// Critical Administrative Panel (Vulnerable to Session Hijacking replay)
app.get('/console/dashboard', (req, res) => {
    const activeToken = req.cookies['aether_session_state'] || "";
    
    // Verification Bypass Vulnerability: Simply check for custom admin token prefix
    if (activeToken.startsWith('aether_sess_admin_')) {
        return res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Aether Operations Console</title>
                <style>
                    body { font-family: monospace; background: #020617; color: #38bdf8; padding: 40px; }
                    .terminal { background: #090d16; border: 1px solid #1e293b; padding: 25px; border-radius: 6px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
                    .log-alert { color: #ef4444; border-left: 4px solid #ef4444; padding-left: 15px; margin: 20px 0; }
                    .flag-box { border: 1px dashed #22c55e; padding: 10px; color: #22c55e; }
                </style>
            </head>
            <body>
                <div class="terminal">
                    <h2>SYSTEM CONSOLE: MASTER OPERATIONS ACTIVE</h2>
                    <p>SecOps Clearance Status: Absolute Operator Verified.</p>
                    
                    <div class="flag-box">
                        SECURE CONFIG TOKEN: [ AETHER_SYSTEM_SESSION_BYPASS_VERIFIED ]
                    </div>
                    
                    <div class="log-alert">
                        <strong>Live Diagnostic Queue Review:</strong><br><br>
                        <div style="color: #cbd5e1;">${systemReviewStore}</div>
                    </div>
                </div>
            </body>
            </html>
        `);
    } else {
        return res.status(401).send("<h1>401 Access Denied: MFA State Verification Required</h1>");
    }
});

app.listen(PORT, () => {
    console.log(`Gateway process active on local port ${PORT}`);
});
EOF

cat << 'EOF' > "$APP_DIR/Dockerfile"
FROM node:20-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY server.js .
EXPOSE 3000
CMD [ "npm", "start" ]
EOF

# 6. Configure Nginx with SIEM-ready Structured Logging
# Translating standard logs into high-fidelity structured formats
echo "[*] Formatting structured Nginx reverse proxy configurations..."
cat << 'EOF' > "$PROXY_DIR/nginx.conf"
events { worker_connections 1024; }

http {
    # Modern Enterprise Standard: JSON Structured Logging for Easy SIEM ingestion
    log_format siem_json escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"client_ip":"$remote_addr",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"http_referrer":"$http_referer",'
        '"user_agent":"$http_user_agent",'
        '"session_cookie":"$http_cookie",'
        '"forwarded_for":"$http_x_forwarded_for"'
    '}';

    access_log /var/log/nginx/siem_access.json siem_json;
    error_log /var/log/nginx/siem_error.log warn;

    server {
        listen 80;

        location / {
            proxy_pass http://gateway-core:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF

# 7. Establish Docker Compose Orchestration Layer
echo "[*] Drafting docker-compose manifest..."
cat << 'EOF' > "$BASE_DIR/docker-compose.yml"
version: '3.8'

services:
  gateway-core:
    build:
      context: ./src/gateway-service
      dockerfile: Dockerfile
    container_name: aether-gateway-app
    expose:
      - "3000"
    restart: always

  reverse-proxy:
    image: nginx:alpine
    container_name: aether-nginx-proxy
    ports:
      - "80:80"
    volumes:
      - ./src/proxy-service/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./telemetry:/var/log/nginx
    depends_on:
      - gateway-core
    restart: always
EOF

# 8. Deploy Containerized Network Core
echo "[*] Booting Docker container services..."
cd "$BASE_DIR"
docker compose down -v --remove-orphans || true
docker compose up -d --build

# 9. Forensics Log Generation Script (Active Telemetry Seeding)
echo "[*] Executing diagnostic telemetry logs (Blue Team Forensics Trail)..."
sleep 4

ATTACKER_IP="10.10.14.50"
LEGIT_IP="192.168.1.100"
MOCK_UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0"
# Rebranded base64 string matching the requested length and format (custom key payload)
SECURE_B64="QUVUSEVSX1NJRU1fTE9HX0ZPUkVOU0lDU19NQVNURVI="

# Generate Siem JSON Access Logs
cat << EOF > "$LOG_DIR/siem_access.json"
{"timestamp":"2026-07-05T08:45:12+07:00","client_ip":"$LEGIT_IP","request_method":"GET","request_uri":"/console/dashboard","status":200,"body_bytes_sent":2540,"http_referrer":"-","user_agent":"$MOCK_UA","session_cookie":"aether_session_state=aether_sess_admin_x9812y3d","forwarded_for":"-"}
{"timestamp":"2026-07-05T08:48:33+07:00","client_ip":"$ATTACKER_IP","request_method":"GET","request_uri":"/","status":200,"body_bytes_sent":4120,"http_referrer":"-","user_agent":"$MOCK_UA","session_cookie":"aether_session_state=auth_handshake_pending","forwarded_for":"-"}
{"timestamp":"2026-07-05T08:49:01+07:00","client_ip":"$ATTACKER_IP","request_method":"GET","request_uri":"/robots.txt","status":200,"body_bytes_sent":152,"http_referrer":"-","user_agent":"$MOCK_UA","session_cookie":"aether_session_state=auth_handshake_pending","forwarded_for":"-"}
{"timestamp":"2026-07-05T08:50:15+07:00","client_ip":"$ATTACKER_IP","request_method":"POST","request_uri":"/api/v1/telemetry/submit","status":403,"body_bytes_sent":320,"http_referrer":"http://$ATTACKER_IP/","user_agent":"$MOCK_UA","session_cookie":"aether_session_state=auth_handshake_pending","forwarded_for":"-"}
{"timestamp":"2026-07-05T08:51:10+07:00","client_ip":"$ATTACKER_IP","request_method":"POST","request_uri":"/api/v1/telemetry/submit","status":200,"body_bytes_sent":204,"http_referrer":"http://$ATTACKER_IP/","user_agent":"$MOCK_UA","session_cookie":"aether_session_state=auth_handshake_pending","forwarded_for":"-"}
{"timestamp":"2026-07-05T08:51:55+07:00","client_ip":"$ATTACKER_IP","request_method":"GET","request_uri":"/console/dashboard","status":200,"body_bytes_sent":2540,"http_referrer":"-","user_agent":"$MOCK_UA","session_cookie":"aether_session_state=aether_sess_admin_x9812y3d","forwarded_for":"$SECURE_B64"}
EOF

# Generate Standard SIEM Error logs
cat << EOF > "$LOG_DIR/siem_error.log"
2026/07/05 08:50:15 [error] 42#42: *11 WAF Security Filter triggered: Reflected script pattern block for client: $ATTACKER_IP
2026/07/05 08:53:10 [crit] 42#42: *18 SECURITY_CRITICAL Anomaly: Session Hijacking Detected. active session token (aether_sess_admin_x9812y3d) concurrently parsed from distinct subnets. Source origin 1: $LEGIT_IP, Source origin 2: $ATTACKER_IP. Execution Terminated.
EOF

# Set target system permissions
chmod -R 755 "$BASE_DIR"
chown -R "$ANALYST_USER:$ANALYST_USER" "$BASE_DIR"

echo "======================================================================"
echo "[+] SUCCESS: ENTERPRISE TELEMETRY RANGE ONLINE!"
echo "    App Location: HTTP / Port 80 (routed dynamically)"
echo "    SecOps SSH Connection: Port $SSH_PORT ($ANALYST_USER / $ANALYST_PASS)"
echo "    Modern SIEM Telemetry Logs: $LOG_DIR/siem_access.json"
echo "======================================================================"