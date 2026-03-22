# REST Endpoint Design Reference

These best practices apply to public-facing REST APIs. Evaluate endpoints for
consistency, discoverability, and adherence to HTTP conventions.

## URL Structure

### Use nouns, not verbs, in endpoint paths

The HTTP method is the verb. The path identifies the resource.

| Bad | Good | Why |
|-----|------|-----|
| `GET /getUsers` | `GET /users` | GET already means "get" |
| `POST /createOrder` | `POST /orders` | POST already means "create" |
| `DELETE /removeUser/123` | `DELETE /users/123` | DELETE already means "remove" |
| `PUT /updateProduct/456` | `PUT /products/456` | PUT already means "update" |

### Use plural nouns for collections

Collections contain multiple resources. Name them accordingly.

| Bad | Good |
|-----|------|
| `/user` | `/users` |
| `/order/123` | `/orders/123` |
| `/product-category` | `/product-categories` |

### Use kebab-case for multi-word paths

URLs are case-insensitive by convention. Kebab-case is the standard for
readability.

| Bad | Good |
|-----|------|
| `/userProfiles` | `/user-profiles` |
| `/order_items` | `/order-items` |
| `/ProductCategories` | `/product-categories` |

### Nest resources to express relationships

Use nesting to express ownership or containment. Limit nesting to two levels
to avoid unwieldy URLs.

```
GET  /users/123/orders          # Orders belonging to user 123
GET  /users/123/orders/456      # Specific order for user 123
```

**Avoid deep nesting**:
```
# Bad: three levels deep, hard to construct and cache
GET /users/123/orders/456/items/789/reviews

# Good: flatten to top-level resource with query filters
GET /order-items/789/reviews
# or
GET /reviews?orderItemId=789
```

### Use camelCase for JSON field names

```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "emailAddress": "jane@example.com",
  "createdAt": "2026-01-15T10:30:00Z"
}
```

Not `first_name`, `FirstName`, or `FIRST_NAME` — camelCase is the JavaScript
ecosystem convention and the most widely adopted in REST APIs.

---

## HTTP Methods

Use standard HTTP methods according to their defined semantics:

| Method | Purpose | Idempotent | Request Body | Typical Response |
|--------|---------|------------|--------------|------------------|
| `GET` | Retrieve a resource or collection | Yes | No | 200 with resource |
| `POST` | Create a new resource | No | Yes | 201 with created resource and Location header |
| `PUT` | Replace a resource entirely | Yes | Yes | 200 with updated resource |
| `PATCH` | Update specific fields | No | Yes (partial) | 200 with updated resource |
| `DELETE` | Remove a resource | Yes | No | 204 No Content |

### Common violations

- Using `POST` for everything (ignores HTTP semantics)
- Using `PUT` for partial updates (that is `PATCH`)
- Using `GET` with a request body (bodies on GET are ignored by many proxies)
- Returning `200 OK` for a creation (should be `201 Created`)
- Returning `200 OK` with empty body for a deletion (should be `204`)

---

## Status Codes

Return the most specific applicable status code. Do not return `200` for
everything.

### Success codes
| Code | When to Use |
|------|-------------|
| `200 OK` | Successful GET, PUT, or PATCH |
| `201 Created` | Successful POST that created a resource (include `Location` header) |
| `204 No Content` | Successful DELETE or PUT/PATCH with no response body |

### Client error codes
| Code | When to Use |
|------|-------------|
| `400 Bad Request` | Malformed request, validation failure |
| `401 Unauthorized` | Missing or invalid authentication |
| `403 Forbidden` | Authenticated but not authorized |
| `404 Not Found` | Resource does not exist |
| `409 Conflict` | Request conflicts with current state (duplicate, version mismatch) |
| `422 Unprocessable Entity` | Request is syntactically valid but semantically wrong |
| `429 Too Many Requests` | Rate limit exceeded (include `Retry-After` header) |

### Server error codes
| Code | When to Use |
|------|-------------|
| `500 Internal Server Error` | Unexpected server failure |
| `502 Bad Gateway` | Upstream service failure |
| `503 Service Unavailable` | Server is temporarily unavailable (include `Retry-After`) |

---

## Querying and Filtering

### Use query parameters for filtering, sorting, and pagination

```
GET /orders?status=active&sort=createdAt:desc&limit=20&offset=40
GET /users?role=admin&fields=id,name,email
```

### Pagination is mandatory for collection endpoints

Any endpoint that returns a list MUST support pagination. Unbounded result
sets are a reliability risk.

**Offset-based** (simple, common):
```
GET /orders?limit=20&offset=40
```

**Cursor-based** (better for large datasets, no skipping):
```
GET /orders?limit=20&after=eyJpZCI6MTIzfQ
```

Response should include pagination metadata:
```json
{
  "data": [...],
  "pagination": {
    "total": 142,
    "limit": 20,
    "offset": 40,
    "hasMore": true
  }
}
```

### Support field selection to reduce payload size

```
GET /users?fields=id,name,email
```

This is especially valuable for mobile clients or bandwidth-sensitive
consumers.

---

## Error Responses

### Use a consistent error response structure

Every error response should follow the same schema so clients can parse
errors uniformly:

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The request body contains invalid fields",
    "details": [
      {
        "field": "emailAddress",
        "message": "Must be a valid email address",
        "value": "not-an-email"
      }
    ]
  }
}
```

### Error messages should help the consumer fix the problem

| Bad | Good |
|-----|------|
| "Invalid input" | "The 'startDate' field must be a date in ISO 8601 format (e.g., 2026-01-15)" |
| "Server error" | "Unable to process payment: the payment gateway timed out. Please retry." |
| "Not found" | "No order found with ID 456 for user 123" |

---

## Versioning

### Version your API from day one

Use URI path versioning for simplicity and discoverability:

```
GET /v1/users
GET /v2/users
```

### Do not break backward compatibility within a version

Within a version, you may:
- Add new fields to responses
- Add new optional query parameters
- Add new endpoints

You must not:
- Remove or rename existing fields
- Change field types
- Change the meaning of existing status codes
- Add required parameters to existing endpoints

---

## Common Review Findings

When reviewing REST endpoints, flag:

1. **Verbs in paths**: `/getUser` instead of `GET /users/:id`
2. **Singular collection names**: `/user` instead of `/users`
3. **Missing pagination**: List endpoints without limit/offset
4. **Generic status codes**: Returning 200 for everything
5. **Inconsistent error format**: Different error shapes across endpoints
6. **Missing versioning**: No `/v1/` prefix or version header
7. **Deep nesting**: More than two levels of resource nesting
8. **Mixed casing**: snake_case URLs, PascalCase JSON, etc.
9. **Missing Location header**: POST returns 201 without a Location header
10. **PUT for partial updates**: Using PUT when PATCH is appropriate
