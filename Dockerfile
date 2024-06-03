ARG ALPINE_VERSION=3.20

FROM alpine:$ALPINE_VERSION AS BASE

ARG RESTIC_VERSION=0.16.4
ARG RCLONE_VERSION=1.66.0

ARG SUPERCRONIC_VERSION=0.2.29
ARG SUPERCRONIC=supercronic-linux-amd64
ARG SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN apk add --no-cache zip curl \
    # Install restic
    && wget -O "/tmp/restic.bz2" https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2 \
        && bzip2 -d "/tmp/restic.bz2" \
    # Install rclone
    && wget -O "/tmp/rclone.zip" https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip \
        && unzip -d "/tmp/" "/tmp/rclone.zip" \
        && mv "/tmp/rclone-v$RCLONE_VERSION-linux-amd64" "/tmp/rclone" \
    # Install supercronic
    && curl -fsSLO "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64" \
        && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
        && chmod +x "$SUPERCRONIC" \
        && mv "$SUPERCRONIC" "/tmp/supercronic"

FROM alpine:$ALPINE_VERSION

RUN apk add --no-cache bash

COPY --from=BASE --chmod=0755 /tmp/restic /usr/local/bin/restic
COPY --from=BASE --chmod=0755 /tmp/rclone/rclone /usr/local/bin/rclone
COPY --from=BASE --chmod=0755 /tmp/supercronic /usr/local/bin/supercronic

COPY --chmod=0755 ./backup.sh /opt/restic/backup.sh
COPY --chmod=0755 ./prune.sh /opt/restic/prune.sh
COPY --chmod=0755 ./entrypoint.sh /opt/estic/entrypoint.sh
COPY --chmod=0655 ./main.crontab /opt/restic/main.crontab

ENTRYPOINT [ "/opt/estic/entrypoint.sh" ]
