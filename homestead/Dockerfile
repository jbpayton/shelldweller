FROM alpine:latest
RUN apk add --no-cache bash curl jq socat python3 coreutils findutils
COPY seed/bin/ /usr/local/bin/
COPY entrypoint /usr/local/bin/homestead-entry
COPY life /usr/local/bin/homestead-life
COPY mission.txt /etc/homestead-mission.txt
RUN chmod +x /usr/local/bin/*
ENTRYPOINT ["homestead-life"]
