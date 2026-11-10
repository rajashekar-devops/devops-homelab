#!/bin/bash
set -euo pipefail

#Configuration
LOG_DIR="/tmp/app_logs"
COMPRESS_DAYS=7
RETENTION_DAYS=30

echo "Starting log rotation job for: ${LOG_DIR}"

#Verification: Check if target directory exists
if [ ! -d "$LOG_DIR" ]; then
	echo "ERROR: Directory $LOG_DIR doesnot exists"
	exit 1
fi

# Step 1: Compress uncompressed .log files older than COMPRESS_DAYS
echo "Compressing .log files older than ${COMPRESS_DAYS} days..."
find "$LOG_DIR" -type f -name "*.log" -mtime +"$COMPRESS_DAYS" -exec gzip {} \;

# Step 2: Delete old compressed .gz files older than RETENTION_DAYS
echo "Purging .gz files older than ${RETENTION_DAYS} days..."
find "$LOG_DIR" -type f -name "*.gz" -mtime +"$RETENTION_DAYS" -delete

echo "Log rotation completed successfully"
exit 0

