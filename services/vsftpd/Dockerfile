ARG IMAGE_REGISTRY
ARG VSFTPD_VERSION
FROM ${IMAGE_REGISTRY:-docker.cnb.cool/seatonjiang/vsftpd}/vsftpd:${VSFTPD_VERSION:-alpine}

ARG ALPINE_MIRROR
RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR:-mirrors.cloud.tencent.com}/g" /etc/apk/repositories

RUN apk update && apk --no-cache add tzdata \
    && rm -rf /var/cache/apk/*

RUN openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem -subj "/C=CN/ST=Shanghai/L=Shanghai/O=vsftpd/CN=vsftpd"

RUN mkdir -p /var/log/vsftpd/ \
    && ln -sf /dev/stdout /var/log/vsftpd/vsftpd.log \
    && mkdir -p /var/run/vsftpd/empty \
    && touch /var/log/vsftpd/vsftpd.log

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 21 50000-50100

ENTRYPOINT ["docker-entrypoint.sh"]
