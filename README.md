# bridadan.github.io

My personal site

## Running locally

1. Install Ruby 2.7
1. Run the following commands:

```bash
gem install bundler
bundler install
bundler exec jekyll serve
```

## Running locally with docker

```bash
./start_docker.sh
bundler install
bundler exec jekyll server -H 0.0.0.0
```
