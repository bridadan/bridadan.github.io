# Container image that runs your code
FROM alpine:3.10

RUN apk add git

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["git", "log", "-3"]
