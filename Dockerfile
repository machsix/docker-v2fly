FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="V2Fly Community <dev@v2fly.org>"

WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh .
COPY v4-forward.conf /etc/sysctl.d/v4-forward.conf
COPY rules.v4 /etc/iptables/rules.v4
COPY tproxy.sh /usr/bin/v2ray-tproxy

RUN set -ex \
    && apk add --no-cache ca-certificates curl iptables \
    && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log \
    && chmod +x ./v2ray.sh \
    && chmod +x /usr/bin/v2ray-tproxy \
    && ./v2ray.sh "${TARGETPLATFORM}" "${TAG}"

ENV V2RAY_LOCATION_ASSET="/usr/local/share/v2ray"
ENV V2RAY_LOCATION_CONFIG="/etc/v2ray"

RUN echo "#!/bin/sh" > /entrypoint.sh \
    && echo "exec /usr/bin/v2ray run -config /etc/v2ray/config.json" >> /entrypoint.sh \
    && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
