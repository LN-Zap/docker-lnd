# Builder image
FROM golang:1.17-alpine3.15 as builder

# Add build tools.
RUN apk --no-cache --virtual build-dependencies add \
  build-base \
  git

# Grab and install the latest version of lnd and all related dependencies.
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN git config --global user.email "luizfilipester@gmail.com" \
  && git config --global user.name "Luiz Parreira" \
  && git clone https://github.com/lightningnetwork/lnd . \
  && git reset --hard v0.15.5-beta \
  && git remote add ln https://github.com/lightningnetwork/lnd \
  && git fetch ln \
  && make \
  && make install tags="experimental monitoring autopilotrpc chainrpc invoicesrpc routerrpc signrpc walletrpc watchtowerrpc wtclientrpc" \
  && cp /go/bin/lncli /bin/ \
  && cp /go/bin/lnd /bin/

# Final image
FROM alpine:3.10 as final

# Add utils.
RUN apk --no-cache add \
  bash \
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

## Set BUILD_VER build arg to break the cache here.
ARG BUILD_VER=unknown

ADD ./bin /usr/local/bin

VOLUME ["/lnd"]

# Expose p2p port
EXPOSE 9735

# Expose grpc port
EXPOSE 10009

# Expose rest port
EXPOSE 8081

WORKDIR /lnd

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["lnd_oneshot"]
