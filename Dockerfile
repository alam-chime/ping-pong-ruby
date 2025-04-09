FROM ruby:3.4.2-slim
WORKDIR /rails

RUN <<EOF
    set -ex

    apt-get update
    apt-get install --no-install-recommends -y curl \
        libjemalloc2 \
        libvips \
        sqlite3 \
        build-essential \
        git \
        libyaml-dev \
        pkg-config

    rm -rf /var/lib/apt/lists /var/cache/apt/archives
EOF

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

COPY Gemfile Gemfile.lock ./
RUN bundle install && bundle exec bootsnap precompile --gemfile

COPY . ./
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN <<EOF
    groupadd --system --gid 1000 rails
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
    chown -R rails:rails db log storage tmp config
EOF

USER rails:rails

CMD ["./bin/rails", "server"]
