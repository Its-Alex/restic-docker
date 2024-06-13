# Demo

This demo launch two services:

- [`stilliard/pure-ftpd`](https://github.com/stilliard/docker-pure-ftpd)
- [`Its-Alex/restic-docker`](/)

You can find their configuration in [docker-compose.yml](./docker-compose.yml).

## Setup

You can launch the demo using:

```sh-session
$ docker compose build && docker compose up -d
```

Then you can go see the logs:

```sh-session
$ docker compose logs
restic-1       | main.crontab content:
restic-1       | # Backup script
restic-1       | */1 * * * * flock -n /opt/restic/backup.lockfile /opt/restic/backup.sh
restic-1       |
restic-1       | # Forget script
restic-1       | */2 * * * * flock -n /opt/restic/forget.lockfile /opt/restic/forget.sh
restic-1       | time="2024-06-05T21:06:07Z" level=info msg="read crontab: /opt/restic/main.crontab"
ftpd_server-1  | Creating user...
ftpd_server-1  | Password:
ftpd_server-1  | Enter it again:
ftpd_server-1  |  root user give /home/restic directory ftpuser owner
ftpd_server-1  | Setting default port range to: 30000:30009
ftpd_server-1  | Setting default max clients to: 5
ftpd_server-1  | Setting default max connections per ip to: 5
ftpd_server-1  | Starting Pure-FTPd:
ftpd_server-1  |   pure-ftpd  -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P localhost   -p 30000:30009 -c 5 -C 5
```

`restic-docker` is configured to make backup every minute, and forget every
two minutes. Configuration can be checked in [docker-compose.yml](./docker-compose.yml).
So wait few minutes to have snapshots availables.

## How to restore a snapshot

First you should list all availables snapshots:

```sh-session
$ docker run --rm \
    --network "restic-docker" \
    -e "RESTIC_PASSWORD=password" \
    -e "RESTIC_REPOSITORY=rclone:ftpd_server:backup" \
    -v "./rclone.conf:/root/.config/rclone/rclone.conf:ro" \
    -v ./restore:/restore/ \
    Its-Alex/restic-docker:latest \
    snapshots
ID        Time                 Host          Tags        Paths
----------------------------------------------------------------
a46d6b7e  2024-06-06 12:47:03  62e7fedad946              /backup
0762a2d6  2024-06-06 12:59:00  62e7fedad946              /backup
7ee735a9  2024-06-06 13:00:11  62e7fedad946              /backup
ae11ed5e  2024-06-06 13:01:00  690b65f37948              /backup
----------------------------------------------------------------
4 snapshots
```

Select the snapshot to restore and use:

```sh-session
$ docker run --rm \
    --network "restic-docker" \
    -e "RESTIC_PASSWORD=password" \
    -e "RESTIC_REPOSITORY=rclone:ftpd_server:backup" \
    -v "./rclone.conf:/root/.config/rclone/rclone.conf:ro" \
    -v ./restore:/restore/ \
    Its-Alex/restic-docker:latest \
    restore a46d6b7e -t "/restore"
restoring <Snapshot a46d6b7e of [/backup] at 2024-06-06 12:47:03.188732624 +0000 UTC by root@62e7fedad946> to /restore
Summary: Restored 2 files/dirs (19 B) in 0:00
```

## Hack

Once containers are launch you can go inside the restic container and hack it:

```sh-session
$ docker compose exec -it restic bash
ae16c8e29554:/#
```