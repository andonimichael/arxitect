# SOLID Principles Reference

## Single Responsibility Principle (SRP)

**Definition**: A class should have one, and only one, reason to change. Each
class should encapsulate a single responsibility or concept.

**Violation indicators**:
- Class name contains "And" or "Manager" or "Handler" with multiple unrelated
  behaviors
- A change to one feature requires modifying a class that also handles an
  unrelated feature
- Class has methods that operate on different groups of instance variables
- Class imports from many unrelated modules or packages
- The class description requires the word "and" to summarize its purpose

**Evaluation approach**:
1. Identify who or what would request a change to this class
2. If more than one actor could independently require changes, the class
   likely violates SRP
3. Look for cohesion: do all methods operate on the same data?

**Common fix**: Extract the secondary responsibility into its own class. The
original class delegates to the new class or they share a common interface.

**When SRP does not apply**: Simple data transfer objects, configuration
classes, and thin wrappers where splitting would add complexity without
benefit.

---

## Open/Closed Principle (OCP)

**Definition**: Software entities should be open for extension but closed for
modification. You should be able to add new behavior without changing existing
code.

**Violation indicators**:
- Long if/else or switch chains that grow when new types are added
- Functions that check `instanceof` or type tags to decide behavior
- Adding a new feature requires modifying a stable, well-tested class
- Feature flags embedded in business logic

**Evaluation approach**:
1. Imagine adding a new variant of the behavior. How many existing files
   must change?
2. If adding a new type requires modifying an existing class beyond
   registration, OCP is violated
3. Look for polymorphism opportunities where conditionals exist

**Common fix**: Introduce an abstraction (interface or abstract class) and
implement new behavior as new classes that conform to the abstraction.

**When OCP does not apply**: Simple programs with no anticipated variation.
Premature abstraction for hypothetical future requirements is worse than a
straightforward conditional.

---

## Liskov Substitution Principle (LSP)

**Definition**: Subtypes must be substitutable for their base types without
altering the correctness of the program.

**Violation indicators**:
- Subclass overrides a method and changes its expected behavior or throws an
  unexpected exception
- Subclass has empty or no-op implementations of inherited methods
- Client code checks the concrete type of an object before calling a method
- Subclass weakens postconditions or strengthens preconditions

**Evaluation approach**:
1. For each subclass, verify that it honors the contract established by the
   base class
2. Check that overridden methods maintain the same preconditions,
   postconditions, and invariants
3. Look for "refused bequest" -- inherited methods that the subclass does
   not meaningfully implement

**Common fix**: Reconsider the inheritance hierarchy. Often composition is
more appropriate than inheritance. Extract a narrower interface that the
subclass can honestly implement.

**When LSP does not apply**: When inheritance is not used. LSP is specifically
about subtype relationships.

---

## Interface Segregation Principle (ISP)

**Definition**: Clients should not be forced to depend on interfaces they do
not use. Prefer many small, specific interfaces over one large general-purpose
interface.

**Violation indicators**:
- Interface with many methods where most implementers only use a few
- Classes that implement an interface but throw "not supported" for some
  methods
- Changes to an interface method force recompilation or modification of
  classes that never call that method
- A "god interface" that tries to represent all behaviors of a subsystem

**Evaluation approach**:
1. For each interface, check how many of its methods each implementer uses
2. If implementers routinely ignore methods, the interface is too broad
3. Look for natural groupings of methods that serve different clients

**Common fix**: Split the interface into smaller, role-specific interfaces.
Classes implement only the interfaces relevant to their behavior.

**When ISP does not apply**: When an interface genuinely represents a
cohesive set of operations that all implementers need.

---

## Dependency Inversion Principle (DIP)

**Definition**: High-level modules should not depend on low-level modules.
Both should depend on abstractions. Abstractions should not depend on details.
Details should depend on abstractions.

**Violation indicators**:
- Business logic directly instantiates infrastructure classes (database
  connections, HTTP clients, file system access)
- High-level policy code imports from low-level implementation packages
- No interfaces or abstractions between layers
- Changing a database driver requires modifying business logic

**Evaluation approach**:
1. Trace the dependency direction: do abstractions live with the high-level
   code or the low-level code?
2. Check if business logic can be tested without real infrastructure
3. Look for `new` / direct construction of dependencies that should be
   injected

**Common fix**: Define interfaces in the high-level module. Low-level modules
implement those interfaces. Use dependency injection to wire them together.

**When DIP does not apply**: Small scripts, simple applications with no
layering, or leaf nodes of the dependency graph where inversion adds no value.
