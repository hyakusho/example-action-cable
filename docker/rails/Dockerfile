# syntax=docker/dockerfile:experimental
FROM ruby:2.7.0-alpine3.11
WORKDIR /app
ARG RAILS_VERSION=6.0.2.1
RUN \
  --mount=type=cache,target=/var/cache/apk \
  --mount=type=cache,target=/var/lib/apk \
  --mount=type=cache,target=/etc/apk/cache \
  apk add -U \
    build-base \
    git \
    sqlite-dev \
    tzdata \
    yarn \
    && \
  gem install rails -v $RAILS_VERSION
COPY ./docker/rails/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
