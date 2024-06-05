# Restic ftp docker

This container aim to create a container capable to backup files with restic
to a ftp server using rclone.

## Getting started

To use this container you can launch it from docker cli:

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

## Configuration

To configure `restic-ftp-docker`, you can use
[environment variables from `restic`](https://restic.readthedocs.io/en/latest/manual_rest.html)
and environment variables from `restic-ftp-docker` documented below:

| Name                                   | Default     | Description                                                                                                                                                                              |
| -------------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RESTIC_FTP_DOCKER_BACKUP_CRON_SCHEDULE | `0 * * * *` | Cron expression to launch backup script                                                                                                                                                  |
| RESTIC_FTP_DOCKER_BACKUP_FOLDER        | `/backup`   | Backup path                                                                                                                                                                              |
| RESTIC_FTP_DOCKER_IS_FORGET_ENABLE     | `1`         | Enable or disable `restic forget script in crontab`                                                                                                                                      |
| RESTIC_FTP_DOCKER_FORGET_CRON_SCHEDULE | `0 0 * * *` | Cron expression to launch forget script                                                                                                                                                  |
| RESTIC_FTP_DOCKER_KEEP_HOURLY          | `24`        | argument for `--keep-hourly` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy)  |
| RESTIC_FTP_DOCKER_KEEP_DAILY           | `7`         | argument for `--keep-daily` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy)   |
| RESTIC_FTP_DOCKER_KEEP_WEEKLY          | `4`         | argument for `--keep-weekly` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy)  |
| RESTIC_FTP_DOCKER_KEEP_MONTHLY         | `12`        | argument for `--keep-monthly` of `restic forget` command, see [restic forget policies](https://restic.readthedocs.io/en/latest/060_forget.html#removing-snapshots-according-to-a-policy) |

## Demo

You can try the container `restic-ftp-docker` in [/demo](/demo/) folder.

## License

Restic sftp docker is licensed under [BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause). You can find the
complete text in [`LICENSE`](LICENSE).
