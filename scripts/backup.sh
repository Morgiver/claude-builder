#!/bin/bash
# Claude Code Configuration Backup Script (Linux/macOS)
# Creates a complete timestamped backup of the production configuration

set -euo pipefail

# Configuration
BACKUP_PATH="${1:-./backups}"

# Auto-detect production path with fallback options
if [ ! -z "${CLAUDE_CONFIG_PATH:-}" ]; then
    PRODUCTION_PATH="$CLAUDE_CONFIG_PATH"
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
    
    # Default to first option if none found
    if [ -z "$PRODUCTION_PATH" ]; then
        PRODUCTION_PATH="${UNIX_PATHS[0]}"
    fi
fi
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="claude-config-backup-$TIMESTAMP"
FULL_BACKUP_PATH="$BACKUP_PATH/$BACKUP_NAME"

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

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_PATH" ]; then
    mkdir -p "$BACKUP_PATH"
    log_success "Created backup directory: $BACKUP_PATH"
fi

# Check if production directory exists
if [ ! -d "$PRODUCTION_PATH" ]; then
    log_warning "Warning: Production directory not found at $PRODUCTION_PATH"
    log_warning "This might be the first deployment."
    exit 0
fi

log_info "Starting backup of Claude Code configuration..."
log_gray "Source: $PRODUCTION_PATH"
log_gray "Destination: $FULL_BACKUP_PATH"

# Create timestamped backup directory
mkdir -p "$FULL_BACKUP_PATH"

# Copy entire .config/claude directory
cp -r "$PRODUCTION_PATH"/* "$FULL_BACKUP_PATH"/ 2>/dev/null || true

# Calculate backup statistics
FILES_COUNT=$(find "$FULL_BACKUP_PATH" -type f | wc -l)
BACKUP_SIZE=$(du -sh "$FULL_BACKUP_PATH" | cut -f1)

# Create backup metadata
cat > "$FULL_BACKUP_PATH/backup-info.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "source": "$PRODUCTION_PATH",
  "backup_path": "$FULL_BACKUP_PATH",
  "files_backed_up": $FILES_COUNT,
  "backup_size": "$BACKUP_SIZE",
  "platform": "$(uname -s)",
  "hostname": "$(hostname)"
}
EOF

log_success "✓ Backup completed successfully!"
log_gray "  Files backed up: $FILES_COUNT"
log_gray "  Backup size: $BACKUP_SIZE"
log_gray "  Backup location: $FULL_BACKUP_PATH"

# Clean old backups (keep last 10)
OLD_BACKUPS=$(find "$BACKUP_PATH" -maxdepth 1 -type d -name "claude-config-backup-*" | sort -r | tail -n +11)
if [ ! -z "$OLD_BACKUPS" ]; then
    echo "$OLD_BACKUPS" | while read -r old_backup; do
        rm -rf "$old_backup"
        log_warning "Cleaned old backup: $(basename "$old_backup")"
    done
fi

# Return backup path for deployment script
echo "$FULL_BACKUP_PATH"