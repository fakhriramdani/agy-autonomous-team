---
name: to-spec
description: Synthesize business scope into User Personas, User Stories, quantifiable Gherkin Acceptance Criteria, Functional Requirements, and Business Data Rules in docs/00-product/prd.md.
---

# To Spec (Functional PRD Synthesis — Zero Technical Overlap)

This skill takes `GLOSSARY.md` and `docs/00-product/scope.md` and synthesizes or version-updates the single canonical Product Requirements Document at **`docs/00-product/prd.md`** (never create duplicate `prd.md` files in other folders).

## Process

1. Read `GLOSSARY.md` (read-only) and `docs/00-product/scope.md`. Use the exact `GLOSSARY.md` domain vocabulary throughout `docs/00-product/prd.md`.
2. Do **NOT** duplicate the Problem Statement, Solution Vision, RICE table, or Out-of-Scope list from `docs/00-product/scope.md`, and do **NOT** write technical REST endpoints, Zod schemas, SQL tables, or module seams (those belong exclusively to `@lead-engineer` in `docs/02-architecture/architecture.md`).
3. Write or version-update **`docs/00-product/prd.md`** (incrementing `Version: 1.0 -> 1.1` and appending to `## 6. Revision History` when adding features) following the exact template in `skills/pm/SKILL.md`:
   - `## 1. Target Users & Personas`
   - `## 2. User Journeys & End-to-End Functional Flows`
   - `## 3. User Stories & Quantifiable Gherkin Acceptance Criteria` (`US-01..US-XX`: Happy Path, Validation/Negative Flow, Business Edge Case)
   - `## 4. Functional Requirements Matrix` (`FR-01..FR-XX`)
   - `## 5. Business Data Entities & Domain Validation Rules`
   - `## 6. Revision History`
