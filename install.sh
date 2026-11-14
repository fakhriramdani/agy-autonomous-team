#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="autonomous-team-kit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.gemini/config/plugins/${PLUGIN_NAME}"

mkdir -p "$(dirname "${TARGET_DIR}")"
rm -rf "${TARGET_DIR}"
cp -R "${SCRIPT_DIR}" "${TARGET_DIR}"
rm -rf "${TARGET_DIR}/figma-skills-backup" "${TARGET_DIR}/scripts"

# Safe Non-Destructive Global Registration for Gemini CLI (~/.gemini/GEMINI.md) & Claude Code (~/.claude/CLAUDE.md):
# - Never overwrites existing user content outside <!-- BEGIN AGY-AUTONOMOUS-TEAM --> ... <!-- END AGY-AUTONOMOUS-TEAM -->
# - If a previous run overwrote the whole file with raw AGENTS.md (starts with "# Autonomous Team Kit"), clean it first.
update_global_md() {
  local target_file="$1"
  mkdir -p "$(dirname "${target_file}")"
  if [ -f "${target_file}" ] && head -n 1 "${target_file}" | grep -q "^# Autonomous Team Kit"; then
    rm -f "${target_file}"
  fi
  if [ -f "${target_file}" ]; then
    sed -i '/<!-- BEGIN AGY-AUTONOMOUS-TEAM -->/,/<!-- END AGY-AUTONOMOUS-TEAM -->/d' "${target_file}"
  fi
  {
    echo "<!-- BEGIN AGY-AUTONOMOUS-TEAM -->"
    cat "${SCRIPT_DIR}/rules/AGENTS.md"
    echo "<!-- END AGY-AUTONOMOUS-TEAM -->"
  } >> "${target_file}"
}

# Clean any duplicate block in ~/.gemini/GEMINI.md so Antigravity does not double-load AGENTS.md and hit the rules token budget:
if [ -f "${HOME}/.gemini/GEMINI.md" ]; then
  if head -n 1 "${HOME}/.gemini/GEMINI.md" | grep -q "^# Autonomous Team Kit"; then
    rm -f "${HOME}/.gemini/GEMINI.md"
  else
    sed -i '/<!-- BEGIN AGY-AUTONOMOUS-TEAM -->/,/<!-- END AGY-AUTONOMOUS-TEAM -->/d' "${HOME}/.gemini/GEMINI.md"
    if [ ! -s "${HOME}/.gemini/GEMINI.md" ]; then
      rm -f "${HOME}/.gemini/GEMINI.md"
    fi
  fi
fi

# Safe Non-Destructive Global Registration for Claude Code (~/.claude/CLAUDE.md):
update_global_md "${HOME}/.claude/CLAUDE.md"

# Avoid duplicate skill loading in Antigravity: remove duplicate standalone skill copies from ~/.gemini/config/skills
if [ -d "${HOME}/.gemini/config/skills" ]; then
  for skill_dir in "${SCRIPT_DIR}/skills/"*; do
    skill_name="$(basename "${skill_dir}")"
    rm -rf "${HOME}/.gemini/config/skills/${skill_name}"
  done
fi

# Remove redundant standalone caveman/ponytail plugins if present
rm -rf "${HOME}/.gemini/config/plugins/caveman" "${HOME}/.gemini/config/plugins/ponytail"

# Load FIGMA_ACCESS_TOKEN from ~/.gemini/config/.env or ./.env if not already in environment
if [ -z "${FIGMA_ACCESS_TOKEN:-}" ]; then
  for env_file in "${PWD}/.env" "${HOME}/.gemini/config/.env" "${HOME}/.env"; do
    if [ -f "${env_file}" ]; then
      tok="$(grep -E '^(export[[:space:]]+)?(FIGMA_ACCESS_TOKEN|FIGMA_API_KEY)=' "${env_file}" | tail -n 1 | cut -d= -f2- | tr -d '"' | tr -d "'" | tr -d '\r' || true)"
      if [ -n "${tok}" ]; then
        export FIGMA_ACCESS_TOKEN="${tok}"
        break
      fi
    fi
  done
fi

