# Method and Parameter Design Reference

Well-designed methods are the building blocks of usable APIs. A method
signature is a contract: it should communicate what the method does, what it
needs, and what it returns — all without requiring the caller to read the
implementation.

## Method Signature Principles

### Keep parameter lists short

Methods with many parameters are hard to call correctly. Each parameter is a
decision the caller must make, and decisions compound cognitive load.

| Parameters | Assessment | Action |
|------------|------------|--------|
| 0-2 | Ideal | No action needed |
| 3 | Acceptable | Ensure each parameter is essential |
| 4+ | Too many | Introduce a parameter object or builder |

**Fixing long parameter lists**:

1. **Parameter object**: Group related parameters into a named object.
   ```
   // Before: 6 parameters, easy to mix up
   createUser(name, email, role, department, startDate, manager)

   // After: intent is clear, order does not matter
   createUser(UserRegistration(name, email, role, department, startDate, manager))
   ```

2. **Builder pattern**: For optional parameters, use a builder that makes
   each option explicit.
   ```
   QueryBuilder()
     .from("orders")
     .where(status: "active")
     .limit(50)
     .build()
   ```

3. **Split the method**: If a method needs many parameters, it may be doing
   too much. Consider breaking it into focused methods.

### Avoid output parameters

Parameters should be inputs. When a method needs to return multiple values,
return an object instead of mutating a parameter.

```
// Bad: caller must know that "errors" is mutated
validate(order, errors)

// Good: return value is explicit
errors = validate(order)
```

### Order parameters by importance

Place required parameters first, optional parameters last. Place the "main
subject" of the operation first.

```
// Good: the thing being operated on comes first
sendEmail(recipient, subject, body, options)

// Bad: options before the main subject
sendEmail(options, recipient, subject, body)
```

---

## Self-Documenting Interfaces

### The Principle of Least Surprise

A method should do what its name says, nothing more. Side effects should be
either obvious from the name or absent entirely.

| Surprising | Unsurprising | Why |
|------------|--------------|-----|
| `getUser()` writes to a log | `getUser()` returns a user | "get" implies pure retrieval |
| `validate()` modifies the object | `validate()` returns errors | "validate" implies checking, not changing |
| `toString()` triggers a database query | `toString()` formats in memory | Conversion should be cheap |
| `close()` sends a notification | `close()` releases resources | Cleanup should not have business side effects |

### Make invalid states unrepresentable

Design types and method signatures so that misuse is a compile-time error,
not a runtime surprise.

```
// Bad: caller can pass any string, errors are runtime
setStatus("actve")  // typo discovered in production

// Good: compiler prevents invalid values
setStatus(Status.ACTIVE)
```

```
// Bad: nothing prevents negative quantity
createLineItem(product, -5, price)

// Good: type prevents invalid values
createLineItem(product, Quantity.of(5), price)
// Quantity.of(-5) throws at construction time
```

### Design for the call site, not the implementation

Read the method signature from the caller's perspective. What will the call
site look like?

```
// Implementation-centric: caller sees cryptic flags
cache.get("user:123", true, false, 300)

// Call-site-centric: intent is readable
cache.get("user:123", CacheOptions(
  refreshIfStale: true,
  throwOnMiss: false,
  timeoutSeconds: 300
))
```

---

## Return Type Design

### Return the most useful type

The return type should give callers what they need without forcing them to
transform or unwrap unnecessarily.

| Weak Return | Strong Return | Why |
|-------------|---------------|-----|
| `void` when a result exists | The result itself | Enable method chaining and assertions |
| `boolean` for success/failure | Result object or throw exception | Booleans cannot explain what went wrong |
| `null` for "not found" | `Optional<T>` or empty collection | Forces callers to handle absence explicitly |
| Raw collection | Immutable collection | Prevents callers from accidentally mutating state |

### Fail fast and fail loudly

When a method cannot fulfill its contract, it should fail immediately with a
clear error — not return a sentinel value that the caller might ignore.

```
// Bad: caller might not check for null
findUser(id): User | null

// Good: absence is explicit in the type
findUser(id): Optional<User>

// Also good: throw when absence is a bug, not an expected case
getUser(id): User  // throws UserNotFoundException
```

### Be consistent with collection returns

- Return empty collections, not null, when there are no results
- Use the most general collection interface as the return type
  (`List`, not `ArrayList`)
- Document whether the returned collection is mutable or immutable

---

## Error Design

### Exception names should describe what went wrong

| Bad | Good |
|-----|------|
| `AppException` | `PaymentDeclinedException` |
| `InvalidDataError` | `InvalidEmailFormatError` |
| `ProcessingError` | `OrderAlreadyFulfilledException` |

### Include context in error messages

Error messages should answer: what happened, what was expected, and what was
the actual value?

```
// Bad
raise ValueError("Invalid input")

// Good
raise InvalidEmailError(
  f"Expected a valid email address but received '{value}': "
  f"missing '@' symbol"
)
```

### Use error hierarchies for catch granularity

Define a base exception for your domain and specific subtypes for each
failure mode. This allows callers to catch broadly or narrowly as needed.

```
PaymentError (base)
├── InsufficientFundsError
├── PaymentDeclinedError
├── PaymentGatewayTimeoutError
└── InvalidPaymentMethodError
```

---

## Overloading and Default Parameters

### Prefer overloading or defaults to boolean mode switches

Each overload or default should represent a coherent use case, not a
combination of flags.

```
// Bad: two booleans create four possible behaviors, most nonsensical
export(data, includeHeaders: true, compressed: false)

// Good: named variants for each use case
exportWithHeaders(data)
exportCompressed(data)
exportCompressedWithHeaders(data)
```

### Telescope constructors toward convenience

The simplest constructor should require the minimum information needed.
Additional constructors (or factory methods) add optional configuration.

```
// Simple: just the essentials
HttpClient(baseUrl)

// Configured: adds optional settings
HttpClient(baseUrl, HttpClientOptions(
  timeout: Duration.ofSeconds(30),
  retryPolicy: RetryPolicy.exponentialBackoff(maxRetries: 3)
))
```
