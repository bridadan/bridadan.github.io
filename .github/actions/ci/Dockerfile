# Container image that runs your code
FROM alpine:3.10

RUN apk update

RUN apk add aspell aspell-en

ENTRYPOINT [".github/actions/ci/checks.sh"]
