#!/bin/sh
echo "- $1 -"
wrongwords=$(cat $1 | aspell list --home-dir $(dirname $0) --ignore 3)
wrongword_count=$(echo $wrongwords | wc -c)

# Needs to be > 1 since there's a null character in there
if [ "$wrongword_count" -gt "1" ]; then
    echo $wrongwords
    exit 1
fi
