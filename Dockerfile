FROM alpine:3.14

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ARG PUID=2000
ARG PGID=2000
ARG MM_PACKAGE="https://github-releases.githubusercontent.com/107789421/7b1a221f-1d70-436f-b4c5-e55f75fe383a?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20211022%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211022T185134Z&X-Amz-Expires=300&X-Amz-Signature=7524bebee819061c6ae1389392156456c65181f60d73bbaac2cc45b6d0e71b7c&X-Amz-SignedHeaders=host&actor_id=6220692&key_id=0&repo_id=107789421&response-content-disposition=attachment%3B%20filename%3Dmattermost-v6.0.1-linux-arm64.tar.gz&response-content-type=application%2Foctet-stream"

# Install some needed packages
RUN apk add --no-cache \
  ca-certificates \
  curl \
  libc6-compat \
  libffi-dev \
  linux-headers \
  mailcap \
  netcat-openbsd \
  xmlsec-dev \
  tzdata \
  wv \
  poppler-utils \
  tidyhtml \
  && rm -rf /tmp/*

# Get Mattermost
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins \
  && if [ ! -z "$MM_PACKAGE" ]; then curl $MM_PACKAGE | tar -xvz ; \
  else echo "please set the MM_PACKAGE" ; fi \
  && addgroup -g ${PGID} mattermost \
  && adduser -D -u ${PUID} -G mattermost -h /mattermost -D mattermost \
  && chown -R mattermost:mattermost /mattermost /mattermost/plugins /mattermost/client/plugins

USER mattermost

#Healthcheck to make sure container is ready
HEALTHCHECK --interval=30s --timeout=10s \
  CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1


# Configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["mattermost"]

EXPOSE 8065 8067 8074 8075

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
