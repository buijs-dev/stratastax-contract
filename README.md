# Stratastax Contract

[![Stratastax](https://img.shields.io/badge/Product-stratastax.dev-4F46E5?style=flat)](https://stratastax.dev/)
[![](https://img.shields.io/badge/Buijs-Software-blue)](https://buijs.dev/)
[![GitHub](https://img.shields.io/github/license/buijs-dev/klutter?color=black)](https://github.com/buijs-dev/stratastax-infrastructure/blob/main/LICENSE)

The REST API interface definition and database schemas for the Stratastax platform.

| Module               | Contents                                                                                       |
|----------------------|------------------------------------------------------------------------------------------------|
| `stratastax-openapi` | The OpenAPI specs, bundled with Redocly ([guidelines](stratastax-openapi/README.md))           |
| `stratastax-schema`  | The Flyway migrations of engine, game-catalog and i18n ([schema](stratastax-schema/README.md)) |

| Spec                              | API                                         | Maven classifier  |
|-----------------------------------|---------------------------------------------|-------------------|
| `stratastax.platform.api-v1.yaml` | Platform (stratastax-engine)                | `openapi`         |
| `stratastax.catalog.api-v1.yaml`  | Game catalog (stratastax-game-catalog)      | `catalog-openapi` |
| `stratastax.i18n.api-v1.yaml`     | Translations (the i18n service and its CMS) | `i18n-openapi`    |

## Documentation

Everything in this repository is published on [docs.stratastax.dev](https://docs.stratastax.dev):

- [API reference](https://docs.stratastax.dev/technical/api/) and an [API explorer](https://docs.stratastax.dev/technical/api/explorer/) (Swagger UI) per spec
- the bundled specs, for code generators: `https://docs.stratastax.dev/openapi/<spec>.yaml`
- [database schema](https://docs.stratastax.dev/technical/database/) per service, generated with tbls

Every push to `main` that touches a spec or a migration runs [`docs.yml`](.github/workflows/docs.yml):
it lints and bundles the specs and validates the migrations, then triggers the build of
[stratastax-horizon](https://github.com/buijs-dev/stratastax-horizon), which publishes the site.
The trigger needs the repository secret `DOCS_DISPATCH_TOKEN`: a fine-grained token with
*Contents: read and write* on stratastax-horizon only. Without it the workflow only warns.

## Versioning

A spec file is versioned by the major version in its name (`api-v1`) and in its paths (`/api/v1`).
The site always serves the latest bundle, and consumers pin what they generated against
(the stx compiler keeps a sha256 per spec in `stx.lock`), so:

- within `api-vN` only backward compatible changes: new operations, new optional request fields
  and parameters, new response fields;
- a breaking change (removing or renaming anything, making something required, changing a type)
  goes into a new file `api-v(N+1)` next to the old one, which stays until its consumers moved;
- `info.version` is bumped with every change: minor for additions, patch for documentation.

## Related Stratastax projects

- [stratastax-engine](https://github.com/buijs-dev/stratastax-engine) - implements the platform OpenAPI spec and the engine schema
- [stratastax-game-catalog](https://github.com/buijs-dev/stratastax-game-catalog) - implements the catalog OpenAPI spec and schema
- [stratastax-codegen](https://github.com/buijs-dev/stratastax-codegen) - generates the REST layer from these specs
- [stratastax-search](https://github.com/buijs-dev/stratastax-search) - the contract every search endpoint follows
- [stratastax-portal](https://github.com/buijs-dev/stratastax-portal) - the client of these APIs
- [stratastax-flutter](https://github.com/buijs-dev/stratastax-flutter) - generates typed Flutter clients and forms from these specs
- [stratastax-horizon](https://github.com/buijs-dev/stratastax-horizon) - the documentation site that publishes these specs and the schema docs
