---
name: agy-team
description: Initialize, check status, or remove the AGY Autonomous Team workflow in the current repository. Trigger with /agy-team init, /agy-team status, /agy-team off, or /agy-team remove.
---

# Skill: `agy-team` (Repository Initialization & Removal Controller)

Use this skill whenever the user types `/agy-team init`, `/agy-team off`, `/agy-team remove`, `/agy-team status` (or asks to enable/disable the `agy-autonomous-team` workflow in the current repository).

## Commands

### 1. `/agy-team init [optional project brief]` — Activate Workflow in Current Repo
1. Create directory `.agents/` (if not present) and write `.agents/TEAM_STATE.json`:
   ```json
   {
     "enabled": true,
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
2. Ensure `.agents/` is tracked or ignored per project preference, and create `.agents/LESSONS_LEARNED.md` and `.agents/METRICS.log` if missing.
3. Confirm to the User:
   > "✅ **AGY Autonomous Team (`agy-team`) resmi aktif di repository ini** (`.agents/TEAM_STATE.json` dibuat)."
4. If the User also provided a feature/project request (or wants to start immediately), immediately execute **Gate 0: Discovery Interview** from `role-orchestrator` (displaying the **6 Curated Design Archetypes & Clickable Reference Links Table** and calling `ask_question`).

---

### 2. `/agy-team off` or `/agy-team remove` — Deactivate & Remove Workflow from Current Repo
1. **Default (`/agy-team off` or `/agy-team remove`):**
   - Delete `.agents/TEAM_STATE.json`, `.agents/LESSONS_LEARNED.md`, `.agents/METRICS.log`, and remove the `.agents/` directory if empty.
   - Delete `.taste-skill/` temporary cache if present.
   - **Preserve** `docs/` and `GLOSSARY.md` by default so existing product/architecture documentation is never lost accidentally.
   - Confirm to the User:
     > "🛑 **AGY Autonomous Team telah dihapus/dinonaktifkan dari repository ini** (`.agents/TEAM_STATE.json` dihapus). Repository ini sekarang kembali ke mode asisten AI standar (Dormant Mode). File dokumentasi di `docs/` tetap disimpan."
2. **Full Purge (`/agy-team remove --purge-docs`):**
   - Only if the User explicitly asks to also delete `docs/` and `GLOSSARY.md`, confirm first or remove `.agents/`, `.taste-skill/`, `docs/`, and `GLOSSARY.md`.

---

### 3. `/agy-team status` — Inspect Current Repo Workflow State
1. Check whether `.agents/TEAM_STATE.json` exists in the current workspace.
2. If it does **NOT** exist:
   - Report: `"Status: DORMANT (Standar AI Assistant — belum diinisiasi). Ketik /agy-team init untuk mengaktifkan workflow Autonomous Team di repo ini."`
3. If it **DOES** exist:
   - Read `.agents/TEAM_STATE.json` and print a concise status table: `ticket_id`, `tier`, `stage`, `branch`, `design_archetype`, and the 4 Gate Lock flags (`gate_0_user_approved`, `gate_1_user_approved`, `pr_user_approved`, `gate_2_user_approved`).
