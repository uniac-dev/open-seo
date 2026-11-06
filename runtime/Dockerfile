FROM ghcr.io/every-app/open-seo-standalone@sha256:ae5b43af1698ea01633f232dd9c5a2b89bfcbb75990185f85db29e38e0c001e5
USER root
RUN apt-get update && apt-get install -y --no-install-recommends gosu tini && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /config /data /web-config && \
    ln -s /state/config /config && \
    ln -s /state/data /data && \
    ln -s /state/web-config /web-config
# Use the local crawl gateway and wait for writable storage at startup.
RUN node -e ' \
    const fs = require("node:fs"); \
    const address = JSON.stringify("http://crawl-gateway:8090"); \
    for (const [file, from, to] of [ \
      ["/opt/standalone/configure.mjs", address, "process.env.CRAWL_GATEWAY_URL || " + address], \
      ["/opt/standalone/run.sh", "curl -sS -o /tmp/create-bucket-response", "curl --retry 90 --retry-max-time 90 --retry-delay 1 --retry-connrefused --connect-timeout 2 --max-time 3 -sS -o /tmp/create-bucket-response"] \
    ]) { \
      const source = fs.readFileSync(file, "utf8"); \
      if (source.split(from).length !== 2) throw new Error("Unexpected upstream configuration in " + file); \
      fs.writeFileSync(file, source.replace(from, to)); \
    } \
    '
COPY runtime/start.sh /opt/uniac/start.sh
ENV CRAWL_GATEWAY_URL=http://127.0.0.1:8090
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["bash", "/opt/uniac/start.sh"]
