---
name: to-tickets
description: Break specs into tracer-bullet vertical slice tickets with explicit Blocked-by dependency edges.
---

# To Tickets (Tracer-Bullet Vertical Slicing)

Break a plan or PRD (`docs/03-features/<FEAT-ID>-<slug>/prd.md` & `docs/02-architecture/architecture.md`) into a set of **tracer-bullet vertical slice tickets** inside `docs/03-features/<FEAT-ID>-<slug>/tasks.md`, each declaring the tickets/tasks that **block** it (`Blocked by:`).

## Process

### 1. Gather context

Read `GLOSSARY.md`, `docs/03-features/<FEAT-ID>-<slug>/prd.md`, `docs/01-design/design-spec.md`, and `docs/02-architecture/architecture.md`.

### 2. Explore the codebase

Understand the current state of the code. Ticket titles and descriptions must use the project's `GLOSSARY.md` domain vocabulary and respect ADRs in `docs/02-architecture/adr/`.

Look for opportunities to prefactor the code to make the implementation cleaner. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** vertical slices:

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, deep module, API, UI, seam tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable and verifiable on its own
- Each slice is sized to fit cleanly in a single context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each Story and `TASK-XX` its **blocking edges** (`Blocked by:`): the other tasks that must complete before it can start. A task with `Blocked by: None` can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks many call sites at once. Sequence wide refactors as **expand–contract**:
1. **Expand:** Add the new form beside the old so nothing breaks.
2. **Migrate batches:** Migrate call sites in batches sized by blast radius, keeping tests green batch to batch.
3. **Contract:** Delete the old form once no caller remains.

### 4. Write the Vertical Slice Task Board (`docs/03-features/<FEAT-ID>-<slug>/tasks.md`)

Write the complete Tracer-Bullet Vertical Slice task board directly into `docs/03-features/<FEAT-ID>-<slug>/tasks.md` (and/or `docs/tasks.md` following the exact template in `skills/lead-engineer/SKILL.md`), where every Story (`Story 1`, `Story 2`, ...) and every sub-task (`TASK-01 (RED)`, `TASK-02 (GREEN - Schema)`, `TASK-03 (GREEN - Module)`, `TASK-04 (GREEN - API)`, `TASK-05 (GREEN - UI)`, `TASK-06 (VERIFY)`) has explicit `Blocked by:` dependency edges, estimated files to touch, and a complete Definition of Done checklist.
