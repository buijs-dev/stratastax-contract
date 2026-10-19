# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

First release of Stratastax Contract: the REST API interface definitions and database schemas
of the Stratastax platform.

- OpenAPI specs `api-v1` for the platform, the game catalog and i18n, linted and bundled with Redocly
  and published under the classifiers `openapi`, `catalog-openapi` and `i18n-openapi`.
- Flyway migrations for engine, game-catalog and i18n, with deterministic seed data for dev and test.
- A schema migration docker image per service: `database-schema-engine`, `database-schema-game-catalog`
  and `database-schema-i18n`.
- API reference, API explorer and database schema docs on [docs.stratastax.dev](https://docs.stratastax.dev).

See [stratastax-openapi/README.md](https://github.com/buijs-dev/stratastax-contract/blob/main/stratastax-openapi/README.md)
for the API guidelines and [stratastax-schema/README.md](https://github.com/buijs-dev/stratastax-contract/blob/main/stratastax-schema/README.md)
for the schemas.
