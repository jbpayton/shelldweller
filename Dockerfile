FROM alpine:latest
RUN apk add --no-cache bash curl jq coreutils findutils
COPY bin/llm bin/shelldweller /usr/local/bin/
RUN chmod +x /usr/local/bin/llm /usr/local/bin/shelldweller
ENTRYPOINT ["shelldweller"]
