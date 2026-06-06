#!/usr/bin/env bash
set -euo pipefail

# ============================================
# SenaiVerse - Claude Code Agent System
# Version: 1.2.0
# Created: 2025-10-03
# Updated: 2025-10-04
# ============================================
#
# Claude Code Agent System - macOS/Linux Installation Script
# Supports BOTH global and project-scoped installation
#
# Usage:
#   ./install-agents.sh                        # Interactive mode (prompts user to choose)
#   ./install-agents.sh --scope global         # Force global installation
#   ./install-agents.sh --scope project        # Force project installation
#   ./install-agents.sh --project-path /path   # Specify project path

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
SCOPE="auto"
PROJECT_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --scope)
            SCOPE="$2"
            if [[ "$SCOPE" != "auto" && "$SCOPE" != "global" && "$SCOPE" != "project" ]]; then
                echo -e "${RED}[ERROR] Invalid scope: '$SCOPE'. Must be auto, global, or project.${NC}"
                exit 1
            fi
            shift 2
            ;;
        --project-path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --scope auto|global|project   Installation scope (default: auto = interactive)"
            echo "  --project-path PATH           Path to project root"
            echo "  --help, -h                    Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}[ERROR] Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}Claude Code Agent System Installer${NC}"
echo -e "${CYAN}Expo/React Native Development${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Check if Claude Code is installed
echo -e "${YELLOW}Checking Claude Code installation...${NC}"
if claude_version=$(claude --version 2>&1); then
    echo -e "${GREEN}[OK] Claude Code found: ${claude_version}${NC}"
    echo ""
else
    echo -e "${RED}[X] Claude Code not found!${NC}"
    echo -e "${RED}Please install Claude Code first: npm install -g @anthropic-ai/claude-code${NC}"
    exit 1
fi

# Source directory
SOURCE_DIR="${SCRIPT_DIR}/../ready-to-use"

