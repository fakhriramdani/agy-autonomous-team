# AGY Autonomous Team (`agy-autonomous-team`)

[![Antigravity](https://img.shields.io/badge/Antigravity-Plugin-blue.svg)](https://github.com/google/antigravity)
[![Figma MCP](https://img.shields.io/badge/Figma-Official%20MCP-F24E1E.svg)](https://mcp.figma.com/mcp)
[![Taste Skill](https://img.shields.io/badge/Taste%20Skill-2.5.1%20Anti--Slop-black.svg)](https://github.com/Leonxlnx/taste-skill)
[![Architecture](https://img.shields.io/badge/Architecture-Matt%20Pocock%20Suite-8A2BE2.svg)](https://github.com/mattpocock/skills)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-grade, 100% self-contained multi-role software engineering organization for **Google Antigravity**, **Claude Code**, and **Gemini CLI**. Runs with zero configuration divergence on **Windows Local**, **macOS**, and **Headless Linux VPS**.

Equipped with **60+ bundled professional engineering skills**, strict ironclad role boundaries, and automated approval interlocks.

---

## 1. Team Organization & Role Boundaries

Trigger any role explicitly in chat via `@orchestrator`, `@lead-pm`, `@pm`, `@uiux`, `@lead-engineer`, `@engineer`, `@qa`, or let `@orchestrator` route automatically.

| Role | Role Skill | Enforced Skills & Standards | Allowed Write Whitelist | Output Artifact |
| :--- | :--- | :--- | :--- | :--- |
| **Orchestrator** | `role-orchestrator` | `caveman`, `cavecrew`, `grilling`, `to-questionnaire`, `triage`, `wayfinder`, `handoff` | `.agents/TEAM_STATE.json`, `.agents/METRICS.log`, `.agents/LESSONS_LEARNED.md`, Git operations | Orchestration State & Release |
| **Lead PM** | `role-lead-pm` | `grilling` (Frontier Interview), `domain-modeling`, `to-spec`, MoSCoW / RICE | `docs/scope.md`, `GLOSSARY.md`, PRD Verdict Header | Scope & Domain Model |
| **PM** | `role-pm` | `to-spec` (Spec Template), `to-tickets` (Vertical Slices), Gherkin BDD | `docs/prd.md` | PRD & Acceptance Criteria |
| **UI/UX Designer** | `role-uiux` | Full `taste-skill 2.5.1` (9 House Rules, palettes, type, CLI dealers), Official Figma MCP | `docs/design-spec.md`, `docs/preview.html`, `docs/figma-plugin/*`, `docs/figma-console.js` | Design Spec, HTML Preview, Figma Frames |
| **Lead Engineer** | `role-lead-engineer` | `codebase-design` (Deep Modules & Seams), `domain-modeling` (ADRs), `ponytail-review`, 2-Axis `code-review` | `docs/architecture.md`, `docs/tasks.md`, `docs/adr/NNNN-*.md`, `docs/code-review.md` | Architecture, Task Board, Code Review |
| **Engineer** | `role-engineer` | `tdd` (Red-Green Vertical Slices at Agreed Seams), `ponytail` (YAGNI + Debt Tags), `caveman-commit` | Application code (`src/*`, `app/*`), seam tests (`tests/*`), task checkboxes in `docs/tasks.md` (**on `feat/*` only**) | Verified Working Code on Branch |
| **QA Engineer** | `role-qa` | `verify-and-stop`, `investigate-first`, `diagnosing-bugs` (6-Phase Repro Loop), `taste-skill` Gate Checks | `docs/test-plan.md`, `docs/qa-report.md`, `.taste-skill/*` | Test Plan, Edge Matrix, QA Verdict on `main` |

---

## 2. Core Guardrails & Hard Operational Rules

1. **Ironclad Boundaries (Zero Trespassing):** Each role can ONLY write to its designated whitelist. Unauthorized file edits are automatically reverted with `git checkout -- <file>` by the Orchestrator.
2. **Double-Lock Gate Approval (No Skipping):**
   - **Gate 0 (Discovery Interview):** Mandatory clarification of platform, scope, stack, auth, and aesthetic via `ask_question`.
   - **Gate 1 (Blueprint Approval):** After PRD, Design Spec, Architecture, Tasks, and Test Plan are authored, **the agent MUST stop execution (`call no tools`)**. The Engineer is physically locked from writing code until the User explicitly says "Approve" / "Lanjut" in a new turn (`gate_1_user_approved: true`).
3. **Dual-Repository Workflow:**
   - Engineer codes exclusively on branch `feat/<ticket-slug>`.
   - Lead Engineer reviews every Story vertical slice incrementally.
   - Code is merged to `main` of the Development Repository upon `FINAL_CODE_APPROVED`.
   - QA audits tests, security, and headless visual diff directly on `main`.
   - Push to Production Repo occurs only after QA stamps `APPROVED` on `main`, tagged with SemVer 2.0.0 (`vMAJOR.MINOR.PATCH`).
4. **Figma MCP-First with Dual Fallbacks:**
   - **Primary:** Official Figma MCP (`https://mcp.figma.com/mcp`).
   - **Fallback 1:** Auto-generated plugin manifest & code (`docs/figma-plugin/manifest.json` + `code.js`).
   - **Fallback 2:** Instant DevTools Console script (`docs/figma-console.js`).
5. **Anti-Slop Visual Quality:** Powered by `Leonxlnx/taste-skill 2.5.1`. Zero neon purple gradients, zero generic Lucide bento cards, real photography tokens, curated typography, and headless browser gate verification.

---

## 3. Quick Installation

### Linux VPS / WSL / macOS
```bash
# 1. Clone repository
git clone https://github.com/<your-username>/agy-autonomous-team.git

# 2. Run the automated installer
cd agy-autonomous-team
chmod +x install.sh
./install.sh
```

### Windows (PowerShell)
```powershell
# 1. Clone repository
git clone https://github.com/<your-username>/agy-autonomous-team.git

# 2. Run the automated installer
cd agy-autonomous-team
.\install.ps1
```

---

## 4. Headless VPS Configuration (Optional)

When deploying to a remote Linux VPS without a desktop browser, set your Figma access token before running `install.sh`:

```bash
# Export your personal access token (no browser OAuth required)
export FIGMA_ACCESS_TOKEN="figd_your_personal_access_token"

# Re-run installer to auto-wire the official Figma MCP server
./install.sh

# Optional: Set webhook alerts for Approval Gates and Blockers
export AGENT_WEBHOOK_URL="https://discord.com/api/webhooks/..."
```

Verify installed servers in CLI:
```bash
agy mcp list
agy plugin list
```

---

## 5. Typical Workflow Example

```text
User: "@orchestrator buatkan sistem otentikasi WhatsApp OTP"

1. Orchestrator -> [Gate 0 Discovery Interview via ask_question]
2. User selects options
3. Lead PM -> docs/scope.md (MoSCoW matrix) & GLOSSARY.md
4. PM -> docs/prd.md (User Stories & Gherkin ACs)
5. Lead PM -> Audits & approves PRD
6. Parallel Phase:
   - UI/UX -> 4 Token Tables in chat + docs/design-spec.md + docs/preview.html + Figma MCP
   - Lead Engineer -> docs/architecture.md + docs/tasks.md + docs/adr/
   - QA -> docs/test-plan.md (Shift-Left Test Matrix)
7. [Gate 1 Hard Stop] -> Agent prints complete Blueprint and stops.
8. User replies: "Lanjut koding"
9. Engineer -> Implements Story-by-Story using strict TDD on branch feat/auth-otp
10. Lead Engineer -> Reviews each Story diff (2-Axis Review: Standards + Smells & Spec)
11. Orchestrator -> Merges to main (Dev Repo)
12. QA -> Runs automated suite & headless browser gate on main
13. Orchestrator -> Tags SemVer v1.1.0 & pushes to Production Repo
```

---

## License
MIT © fakhriramdani
