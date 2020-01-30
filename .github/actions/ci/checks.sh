#!/bin/sh
echo "=== Checking for spelling errors ==="
find . -name "*.md" -not -path "./vendor/*" -exec $(dirname $0)/spell_check.sh {} \;
