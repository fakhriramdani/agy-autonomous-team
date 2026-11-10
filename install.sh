#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="autonomous-team-kit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.gemini/config/plugins/${PLUGIN_NAME}"

mkdir -p "$(dirname "${TARGET_DIR}")"
rm -rf "${TARGET_DIR}"
cp -R "${SCRIPT_DIR}" "${TARGET_DIR}"
rm -rf "${TARGET_DIR}/figma-skills-backup" "${TARGET_DIR}/scripts"

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

echo "[OK] Installed ${PLUGIN_NAME} to ${TARGET_DIR}"
