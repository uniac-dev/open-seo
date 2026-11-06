FROM rustfs/rustfs:1.0.3@sha256:9ca9559533b537d10482fe923288b676ad08f92a7069d9a17327fbae3cab688b
USER root
RUN apk add --no-cache su-exec
COPY storage/start.sh /opt/uniac/storage.sh
ENV RUSTFS_VOLUMES=/data/objects
ENTRYPOINT ["sh", "/opt/uniac/storage.sh"]
CMD ["rustfs"]
