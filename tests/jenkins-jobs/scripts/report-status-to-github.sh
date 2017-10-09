#!/bin/bash -ex

STATUS="$1"

COMMIT=$(git log -n 1 --no-merges --pretty=format:'%H')

env

curl -f -H 'Content-Type: application/json' -u "$GITHUB_CREDENTIALS" "https://api.github.com/repos/coreos/tectonic-installer/statuses/${COMMIT}" -d '{"state": "${STATUS}", "target_url": "https://example.com/build/status", "description": "The build succeeded!", "context": "continuous-integration/jenkins"}'
