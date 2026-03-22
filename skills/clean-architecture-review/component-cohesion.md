# Component Cohesion Principles Reference

These three principles govern which classes belong together in a component.
They exist in tension with each other: maximizing one often comes at the
expense of another. The architect's job is to find the right balance for the
system's current needs.

## Reuse/Release Equivalence Principle (REP)

**Definition**: The granule of reuse is the granule of release. Classes and
modules that are grouped into a component should be releasable together. A
component should make sense as a coherent, versioned unit.

**Violation indicators**:
- A component contains classes that serve unrelated purposes and would never
  be reused together
- A consumer of the component must depend on classes they do not need
- The component's name requires "Utils", "Common", or "Misc" because its
  contents have no unifying theme
- Changing one class in the component has no logical relationship to the
  other classes

**Evaluation approach**:
1. Ask: "Would someone reuse all of these classes together, or just a
   subset?"
2. Ask: "Does this component have a coherent theme that a consumer would
   recognize?"
3. Check that every class in the component relates to the component's stated
   purpose

**Common fix**: Split the component into smaller, thematically coherent
components. Each should have a clear, descriptive name that summarizes its
contents without using "and".

---

## Common Reuse Principle (CRP)

**Definition**: Classes that are used together should be grouped together.
Conversely, classes that are not used together should not be in the same
component. A dependency on a component is a dependency on everything in that
component.

**Violation indicators**:
- A consumer imports a component but uses only a small fraction of its classes
- Changes to unused classes in the component force consumers to revalidate
  or redeploy
- The component has "zones" of classes that are used by different sets of
  consumers
- Adding a dependency on this component pulls in transitive dependencies the
  consumer does not need

**Evaluation approach**:
1. For each consumer of the component, identify which classes they actually
   use
2. If different consumers use non-overlapping subsets, the component should
   be split
3. Check if the component's transitive dependencies are all relevant to its
   consumers

**Common fix**: Split the component along usage boundaries. Group classes
by which consumers need them together.

---

## Common Closure Principle (CCP)

**Definition**: Classes that change for the same reason and at the same time
should be grouped together. Classes that change at different times or for
different reasons should be separated. This is the Single Responsibility
Principle applied at the component level.

**Violation indicators**:
- A single change request requires modifying classes in many different
  components
- A component contains classes that change at very different rates (one
  class changes weekly, another has not changed in a year)
- Bug fixes or feature changes routinely touch multiple components that
  should be cohesive
- A component's change log shows unrelated changes interleaved

**Evaluation approach**:
1. Review the git history for the component. Do all classes change together?
2. Imagine a typical change request. How many components must be modified?
3. Identify the "reason for change" for each class and verify that all
   classes in the component share the same reason

**Common fix**: Regroup classes by their reason for change. If two classes
always change together but live in different components, move them together.

---

## The Tension Triangle

REP and CCP tend to make components larger (more classes together for
coherence and co-change). CRP tends to make components smaller (only include
what is used together). The right balance depends on the project's maturity:

- **Early in development**: Favor CCP. Minimize the cost of change by
  keeping co-changing classes together, even if components are larger.
- **As the system stabilizes**: Favor CRP. Minimize unnecessary dependencies
  by splitting components along usage boundaries.
- **For reusable libraries**: Favor REP. Ensure components make sense as
  coherent, releasable units.

When reviewing, consider where the project is in this lifecycle and evaluate
component boundaries accordingly.
