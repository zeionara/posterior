#!/bin/bash

port=${POSTERIOR_PORT:-7171}
host=${POSTERIOR_HOST:-localhost}

curl -X POST $host:$port/predict \
    -H "Content-Type: application/json" \
    -d '{"url":"'$1'"}'

echo
