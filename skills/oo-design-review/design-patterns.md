# Gang of Four Design Patterns Reference

This reference covers when to apply and when to avoid the classic design
patterns. The goal is pragmatic application, not pattern maximization.

## Creational Patterns

### Factory Method
**When to apply**: Code uses `new` with conditional logic to decide which
class to instantiate. Multiple places create the same family of objects.
**When to avoid**: Only one concrete type exists and no variation is expected.
**Misapplication signal**: A factory that creates exactly one type.

### Abstract Factory
**When to apply**: A system must work with multiple families of related
objects and should be independent of how they are created.
**When to avoid**: There is only one product family. Simpler factory methods
or direct construction suffice.
**Misapplication signal**: Abstract factory with one concrete factory.

### Builder
**When to apply**: Object construction requires many parameters, optional
configurations, or step-by-step assembly. Telescoping constructors are
appearing.
**When to avoid**: The object has few, required parameters with no optional
configuration.
**Misapplication signal**: Builder for a class with two fields.

### Singleton
**When to apply**: Exactly one instance must exist system-wide and global
access is genuinely needed (not just convenient). Logging frameworks and
configuration registries are common legitimate uses.
**When to avoid**: Almost always. Singletons hide dependencies, make testing
difficult, and introduce global mutable state.
**Misapplication signal**: Using Singleton to avoid passing dependencies.
Prefer dependency injection.

### Prototype
**When to apply**: Creating objects is expensive and a similar object already
exists that can be cloned and modified.
**When to avoid**: Object creation is cheap. The clone semantics are unclear
(deep vs. shallow).

## Structural Patterns

### Adapter
**When to apply**: Integrating with a third-party API or legacy system whose
interface does not match your domain model.
**When to avoid**: You control both sides of the interface and can change one
to match the other.
**Misapplication signal**: Adapter between two classes in the same module.

### Decorator
**When to apply**: Adding behavior to individual objects without affecting
others of the same class. Cross-cutting concerns like logging, caching, or
authorization layered onto a core implementation.
**When to avoid**: The "decorations" are actually core behavior that belongs
in the class itself.
**Misapplication signal**: A single decorator used in exactly one place.

### Facade
**When to apply**: A subsystem has a complex API with many classes and a
simpler, unified interface would serve most clients.
**When to avoid**: The subsystem is already simple. Adding a facade just adds
another layer of indirection.

### Composite
**When to apply**: Objects form tree structures and clients should treat
individual objects and compositions uniformly (e.g., file systems, UI
component trees, expression trees).
**When to avoid**: The structure is flat. There is no meaningful "part-whole"
hierarchy.

### Proxy
**When to apply**: Access control, lazy loading, logging, or remote access
requires wrapping an object transparently.
**When to avoid**: The extra indirection provides no benefit.

## Behavioral Patterns

### Strategy
**When to apply**: An algorithm varies independently from the clients that
use it. Multiple conditional branches select between behavioral variants.
**When to avoid**: There is only one algorithm with no expected variation.
A simple lambda or function reference suffices for trivial cases.
**Misapplication signal**: Strategy pattern with one concrete strategy.

### Observer
**When to apply**: One-to-many dependency where changes to one object must
notify others, and the publisher should not know about subscribers.
**When to avoid**: There is exactly one subscriber. Direct method calls are
simpler and more traceable.

### Command
**When to apply**: Operations must be parameterized, queued, logged, or
undone. Request handling must be decoupled from request execution.
**When to avoid**: Simple direct method calls suffice and there is no need
for undo, queueing, or logging.

### Template Method
**When to apply**: An algorithm's structure is fixed but specific steps vary.
Subclasses override only the varying steps.
**When to avoid**: The "template" has only one implementation. Prefer
composition (Strategy) over inheritance when the variation is complex.

### State
**When to apply**: An object's behavior changes significantly based on its
internal state, and state-specific logic is scattered across conditionals.
**When to avoid**: There are only two or three simple states. A boolean or
enum with a switch is more readable.

### Iterator
**When to apply**: Traversal logic for a collection is complex or multiple
traversal strategies are needed.
**When to avoid**: The language's built-in iteration mechanisms suffice.

### Chain of Responsibility
**When to apply**: Multiple handlers might process a request, and the handler
is determined at runtime. Middleware pipelines are a common example.
**When to avoid**: There is a single, known handler.

## General Guidance

- Prefer the simplest solution that works. Introduce a pattern when the
  problem it solves actually exists, not when it might exist someday.
- If you cannot name the specific problem a pattern solves in the current
  code, the pattern is premature.
- Three is the magic number: wait until you see three instances of a problem
  before abstracting.
- Patterns are communication tools. Use them when they make the design
  clearer to the team, not when they make it more impressive.
