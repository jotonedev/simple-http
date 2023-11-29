## Build
FROM golang:latest as builder

WORKDIR /build
ENV GO111MODULE=on
ENV GIN_MODE=release

COPY src/main.go .
RUN CGO_ENABLED=0 go build -v -a -ldflags '-s -w -extldflags "-static"' -o server src/main.go


## Run
FROM busybox:latest

WORKDIR /srv

ENV PORT=8080
ENV RESPONSE_STRING="Hello World!"
ENV GO111MODULE=on
ENV GIN_MODE=release

RUN echo "nonroot:x:1002:1002:nobody:/:/bin/sh" >> /etc/passwd
RUN echo "nonroot:x:1002:" >> /etc/group
COPY --from=builder /build/server /srv/server
RUN chmod 005 /srv/server

USER nonroot:nonroot
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD /bin/netstat -atl | /bin/grep ':8080' || exit 1

CMD ["/srv/server"]