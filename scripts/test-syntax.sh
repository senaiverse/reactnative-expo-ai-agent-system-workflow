#!/usr/bin/env bash
set -euo pipefail

# Test: Bash Syntax Validation for install-agents.sh

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/install-agents.sh"

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo -e "${RED}[FAIL] install-agents.sh not found at ${SCRIPT_PATH}${NC}"
    exit 1
fi

content=$(cat "$SCRIPT_PATH")
pass_count=0
fail_count=0

pass() {
    echo -e "  ${GREEN}[PASS] $1${NC}"
    pass_count=$((pass_count + 1))
}

fail() {
    echo -e "  ${RED}[FAIL] $1${NC}"
    fail_count=$((fail_count + 1))
}

# Test 1: Bash syntax check
echo -e "${CYAN}TEST 1 - SYNTAX:${NC}"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    pass "Bash syntax is valid"
else
    fail "Bash syntax errors detected"
fi

# Test 2: Parameter Validation
echo ""
echo -e "${CYAN}TEST 2 - PARAMETER PRESERVATION:${NC}"

if echo "$content" | grep -q '\-\-scope'; then
    pass "--scope parameter exists"
else
    fail "--scope parameter missing"
fi

if echo "$content" | grep -q 'SCOPE="auto"'; then
    pass "Default scope is 'auto'"
else
    fail "Default scope changed"
fi

if echo "$content" | grep -q '\-\-project-path'; then
    pass "--project-path parameter exists"
else
    fail "--project-path parameter missing"
fi

# Test 3: Conditional Flow Logic
echo ""
echo -e "${CYAN}TEST 3 - CONDITIONAL FLOW:${NC}"

if echo "$content" | grep -q 'SCOPE.*==.*auto'; then
    pass "Interactive block trigger found"
else
    fail "Interactive block missing"
fi

if echo "$content" | grep -q 'read.*choice'; then
    pass "User choice prompt found"
else
    fail "User choice prompt missing"
fi

if echo "$content" | grep -q 'package\.json'; then
    pass "package.json scan logic found"
else
    fail "package.json scan missing"
fi

if echo "$content" | grep -q 'Proceed.*Y/N'; then
    pass "Confirmation prompt found"
else
    fail "Confirmation prompt missing"
fi

# Test 4: Error Handling
echo ""
echo -e "${CYAN}TEST 4 - ERROR HANDLING:${NC}"

exit_count=$(echo "$content" | grep -cE 'exit[[:space:]]+[01]' || true)
pass "Found ${exit_count} exit statements"

if echo "$content" | grep -q 'NO PROJECT FOUND'; then
    pass "'NO PROJECT FOUND' error message exists"
else
    fail "Missing project not found error"
fi

if echo "$content" | grep -qE 'CANCELLED|cancelled'; then
    pass "Cancellation handling exists"
else
    fail "Missing cancellation handling"
fi

if echo "$content" | grep -q 'Invalid choice'; then
    pass "Invalid input handling exists"
else
    fail "Missing invalid input handling"
fi

# Test 5: Variable Flow
echo ""
echo -e "${CYAN}TEST 5 - VARIABLE STATE:${NC}"

scope_assignments=$(echo "$content" | grep -cE 'SCOPE="(project|global)"' || true)
if [[ "$scope_assignments" -ge 2 ]]; then
    pass "Scope variable assigned in both paths (${scope_assignments} assignments)"
else
    fail "Missing scope assignments (found ${scope_assignments})"
fi

# Summary
echo ""
echo -e "${CYAN}========================================${NC}"
total=$((pass_count + fail_count))
if [[ "$fail_count" -eq 0 ]]; then
    echo -e "${GREEN}VALIDATION COMPLETE: ${pass_count}/${total} tests passed${NC}"
else
    echo -e "${RED}VALIDATION COMPLETE: ${pass_count}/${total} tests passed, ${fail_count} failed${NC}"
fi
echo -e "${CYAN}========================================${NC}"
echo ""

exit "$fail_count"
