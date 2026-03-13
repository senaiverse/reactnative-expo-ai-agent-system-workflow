#!/usr/bin/env bash
set -euo pipefail

# ============================================
# SenaiVerse - Claude Code Agent System
# Version: 1.0.0
# Created: 2025-10-03
# ============================================
#
# Quick verification script - Run this before installation

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/../ready-to-use"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} INSTALLATION READINESS CHECK${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${YELLOW}Checking source files...${NC}"

# Count files
agent_count=$(find "${SOURCE_DIR}/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
command_count=$(find "${SOURCE_DIR}/commands" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
settings_exists="false"
claude_exists="false"

[[ -f "${SOURCE_DIR}/templates/settings.json" ]] && settings_exists="true"
[[ -f "${SOURCE_DIR}/templates/CLAUDE.md" ]] && claude_exists="true"

# Display results
if [[ "$agent_count" -ge 7 ]]; then
    echo -e "  ${GREEN}Agent files found: ${agent_count}${NC}"
else
    echo -e "  ${RED}Agent files found: ${agent_count}${NC}"
fi

if [[ "$command_count" -ge 3 ]]; then
    echo -e "  ${GREEN}Command files found: ${command_count}${NC}"
else
    echo -e "  ${RED}Command files found: ${command_count}${NC}"
fi

if [[ "$settings_exists" == "true" ]]; then
    echo -e "  ${GREEN}settings.json: Found${NC}"
else
    echo -e "  ${RED}settings.json: MISSING${NC}"
fi

if [[ "$claude_exists" == "true" ]]; then
    echo -e "  ${GREEN}CLAUDE.md: Found${NC}"
else
    echo -e "  ${RED}CLAUDE.md: MISSING${NC}"
fi

echo ""

if [[ "$agent_count" -ge 7 && "$command_count" -ge 3 && "$settings_exists" == "true" && "$claude_exists" == "true" ]]; then
    echo -e "${GREEN}[OK] Ready to install!${NC}"
    echo ""
    echo -e "${CYAN}Run: ./install-agents.sh${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}[ERROR] Missing files - installation will fail!${NC}"
    echo ""
    exit 1
fi
