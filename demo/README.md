# Demo

This demo launch two services:

- [`stilliard/pure-ftpd`](https://github.com/stilliard/docker-pure-ftpd)
- [`Its-Alex/restic-docker`](/)

You can find their configuration in [docker-compose.yml](./docker-compose.yml),

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
restic-1       | # Prune script
restic-1       | */2 * * * * flock -n /opt/restic/prune.lockfile /opt/restic/prune.sh
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

`restic-ftp-docker` is configured to make backup every minute, and prune every
two minutes.

## Hack

Once containers are launch you can go inside the restic container and hack it:

```sh-session
$ docker compose exec -it restic bash
ae16c8e29554:/#
```