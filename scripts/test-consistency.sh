#!/usr/bin/env bash
set -euo pipefail

# Test 6: Documentation Consistency Check

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}TEST 6 - DOCUMENTATION CONSISTENCY${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

files=(
    "README.md"
    "START-HERE.md"
    "COMPLETE-GUIDE.md"
    "TROUBLESHOOTING-AND-FAQ.md"
    "ready-to-use/templates/CLAUDE.md"
    "claude-code-system.html"
)

# Check 1: All files mention interactive mode
echo -e "${YELLOW}CHECK 1: Interactive Mode Mentioned${NC}"
for file in "${files[@]}"; do
    path="${ROOT_DIR}/${file}"
    if [[ -f "$path" ]]; then
        if grep -qiE "interactive" "$path"; then
            echo -e "  ${GREEN}[OK] ${file}${NC}"
        else
            echo -e "  ${YELLOW}[WARN] ${file} - No mention of interactive mode${NC}"
        fi
    else
        echo -e "  ${RED}[FAIL] ${file} - File not found${NC}"
    fi
done

# Check 2: Command syntax consistency
echo ""
echo -e "${YELLOW}CHECK 2: Command Syntax Consistency${NC}"
echo -e "  Found command variations:"
for file in "${files[@]}"; do
    path="${ROOT_DIR}/${file}"
    if [[ -f "$path" ]]; then
        # Search for both .ps1 and .sh variants
        grep -oE 'install-agents\.(ps1|sh)[^\n]*' "$path" 2>/dev/null | head -3 | while read -r match; do
            echo -e "    ${GRAY}${file}: ${match}${NC}"
        done
    fi
done

# Check 3: Scope terminology consistency
echo ""
echo -e "${YELLOW}CHECK 3: Scope Terminology${NC}"
terms=("project-scoped" "Project-scoped" "Project-Scoped" "global" "Global")
for term in "${terms[@]}"; do
    count=0
    for file in "${files[@]}"; do
        path="${ROOT_DIR}/${file}"
        if [[ -f "$path" ]]; then
            file_count=$(grep -c "$term" "$path" 2>/dev/null || true)
            count=$((count + file_count))
        fi
    done
    if [[ "$count" -gt 0 ]]; then
        echo -e "  ${GRAY}'${term}': ${count} occurrences${NC}"
    fi
done

# Check 4: Version consistency
echo ""
echo -e "${YELLOW}CHECK 4: Version Numbers${NC}"
# Check both .ps1 and .sh installer
for script_name in "install-agents.ps1" "install-agents.sh"; do
    script_path="${SCRIPT_DIR}/${script_name}"
    if [[ -f "$script_path" ]]; then
        version=$(grep -oE 'Version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+' "$script_path" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        if [[ -n "$version" ]]; then
            echo -e "  ${GREEN}${script_name} version: ${version}${NC}"
        else
            echo -e "  ${RED}${script_name} version not found${NC}"
        fi
    fi
done

# Check 5: Step count in HTML files
echo ""
echo -e "${YELLOW}CHECK 5: HTML Step Count${NC}"
html_path="${ROOT_DIR}/claude-code-system.html"
if [[ -f "$html_path" ]]; then
    max_step=$(grep -oE 'Step[[:space:]]+[0-9]+:' "$html_path" | grep -oE '[0-9]+' | sort -n | tail -1)
    echo -e "  ${GRAY}claude-code-system.html - Maximum step: ${max_step:-N/A}${NC}"
else
    echo -e "  ${RED}claude-code-system.html - File not found${NC}"
fi

# Check 6: Error message consistency
echo ""
echo -e "${YELLOW}CHECK 6: Error Messages in Scripts${NC}"
for script_name in "install-agents.ps1" "install-agents.sh"; do
    script_path="${SCRIPT_DIR}/${script_name}"
    if [[ -f "$script_path" ]]; then
        error_count=$(grep -c '\[ERROR\]' "$script_path" 2>/dev/null || true)
        echo -e "  ${GRAY}${script_name}: ${error_count} [ERROR] message(s)${NC}"
        grep -o '\[ERROR\][^"]*' "$script_path" 2>/dev/null | head -5 | while read -r msg; do
            echo -e "    ${GRAY}${msg}${NC}"
        done
    fi
done

# Check 7: Success message consistency
echo ""
echo -e "${YELLOW}CHECK 7: Success Messages in Scripts${NC}"
for script_name in "install-agents.ps1" "install-agents.sh"; do
    script_path="${SCRIPT_DIR}/${script_name}"
    if [[ -f "$script_path" ]]; then
        ok_count=$(grep -c '\[OK\]' "$script_path" 2>/dev/null || true)
        echo -e "  ${GRAY}${script_name}: ${ok_count} [OK] message(s)${NC}"
        grep -o '\[OK\][^"]*' "$script_path" 2>/dev/null | head -5 | while read -r msg; do
            echo -e "    ${GRAY}${msg}${NC}"
        done
    fi
done

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}CONSISTENCY CHECK COMPLETE${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
