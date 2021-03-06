FROM ruby:3.0.1-alpine3.13

ENV BUNDLE_AUTO_INSTALL=true \
    BUNDLE_JOBS=4 \
    BUNDLE_PATH=/bundle

WORKDIR /usr/src/app

RUN apk add --update --no-cache \
      # for native extensions
      build-base \
      # for pg
      postgresql-dev \
      # for activesupport
      tzdata \
      # for rails-erd
      graphviz ttf-freefont \
      # development tools
      less \
  && gem install bundler --no-document
