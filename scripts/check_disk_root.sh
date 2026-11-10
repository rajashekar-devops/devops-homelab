#!/bin/bash
set -euo pipefail

MOUNT_POINT="/"
THRESHOLD=80

#Check root file system disk usage
CURRENT_USAGE=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Checking root filesystem usage: $MOUNT_POINT"

if [ "$CURRENT_USAGE" -ge "$THRESHOLD" ]; then
	echo "[ALERT] Critical! Disk usage is: $CURRENT_USAGE, Limit: ${THRESHOLD}"
	exit 1
else
	echo "[OK] Disk usage is: $CURRENT_USAGE, Limit: ${THRESHOLD}"
	exit 0
fi
