#!/bin/sh
# Fetch Codex CLI rate-limit usage (same data as the /status command) via the
# ChatGPT backend, using the local Codex credentials. Prints the usage JSON on
# stdout; never prints the token. Exit 1 on any failure.
AUTH="$HOME/.codex/auth.json"
[ -r "$AUTH" ] || exit 1
TOKEN=$(jq -r '.tokens.access_token // empty' "$AUTH" 2>/dev/null)
ACCOUNT=$(jq -r '.tokens.account_id // empty' "$AUTH" 2>/dev/null)
[ -n "$TOKEN" ] || exit 1
curl -fsS --max-time 15 \
    -H "Authorization: Bearer $TOKEN" \
    ${ACCOUNT:+-H "ChatGPT-Account-Id: $ACCOUNT"} \
    -H "User-Agent: codex_cli_rs" \
    "https://chatgpt.com/backend-api/wham/usage"
