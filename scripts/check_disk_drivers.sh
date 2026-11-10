#!/bin/bash
set -euo pipefail

MOUNT_POINT="/usr/lib/wsl/drivers"
THRESHOLD=80

#Capture current percentage as an integer
CURRENT_USAGE=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Checking filesystem mounted at: $MOUNT_POINT"

if [ "$CURRENT_USAGE" -ge "$THRESHOLD" ]; then
	echo "[ALERT] Disk space critical! Current usage: ${CURRENT_USAGE}% (Limit: ${THRESHOLD}%)"
	exit 1
else
	echo "[OK]: Disk space healthy. Current usage: ${CURRENT_USAGE}% (Limit: ${THRESHOLD}%)"
	exit 0
fi
