# [Title]

## 1. Metadata
- **Decision ID:** ADR-XXX
- **Date:** [YYYY-MM-DD]
- **Roadmap Phase:** (Phase 1 / 2 / 3 / 4)
- **Status:** Proposed / Accepted / Deprecated
- **Scope:** (Global / Feature: Transaction / Auth / Core)

## 2. Context (Why this decision exists)
Explain the technical conditions when the decision was made.

**Writing Guide:**
- What problem is being faced?
- What constraints are relevant? (time, skill, performance, team)
- Which roadmap phase is currently active?
- Focus on context, not the solution.

## 3. Decision
State the decision made clearly and explicitly.

**Example:**
We will use Riverpod as the primary state management solution for all features.

## 4. Options Considered
List the alternatives that were genuinely considered.

**Suggested Format:**
- Option A — [Alternative 1]
- Option B — [Alternative 2]
- Option C — [Alternative 3]

Does not need to be long, but must be honest.

## 5. Trade-offs Analysis (Critical Section)
For each option, explain:
- Pros
- Cons
- Long-term impact

**Example:**
**Riverpod**
- (+) Compile-time safety
- (+) High testability
- (−) Learning curve

This section demonstrates your engineering maturity.

## 6. Consequences
What is the impact of this decision going forward?
- What becomes easier?
- What becomes harder?
- What risks must be accepted?

**Example:**
Initial refactor is more expensive, but feature scaling is safer.

## 7. Implementation Notes
Practical implementation notes:
- Boundaries to maintain
- Anti-patterns to avoid
- Folder / file references

## 8. Revisit Criteria
When can this decision be re-evaluated?

**Example:**
- If feature count > X
- If performance degrades significantly
- If requirements change

This shows that the decision is not dogma.

## 9. Related Artifacts
- PR Link
- Diagrams
- Related documentation
