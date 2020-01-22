#!/bin/ash
set -xeuo pipefail

[ ! -f "Gemfile" ] && rails new --skip .

bundle install --jobs=4 --retry=3

[ "$RAILS_ENV" = "development" ] && yarn install --check-files

bundle exec rails db:migrate

exec "$@"
