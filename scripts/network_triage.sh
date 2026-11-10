#!/bin/bash
set -euo pipefail

#  1. Validate input arguments
if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <hostname_or_ip> <port>"
	echo "Example: $0 google.com 443"
	exit 1
fi

TARGET_HOST=$1
TARGET_PORT=$2

echo "===================================================================="
echo "  Starting  Network Triage for: ${TARGET_HOST}:${TARGET_PORT} "
echo "===================================================================="


# 2. DNS Resolution Check
echo -n "[1/3] Checking DNS Resolution..."
RESOLVED_IP=$(dig +short "$TARGET_HOST" | tail -n 1 || true)

if [ -z "$RESOLVED_IP" ]; then
	echo "FAILED"
	echo "ERROR: Unable to resolve hostname '$TARGET_HOST' to an IP address."
	echo 1
else
	echo "OK (Resolved to: $RESOLVED_IP)"
fi

# 3. TCP Port Handshake Check
echo -n "[2/3] Testing TCP connectivity to port ${TARGET_PORT}..."
if nc -zv -w 3 "$TARGET_HOST" "$TARGET_PORT" > /dev/null 2>&1; then
	echo "OPEN / REACHABLE"
else
	echo "CLOSE or FILTERED (Firewall/Security Group drop or service down)"
	exit 1
fi

# 4. HTTP/HTTPS Status Check
echo -n "[3/3] Querying application HTTP status..."
PROTOCOL="http"
if [ "$TARGET_PORT" -eq 443 ]; then
	PROTOCOL="https"
fi

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "${PROTOCOL}://${TARGET_HOST}:${TARGET_PORT}" || echo "000")

if [ "$HTTP_CODE" = "000" ]; then
	echo "No HTTP response (Connection failed or timed out)"
else
	echo "HTTP Status Code: ${HTTP_CODE}"
fi

echo "================================================="
echo "Triage complete."
exit 0
