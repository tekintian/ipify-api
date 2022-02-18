# ipify-api server builder container
FROM golang:alpine3.15 as builder

WORKDIR /usr/src
COPY docker-entrypoint.sh /docker-entrypoint.sh

# ADD ./ /usr/src/ipify-api
RUN sed -i -e 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apk/repositories; \
    apk update; \
    apk add --no-cache curl ca-certificates wget git ; \
    #set the global default user and email
    git config --global user.name "AlpineBuilder"; \
    git config --global user.email "builder@gmail.com" ; \
    # clone the ipify-api code
    git clone https://github.com/tekintian/ipify-api.git; \
    cd /usr/src/ipify-api ;\
    go mod init ; \
    go build -v; \
    chmod +x ipify-api; \
    chmod +x /docker-entrypoint.sh

# ipify-api server run container
FROM alpine:3.6
LABEL maintainer="tekintian@gmail.com"

WORKDIR /usr/local/bin

COPY --from=builder /usr/src/ipify-api/ipify-api .
COPY --from=builder /docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/docker-entrypoint.sh"]