if [[ "$SCOPE" == "auto" ]]; then
    # Interactive mode: Ask user to choose scope
    echo ""
    echo -e "${CYAN}+----------------------------------------------------------+${NC}"
    echo -e "${CYAN}|          Choose Installation Scope                       |${NC}"
    echo -e "${CYAN}+----------------------------------------------------------+${NC}"
    echo ""

    echo -e "  ${GREEN}1) Project-Scoped (Recommended for Teams)${NC}"
    echo -e "  ${GRAY}     Installs to: .claude/ in your project folder${NC}"
    echo -e "  ${GRAY}     Team sync via git (version controlled)${NC}"
    echo -e "  ${GRAY}     Project-specific customization${NC}"
    echo -e "  ${GRAY}     Higher priority than global agents${NC}"
    echo ""

    echo -e "  ${YELLOW}2) Global (Personal Use)${NC}"
    echo -e "  ${GRAY}     Installs to: ~/.claude/ in your home folder${NC}"
    echo -e "  ${GRAY}     Available in all projects${NC}"
    echo -e "  ${GRAY}     Install once, use everywhere${NC}"
    echo ""

    read -rp "Enter your choice (1 or 2): " choice

    if [[ "$choice" == "1" ]]; then
        # Project-scoped chosen - scan for package.json
        current_dir="$(pwd)"
        package_json_path="${current_dir}/package.json"

        echo ""
        echo -e "${YELLOW}Scanning current directory for package.json...${NC}"

        if [[ -f "$package_json_path" ]]; then
            # Read project name from package.json
            if command -v jq &>/dev/null; then
                project_name=$(jq -r '.name // "Unnamed Project"' "$package_json_path" 2>/dev/null || echo "Unnamed Project")
            else
                project_name=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$package_json_path" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "Unnamed Project")
            fi
            [[ -z "$project_name" ]] && project_name="Unnamed Project"

            echo ""
            echo -e "${GREEN}+----------------------------------------------------------+${NC}"
            echo -e "${GREEN}|          PROJECT DETECTED                                |${NC}"
            echo -e "${GREEN}+----------------------------------------------------------+${NC}"
            echo ""

            echo -e "  ${CYAN}Project Name: ${project_name}${NC}"
            echo -e "  ${GRAY}Location: ${current_dir}${NC}"
            echo -e "  ${GRAY}package.json: Found${NC}"
            echo ""

            # Preview what will be installed
            echo -e "  ${YELLOW}Installation Preview:${NC}"
            agent_count=$(find "${SOURCE_DIR}/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
            command_count=$(find "${SOURCE_DIR}/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

            echo -e "  ${GRAY}  * ${agent_count} AI agents${NC}"
            echo -e "  ${GRAY}  * ${command_count} slash commands${NC}"
            echo -e "  ${GRAY}  * 1 settings.json configuration${NC}"
            echo -e "  ${GRAY}  * 1 CLAUDE.md template${NC}"
            echo ""

            read -rp "Proceed with PROJECT installation? (Y/N): " confirm

            if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
                SCOPE="project"
                echo ""
                echo -e "${GREEN}[OK] Starting project-scoped installation...${NC}"
                echo ""
            else
                echo ""
                echo -e "${YELLOW}[CANCELLED] Installation aborted by user.${NC}"
                echo ""
                exit 0
            fi
        else
            echo ""
            echo -e "${RED}+----------------------------------------------------------+${NC}"
            echo -e "${RED}|          ERROR: NO PROJECT FOUND                         |${NC}"
            echo -e "${RED}+----------------------------------------------------------+${NC}"
            echo ""

            echo -e "  ${GRAY}Current directory: ${current_dir}${NC}"
            echo -e "  ${GRAY}package.json: Not found${NC}"
            echo ""

            echo -e "${YELLOW}Tip: Navigate to your Expo/React Native project root first:${NC}"
            echo -e "${YELLOW}   cd /path/to/your/expo-project${NC}"
            echo -e "${YELLOW}   Then run this installer again.${NC}"
            echo ""

            echo -e "${YELLOW}Or use --project-path parameter:${NC}"
            echo -e "${YELLOW}   ./install-agents.sh --project-path /path/to/project${NC}"
            echo ""

            exit 1
        fi

    elif [[ "$choice" == "2" ]]; then
        # Global chosen
        SCOPE="global"
        echo ""
        echo -e "${GREEN}[OK] Starting global installation...${NC}"
        echo ""

    else
        # Invalid choice
        echo ""
        echo -e "${RED}[ERROR] Invalid choice: '${choice}'${NC}"
        echo -e "${YELLOW}Please enter 1 or 2.${NC}"
        echo ""
        exit 1
    fi
fi

# Define paths based on scope
if [[ "$SCOPE" == "project" ]]; then
    if [[ -n "$PROJECT_PATH" ]]; then
        if [[ ! -d "$PROJECT_PATH" ]]; then
            echo -e "${RED}[X] Project path not found: ${PROJECT_PATH}${NC}"
            exit 1
        fi
        project_root="$PROJECT_PATH"
    else
        project_root="$(pwd)"
    fi

    # Validate project structure
    if [[ ! -f "${project_root}/package.json" ]]; then
        echo -e "${RED}[X] Not a valid project directory (package.json not found)${NC}"
        echo -e "${YELLOW}Tip: Run this from your Expo/React Native project root, or use --project-path${NC}"
        exit 1
    fi

    claude_dir="${project_root}/.claude"
    install_location="PROJECT: ${project_root}"
    echo -e "${GREEN}Installing to PROJECT directory${NC}"
    echo -e "  ${GRAY}Location: ${claude_dir}${NC}"
    echo ""
else
    user_home="$HOME"
    claude_dir="${user_home}/.claude"
    install_location="GLOBAL: ${user_home}"
    echo -e "${GREEN}Installing to GLOBAL directory${NC}"
    echo -e "  ${GRAY}Location: ${claude_dir}${NC}"
    echo ""
fi

agents_dir="${claude_dir}/agents"
commands_dir="${claude_dir}/commands"
hooks_dir="${claude_dir}/hooks"

# Create directories
echo -e "${YELLOW}Creating directory structure...${NC}"
for dir in "$claude_dir" "$agents_dir" "$commands_dir" "$hooks_dir"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo -e "  ${GRAY}Created: ${dir}${NC}"
    else
        echo -e "  ${GRAY}Exists: ${dir}${NC}"
    fi
done
echo -e "${GREEN}[OK] Directories ready${NC}"
echo ""

# Copy agents
echo -e "${YELLOW}Installing agents...${NC}"
agent_source_dir="${SOURCE_DIR}/agents"
if [[ -d "$agent_source_dir" ]]; then
    agent_count=0
    while IFS= read -r file; do
        relative_path="${file#${agent_source_dir}/}"
        dest_path="${agents_dir}/${relative_path}"
        dest_dir="$(dirname "$dest_path")"

        if [[ ! -d "$dest_dir" ]]; then
            mkdir -p "$dest_dir"
        fi

        cp "$file" "$dest_path"
        echo -e "  ${GRAY}+ $(basename "$file")${NC}"
        agent_count=$((agent_count + 1))
    done < <(find "$agent_source_dir" -name "*.md" -type f)
    echo -e "${GREEN}[OK] Installed ${agent_count} agents${NC}"
    echo ""
else
    echo -e "${YELLOW}[WARN] Agent source directory not found${NC}"
    echo ""
fi

# Copy commands
echo -e "${YELLOW}Installing slash commands...${NC}"
command_source_dir="${SOURCE_DIR}/commands"
if [[ -d "$command_source_dir" ]]; then
    command_count=0
    while IFS= read -r file; do
        cp "$file" "$commands_dir/"
        basename_no_ext="${file##*/}"
        basename_no_ext="${basename_no_ext%.md}"
        echo -e "  ${GRAY}+ /${basename_no_ext}${NC}"
        command_count=$((command_count + 1))
    done < <(find "$command_source_dir" -maxdepth 1 -name "*.md" -type f)
    echo -e "${GREEN}[OK] Installed ${command_count} commands${NC}"
    echo ""
else
    echo -e "${YELLOW}[WARN] Command source directory not found${NC}"
    echo ""
fi

# Copy configuration
echo -e "${YELLOW}Installing configuration...${NC}"
config_source="${SOURCE_DIR}/templates/settings.json"
config_dest="${claude_dir}/settings.json"
if [[ -f "$config_source" ]]; then
    if [[ ! -f "$config_dest" ]]; then
        cp "$config_source" "$config_dest"
        echo -e "${GREEN}[OK] Installed settings.json${NC}"
    else
        echo -e "${YELLOW}[WARN] settings.json already exists (not overwriting)${NC}"
    fi
else
    echo -e "${YELLOW}[WARN] Config template not found${NC}"
fi

# Copy CLAUDE.md template for project installations
if [[ "$SCOPE" == "project" ]]; then
    claude_md_source="${SOURCE_DIR}/templates/CLAUDE.md"
    claude_md_dest="${project_root}/CLAUDE.md"
    if [[ -f "$claude_md_source" ]]; then
        if [[ ! -f "$claude_md_dest" ]]; then
            cp "$claude_md_source" "$claude_md_dest"
            echo -e "${GREEN}[OK] Installed CLAUDE.md template (customize for your project)${NC}"
        else
            echo -e "${CYAN}[INFO] CLAUDE.md already exists (not overwriting)${NC}"
        fi
    fi
fi
echo ""

# Summary
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

if [[ "$SCOPE" == "project" ]]; then
    scope_desc="recommended for teams"
else
    scope_desc="use for personal agents"
fi
echo -e "${WHITE}Installation Scope: ${SCOPE} (${scope_desc})${NC}"
echo -e "${WHITE}Installed to:${NC}"
echo -e "  ${GRAY}Agents:   ${agents_dir}${NC}"
echo -e "  ${GRAY}Commands: ${commands_dir}${NC}"
echo -e "  ${GRAY}Config:   ${config_dest}${NC}"
echo ""

if [[ "$SCOPE" == "project" ]]; then
    echo -e "${GREEN}PROJECT INSTALLATION${NC}"
    echo -e "${WHITE}Benefits:${NC}"
    echo -e "  ${GRAY}- Agents are version controlled (team can sync via git)${NC}"
    echo -e "  ${GRAY}- Project-specific customization${NC}"
    echo -e "  ${GRAY}- Higher priority than global agents${NC}"
    echo ""

    echo -e "${WHITE}Next Steps:${NC}"
    echo -e "${GRAY}1. Customize CLAUDE.md for your project:${NC}"
    echo -e "${GRAY}   code ${project_root}/CLAUDE.md${NC}"
    echo ""

    echo -e "${GRAY}2. Commit agents to version control:${NC}"
    echo -e "${GRAY}   git add .claude/${NC}"
    echo -e "${GRAY}   git commit -m 'Add Claude Code agents'${NC}"
    echo ""

    echo -e "${GRAY}3. Start Claude Code:${NC}"
    echo -e "${GRAY}   cd ${project_root}${NC}"
    echo -e "${GRAY}   claude${NC}"
    echo ""
else
    echo -e "${GREEN}GLOBAL INSTALLATION${NC}"
    echo -e "${WHITE}Benefits:${NC}"
    echo -e "  ${GRAY}- Available in all projects${NC}"
    echo -e "  ${GRAY}- Install once, use everywhere${NC}"
    echo ""

    echo -e "${WHITE}Next Steps:${NC}"
    echo -e "${GRAY}1. Copy CLAUDE.md template to your Expo project:${NC}"
    echo -e "${GRAY}   cp ${SOURCE_DIR}/templates/CLAUDE.md [your-project]/CLAUDE.md${NC}"
    echo ""

    echo -e "${GRAY}2. Navigate to your project and start Claude Code:${NC}"
    echo -e "${GRAY}   cd [your-project]${NC}"
    echo -e "${GRAY}   claude${NC}"
    echo ""

    echo -e "${YELLOW}Tip: For team projects, consider project-scoped installation:${NC}"
    echo -e "${YELLOW}  cd [your-project]${NC}"
    echo -e "${YELLOW}  ./install-agents.sh --scope project${NC}"
    echo ""
fi

echo -e "${GRAY}3. Try invoking an agent:${NC}"
echo -e "${GRAY}   > Check accessibility of my components${NC}"
echo -e "${GRAY}   > /review src/components/Button.tsx${NC}"
echo ""

echo -e "${GRAY}4. Read the documentation:${NC}"
echo -e "${GRAY}   - START-HERE.md (quick start)${NC}"
echo -e "${GRAY}   - COMPLETE-GUIDE.md (full reference)${NC}"
echo ""

echo -e "${WHITE}Available Agents (invoke with @agent-name):${NC}"
echo -e "  ${GRAY}- @grand-architect${NC}"
echo -e "  ${GRAY}- @design-token-guardian${NC}"
echo -e "  ${GRAY}- @a11y-enforcer${NC}"
echo -e "  ${GRAY}- @test-generator${NC}"
echo -e "  ${GRAY}- @performance-enforcer${NC}"
echo -e "  ${GRAY}- @performance-prophet${NC}"
echo -e "  ${GRAY}- @security-specialist${NC}"
echo -e "  ${GRAY}- And more!${NC}"
echo ""

echo -e "${WHITE}Available Commands (invoke with /command):${NC}"
echo -e "  ${GRAY}- /feature [description]${NC}"
echo -e "  ${GRAY}- /review [file]${NC}"
echo -e "  ${GRAY}- /test [file]${NC}"
echo ""

echo -e "${YELLOW}For help: See START-HERE.md or COMPLETE-GUIDE.md${NC}"
echo ""

echo -e "${CYAN}Happy coding!${NC}"
