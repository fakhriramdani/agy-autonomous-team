---
name: agy-team
description: Initialize (standard or open-source stealth mode), check status, or remove the AGY Autonomous Team workflow in the current repository. Trigger with /agy-team init, /agy-team init-oss, /agy-team status, /agy-team off, or /agy-team remove.
---

# Skill: `agy-team` (Repository Initialization, Open-Source Stealth Mode & Removal Controller)

Use this skill whenever the user types `/agy-team init`, `/agy-team init-oss` (or `/agy-team init --oss`), `/agy-team off`, `/agy-team remove`, or `/agy-team status`.

## 2 Initialization Modes (`standard` vs `oss-stealth`)

### Mode A: `/agy-team init [optional project brief]` — Standard Setup (Docs Tracked in Git)
Use for **Private / Internal / Team Repositories** where product, design, architecture, and QA documentation (`docs/**`, `GLOSSARY.md`) SHOULD be tracked in Git alongside application code.
1. Create `.agents/TEAM_STATE.json` with `"enabled": true` and `"repo_mode": "standard"`:
   ```json
   {
     "enabled": true,
     "repo_mode": "standard",
     "ticket_id": "FEAT-001",
     "tier": 3,
     "stage": "GATE_0_DISCOVERY",
     "gate_0_user_approved": false,
     "gate_1_user_approved": false,
     "pr_user_approved": false,
     "gate_2_user_approved": false,
     "initialized_at": "<ISO-8601>"
   }
   ```
2. Create `.agents/LESSONS_LEARNED.md` and `.agents/METRICS.log` if missing.
3. If `.git/info/exclude` previously contained an `# BEGIN AGY-TEAM-OSS-EXCLUDE` block, remove that block so `docs/` can be tracked normally.
4. Confirm to the User:
   > "✅ **AGY Autonomous Team (`STANDARD MODE`) aktif di repository ini.** Seluruh kode dan dokumentasi (`docs/`) akan ter-track di Git."
5. Proceed to **Gate 0: Discovery Interview** (`role-orchestrator`).

---

### Mode B: `/agy-team init-oss [optional project brief]` (or `/agy-team init --oss`) — Open-Source Stealth Setup (Code-Only Git History)
Use for **Public / Open-Source Repositories** where you want **ONLY `@engineer`'s clean source code & test commits** in Git history, while keeping all internal workflow artifacts (`.agents/`, `.taste-skill/`, `GLOSSARY.md`, `docs/00-product/`..`docs/04-patches/`) **100% local on disk and invisible to Git** (without even polluting the public `.gitignore`!).
1. Ensure `.git` exists (`git init` if not yet a git repository).
2. Write `.agents/TEAM_STATE.json` with `"enabled": true` and `"repo_mode": "oss-stealth"`:
   ```json
   {
     "enabled": true,
     "repo_mode": "oss-stealth",
     "ticket_id": "FEAT-001",
     "tier": 3,
     "stage": "GATE_0_DISCOVERY",
     "gate_0_user_approved": false,
     "gate_1_user_approved": false,
     "pr_user_approved": false,
     "gate_2_user_approved": false,
     "initialized_at": "<ISO-8601>"
   }
   ```
3. Automatically append the **Stealth Exclude Block** into **`.git/info/exclude`** (never `.gitignore`, so the public repository shows zero trace of AI tooling):
   ```gitignore
   # BEGIN AGY-TEAM-OSS-EXCLUDE
   /.agents/
   /.taste-skill/
   /GLOSSARY.md
   /docs/00-product/
   /docs/01-design/
   /docs/02-architecture/
   /docs/03-features/
   /docs/04-patches/
   /docs/scope.md
   /docs/prd.md
   /docs/design-spec.md
   /docs/preview.html
   /docs/figma-console.js
   /docs/figma-plugin/
   /docs/architecture.md
   /docs/tasks.md
   /docs/adr/
   /docs/code-review.md
   /docs/test-plan.md
   /docs/qa-report.md
   # END AGY-TEAM-OSS-EXCLUDE
   ```
4. **Auto-Generate Non-Commercial License (`LICENSE`):**
   - If the repository does not yet have a `LICENSE` file, copy `~/.gemini/config/plugins/autonomous-team-kit/LICENSE` (**PolyForm Noncommercial License 1.0.0**, Copyright Fakhri Ramdani) to `./LICENSE` so the public repository is legally protected against unauthorized third-party commercialization from Day 1.
5. Enforce **Engineer-Only Clean Code Commits**:
   - All roles (`@lead-pm`, `@pm`, `@uiux`, `@lead-engineer`, `@qa`) still write and read `docs/**` and `.agents/**` on local disk as usual, but **NEVER run `git add` or `git commit` on them**.
   - `@engineer` stages and commits **ONLY application code, tests, and `LICENSE` / public `README.md`** (`src/`, `app/`, `tests/`, `package.json`, `LICENSE`, etc.) using clean Conventional Commits (`<type>(<scope>): <summary>`) without internal `(TASK-XX)` suffixes.
6. Confirm to the User:
   > "🕵️‍♂️ **AGY Autonomous Team (`OPEN-SOURCE STEALTH MODE`) aktif di repository ini.**
   > - Seluruh dokumen internal (`.agents/`, `docs/00-product`..`04-patches`, `GLOSSARY.md`) tetap dibuat di disk lokal untuk panduan antar-role, tetapi otomatis dikecualikan via `.git/info/exclude` (tanpa mengotori `.gitignore` publik).
   > - File `LICENSE` (**PolyForm Noncommercial License 1.0.0**) telah dipasang untuk melarang komersialisasi oleh pihak ketiga.
   > - Di GitHub publik nanti **100% hanya akan ada commit kode bersih dari `@engineer`**."
7. Proceed to **Gate 0: Discovery Interview** (`role-orchestrator`).

---

## Removal & Status Commands

### 3. `/agy-team off` or `/agy-team remove` — Deactivate & Remove Workflow from Current Repo
1. Delete `.agents/` and `.taste-skill/`.
2. Strip the `# BEGIN AGY-TEAM-OSS-EXCLUDE ... # END AGY-TEAM-OSS-EXCLUDE` block from `.git/info/exclude` if present.
3. Preserve `docs/` by default unless `--purge-docs` is passed (`/agy-team remove --purge-docs`).
4. Confirm to the User that the repository has returned to **DORMANT MODE (Standard AI Assistant)**.

### 4. `/agy-team status` — Inspect Current Repo Workflow State
1. Check whether `.agents/TEAM_STATE.json` exists.
2. Print `ACTIVE` (showing `repo_mode`: `standard` vs `oss-stealth`, `ticket_id`, `stage`, and Gate flags) or `DORMANT`.
