FROM chlorm/builder:latest AS builder

RUN zypper --non-interactive install curl
RUN curl -sSLO 'https://build.opensuse.org/projects/Virtualization:containers/public_key'
RUN rpmkeys --import 'public_key'
RUN zypper addrepo --enable --refresh --check --gpgcheck \
    'https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Tumbleweed/Virtualization:containers.repo'

RUN zypper --non-interactive install dumb-init timezone util-linux

FROM registry.opensuse.org/opensuse/busybox:latest AS base

LABEL org.opencontainers.image.vendor="Chlorm" \
    org.opencontainers.image.url="https://github.com/chlorm/docker-base" \
    org.opencontainers.image.licenses="Apache-2.0"

COPY --from=builder \
    /usr/bin/setpriv \
    /usr/sbin/dumb-init \
    /usr/bin/
COPY --from=builder \
    /usr/lib64/libcap-ng.so* \
    /usr/lib64/
COPY --from=builder \
    /usr/share/zoneinfo/UTC \
    /usr/share/zoneinfo/
RUN ln -fsv /usr/share/zoneinfo/UTC /etc/localtime \
    && echo 'UTC' > /etc/timezone

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]