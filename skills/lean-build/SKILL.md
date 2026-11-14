---
name: lean-build
description: Build complete, production-grade vertical slices with clean module ownership, repository reuse, and full UI/UX polish.
---

# Lean Build (Cohesive End-to-End Vertical Slice Execution)

Turn each feature requirement into a complete, production-ready end-to-end vertical slice fitting the system's architecture.

- Derive observable acceptance criteria and explicit non-goals from `prd.md`, `design-spec.md`, `architecture.md`, and the repository.
- Trace entry points through all layers owning invariants (Transport/Route -> Domain Service -> Repository/Adapter -> UI).
- Deliver a complete, cohesive end-to-end path across responsible layers; never force complex work into a single monolithic file or hacky local patch.
- Reuse fitting public seams and helpers. Refactor cleanly when patching would duplicate behavior, weaken module ownership, or hide root causes.
- Preserve full visual polish, 7 interactive component states (`taste-skill 2.5.1`), structured logging (`requestId`), and strict TypeScript safety. Omit only unrequested speculative features (`Won't-Have` items).
- Keep the application runnable and buildable at every step.

Exercise the full path, run deterministic seam tests and runtime verification, and report completion with exact evidence.
