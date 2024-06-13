# Restic docker

This repository aim to create a container capable to backup files with restic
using rclone to be compatible with any provider.

## Getting started

To use this container you can launch it from docker cli, for example using
rclone:

```sh-session
$ docker run \
    -e RESTIC_PASSWORD="your_password" \
    -e RESTIC_REPOSITORY="rclone:your_config:path_in_ftp" \
    -v "./rclone.conf:/root/.config/rclone/rclone.conf:ro" \
    -v "./path-to-backup:/backup/"
    Its-Alex/restic-docker:latest
```

Or add it to a `docker-compose.yml`:

```yaml
  restic:
    image: Its-Alex/restic-docker:latest
    environment:
        RESTIC_PASSWORD="your_password" # Use your repository password
        RESTIC_REPOSITORY="rclone:your_config:path_in_ftp" # Add your config and path
    volumes:
      - ./rclone.conf:/root/.config/rclone/rclone.conf:ro # Add your ftp to rclone config file
      - ./path-to-backup:/backup/
```

You can configure `backup` and `forget` commands using
[environment variables](#configuration).

You can execute [`restic`](https://github.com/restic/restic) commands from the
container using [`command` argument of docker run](https://docs.docker.com/reference/cli/docker/container/run/),
for example to list existing snapshots:

```sh-session
$ docker run --rm \
    --network "restic-docker" \
    -e "RESTIC_PASSWORD=your_password" \
    -e "RESTIC_REPOSITORY=rclone:your_config:path_in_ftp" \
    -v "./rclone.conf:/root/.config/rclone/rclone.conf:ro" \
    -v ./path-to-restore-folder:/restore/ \
    Its-Alex/restic-docker:latest \
    snapshots
```

Or to restore a snapshot:

```sh-session
$ docker run --rm \
    --network "restic-docker" \
    -e "RESTIC_PASSWORD=your_password" \
    -e "RESTIC_REPOSITORY=rclone:your_config:path_in_ftp" \
    -v "./rclone.conf:/root/.config/rclone/rclone.conf:ro" \
    -v ./path-to-restore-folder:/restore/ \
    Its-Alex/restic-docker:latest \
    restore a46d6b7e -t "/restore"
```

## Configuration

To configure `restic-docker`, you can use environment variables from both `restic` and `restic-docker`, as documented below.

Please note that the `RESTIC_DOCKER_` prefix is used for `restic-docker` project environment variables.  
When the `_DOCKER_` suffix is not present in the prefix, these are the environment variables supported in the restic project.

For information on environment variables supported in the restic project, refer to [this documentation](https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables).

| Name                               | Default     | Description                                                                                                                                                                              |
| ---------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RESTIC_DOCKER_BACKUP_CRON_SCHEDULE | `0 * * * *` | Cron expression to launch [backup script](/backup.sh)                                                                                                                                    |
| RESTIC_DOCKER_BACKUP_FOLDER        | `/backup`   | Backup path                                                                                                                                                                              |
| RESTIC_DOCKER_IS_FORGET_ENABLE     | `1`         | Enable or disable `restic forget script in crontab`                                                                                                                                      |
| RESTIC_DOCKER_FORGET_CRON_SCHEDULE | `0 0 * * *` | Cron expression to launch [forget script](/forget.sh)                                                                                                                                    |
| RESTIC_DOCKER_KEEP_HOURLY          | `24`        | argument for `--keep-hourly` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy)  |
| RESTIC_DOCKER_KEEP_DAILY           | `7`         | argument for `--keep-daily` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy)   |
| RESTIC_DOCKER_KEEP_WEEKLY          | `4`         | argument for `--keep-weekly` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy)  |
| RESTIC_DOCKER_KEEP_MONTHLY         | `12`        | argument for `--keep-monthly` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy) |

## Demo

You can try the container `restic-docker` with some examples:

- Backup in `ftp` in [/demo/ftp](/demo/ftp) folder.

## License

Restic docker is licensed under [BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause).
You can find the complete text in [`LICENSE`](LICENSE).
