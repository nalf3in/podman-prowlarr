FROM debian:trixie-slim

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Debian version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nalf3in"

ENV DEBIAN_FRONTEND=noninteractive

# TARGETARCH is automatically populated by Docker Buildx (e.g., amd64, arm64)
ARG TARGETARCH

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      sqlite3 \
      libicu-dev \
      tzdata \
 && rm -rf /var/lib/apt/lists/* \
 && case "${TARGETARCH}" in \
      "amd64") PROWLARR_ARCH="x64" ;; \
      "arm64") PROWLARR_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
 && mkdir -p /opt/Prowlarr /config \
 && curl -fsSL "https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${PROWLARR_ARCH}" | tar xzf - -C /opt/Prowlarr --strip-components=1 \
 && rm -rf /opt/Prowlarr/Prowlarr.Update

VOLUME /config
EXPOSE 9696

CMD ["/opt/Prowlarr/Prowlarr", "--nobrowser", "--data=/config"]