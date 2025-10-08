#!/bin/bash
set -o pipefail

if [[ "$SERVERGAMEPORT" = "8888" ]]; then
    SERVERSTATUSPORT="8889"
else
    SERVERSTATUSPORT="8888"
fi

STATUS=$(curl -k -f -s -S "http://127.0.0.1:${SERVERSTATUSPORT}/status")

if [[ $(jq -r '.status' <<<"$STATUS") = "ready" ]]; then
    exit 0
fi

exit 1
