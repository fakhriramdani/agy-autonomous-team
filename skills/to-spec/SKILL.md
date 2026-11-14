---
name: to-spec
description: Synthesize requirements into Problem, Solution, User Stories, Implementation & Testing Seams.
---

# To Spec (Production-Grade PRD Synthesis)

This skill takes the current conversation context, `GLOSSARY.md`, and `docs/00-product/scope.md` and synthesizes or version-updates the single canonical Product Requirements Document at **`docs/00-product/prd.md`** (never create duplicate `prd.md` files in other folders).

## Process

1. Explore the repo to understand the current state of the codebase. Use the project's `GLOSSARY.md` domain vocabulary throughout the spec, and respect any ADRs in `docs/02-architecture/adr/`.

2. Identify the public seams at which the feature will be tested (`docs/02-architecture/architecture.md`). Existing seams should be preferred to new ones. Use the highest public seam possible.

3. Write or version-update the specification directly in **`docs/00-product/prd.md`** (incrementing `Version: 1.0 -> 1.1` and updating `## 16. Revision History` when adding new features) following the complete industry-grade PRD template in `skills/pm/SKILL.md` (including quantifiable Gherkin Acceptance Criteria, Functional Requirements Matrix, NFRs, Data Requirements, Zod API Contract Summary, and UI/UX Cross-Reference):

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories & Gherkin Acceptance Criteria

A comprehensive, numbered list of user stories covering all aspects of the feature (`US-01`, `US-02`, ...), each with quantifiable Gherkin scenarios (Happy Path, Validation/Negative Flow, and Edge Case/Concurrency):

1. **US-01:** As a `<Canonical Actor from GLOSSARY.md>`, I want `<feature/capability>`, so that `<measurable benefit>`.
   - **Scenario 1.1 (Happy Path):** Given `<precondition>`, When `<action>`, Then `<quantifiable outcome>`.
   - **Scenario 1.2 (Validation / Negative Flow):** Given `<invalid input>`, When `<action>`, Then `<exact error message & zero state mutation>`.
   - **Scenario 1.3 (Edge Case / Concurrency):** Given `<duplicate click / timeout / unauthorized>`, When `<action>`, Then `<idempotent handling / retry / 401>`.

## Implementation & Seam Decisions

- Modules and public interfaces to be built or modified
- Architectural decisions, DB schema requirements, and Zod API contracts
- Specific UI/UX interactions (`docs/01-design/design-spec.md`)

## Testing Decisions

- Public seams under test (verify external behavior through public interfaces, never private implementation details)
- Concrete boundary and edge-case expectations for `test-plan.md`

## Out of Scope (`Won't-Have`)

Explicit list of excluded features from `scope.md`.

</spec-template>
