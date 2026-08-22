FROM alpine:latest
RUN apk add --no-cache bash curl jq socat python3 coreutils findutils
COPY seed/bin/ /usr/local/bin/
COPY entrypoint /usr/local/bin/homestead-entry
RUN chmod +x /usr/local/bin/*
ENTRYPOINT ["homestead-entry"]
