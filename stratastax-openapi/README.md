# OpenAPI Guidelines

TLDR: OpenAPI specs are split into separate YAML files per path and component, 
stored in `stratastax-contract` and bundled into a single public contract using Redocly.

## Repository & tooling

- **Repo:** `stratastax-contract` (GitHub)
- **Root path:** `stratastax-openapi/src/`
- **Bundler:** Redocly CLI (`redocly bundle`)
- **Output:** one bundled public contract

---

## Directory structure

```
src/main/openapi/
├── stratastax.platform.api-v1.yaml     # Root document (entrypoint for Redocly)
├── paths/
│   ├── matches.yaml                    # All operations on /matches
│   ├── matches_{id}.yaml               # All operations on /matches/{id}
│   └── players.yaml
└── components/
    ├── parameters/
    │   ├── path_id.yaml
    │   └── query_limit.yaml
    ├── requests/
    │   ├── create_match.yaml
    │   └── update_match.yaml
    ├── responses/
    │   ├── match.yaml
    │   ├── match_list.yaml
    │   └── error.yaml
    └── schemas/
        ├── match.yaml
        ├── player_id.yaml
        └── error.yaml
```

---

## Naming conventions

| Type             | Pattern                                     | Example                         |
|------------------|---------------------------------------------|---------------------------------|
| Path files       | resource name, `{param}` becomes `_{param}` | `orders_{id}.yaml`              |
| Query parameters | `query_` prefix                             | `query_status.yaml`             |
| Path parameters  | `path_` prefix                              | `path_order_id.yaml`            |
| Requests         | descriptive name                            | `create_order.yaml`             |
| Responses        | descriptive name, no suffix                 | `order.yaml`, `order_list.yaml` |
| Schemas          | singular, descriptive                       | `order_status.yaml`             |
| **All files:**   | lowercase with underscores                  | —                               |

---

## Root document (`openapi.yaml`)

The root document contains **only** metadata and references. No inline definitions.

```yaml
openapi: 3.1.0

info:
  title: Stratastax API
  version: 1.0.0
  description: >
    Public contract for the Stratastax API.

servers:
  - url: https://api.stratastax.nl/v1
    description: Production
  - url: https://api.staging.stratastax.nl/v1
    description: Staging

security:
  - bearerAuth: []

tags:
  - name: matches
    description: Match statistics
  - name: players
    description: Player management

paths:
  /matches:
    $ref: ./paths/matches.yaml
  /matches/{id}:
    $ref: ./paths/matches_{id}.yaml

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## Path files (`paths/`)

One file per path, **not** per operation. All HTTP methods for that path live in the same file.

```yaml
# paths/matches.yaml
get:
  summary: List matches
  operationId: listMatches
  tags:
    - matches
  parameters:
    - $ref: ../parameters/query_limit.yaml
  responses:
    "200":
      $ref: ../responses/match_list.yaml
    "500":
      $ref: ../responses/internal_server_error.yaml

post:
  summary: Create match
  operationId: createMatch
  tags:
    - matches
  requestBody:
    required: true
    content:
      application/json:
        schema:
          $ref: ../requests/create_match.yaml
  responses:
    "201":
      $ref: ../responses/match.yaml
    "400":
      $ref: ../responses/validation_error.yaml
    "409":
      $ref: ../responses/conflict_error.yaml
    "500":
      $ref: ../responses/internal_server_error.yaml
```

---

## Search Query Parameters
- Only public identifier values should be accepted as explicit query parameters for searching.
- The dedicated query parameter 'search' with 'searchMode' should be used for free-text search.

---

## Components

### Parameters (`components/parameters/`)

Query parameters get the `query_` prefix, path parameters get the `path_` prefix.

```yaml
# components/parameters/query_date_to.yaml
name: dateTo
in: query
required: false
schema:
  $ref: ../schemas/date_time.yaml
description: Filter entities on or before this date-time (ISO 8601)
```

```yaml
# components/parameters/path_game_id.yaml
name: publicId
in: path
required: true
description: Public identifier
schema:
  type: string
  format: uuid
```

### Request bodies (`components/requests/`)

Schema object only — no `content` wrapper. The path file wraps this inside `requestBody`.

```yaml
# components/requests/create_match.yaml
type: object
required:
  - gameId
  - playerScores
properties:
  gameId:
    type: string
    format: uuid
  winnerPlayerId:
    type: string
    format: uuid
  createdAt:
    type: string
    format: date-time
    description: Defaults to server time if omitted
  playerScores:
    type: array
    minItems: 1
    items:
      $ref: ../schemas/player_score.yaml
  expansions:
    type: array
    items:
      type: string
```

### Responses (`components/responses/`)

Full response objects including `description` and `content`.

```yaml
# components/responses/match.yaml
description: Match retrieved successfully
content:
  application/json:
    schema:
      $ref: ../schemas/match.yaml
```

### Schemas (`components/schemas/`)

Reusable data structures. No response wrapper here — only the data shape.

```yaml
# components/schemas/match.yaml
Match:
  type: object
  required:
    - publicId
    - gameId
    - winnerPlayerId
    - createdAt
    - visibility
    - playerScores
  properties:
    publicId:
      type: string
      format: uuid
    gameId:
      type: string
      format: uuid
    winnerPlayerId:
      type: string
      format: uuid
    createdAt:
      type: string
      format: date-time
    visibility:
      type: string
      enum: [PUBLIC, PRIVATE, PRIVILEGED]
    playerScores:
      type: array
      items:
        $ref: player_score.yaml
    expansions:
      type: array
      items:
        type: string
```

---

## $ref conventions

| From                   | To              | Path                                          |
|------------------------|-----------------|-----------------------------------------------|
| `openapi.yaml`         | paths           | `./paths/matches.yaml`                        |
| `openapi.yaml`         | components      | `./components/schemas/match.yaml`             |
| `paths/*.yaml`         | components      | `../components/parameters/query_limit.yaml`   |
| `components/**/*.yaml` | other component | `../schemas/match.yaml` or `./player_id.yaml` |

Always use **relative paths**. No absolute paths, no `#/components/...` references in standalone files (those only resolve after bundling).

---

## HTTP status code conventions
- Paths always return a `500 Internal Server Error` on error.
- Paths which retrieve entities should return `200 OK`.
- Paths which create new entities should return `201 Created` and **not** `200 OK`.
- Paths which create new entities should return `409 Conflict` if any persistence error occurs.
- Paths that receive input should always return a `400 Bad Request` in case of validation errors.
- Paths that require authentication should return a `401 Unauthorized` and `403 Forbidden` on failure.

## Bundling with Redocly
```bash
# Bundle into a single public contract
npx @redocly/cli bundle src/main/openapi/openapi.yaml -o build/openapi/stratastax.platform.api-v1.yaml

# Validate before bundling
redocly lint src/main/openapi/openapi.yaml
```

---

## What I do NOT do
- No inline schema definitions in path files — always use a `$ref` to `/components/schemas/`
- No operations in the root `openapi.yaml` — only `$ref` to `/paths/`
- No `#/components/...` absolute refs in standalone files before bundling
- No camelCase or PascalCase filenames — always lowercase with underscores
- No separate file per HTTP method — one file per path, all methods inside it
