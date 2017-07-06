#!/bin/bash
# filter hides lines with words over MAX chars

MAX=${MAX:-500}
sed -Ee "s/[a-zA-Z0-9\/+]\{${MAX},\}/***OMITTED***/g"

