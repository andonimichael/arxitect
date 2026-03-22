# REST Endpoint Design Reference

These best practices apply to public-facing REST APIs. Evaluate endpoints for
consistency, discoverability, and adherence to HTTP conventions.

## URL Structure

### Use nouns, not verbs, in endpoint paths

The HTTP method is the verb. The path identifies the resource.

| Bad | Good | Why |
|-----|------|-----|
| `GET /getUsers` | `GET /users` | "get" is duplicated |
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
| `/userprofiles` | `/user-profiles` |
| `/order_items` | `/order-items` |
| `/ProductCategories` | `/product-categories` |

### Nest resources to express relationships

Use hierarchical nesting to express ownership or containment.

```
GET  /orders/123/status          # The status belonging to order 123
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

## Return Formatting

### Never Return Raw Primitives

Your responses should always be objects, not raw primitives. This allows you to
extend your API in the future without breaking backwards compatibility.

```
# Bad: Raw response
GET /user/123/active
true

# Good: Extensible object
GET /user/123/active
{
    "isActive": true
}
```

This extends to raw arrays as well. Objects will allow you to add pagination,
metadata, etc. over time.

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

## Querying and Filtering

### Use query parameters for filtering, sorting, and pagination

```
GET /orders?status=active&sort=createdAt:desc&limit=20&offset=40
GET /users?role=admin&fields=id,name,email
```

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
