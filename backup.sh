#!/bin/bash
set -euo pipefail

export RESTIC_DOCKER_BACKUP_FOLDER=${RESTIC_DOCKER_BACKUP_FOLDER:="/backup"}

if ! restic unlock; then
    echo "Init restic repository..."
	restic init
fi

echo "Perform backup..."
# As a result of network problems or other types of issues that I can't remember,
# a loop is implemented here to make 5 backup attempts before returning an error.
retry_count=0
max_retries=5
while ! restic backup "$RESTIC_DOCKER_BACKUP_FOLDER"; do
    retry_count=$((retry_count + 1))
    if [ $retry_count -ge $max_retries ]; then
        echo "Reached maximum retry limit of $max_retries. Exiting."
        exit 1
    fi
    echo "Sleeping for 10 seconds before retry..."
    sleep 10
done
