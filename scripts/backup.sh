#!/bin/bash
# Claude Code Configuration Backup Script (Linux/macOS)
# Creates a timestamped backup of the current Claude Code configuration

set -euo pipefail

# Configuration
BACKUP_PATH="${1:-./backups}"

# Auto-detect production path - SAME AS DEPLOY.SH
if [ ! -z "${CLAUDE_CONFIG_PATH:-}" ]; then
    PRODUCTION_PATH="$CLAUDE_CONFIG_PATH"
else
    # Try default Unix paths in order - SAME ORDER AS DEPLOY.SH
    UNIX_PATHS=(
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
    log_warning "Creating empty backup for deployment..."
    mkdir -p "$FULL_BACKUP_PATH"
else
    log_info "Starting backup of Claude Code configuration..."
    log_gray "Source: $PRODUCTION_PATH"
    log_gray "Destination: $FULL_BACKUP_PATH"
    
    # Create timestamped backup directory
    mkdir -p "$FULL_BACKUP_PATH"
    
    # Copy entire configuration directory
    cp -r "$PRODUCTION_PATH"/* "$FULL_BACKUP_PATH"/ 2>/dev/null || true
fi

# Calculate backup statistics
FILES_COUNT=$(find "$FULL_BACKUP_PATH" -type f 2>/dev/null | wc -l)
BACKUP_SIZE=$(du -sh "$FULL_BACKUP_PATH" 2>/dev/null | cut -f1)

# Create integrity manifest with MD5 hashes
log_gray "Creating integrity manifest..."
MANIFEST_FILE="$FULL_BACKUP_PATH/backup-manifest.txt"
HAS_MANIFEST=false

if command -v md5sum >/dev/null 2>&1 || command -v md5 >/dev/null 2>&1; then
    # Create manifest for all files except backup metadata
    cd "$FULL_BACKUP_PATH" || exit 1
    {
        find . -type f ! -name "backup-*.txt" ! -name "backup-*.json" | sort | while read -r file; do
            if command -v md5sum >/dev/null 2>&1; then
                md5sum "$file" 2>/dev/null || true
            elif command -v md5 >/dev/null 2>&1; then
                HASH=$(md5 -q "$file" 2>/dev/null || true)
                [ ! -z "$HASH" ] && echo "$HASH  $file" || true
            fi
        done
    } > backup-manifest.txt 2>/dev/null
    cd - >/dev/null
    
    if [ -s "$MANIFEST_FILE" ]; then
        HAS_MANIFEST=true
        HASH_COUNT=$(wc -l < "$MANIFEST_FILE")
        log_success "✓ Created integrity manifest with $HASH_COUNT file hashes"
    else
        rm -f "$MANIFEST_FILE"
        log_warning "⚠ Could not create integrity manifest"
    fi
else
    log_warning "⚠ MD5 command not available - integrity verification disabled"
fi

# Create backup metadata
cat > "$FULL_BACKUP_PATH/backup-info.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "source": "$PRODUCTION_PATH",
  "backup_path": "$FULL_BACKUP_PATH",
  "files_backed_up": $FILES_COUNT,
  "backup_size": "$BACKUP_SIZE",
  "platform": "$(uname -s)",
  "hostname": "$(hostname)",
  "has_manifest": $HAS_MANIFEST
}
EOF

log_success "✓ Backup completed successfully!"
log_gray "  Files backed up: $FILES_COUNT"
log_gray "  Backup size: $BACKUP_SIZE"
log_gray "  Backup location: $FULL_BACKUP_PATH"

# Clean old backups (keep last 10)
OLD_BACKUPS=$(find "$BACKUP_PATH" -maxdepth 1 -type d -name "claude-config-backup-*" 2>/dev/null | sort -r | tail -n +11)
if [ ! -z "$OLD_BACKUPS" ]; then
    echo "$OLD_BACKUPS" | while read -r old_backup; do
        rm -rf "$old_backup"
        log_warning "Cleaned old backup: $(basename "$old_backup")"
    done
fi

# Return backup path for deployment script
echo "$FULL_BACKUP_PATH"