# HARE Trail clean-checkout smoke image.
#
# Minimal, tool-agnostic base with exactly what the install scripts need:
#   - bash       : scripts are #!/usr/bin/env bash and use arrays / printf %q
#   - git        : clean-checkout clone + init-data-repo --git-init
#   - jq         : grant-data-access.sh edits Claude/Kiro JSON
#   - python3    : grant-data-access.sh validates Codex TOML via tomllib (>=3.11)
#   - ca-certificates : only needed when cloning from GitHub (SRC=https://...)
#
# The repo itself is NOT copied in. At runtime the container clones ${SRC:-/src}
# into /work/haretrail, so the test always runs the committed checkout, not the
# host working tree with its local cruft.
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        git \
        jq \
        python3 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# The bootstrap is baked into the image (stable), then it materializes the
# checkout and runs that checkout's container-smoke.sh.
COPY bootstrap.sh /usr/local/bin/haretrail-smoke-bootstrap
RUN chmod +x /usr/local/bin/haretrail-smoke-bootstrap

CMD ["haretrail-smoke-bootstrap"]
