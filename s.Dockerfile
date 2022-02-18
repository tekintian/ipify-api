# ipify-api server builder container
FROM golang as builder

WORKDIR /usr/src
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENV CGO_ENABLED=0  GOOS=linux
ADD ./ /usr/src/ipify-api
RUN cd /usr/src; \
    git config --global user.name "AlpineBuilder"; \
    git config --global user.email "builder@gmail.com" ; \
    # git clone https://github.com/tekintian/ipify-api.git; \
    cd /usr/src/ipify-api ;\
    go mod init ; \
    # go build -v; \
    go build -v -a -installsuffix nocgo -ldflags="-s -w" -o /ipify-api github.com/tekintian/ipify-api; \
    chmod +x /ipify-api; \
    chmod +x /docker-entrypoint.sh

# ipify-api server run container
# FROM scratch
FROM alpine:3.8
LABEL maintainer="tekintian@gmail.com"

WORKDIR /

COPY --from=builder /ipify-api /ipify-api
COPY --from=builder /docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/ipify-api"]
