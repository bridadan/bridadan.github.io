#!/bin/bash
docker run -it -v $(pwd):/usr/src/app -w /usr/src/app -p 4000:4000 -e BUNDLE_APP_CONFIG=/usr/src/app/.bundle ruby:2.7.3-buster /bin/bash
