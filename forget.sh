#!/bin/bash
set -euo pipefail

if ! restic unlock; then
    echo "Init restic repository..."
	restic init
fi

echo "Forgetting old snapshots"
retry_count=0
max_retries=5
while ! restic forget \
		--compact \
        --prune \
		--keep-hourly="${RESTIC_FTP_DOCKER_KEEP_HOURLY:-24}" \
		--keep-daily="${RESTIC_FTP_DOCKER_KEEP_DAILY:-7}" \
		--keep-weekly="${RESTIC_FTP_DOCKER_KEEP_WEEKLY:-4}" \
		--keep-monthly="${RESTIC_FTP_DOCKER_KEEP_MONTHLY:-12}"; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -ge $max_retries ]; then
        echo "Reached maximum retry limit of $max_retries. Exiting."
        exit 1
    fi
	echo "Sleeping for 10 seconds before retry..."
	sleep 10
done

# Test repository and remove unwanted cache.
restic check --no-lock
rm -rf /tmp/restic-check-cache-*

echo 'Finished forget with prune successfully'
