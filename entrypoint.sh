#!/bin/bash
set -euo pipefail

RESTIC_FTP_DOCKER_BACKUP_CRON_SCHEDULE=${RESTIC_FTP_DOCKER_BACKUP_CRON_SCHEDULE:-"0 * * * *"}
RESTIC_FTP_DOCKER_PRUNE_CRON_SCHEDULE=${RESTIC_FTP_DOCKER_PRUNE_CRON_SCHEDULE:-"0 0 * * *"}
RESTIC_FTP_DOCKER_PRUNE_ENABLE=${RESTIC_FTP_DOCKER_PRUNE_ENABLE:-"1"}

sed -i "s#RESTIC_FTP_DOCKER_BACKUP_CRON_SCHEDULE#$RESTIC_FTP_DOCKER_BACKUP_CRON_SCHEDULE#g" /opt/restic/main.crontab
if [[ $RESTIC_FTP_DOCKER_PRUNE_ENABLE == "1" || $RESTIC_FTP_DOCKER_PRUNE_ENABLE == "true" ]]; then
    echo "
# Prune script
$RESTIC_FTP_DOCKER_PRUNE_CRON_SCHEDULE flock -n /opt/restic/prune.lockfile /opt/restic/prune.sh" >> /opt/restic/main.crontab
fi

supercronic /opt/restic/main.crontab