# Sync official Figma plugin from Windows if in WSL using ONLY official https://mcp.figma.com/mcp
FIGMA_SYNCED=0
for WIN_FIGMA in /mnt/c/Users/*/.gemini/config/plugins/figma; do
  if [ -d "${WIN_FIGMA}" ]; then
    rm -rf "${HOME}/.gemini/config/plugins/figma"
    cp -R "${WIN_FIGMA}" "${HOME}/.gemini/config/plugins/figma"
    mkdir -p "${HOME}/.gemini/config/plugins/figma/.antigravity-plugin"
    if [ -n "${FIGMA_ACCESS_TOKEN:-}" ]; then
      cat > "${HOME}/.gemini/config/plugins/figma/mcp_config.json" <<EOF
{
  "mcpServers": {
    "figma": {
      "serverUrl": "https://mcp.figma.com/mcp",
      "headers": {
        "X-Figma-Plugin-Bundle": "figma_prod@2_2_174",
        "Authorization": "Bearer ${FIGMA_ACCESS_TOKEN}",
        "X-Figma-Token": "${FIGMA_ACCESS_TOKEN}"
      }
    }
  }
}
EOF
    fi
    cp -f "${HOME}/.gemini/config/plugins/figma/mcp_config.json" "${HOME}/.gemini/config/plugins/figma/.antigravity-plugin/mcp_config.json"
    FIGMA_SYNCED=1
    echo "[OK] Synced official Figma MCP plugin (https://mcp.figma.com/mcp) to ${HOME}/.gemini/config/plugins/figma"
    break
  fi
done

if [ "${FIGMA_SYNCED}" -eq 0 ] && [ ! -d "${HOME}/.gemini/config/plugins/figma" ] && [ -d "${SCRIPT_DIR}/figma-skills-backup" ]; then
  cp -R "${SCRIPT_DIR}/figma-skills-backup/"* "${TARGET_DIR}/skills/"
  echo "[OK] Installed standalone Figma skills for Headless VPS"
fi

# Register ONLY Official Figma MCP (https://mcp.figma.com/mcp) in agy mcp list
AGY_BIN="$(command -v agy || echo "${HOME}/.local/bin/agy")"
if [ -x "${AGY_BIN}" ]; then
  "${AGY_BIN}" mcp remove figma >/dev/null 2>&1 || true
  if [ -n "${FIGMA_ACCESS_TOKEN:-}" ]; then
    "${AGY_BIN}" mcp add \
      --header "X-Figma-Plugin-Bundle: figma_prod@2_2_174" \
      --header "Authorization: Bearer ${FIGMA_ACCESS_TOKEN}" \
      --header "X-Figma-Token: ${FIGMA_ACCESS_TOKEN}" \
      figma https://mcp.figma.com/mcp || true
    echo "[OK] Registered official Figma MCP (https://mcp.figma.com/mcp) with FIGMA_ACCESS_TOKEN"
  else
    "${AGY_BIN}" mcp add \
      --header "X-Figma-Plugin-Bundle: figma_prod@2_2_174" \
      figma https://mcp.figma.com/mcp || true
    echo "[OK] Registered official Figma MCP (https://mcp.figma.com/mcp)"
  fi
fi

# Install dedicated `agy-team` CLI helper (init / init-oss / remove / off / status) to ~/.local/bin/agy-team
mkdir -p "${HOME}/.local/bin"
cat > "${HOME}/.local/bin/agy-team" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-status}"
ARG2="${2:-}"

clean_git_exclude() {
  if [ -f .git/info/exclude ]; then
    sed -i '/# BEGIN AGY-TEAM-OSS-EXCLUDE/,/# END AGY-TEAM-OSS-EXCLUDE/d' .git/info/exclude
  fi
}

add_git_exclude() {
  if [ ! -d .git ]; then
    git init -q
  fi
  mkdir -p .git/info
  clean_git_exclude
  cat >> .git/info/exclude <<'EXCL'
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
EXCL
}

case "${CMD}" in
  init)
    if [ "${ARG2}" = "--oss" ]; then
      MODE="oss-stealth"
      add_git_exclude
      if [ ! -f LICENSE ] && [ -f "${HOME}/.gemini/config/plugins/autonomous-team-kit/LICENSE" ]; then
        cp "${HOME}/.gemini/config/plugins/autonomous-team-kit/LICENSE" ./LICENSE
      fi
    else
      MODE="standard"
      clean_git_exclude
    fi
    mkdir -p .agents
    cat > .agents/TEAM_STATE.json <<JSON
{
  "enabled": true,
  "repo_mode": "${MODE}",
  "ticket_id": "FEAT-001",
  "tier": 3,
  "stage": "GATE_0_DISCOVERY",
  "gate_0_user_approved": false,
  "gate_1_user_approved": false,
  "pr_user_approved": false,
  "gate_2_user_approved": false,
  "initialized_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON
    touch .agents/LESSONS_LEARNED.md .agents/METRICS.log
    echo "[OK] AGY Autonomous Team initialized in $(pwd) [repo_mode=${MODE}]."
    ;;
  init-oss)
    add_git_exclude
    if [ ! -f LICENSE ] && [ -f "${HOME}/.gemini/config/plugins/autonomous-team-kit/LICENSE" ]; then
      cp "${HOME}/.gemini/config/plugins/autonomous-team-kit/LICENSE" ./LICENSE
    fi
    mkdir -p .agents
    cat > .agents/TEAM_STATE.json <<JSON
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
  "initialized_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON
    touch .agents/LESSONS_LEARNED.md .agents/METRICS.log
    echo "[OK] AGY Autonomous Team initialized in $(pwd) [repo_mode=oss-stealth: docs excluded via .git/info/exclude, code-only commits]."
    ;;
  remove|off|disable)
    rm -rf .agents .taste-skill
    clean_git_exclude
    if [ "${ARG2}" = "--purge-docs" ]; then
      rm -rf docs GLOSSARY.md
      echo "[OK] AGY Autonomous Team + docs/ completely purged from $(pwd)."
    else
      echo "[OK] AGY Autonomous Team removed from $(pwd) (.agents/ & .git/info/exclude cleaned; docs/ preserved)."
    fi
    ;;
  status)
    if [ -f .agents/TEAM_STATE.json ]; then
      echo "[ACTIVE] AGY Autonomous Team is ENABLED in $(pwd):"
      cat .agents/TEAM_STATE.json
    else
      echo "[DORMANT] AGY Autonomous Team is NOT initialized in $(pwd). Run 'agy-team init' (Standard) or 'agy-team init-oss' (Open-Source Stealth)."
    fi
    ;;
  *)
    echo "Usage: agy-team {init|init-oss|remove|off|status} [--oss|--purge-docs]"
    exit 1
    ;;
esac
EOF
chmod +x "${HOME}/.local/bin/agy-team"

echo "[OK] Installed ${PLUGIN_NAME} to ${TARGET_DIR} and CLI 'agy-team' to ${HOME}/.local/bin/agy-team"
