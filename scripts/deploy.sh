#!/bin/bash
# Claude Code Configuration Deployment Script (Linux/macOS)
# Deploys development configuration to production with automatic backup

set -euo pipefail

# Configuration
DEV_PATH="./.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Auto-detect production path with fallback options
if [ ! -z "${CLAUDE_CONFIG_PATH:-}" ]; then
    PRODUCTION_PATH="$CLAUDE_CONFIG_PATH"
    echo -e "${CYAN}Using custom path from CLAUDE_CONFIG_PATH: $PRODUCTION_PATH${NC}"
else
    # Try default Unix paths in order
    UNIX_PATHS=(
        "$HOME/.config/claude"
        "$HOME/.claude"
    )
    
    # On macOS, add macOS-specific path
    if [[ "$OSTYPE" == "darwin"* ]]; then
        UNIX_PATHS+=("$HOME/Library/Application Support/claude")
    fi
    
    PRODUCTION_PATH=""
    for path in "${UNIX_PATHS[@]}"; do
        if [ -d "$path" ]; then
            PRODUCTION_PATH="$path"
            break
        fi
    done
    
    # If no existing directory found, try parent directories
    if [ -z "$PRODUCTION_PATH" ]; then
        for path in "${UNIX_PATHS[@]}"; do
            parent_dir=$(dirname "$path")
            if [ -d "$parent_dir" ] && [ -w "$parent_dir" ]; then
                PRODUCTION_PATH="$path"
                break
            fi
        done
    fi
    
    # Default to first option if none found
    if [ -z "$PRODUCTION_PATH" ]; then
        PRODUCTION_PATH="${UNIX_PATHS[0]}"
    fi
fi

# Parse command line arguments
FORCE=false
SKIP_BACKUP=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--force] [--skip-backup] [--verbose]"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${CYAN}$1${NC}"; }
log_success() { echo -e "${GREEN}$1${NC}"; }
log_warning() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }
log_gray() { echo -e "${GRAY}$1${NC}"; }

log_info "Claude Code Configuration Deployment"
log_info "===================================="

# Validate development configuration exists
if [ ! -d "$DEV_PATH" ]; then
    log_error "✗ Development configuration not found at: $DEV_PATH"
    exit 1
fi

# Validate settings.json syntax
SETTINGS_PATH="$DEV_PATH/settings.json"
if [ -f "$SETTINGS_PATH" ]; then
    if ! node -e "JSON.parse(require('fs').readFileSync('$SETTINGS_PATH', 'utf8'))" > /dev/null 2>&1; then
        log_error "✗ Invalid settings.json syntax!"
        exit 1
    fi
    log_success "✓ settings.json syntax is valid"
fi

# Create backup unless skipped
BACKUP_PATH=""
if [ "$SKIP_BACKUP" = false ]; then
    echo
    log_warning "Creating backup..."
    if BACKUP_PATH=$("$SCRIPT_DIR/backup.sh" 2>&1); then
        log_success "✓ Backup created successfully"
    else
        log_error "✗ Backup failed!"
        if [ "$FORCE" = false ]; then
            log_warning "Use --force to deploy without backup"
            exit 1
        fi
    fi
fi

# Confirm deployment
if [ "$FORCE" = false ]; then
    echo
    log_warning "Ready to deploy configuration:"
    log_gray "  From: $DEV_PATH"
    log_gray "  To: $PRODUCTION_PATH"
    [ ! -z "$BACKUP_PATH" ] && log_gray "  Backup: $BACKUP_PATH"
    
    echo
    read -p "Proceed with deployment? (y/N): " -n 1 -r REPLY
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Deployment cancelled."
        exit 0
    fi
fi

# Deploy configuration
echo
log_info "Deploying configuration..."

# Create production directory if it doesn't exist
mkdir -p "$PRODUCTION_PATH"

# Deploy CLAUDE-build.md as CLAUDE.md
DEV_CLAUDE="CLAUDE-build.md"
PROD_CLAUDE="$PRODUCTION_PATH/CLAUDE.md"
if [ -f "$DEV_CLAUDE" ]; then
    cp "$DEV_CLAUDE" "$PROD_CLAUDE"
    log_success "✓ Deployed CLAUDE.md"
fi

