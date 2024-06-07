ARG ALPINE_VERSION=3.20

FROM --platform=$BUILDPLATFORM alpine:$ALPINE_VERSION AS base-download-cli

ARG TARGETOS
ARG TARGETARCH

ARG RESTIC_VERSION=0.16.4
ARG RCLONE_VERSION=1.66.0
ARG SUPERCRONIC_VERSION=0.2.29

RUN apk add --no-cache zip curl \
    # Install restic
    && wget -O "/tmp/restic.bz2" https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_${TARGETOS}_${TARGETARCH}.bz2 \
        && bzip2 -d "/tmp/restic.bz2" \
    # Install rclone
    && wget -O "/tmp/rclone.zip" https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-${TARGETOS}-${TARGETARCH}.zip \
        && unzip -d "/tmp/" "/tmp/rclone.zip" \
        && mv "/tmp/rclone-v$RCLONE_VERSION-${TARGETOS}-${TARGETARCH}" "/tmp/rclone" \
    # Install supercronic
    && curl -fsSLO "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-${TARGETOS}-${TARGETARCH}" \
        && mv "supercronic-${TARGETOS}-${TARGETARCH}" "/tmp/supercronic"

FROM --platform=$BUILDPLATFORM alpine:$ALPINE_VERSION

RUN apk add --no-cache bash

COPY --from=base-download-cli --chmod=0755 /tmp/restic /usr/local/bin/restic
COPY --from=base-download-cli --chmod=0755 /tmp/rclone/rclone /usr/local/bin/rclone
COPY --from=base-download-cli --chmod=0755 /tmp/supercronic /usr/local/bin/supercronic

COPY --chmod=0755 ./backup.sh /opt/restic/backup.sh
COPY --chmod=0755 ./forget.sh /opt/restic/forget.sh
COPY --chmod=0755 ./entrypoint.sh /opt/estic/entrypoint.sh
COPY --chmod=0655 ./main.crontab /opt/restic/main.crontab

ENTRYPOINT [ "/opt/estic/entrypoint.sh" ]
