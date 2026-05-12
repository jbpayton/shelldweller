FROM alpine:latest
RUN apk add --no-cache bash curl jq coreutils findutils socat python3
COPY bin/llm bin/llm-bash bin/shelldweller bin/narrate bin/checkbash /usr/local/bin/
COPY docs/protocol.md /etc/shelldweller-protocol.md
RUN chmod +x /usr/local/bin/llm /usr/local/bin/llm-bash /usr/local/bin/shelldweller /usr/local/bin/narrate /usr/local/bin/checkbash
ENTRYPOINT ["shelldweller"]
