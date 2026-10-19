// Redocly rules for the conventions of README.md ("HTTP status codes" and "Idempotency").
const MUTATING = ['put', 'post', 'patch', 'delete'];
const METHODS = ['get', ...MUTATING];

/** The parameters of an operation, path-level ones included, with their $refs resolved. */
function parameters(pathItem, operation, ctx) {
  return [...(pathItem.parameters || []), ...(operation.parameters || [])].map(
    (parameter) => (parameter.$ref ? ctx.resolve(parameter).node : parameter) || {},
  );
}

function requiredResponses(method, params) {
  const required = ['400', '401', '403', '500'];
  if (params.some((p) => p.in === 'path')) required.push('404');
  if (MUTATING.includes(method)) required.push('409', '422');
  if (params.some((p) => p.in === 'header' && p.name === 'If-Match')) required.push('412');
  return required;
}

function StandardResponses() {
  return {
    PathItem(pathItem, ctx) {
      for (const method of METHODS) {
        const operation = pathItem[method];
        if (!operation) continue;
        const declared = Object.keys(operation.responses || {});
        const missing = requiredResponses(method, parameters(pathItem, operation, ctx)).filter(
          (code) => !declared.includes(code),
        );
        if (missing.length > 0) {
          ctx.report({
            message: `${method.toUpperCase()} ${operation.operationId} lacks the standard responses ${missing.join(', ')}.`,
            location: ctx.location.child([method, 'responses']),
          });
        }
      }
    },
  };
}

function IdempotencyKey() {
  return {
    PathItem(pathItem, ctx) {
      for (const method of MUTATING) {
        const operation = pathItem[method];
        if (!operation) continue;
        const key = parameters(pathItem, operation, ctx).find(
          (p) => p.in === 'header' && p.name === 'Idempotency-Key',
        );
        if (!key || key.required !== true) {
          ctx.report({
            message: `${method.toUpperCase()} ${operation.operationId} lacks a required Idempotency-Key header.`,
            location: ctx.location.child([method]),
          });
        }
      }
    },
  };
}

module.exports = function stratastaxRules() {
  return {
    id: 'stratastax',
    rules: {
      oas3: {
        'standard-responses': StandardResponses,
        'idempotency-key': IdempotencyKey,
      },
    },
  };
};
