# Composition and Inheritance Reference

Composition and inheritance are the two fundamental mechanisms for code reuse
and type relationships in object-oriented design. Each has strengths. The
skill is knowing which one a given situation calls for.

## When Inheritance Is the Right Choice

Inheritance models an **"is-a"** relationship. Use it when:

### The subtype genuinely represents a specialization

The subclass is a more specific version of the superclass. Every instance
of the subclass is, in every meaningful sense, an instance of the superclass.

```
# Good: a SavingsAccount is genuinely a kind of Account
class Account:
    def deposit(self, amount): ...
    def withdraw(self, amount): ...

class SavingsAccount(Account):
    def accrue_interest(self): ...
```

### The Liskov Substitution test passes

Any code that works with the base class should work identically with the
subclass. If you find yourself needing to override a method to do nothing,
throw an exception, or change the expected behavior, inheritance is wrong.

```
# Bad: Square violates Rectangle's contract
class Rectangle:
    def set_width(self, w): self.width = w
    def set_height(self, h): self.height = h

class Square(Rectangle):
    def set_width(self, w):
        self.width = w
        self.height = w  # Surprise! Setting width changes height
```

### The hierarchy is shallow and stable

Inheritance works best with one or two levels of depth. Deep hierarchies
are fragile: a change to a base class ripples unpredictably through all
descendants.

| Depth | Assessment |
|-------|------------|
| 1 level (base → child) | Usually fine |
| 2 levels | Acceptable if the middle class represents a genuine concept |
| 3+ levels | Likely a problem; consider refactoring to composition |

### You need polymorphic substitution

When client code needs to treat different variants uniformly through a
common interface, inheritance (or interface implementation) is the natural
fit.

```
// Good: polymorphic dispatch through a common base
for (Shape shape : shapes) {
    shape.draw(canvas);
}
```

---

## When Composition Is the Right Choice

Composition models a **"has-a"** or **"uses-a"** relationship. Use it when:

### You need behavior from multiple sources

Most languages allow only single inheritance. When a class needs
capabilities from several different sources, composition lets you combine
them without artificial hierarchy constraints.

```
// Composition: combine behaviors freely
class OrderProcessor {
    private final PaymentGateway payments;
    private final InventoryService inventory;
    private final NotificationSender notifications;

    // Uses each collaborator for its specific capability
}
```

### The relationship is about behavior, not identity

If you are reaching for inheritance to reuse methods rather than to express
a type relationship, composition is the better tool.

```
# Bad: inheriting for reuse, not identity
class UserService(DatabaseConnection):
    def find_user(self, user_id): ...

# Good: using the capability without becoming it
class UserService:
    def __init__(self, db: DatabaseConnection):
        self.db = db
    def find_user(self, user_id): ...
```

### The "inherited" behavior may change independently

When the behavior you are reusing might need to be swapped, configured, or
vary at runtime, composition with dependency injection gives you that
flexibility. Inheritance locks the choice at compile time.

```
// Composition: strategy can change at runtime or per configuration
class ReportGenerator {
    private final Formatter formatter;  // Could be CsvFormatter, PdfFormatter, etc.

    ReportGenerator(Formatter formatter) {
        this.formatter = formatter;
    }
}
```

### You want to limit the interface exposed to clients

Inheritance exposes the entire parent interface to consumers of the
subclass. Composition lets you expose only the specific methods the class
needs, keeping its surface area small.

```
# Inheritance: Stack inherits all of List's methods, including
# random access by index, which violates stack semantics
class Stack(List):  # Bad
    def push(self, item): self.append(item)
    def pop(self): return super().pop()
    # But clients can also call stack.insert(0, x), breaking LIFO

# Composition: Stack exposes only stack operations
class Stack:  # Good
    def __init__(self):
        self._items = []
    def push(self, item): self._items.append(item)
    def pop(self): return self._items.pop()
```

---

## Decision Framework

Use this checklist to decide between composition and inheritance:

| Question | If Yes → | If No → |
|----------|----------|---------|
| Is there a true "is-a" relationship that passes the Liskov test? | Inheritance is a candidate | Use composition |
| Will the hierarchy be shallow (1-2 levels)? | Inheritance remains viable | Use composition |
| Do clients need polymorphic substitution? | Inheritance or interfaces | Composition is fine |
| Do you need behavior from multiple unrelated sources? | Use composition | Either could work |
| Might the reused behavior change independently? | Use composition | Either could work |
| Are you inheriting to reuse code, not to model a type? | Use composition | Inheritance is appropriate |

When in doubt, start with composition. It is easier to introduce inheritance
later (by extracting an interface) than to decompose an inheritance hierarchy
into composed objects.

---

## Common Misapplications

### Inheriting from utility or infrastructure classes

```
# Bad: a service is not a kind of database connection
class UserService(PostgresConnection): ...

# Bad: a controller is not a kind of JSON serializer
class OrderController(JsonSerializer): ...
```

These create nonsensical type relationships and couple the class to a
specific infrastructure implementation.

### Deep hierarchies for slight variations

```
# Bad: 5-level hierarchy where each level adds one field
Animal → Mammal → Domestic → Pet → Dog → GoldenRetriever
```

This is fragile and hard to navigate. Prefer a flat structure with
composed traits or capabilities.

### Inheriting to share private helpers

If two classes need the same helper method, extract it into a shared utility
or collaborator class rather than creating an inheritance relationship that
does not model a real type hierarchy.

### "Refusing" inherited methods

If a subclass needs to disable, ignore, or throw exceptions for inherited
methods, the inheritance relationship is incorrect. The subclass is not truly
substitutable for the parent.

---

## Language-Specific Considerations

### Java

- Prefer interfaces with default methods over abstract classes when there
  is no shared state
- Use `final` on classes not designed for inheritance to signal intent
- Delegation (composition) is verbose but explicit; consider using Lombok's
  `@Delegate` or similar tools if boilerplate becomes excessive

### Python

- Mixins are a form of multiple inheritance that provides reusable behavior.
  Use them sparingly and keep each mixin focused on a single capability
- Python's duck typing reduces the need for inheritance-based polymorphism;
  a Protocol (structural typing) often suffices
- Dataclass inheritance is appropriate for simple data hierarchies

### TypeScript / JavaScript

- Classes can implement multiple interfaces, enabling polymorphism without
  inheritance
- Object spread and module composition are idiomatic alternatives to class
  inheritance
- Prefer function composition for behavior reuse in functional-style code

### General

Regardless of language, the question is always the same: does this class
**need to be** a kind of the parent, or does it just **need to use** some
of the parent's behavior? The first calls for inheritance. The second calls
for composition.
