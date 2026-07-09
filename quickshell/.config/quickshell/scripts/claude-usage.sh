#!/bin/sh
# Fetch Claude Code rate-limit usage (same data as the /usage command) via the
# OAuth endpoint, using the local Claude Code credentials. Prints the usage
# JSON on stdout; never prints the token. Exit 1 on any failure.
CRED="$HOME/.claude/.credentials.json"
[ -r "$CRED" ] || exit 1
TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CRED" 2>/dev/null)
[ -n "$TOKEN" ] || exit 1
curl -fsS --max-time 15 \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "Content-Type: application/json" \
    "https://api.anthropic.com/api/oauth/usage"
