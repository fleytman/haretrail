# HARE Trail end-to-end agent image.
#
# Unlike the unit smoke image, this one installs the REAL agent CLIs and runs
# them against a clean checkout to test runtime skill loading. It makes live,
# paid API calls; auth tokens are injected at run time (never baked in).
#
#   - node/npm   : base for both agent CLIs
#   - claude     : @anthropic-ai/claude-code (auth via CLAUDE_CODE_OAUTH_TOKEN)
#   - codex      : @openai/codex             (auth via OPENAI_API_KEY)
#   - git/jq/python3 : needed by the HARE Trail install scripts
FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash git jq python3 ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Agent CLIs under test. Pin nothing here: the e2e validates the current tools.
RUN npm install -g @anthropic-ai/claude-code @openai/codex \
    && claude --version \
    && codex --version

# Run as a non-root user: Claude Code refuses bypassPermissions under root/sudo.
# The node base image already ships a non-root `node` user (uid 1000).

WORKDIR /work

COPY bootstrap.sh /usr/local/bin/haretrail-e2e-bootstrap
RUN chmod +x /usr/local/bin/haretrail-e2e-bootstrap \
    && chown -R node:node /work

USER node
CMD ["haretrail-e2e-bootstrap"]