# Deploy settings.json
DEV_SETTINGS="$DEV_PATH/settings.json"
PROD_SETTINGS="$PRODUCTION_PATH/settings.json"
if [ -f "$DEV_SETTINGS" ]; then
    cp "$DEV_SETTINGS" "$PROD_SETTINGS"
    log_success "✓ Deployed settings.json"
fi

# Deploy agents directory
DEV_AGENTS="$DEV_PATH/agents"
PROD_AGENTS="$PRODUCTION_PATH/agents"
if [ -d "$DEV_AGENTS" ]; then
    # Remove existing agents directory and recreate
    [ -d "$PROD_AGENTS" ] && rm -rf "$PROD_AGENTS"
    cp -r "$DEV_AGENTS" "$PROD_AGENTS"
    AGENT_COUNT=$(find "$PROD_AGENTS" -name "*.md" -type f | wc -l)
    log_success "✓ Deployed $AGENT_COUNT agents"
fi

# Deploy hooks directory
DEV_HOOKS="$DEV_PATH/hooks"
PROD_HOOKS="$PRODUCTION_PATH/hooks"
if [ -d "$DEV_HOOKS" ]; then
    # Remove existing hooks directory and recreate
    [ -d "$PROD_HOOKS" ] && rm -rf "$PROD_HOOKS"
    cp -r "$DEV_HOOKS" "$PROD_HOOKS"
    HOOK_COUNT=$(find "$PROD_HOOKS" -type f | wc -l)
    log_success "✓ Deployed $HOOK_COUNT hooks"
fi

# Deploy commands directory
DEV_COMMANDS="$DEV_PATH/commands"
PROD_COMMANDS="$PRODUCTION_PATH/commands"
if [ -d "$DEV_COMMANDS" ]; then
    # Remove existing commands directory and recreate
    [ -d "$PROD_COMMANDS" ] && rm -rf "$PROD_COMMANDS"
    cp -r "$DEV_COMMANDS" "$PROD_COMMANDS"
    COMMAND_COUNT=$(find "$PROD_COMMANDS" -type f | wc -l)
    log_success "✓ Deployed $COMMAND_COUNT commands"
fi

# Deploy contexts directory
DEV_CONTEXTS="$DEV_PATH/contexts"
PROD_CONTEXTS="$PRODUCTION_PATH/contexts"
if [ -d "$DEV_CONTEXTS" ]; then
    # Remove existing contexts directory and recreate
    [ -d "$PROD_CONTEXTS" ] && rm -rf "$PROD_CONTEXTS"
    cp -r "$DEV_CONTEXTS" "$PROD_CONTEXTS"
    CONTEXT_COUNT=$(find "$PROD_CONTEXTS" -type f | wc -l)
    log_success "✓ Deployed $CONTEXT_COUNT contexts"
fi

# Create deployment log
DEPLOYMENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
cat > "$PRODUCTION_PATH/deployment-log.json" << EOF
{
  "timestamp": "$DEPLOYMENT_TIME",
  "source": "$DEV_PATH",
  "destination": "$PRODUCTION_PATH",
  "backup_path": "$BACKUP_PATH",
  "platform": "$(uname -s)",
  "hostname": "$(hostname)",
  "deployed_files": [
EOF

# Add deployed files to log
FIRST=true
find "$PRODUCTION_PATH" -type f | while read -r file; do
    REL_PATH="${file#$PRODUCTION_PATH/}"
    [ "$FIRST" = true ] && FIRST=false || echo ","
    echo "    \"$REL_PATH\""
done >> "$PRODUCTION_PATH/deployment-log.json"

cat >> "$PRODUCTION_PATH/deployment-log.json" << EOF
  ]
}
EOF

DEPLOYED_COUNT=$(find "$PRODUCTION_PATH" -type f | wc -l)

echo
log_success "✓ Deployment completed successfully!"
log_gray "  Configuration is now active at: $PRODUCTION_PATH"
log_gray "  Files deployed: $DEPLOYED_COUNT"

if [ ! -z "$BACKUP_PATH" ]; then
    echo
    log_info "💡 To rollback if needed:"
    log_gray "  $SCRIPT_DIR/restore.sh --backup-path '$BACKUP_PATH'"
fi