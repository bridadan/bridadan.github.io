#!/bin/sh
echo "=== Checking for spelling errors ==="
find . -name "*.md" -not -path "./vendor/*" | xargs -n1 $(dirname $0)/spell_check.sh

