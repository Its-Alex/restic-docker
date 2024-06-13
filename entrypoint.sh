#!/bin/bash
set -euo pipefail

# If command are passed to docker container execute restic
if [[ $# -ne 0 ]]; then
    restic "$@"
    exit 0
fi

RESTIC_DOCKER_BACKUP_AND_FORGET_CRON_SCHEDULE=${RESTIC_DOCKER_BACKUP_AND_FORGET_CRON_SCHEDULE:-"0 * * * *"}
RESTIC_DOCKER_IS_FORGET_ENABLE=${RESTIC_DOCKER_IS_FORGET_ENABLE:-"1"}

sed -i "s#RESTIC_DOCKER_BACKUP_AND_FORGET_CRON_SCHEDULE#$RESTIC_DOCKER_BACKUP_AND_FORGET_CRON_SCHEDULE#g" /opt/restic/main.crontab

echo "main.crontab content:"
cat /opt/restic/main.crontab

supercronic /opt/restic/main.crontab
