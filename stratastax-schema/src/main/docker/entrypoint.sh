#!/usr/bin/env sh
set -eu

flyway \
  -locations="filesystem:/flyway/migrations" \
  -connectRetries=10 \
  -baselineOnMigrate=true \
  migrate