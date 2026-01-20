FROM golang:1.25.6-bookworm AS builder

RUN apt-get update && apt-get install -y ca-certificates && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && update-ca-certificates

WORKDIR /src

COPY go.mod .
COPY go.sum .
RUN  go mod download

COPY . .

ARG CGO_ENABLED=0
ARG GO_BUILD_ARGS=
RUN CGO_ENABLED=${CGO_ENABLED} GOOS=linux go build ${GO_BUILD_ARGS} -ldflags="-w -s" -a -o /go/bin/app .

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /go/bin/app /go/bin/app

ENTRYPOINT ["/go/bin/app"]
