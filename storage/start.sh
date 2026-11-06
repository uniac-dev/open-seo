#!/bin/sh
set -eu
mkdir -p /data/objects
chown rustfs:rustfs /data /data/objects
exec su-exec rustfs /entrypoint.sh "$@"
