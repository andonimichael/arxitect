# Naming Conventions Reference

Names are the primary documentation of code. A well-named class, method, or
variable communicates intent without requiring comments or documentation. This
reference covers naming principles that apply across languages.

## General Principles

### Use complete words, never abbreviations

Abbreviations save keystrokes but cost comprehension. Every reader must
mentally expand the abbreviation, and different readers may expand it
differently.

| Bad | Good | Why |
|-----|------|-----|
| `usrMgr` | `userManager` | "usr" could be "user" or "username" |
| `reqCtx` | `requestContext` | Abbreviations exclude newcomers |
| `authSvc` | `authenticationService` | "auth" is ambiguous: authentication or authorization? |
| `tmpFile` | `temporaryFile` | "tmp" is jargon |
| `numRetries` | `retryCount` | "num" prefix is a holdover from Hungarian notation |
| `e` | `error` or `exception` | Single-letter names reveal nothing |
| `cb` | `callback` or `onComplete` | Describe what it does, not what it is |

**Exception**: Loop variables `i`, `j`, `k` in small, tight loops where the
scope is three lines or fewer. Even then, `index`, `row`, `column` are
clearer.

### Use upper camel case for acronyms in identifiers

Treat acronyms as words, not as sequences of capital letters. All-caps
acronyms create unreadable compound names and ambiguous word boundaries.

| Bad | Good | Why |
|-----|------|-----|
| `HTTPSRESTClient` | `HttpsRestClient` | Word boundaries are invisible in all-caps |
| `XMLHTTPRequest` | `XmlHttpRequest` | Where does XML end and HTTP begin? |
| `getHTTPSURL` | `getHttpsUrl` | Three concatenated acronyms are unreadable |
| `parseJSONRPCResponse` | `parseJsonRpcResponse` | Camel case preserves readability |
| `AWSS3Bucket` | `AwsS3Bucket` | Consistent word-casing throughout |
| `IOError` | `IoError` | Two-letter acronyms follow the same rule |

**The rule**: In camelCase or PascalCase identifiers, capitalize only the
first letter of each acronym. This preserves visual word boundaries that
humans need to parse compound names.

### Names should reveal intent

A name should answer: what does this represent, and why does it exist?

| Bad | Good | Why |
|-----|------|-----|
| `data` | `customerRecords` | What kind of data? |
| `info` | `paymentDetails` | "info" adds no information |
| `result` | `validationErrors` | Result of what? |
| `flag` | `isRetryEnabled` | What does the flag control? |
| `list` | `pendingOrders` | What is in the list? |
| `process()` | `validateAndSubmitOrder()` | "process" could mean anything |
| `handle()` | `routeIncomingRequest()` | What is being handled, and how? |

### Avoid meaningless qualifiers

Words like "data", "info", "object", "item", "thing", "stuff", "helper",
"utils" add no meaning. If removing the qualifier makes the name unclear, the
remaining word is wrong too.

| Bad | Good | Why |
|-----|------|-----|
| `CustomerData` | `Customer` | All classes contain data |
| `OrderInfo` | `OrderSummary` or `Order` | "Info" is noise |
| `StringHelper` | `StringFormatter` | What does it help with? |
| `PaymentUtils` | `PaymentCalculator` | "Utils" is a grab bag |

---

## Class Naming

### Classes are nouns

Classes represent things (entities, concepts, services). Name them as nouns
or noun phrases.

| Bad | Good | Why |
|-----|------|-----|
| `Validate` | `Validator` | Classes are things, not actions |
| `SendEmail` | `EmailSender` | The class name is not a command |
| `ManageUsers` | `UserRepository` | Name the role, not the verb |

### Name classes by their role, not their implementation

| Bad | Good | Why |
|-----|------|-----|
| `HashMap` (as domain class) | `UserRegistry` | Consumers care about role, not storage |
| `OrderArray` | `OrderCollection` | Implementation may change |
| `SqlUserStore` | `UserRepository` | At domain layer, hide the storage mechanism |

**Exception**: Infrastructure implementations can reveal their mechanism
when it distinguishes them from alternatives: `PostgresUserRepository`
implements `UserRepository`.

---

## Method Naming

