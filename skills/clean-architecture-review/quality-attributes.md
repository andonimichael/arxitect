# Quality Attributes Reference

These quality attributes assess whether the architecture supports the
practical needs of the software development lifecycle: the ability to test,
extend, and maintain the system over time.

## Testability

**Definition**: The degree to which the system supports testing individual
components in isolation, without requiring the full system to be running.

**Positive indicators**:
- Dependencies are injected, not constructed internally
- Business logic has no direct dependency on frameworks, databases, or
  external services
- Side effects are isolated behind interfaces that can be replaced with
  test doubles
- Pure functions are used where possible (input in, output out, no side
  effects)
- Test setup is simple: creating an instance of the class under test
  requires few or no dependencies

**Negative indicators**:
- Static method calls or global state make it impossible to substitute
  behavior in tests
- Business logic directly calls database queries, HTTP clients, or file
  system operations
- Constructor does significant work (network calls, file I/O, complex
  initialization)
- Testing a single class requires booting the entire application context
- Tests require specific infrastructure (running database, message queue)
  for unit-level verification

**Evaluation approach**:
1. For each class containing business logic, ask: "Can I instantiate and
   test this class with only in-memory dependencies?"
2. Check for constructor injection or method injection of dependencies
3. Verify that interfaces exist at infrastructure boundaries

---

## Extensibility

**Definition**: The degree to which new behavior can be added to the system
without modifying existing, tested code.

**Positive indicators**:
- New features are added by creating new classes that implement existing
  interfaces
- Plugin points or extension mechanisms exist for anticipated variation
- The Open/Closed Principle is followed at architectural boundaries
- Configuration-driven behavior allows new variants without code changes
- Event-driven patterns decouple producers from consumers

**Negative indicators**:
- Adding a new feature requires modifying a central class or configuration
  that many other parts depend on
- Feature additions consistently require changes to stable, widely-depended-
  upon components
- No clear extension points exist -- every new feature requires inserting
  code into existing control flow
- Adding a new type means updating switch statements or if/else chains in
  multiple locations

**Evaluation approach**:
1. Identify the most likely dimension of change for the system
2. Check whether that change can be made by adding new code rather than
   modifying existing code
3. Verify that extension points exist at the right abstraction level

---

## Maintainability

**Definition**: The degree to which the system is easy to understand, change,
and debug over time.

**Positive indicators**:
- Code is organized by domain concept, not by technical layer
- Names (classes, methods, variables) clearly communicate intent
- Each module has a focused purpose discoverable from its name and structure
- Error handling is consistent and informative
- Dependencies are explicit and traceable (no service locator or hidden
  global state)

**Negative indicators**:
- Classes or functions are excessively long (hundreds of lines)
- Deep inheritance hierarchies make behavior hard to trace
- Side effects are hidden: calling a getter modifies state, or a constructor
  initiates network requests
- "Shotgun surgery": a single conceptual change requires small edits in many
  files across the system
- Inconsistent patterns: the same problem is solved differently in different
  parts of the codebase

**Evaluation approach**:
1. Can a new team member understand the purpose of each module from its name
   and top-level structure?
2. For a typical bug fix, how many files must a developer understand to
   locate and fix the issue?
3. Are error paths handled consistently, or does each module invent its own
   error handling strategy?

---

## Applying Quality Attributes in Review

When reviewing code, evaluate quality attributes in this order:

1. **Testability first.** If the code cannot be tested in isolation, other
   qualities are unprovable. Testability issues are almost always CRITICAL.

2. **Maintainability second.** If the code is testable but hard to
   understand or change, it will accumulate technical debt. Maintainability
   issues are typically WARNING.

3. **Extensibility third.** If the code is testable and maintainable but
   closed to extension in its primary dimension of change, note it.
   Extensibility issues are often SUGGESTION unless the system is clearly
   about to need the extension.
