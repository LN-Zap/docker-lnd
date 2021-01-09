# Builder image
FROM golang:1.14.5-alpine as builder
MAINTAINER Tom Kirkpatrick <tkp@kirkdesigns.co.uk>

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Add build tools.
RUN apk --no-cache --virtual build-dependencies add \
  alpine-sdk \
  git \
  make \
  gcc

# Grab and install the latest version of lnd and all related dependencies.
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN git config --global user.email "tkp@kirkdesigns.co.uk" \
  && git config --global user.name "Tom Kirkpatrick" \
  && git clone https://github.com/lightningnetwork/lnd . \
  && git reset --hard v0.12.0-beta.rc5 \
  && git remote add lnzap https://github.com/LN-Zap/lnd \
  && git fetch lnzap \
  && git cherry-pick b305c99fb1315bec207e41a80224c94323510d3b \
  && git cherry-pick 28f7d7253a2492086268cbaaea18e7e86edbe9d7 \
  && make \
  && make install tags="monitoring autopilotrpc chainrpc invoicesrpc routerrpc signrpc verrpc walletrpc watchtowerrpc wtclientrpc" \
  && cp /go/bin/lncli /bin/ \
  && cp /go/bin/lnd /bin/

# Grab and install the latest version of lndconnect.
WORKDIR $GOPATH/src/github.com/LN-Zap/lndconnect
RUN git clone https://github.com/LN-Zap/lndconnect . \
  && git reset --hard v0.2.0 \
  && make \
  && make install \
  && cp /go/bin/lndconnect /bin/

# Final image
FROM alpine:3.12 as final
MAINTAINER Tom Kirkpatrick <tkp@kirkdesigns.co.uk>

# Add utils.
RUN apk --no-cache add \
  bash \
  jq \
  curl \
  vim \
  su-exec \
  dropbear-dbclient \
  dropbear-scp \
  ca-certificates \
  && update-ca-certificates

ARG USER_ID
ARG GROUP_ID

ENV HOME /lnd

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN addgroup -g ${GROUP_ID} -S lnd && \
  adduser -u ${USER_ID} -S lnd -G lnd -s /bin/bash -h /lnd lnd

# Copy the compiled binaries from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/
COPY --from=builder /go/bin/lndconnect /bin/

## Set BUILD_VER build arg to break the cache here.
ARG BUILD_VER=unknown

ADD ./bin /usr/local/bin

VOLUME ["/lnd"]

# Expose p2p port
EXPOSE 9735

# Expose grpc port
EXPOSE 10009

WORKDIR /lnd

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["lnd_oneshot"]
