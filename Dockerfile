FROM alpine:latest
LABEL maintainer="machsix"
LABEL build_version="${TAG} Build-date:- ${BUILD_DATE}"

ARG TARGETPLATFORM
ARG TAG

WORKDIR /tmp
COPY v2ray.sh .
COPY v4-forward.conf /etc/sysctl.d/v4-forward.conf
COPY rules.v4 /etc/iptables/rules.v4
COPY tproxy.sh /usr/bin/v2ray-tproxy
COPY entrypoint.sh /entrypoint.sh

ENV V2RAY_LOCATION_ASSET="/usr/local/share/v2ray"
ENV V2RAY_LOCATION_CONFIG="/etc/v2ray"

RUN set -ex \
    && apk add --no-cache ca-certificates curl iptables \
    && chmod +x ./v2ray.sh \
    && chmod +x /usr/bin/v2ray-tproxy \
    && chmod +x /entrypoint.sh \
    && ./v2ray.sh "${TARGETPLATFORM}" "${TAG}" \
    && mkdir -p /var/log/v2ray \
    && ln -sf /dev/stdout /var/log/v2ray/access.log \
    && ln -sf /dev/stderr /var/log/v2ray/error.log


ENTRYPOINT ["/entrypoint.sh"]
