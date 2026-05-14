FROM ruby:2.6-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile .

RUN bundle install --no-deployment

EXPOSE 3000
