#!/bin/bash
set -euo pipefail

export RESTIC_DOCKER_BACKUP_FOLDER=${RESTIC_DOCKER_BACKUP_FOLDER:="/backup"}
export RESTIC_DOCKER_IS_FORGET_ENABLE=${RESTIC_DOCKER_IS_FORGET_ENABLE:=""}

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

if [[ $RESTIC_DOCKER_IS_FORGET_ENABLE == "1" || $RESTIC_DOCKER_IS_FORGET_ENABLE == "true" ]]; then
    echo "Forgetting old snapshots"
    # As a result of network problems or other types of issues that I can't remember,
    # a loop is implemented here to make 5 backup attempts before returning an error.
    retry_count=0
    max_retries=5
    while ! restic forget \
            --compact \
            --prune \
            --keep-hourly="${RESTIC_DOCKER_KEEP_HOURLY:-24}" \
            --keep-daily="${RESTIC_DOCKER_KEEP_DAILY:-7}" \
            --keep-weekly="${RESTIC_DOCKER_KEEP_WEEKLY:-4}" \
            --keep-monthly="${RESTIC_DOCKER_KEEP_MONTHLY:-12}"; do
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
fi