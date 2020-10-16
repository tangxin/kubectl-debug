FROM alpine:3.11.5 as build

RUN apk add lxcfs containerd 

FROM alpine:3.11.5

ARG TARGETARCH
ARG TARGETOS

COPY --from=build /usr/bin/lxcfs /usr/bin/lxcfs
COPY --from=build /usr/lib/*fuse* /usr/lib/
COPY --from=build /usr/bin/ctr /usr/bin/ctr

COPY ./scripts/start.sh /
COPY out/debug-agent-$TARGETOS-$TARGETARCH /bin/debug-agent
RUN chmod 755 /start.sh /bin/debug-agent

EXPOSE 10027

CMD ["/start.sh"]
