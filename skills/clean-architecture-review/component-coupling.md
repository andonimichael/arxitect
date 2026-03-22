# Component Coupling Principles Reference

These three principles govern the relationships between components. They
determine which dependencies are healthy and which will cause architectural
decay.

## Acyclic Dependencies Principle (ADP)

**Definition**: The dependency graph of components must be a directed acyclic
graph (DAG). There must be no cycles in the component dependency structure.

**Violation indicators**:
- Component A imports from Component B, and Component B imports from
  Component A (direct cycle)
- A chain of imports forms a cycle through three or more components
  (transitive cycle)
- A change to any component in the cycle forces all others to be rebuilt or
  retested
- You cannot determine a build order because of circular references
- Developers report "everything depends on everything"

**Evaluation approach**:
1. Trace import/require/include statements across components
2. Build a dependency graph and check for cycles
3. For each cycle found, identify which dependency is the weakest (most
   likely to be an accidental coupling)

**Breaking cycles**:
- **Dependency Inversion**: Introduce an interface in the depended-upon
  component that the other component implements
- **Extract shared component**: Move the classes causing the cycle into a
  new component that both depend on
- **Event-based decoupling**: Replace direct calls with events or callbacks

---

## Stable Dependencies Principle (SDP)

**Definition**: Depend in the direction of stability. A component that is
designed to be easy to change should not be depended on by a component that
is hard to change.

**Measuring stability (I)**:
- Fan-in: the number of incoming dependencies (other components that depend
  on this one)
- Fan-out: the number of outgoing dependencies (other components this one
  depends on)
- Instability I = Fan-out / (Fan-in + Fan-out)
- I = 0: maximally stable (many dependents, no dependencies)
- I = 1: maximally unstable (no dependents, many dependencies)

**Violation indicators**:
- A stable component (low I, many dependents) depends on an unstable
  component (high I, few dependents)
- Core business logic depends on UI or infrastructure components that change
  frequently
- A widely-used utility component imports from a feature-specific component

**Evaluation approach**:
1. Calculate or estimate the instability of each component
2. Verify that dependencies flow from unstable toward stable
3. For any dependency where a stable component depends on a less stable one,
   flag it as a violation

**Common fix**: Invert the dependency using an interface. The stable component
defines an interface; the unstable component implements it.

---

## Stable Abstractions Principle (SAP)

**Definition**: A component should be as abstract as it is stable. Stable
components should be abstract so their stability does not prevent extension.
Unstable components should be concrete since their instability allows the
code to be easily changed.

**Measuring abstractness (A)**:
- A = (number of abstract classes and interfaces) / (total number of classes)
- A = 0: fully concrete
- A = 1: fully abstract

**The Main Sequence**:
Plot each component on a graph with I (instability) on one axis and A
(abstractness) on the other. Healthy components fall near the line from
(I=0, A=1) to (I=1, A=0). This line is the Main Sequence.

**Zones of concern**:
- **Zone of Pain** (I=0, A=0): Stable and concrete. Hard to extend, and
  many things depend on it. Database schemas and concrete utility libraries
  often land here. Not always a problem but worth monitoring.
- **Zone of Uselessness** (I=1, A=1): Unstable and abstract. No one depends
  on it. Likely dead code or over-engineered interfaces with no implementers.

**Violation indicators**:
- A highly stable component (many dependents) is entirely concrete with no
  interfaces or abstract classes
- A highly abstract component (mostly interfaces) has no dependents
- Core domain components are concrete and rigid, preventing extension without
  modification

**Evaluation approach**:
1. For key components, estimate both I (instability) and A (abstractness)
2. Check proximity to the Main Sequence
3. Flag components in the Zone of Pain that would benefit from introducing
   abstractions
4. Flag components in the Zone of Uselessness that may be dead code

**Common fix**: For stable-concrete components, extract interfaces for the
behaviors that consumers depend on. For unstable-abstract components, either
find consumers or remove the unused abstractions.

---

## Dependency Direction

Beyond these three principles, verify the overall dependency direction:

- **Dependencies should point inward.** Outer layers (UI, infrastructure,
  frameworks) depend on inner layers (domain, business logic), never the
  reverse.
- **The domain layer has no outward dependencies.** Business rules should
  not import from web frameworks, databases, or UI libraries.
- **Boundary interfaces are defined by the inner layer.** When an inner
  layer needs something from an outer layer, it defines an interface that the
  outer layer implements (Dependency Inversion).
