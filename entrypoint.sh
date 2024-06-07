#!/bin/bash
set -euo pipefail

# If command are passed to docker container execute restic
if [[ $# -ne 0 ]]; then
    restic "$@"
    exit 0
fi

RESTIC_DOCKER_BACKUP_CRON_SCHEDULE=${RESTIC_DOCKER_BACKUP_CRON_SCHEDULE:-"0 * * * *"}
RESTIC_DOCKER_FORGET_CRON_SCHEDULE=${RESTIC_DOCKER_FORGET_CRON_SCHEDULE:-"0 0 * * *"}
RESTIC_DOCKER_IS_FORGET_ENABLE=${RESTIC_DOCKER_IS_FORGET_ENABLE:-"1"}

sed -i "s#RESTIC_DOCKER_BACKUP_CRON_SCHEDULE#$RESTIC_DOCKER_BACKUP_CRON_SCHEDULE#g" /opt/restic/main.crontab
if [[ $RESTIC_DOCKER_IS_FORGET_ENABLE == "1" || $RESTIC_DOCKER_IS_FORGET_ENABLE == "true" ]]; then
    echo "
# Forget script
$RESTIC_DOCKER_FORGET_CRON_SCHEDULE flock -n /opt/restic/forget.lockfile /opt/restic/forget.sh" >> /opt/restic/main.crontab
fi

echo "main.crontab content:"
cat /opt/restic/main.crontab

supercronic /opt/restic/main.crontab