### Methods are verbs (for commands) or describe their return (for queries)

| Type | Pattern | Examples |
|------|---------|----------|
| Command (mutates state) | verb + object | `saveOrder()`, `sendNotification()`, `deleteUser()` |
| Query (returns data) | describes what is returned | `activeUsers()`, `orderTotal()`, `isEligible()` |
| Predicate (returns boolean) | `is`, `has`, `can`, `should` prefix | `isValid()`, `hasPermission()`, `canRetry()` |
| Factory (creates instance) | `create`, `from`, `of` prefix | `createFromTemplate()`, `ofType()`, `fromJson()` |
| Conversion | `to` prefix | `toJson()`, `toString()`, `toDomainModel()` |

### Method names should make call sites read like prose

```
// Bad: what does "execute" mean here?
processor.execute(order, true, null)

// Good: the call site communicates intent
orderProcessor.submitForFulfillment(order)
```

### Avoid get/set prefixes unless they follow a language convention

In languages where getters and setters are idiomatic (Java), follow the
convention. In languages where they are not (Python, Kotlin, Ruby), prefer
direct property access or descriptive method names.

---

## Parameter Naming

### Parameters should be self-documenting

A method signature should read like a sentence. Parameter names are part of
that sentence.

```
// Bad: what do these parameters mean?
transfer(account1, account2, amount, true)

// Good: parameters document themselves
transfer(fromAccount, toAccount, amount, allowOverdraft)
```

### Boolean parameters should describe the true condition

| Bad | Good |
|-----|------|
| `verbose` | `includeDetailedOutput` |
| `force` | `overwriteExisting` |
| `quiet` | `suppressWarnings` |

### Avoid boolean parameters for mode selection

Boolean parameters at call sites are cryptic. Prefer enums, named constants,
or separate methods.

```
// Bad: what does "true" mean?
user.save(true)

// Good: the intent is clear
user.saveWithValidation()
// or
user.save(ValidationMode.STRICT)
```

---

## Type Safety and Expressiveness

### Use types to prevent misuse

Strong typing catches errors at compile time rather than runtime.

| Weak | Strong | Why |
|------|--------|-----|
| `string` for email | `EmailAddress` type | Prevents passing a name where email is expected |
| `number` for currency | `Money` type | Prevents mixing currencies or losing precision |
| `string` for ID | `UserId`, `OrderId` types | Prevents passing a user ID where order ID is expected |
| `any` or `object` | Specific interface | Specific types enable IDE support and catch errors |
| `number` for status | `OrderStatus` enum | Enums document valid values |

### Prefer enums over boolean flags and magic strings

```
// Bad
setLogLevel("warn")
setAlignment(1)

// Good
setLogLevel(LogLevel.WARN)
setAlignment(Alignment.CENTER)
```

### Return specific types, not primitives

```
// Bad: caller must guess what the number means
getAge(): number

// Good: type communicates semantics
getAge(): Years
```

### Use Optional/Maybe for values that may be absent

Do not use `null` to represent "no value" when the language provides an
`Optional`, `Maybe`, or equivalent type. This makes the possibility of
absence explicit in the type signature.

---

## Language-Specific Guidance

### Java (Effective Java inspired)

- Prefer static factory methods over constructors for clarity:
  `Duration.ofMinutes(5)` over `new Duration(5, TimeUnit.MINUTES)`
- Use `Optional<T>` for return types that may be empty; never for parameters
- Prefer interfaces over abstract classes for type definitions
- Use `@Override` consistently
- Avoid raw types; always parameterize generics

### Python (Effective Python inspired)

- Use type hints on all public function signatures
- Use `@dataclass` or `NamedTuple` for data carriers instead of plain dicts
- Use `Enum` instead of string constants
- Prefer keyword arguments for functions with more than two parameters
- Use `Protocol` for structural typing (duck typing with type safety)
- Raise specific exceptions, not generic `Exception` or `ValueError`
  without context

### TypeScript

- Use `readonly` for properties that should not change after construction
- Prefer `interface` over `type` for object shapes (they are extendable)
- Use discriminated unions instead of type assertions
- Avoid `any`; use `unknown` when the type is truly unknown
- Use template literal types for string patterns when appropriate
