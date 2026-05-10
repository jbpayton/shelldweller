FROM alpine:latest
RUN apk add --no-cache bash curl jq coreutils findutils socat python3
COPY bin/llm bin/llm-bash bin/shelldweller /usr/local/bin/
RUN chmod +x /usr/local/bin/llm /usr/local/bin/llm-bash /usr/local/bin/shelldweller
ENTRYPOINT ["shelldweller"]
