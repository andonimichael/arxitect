# Naming Conventions Reference

Names are the primary documentation of code. A well-named class, method, or
variable communicates intent without requiring comments or documentation. This
reference covers naming principles that apply across languages.

## General Principles

### Use complete words, never abbreviations

Abbreviations save keystrokes but cost comprehension. Readability and reducing
the mental overhead is preferred over reducing character counts.

**Exception**: Loop variables (e.g. `i`, `j`, `k`) in small, tight loops. Even
then, consider `index`, `row`, `column`.

### Names should reveal intent

A name should answer: what does this represent, and why does it exist?

| Bad | Good | Why |
|-----|------|-----|
| `data` | `customerRecords` | What kind of data? |
| `result` | `validationErrors` | Result of what? |
| `handle()` | `routeIncomingRequest()` | What is being handled, and how? |

### Avoid meaningless qualifiers

Remove qualifiers that don't add to the understanding of the word.

| Bad | Good | Why |
|-----|------|-----|
| `CustomerData` | `Customer` | All classes contain data |
| `StringHelper` | `StringFormatter` | What does it help with? |
| `PaymentUtils` | `PaymentCalculator` | "Utils" is a grab bag |

### Use upper camel case for acronyms in identifiers

In camelCase or PascalCase identifiers, capitalize only the
first letter of each acronym. This preserves visual word boundaries that
humans need to parse compound names.

| Bad | Good | Why |
|-----|------|-----|
| `HTTPSRESTClient` | `HttpsRestClient` | Word boundaries are invisible in all-caps |
| `parseJSONRPCResponse` | `parseJsonRpcResponse` | Camel case preserves readability |
| `AWSS3Bucket` | `AwsS3Bucket` | Consistent word-casing throughout |

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
| `OrderArray` | `OrderCollection` | Implementation may change |
| `SqlUserStore` | `UserRepository` | At domain layer, hide the storage mechanism |

**Exception**: Infrastructure implementations can reveal their mechanism
when it distinguishes them from alternatives: `PostgresUserRepository`
implements `UserRepository`.

---

## Method Naming

### Methods are verbs

Methods represent actions. Name them as verbs. Class methods should acts as
verbs on that noun.

| Type | Pattern | Examples |
|------|---------|----------|
| Command | verb + object | `saveOrder()`, `sendNotification()`, `deleteUser()` |
| Predicate | `is`, `has`, `can`, `should` prefix | `isValid()`, `hasPermission()`, `canRetry()` |
| Factory | `create`, `from`, `of` prefix | `createTemplate()`, `ofType()`, `fromJson()` |
| Conversion | `to` prefix | `toJson()`, `toString()`, `toDomainModel()` |

### Method names should make call sites read like prose

```
// Bad: what does "execute" mean here?
processor.execute(order, true, null)

// Good: the call site communicates intent
orderProcessor.submitForFulfillment(order)
```

---

## Parameter Naming

### Parameters should be self-documenting

A method signature should read like a sentence. Parameter names are part of
that sentence.

```
// Bad: what are you transferring from/to? What does overdraft mean?
transfer(from, to, amount, overdraft)

// Good: parameters document themselves
transfer(fromAccount, toAccount, amount, allowOverdraft)
```

### Boolean parameters should describe the true condition

| Bad | Good |
|-----|------|
| `force` | `overwriteExisting` |
| `quiet` | `suppressWarnings` |

---

## Type Safety and Expressiveness

### Prefer enums over boolean flags and magic strings

```
// Bad
setLogLevel("warn")
setAlignment(1)

// Good
setLogLevel(LogLevel.WARN)
setAlignment(Alignment.CENTER)
```

### Return specific types over ambiguous primitives

```
// Bad: caller must guess what the number means
getLogLevel(): number

// Good: type communicates semantics
getLogLevel(): LogLevel
```

### Use Optional/Maybe for values that may be absent

Do not use `null` to represent "no value" when the language provides an
`Optional`, `Maybe`, or equivalent type. This makes the possibility of
absence explicit in the type signature.

---
