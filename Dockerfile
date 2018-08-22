FROM golang:1.10-alpine as builder
MAINTAINER Asbjorn Enge <asbjorn@hanafjedle.net>

## Install lnd
#

RUN apk add --no-cache git make
ENV GODEBUG netdns=cgo
RUN git clone https://github.com/lightningnetwork/lnd $GOPATH/src/github.com/lightningnetwork/lnd
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make
RUN make install
RUN cp /go/bin/lncli /bin/
RUN cp /go/bin/lnd /bin/

## Install zapconnect
#

RUN go get -d github.com/LN-Zap/zapconnect
WORKDIR $GOPATH/src/github.com/LN-Zap/zapconnect
RUN make

## Collect in final
#

FROM alpine as final

COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/
COPY --from=builder /go/bin/zapconnect /bin/
