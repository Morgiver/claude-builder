#!/bin/bash
# Claude Code Configuration Restoration Script (Linux/macOS)
# Restores a previous backup to production in case of deployment issues

set -euo pipefail

# Configuration
DEFAULT_BACKUP_DIR="./backups"

# Auto-detect production path with fallback options
if [ ! -z "${CLAUDE_CONFIG_PATH:-}" ]; then
    PRODUCTION_PATH="$CLAUDE_CONFIG_PATH"
else
    # Try default Unix paths in order
    UNIX_PATHS=(
        "$HOME/.claude"
    )
    
    # On macOS, add macOS-specific path
    if [[ "$OSTYPE" == "darwin"* ]]; then
        UNIX_PATHS+=("$HOME/Library/Application Support/claude")
    fi
    
    PRODUCTION_PATH=""
    for path in "${UNIX_PATHS[@]}"; do
        parent_dir=$(dirname "$path")
        if [ -d "$parent_dir" ] && [ -w "$parent_dir" ]; then
            PRODUCTION_PATH="$path"
            break
        fi
    done
    
    # Default to first option if none found
    if [ -z "$PRODUCTION_PATH" ]; then
        PRODUCTION_PATH="${UNIX_PATHS[0]}"
    fi
fi

# Parse command line arguments
BACKUP_PATH=""
LIST_BACKUPS=false
FORCE=true  # Default to force mode to avoid interactive prompts
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --backup-path|-b)
            BACKUP_PATH="$2"
            shift 2
            ;;
        --list-backups|-l)
            LIST_BACKUPS=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--backup-path PATH] [--list-backups] [--force] [--verbose]"
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
WHITE='\033[1;37m'
DARKGRAY='\033[1;30m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${CYAN}$1${NC}"; }
log_success() { echo -e "${GREEN}$1${NC}"; }
log_warning() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }
log_gray() { echo -e "${GRAY}$1${NC}"; }
log_white() { echo -e "${WHITE}$1${NC}"; }
log_darkgray() { echo -e "${DARKGRAY}$1${NC}"; }

# Function to list available backups
show_available_backups() {
    if [ ! -d "$DEFAULT_BACKUP_DIR" ]; then
        log_warning "No backup directory found at: $DEFAULT_BACKUP_DIR"
        return 1
    fi
    
    local backups=($(find "$DEFAULT_BACKUP_DIR" -maxdepth 1 -type d -name "claude-config-backup-*" | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_warning "No backups found in: $DEFAULT_BACKUP_DIR"
        return 1
    fi
    
    log_info "Available backups:"
    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        local backup_name=$(basename "$backup")
        local info_path="$backup/backup-info.json"
        
        local size="Unknown"
        local file_count="Unknown"
        local creation_time=$(stat -c %y "$backup" 2>/dev/null || stat -f %Sm "$backup" 2>/dev/null || echo "Unknown")
        
        if [ -f "$info_path" ]; then
            if command -v jq >/dev/null 2>&1; then
                size=$(jq -r '.backup_size // "Unknown"' "$info_path" 2>/dev/null || echo "Unknown")
                file_count=$(jq -r '.files_backed_up // "Unknown"' "$info_path" 2>/dev/null || echo "Unknown")
            elif command -v python3 >/dev/null 2>&1; then
                size=$(python3 -c "import json; data=json.load(open('$info_path')); print(data.get('backup_size', 'Unknown'))" 2>/dev/null || echo "Unknown")
                file_count=$(python3 -c "import json; data=json.load(open('$info_path')); print(data.get('files_backed_up', 'Unknown'))" 2>/dev/null || echo "Unknown")
            fi
        fi
        
        log_white "  [$((i+1))] $backup_name"
        log_gray "      Created: $creation_time"
        log_gray "      Size: $size, Files: $file_count"
        log_darkgray "      Path: $backup"
    done
    
    echo "${backups[@]}"
}

log_info "Claude Code Configuration Restoration"
log_info "====================================="

# If ListBackups flag is set, just show backups and exit
if [ "$LIST_BACKUPS" = true ]; then
    show_available_backups >/dev/null
    exit 0
fi

# If no backup path specified, let user choose
if [ -z "$BACKUP_PATH" ]; then
    echo
    available_backups=($(show_available_backups))
    
    if [ ${#available_backups[@]} -eq 0 ]; then
        exit 1
    fi
    
    echo
    log_warning "Select backup to restore:"
    read -p "Enter backup number (1-${#available_backups[@]}) or 'q' to quit: " selection
    
    if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
        log_warning "Restoration cancelled."
        exit 0
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#available_backups[@]} ]; then
        log_error "Invalid selection. Please run the script again."
        exit 1
    fi
    
    BACKUP_PATH="${available_backups[$((selection-1))]}"
fi

# Validate backup path
if [ ! -d "$BACKUP_PATH" ]; then
    log_error "✗ Backup not found at: $BACKUP_PATH"
    exit 1
fi

# Load backup info if available
BACKUP_INFO=""
INFO_PATH="$BACKUP_PATH/backup-info.json"
if [ -f "$INFO_PATH" ]; then
    if command -v jq >/dev/null 2>&1; then
        BACKUP_TIMESTAMP=$(jq -r '.timestamp // "Unknown"' "$INFO_PATH" 2>/dev/null || echo "Unknown")
        BACKUP_FILES=$(jq -r '.files_backed_up // "Unknown"' "$INFO_PATH" 2>/dev/null || echo "Unknown")
        BACKUP_SIZE=$(jq -r '.backup_size // "Unknown"' "$INFO_PATH" 2>/dev/null || echo "Unknown")
        BACKUP_INFO="found"
    elif command -v python3 >/dev/null 2>&1; then
        BACKUP_TIMESTAMP=$(python3 -c "import json; data=json.load(open('$INFO_PATH')); print(data.get('timestamp', 'Unknown'))" 2>/dev/null || echo "Unknown")
        BACKUP_FILES=$(python3 -c "import json; data=json.load(open('$INFO_PATH')); print(data.get('files_backed_up', 'Unknown'))" 2>/dev/null || echo "Unknown")
        BACKUP_SIZE=$(python3 -c "import json; data=json.load(open('$INFO_PATH')); print(data.get('backup_size', 'Unknown'))" 2>/dev/null || echo "Unknown")
        BACKUP_INFO="found"
    fi
fi

# Confirm restoration
if [ "$FORCE" = false ]; then
    echo
    log_warning "Restore configuration:"
    log_gray "  From: $BACKUP_PATH"
    log_gray "  To: $PRODUCTION_PATH"
    
    if [ ! -z "$BACKUP_INFO" ]; then
        log_gray "  Backup date: $BACKUP_TIMESTAMP"
        log_gray "  Files: $BACKUP_FILES"
        log_gray "  Size: $BACKUP_SIZE"
    fi
    
    echo
    log_error "⚠️  This will OVERWRITE the current production configuration!"
    read -p "Proceed with restoration? (y/N): " -n 1 -r REPLY
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Restoration cancelled."
        exit 0
    fi
fi

echo
log_info "Restoring configuration..."

# Create a backup of current state before restoration
PRE_RESTORE_BACKUP=""
if [ -d "$PRODUCTION_PATH" ]; then
    PRE_RESTORE_BACKUP="./backups/pre-restore-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$PRE_RESTORE_BACKUP"
    cp -r "$PRODUCTION_PATH"/* "$PRE_RESTORE_BACKUP"/ 2>/dev/null || true
    log_success "✓ Current config backed up to: $PRE_RESTORE_BACKUP"
fi

# IMPORTANT: Completely clean the production directory
log_warning "Cleaning production directory..."
if [ -d "$PRODUCTION_PATH" ]; then
    # Save only essential runtime files that shouldn't be deleted
    TEMP_SAVE="/tmp/claude-runtime-$(date +%s)"
    mkdir -p "$TEMP_SAVE"
    
    # Save runtime files if they exist (shell-snapshots, ide locks, etc.)
    [ -d "$PRODUCTION_PATH/ide" ] && cp -r "$PRODUCTION_PATH/ide" "$TEMP_SAVE/" 2>/dev/null || true
    [ -d "$PRODUCTION_PATH/shell-snapshots" ] && cp -r "$PRODUCTION_PATH/shell-snapshots" "$TEMP_SAVE/" 2>/dev/null || true
    [ -d "$PRODUCTION_PATH/statsig" ] && cp -r "$PRODUCTION_PATH/statsig" "$TEMP_SAVE/" 2>/dev/null || true
    [ -d "$PRODUCTION_PATH/todos" ] && cp -r "$PRODUCTION_PATH/todos" "$TEMP_SAVE/" 2>/dev/null || true
    [ -d "$PRODUCTION_PATH/projects" ] && cp -r "$PRODUCTION_PATH/projects" "$TEMP_SAVE/" 2>/dev/null || true
    
    # Completely remove the directory
    rm -rf "$PRODUCTION_PATH"
    
    # Recreate and restore runtime files
    mkdir -p "$PRODUCTION_PATH"
    cp -r "$TEMP_SAVE"/* "$PRODUCTION_PATH"/ 2>/dev/null || true
    rm -rf "$TEMP_SAVE"
else
    mkdir -p "$PRODUCTION_PATH"
fi

# Restore from backup (exclude backup metadata files)
log_info "Copying backup files..."
find "$BACKUP_PATH" -mindepth 1 -maxdepth 1 ! -name "backup-info.json" ! -name "backup-manifest.txt" -exec cp -r {} "$PRODUCTION_PATH"/ \;

# Verify integrity if manifest exists
MANIFEST_PATH="$(cd "$BACKUP_PATH" && pwd)/backup-manifest.txt"
if [ -f "$MANIFEST_PATH" ] && [ -s "$MANIFEST_PATH" ]; then
    log_info "Verifying file integrity using MD5 manifest..."
    VERIFICATION_FAILED=false
    VERIFIED_COUNT=0
    FAILED_COUNT=0
    MISSING_COUNT=0
    
    cd "$PRODUCTION_PATH"
    while IFS= read -r line; do
        # Skip empty lines and comments
        [ -z "$line" ] && continue
        [[ "$line" =~ ^#.* ]] && continue
        
        # Extract hash and filename from manifest line (format: "hash  filename")
        EXPECTED_HASH=$(echo "$line" | awk '{print $1}')
        FILE_PATH=$(echo "$line" | sed 's/^[^ ]* *//')  # Everything after first space
        
        if [ -f "$FILE_PATH" ]; then
            # Calculate current hash
            if command -v md5sum >/dev/null 2>&1; then
                CURRENT_HASH=$(md5sum "$FILE_PATH" 2>/dev/null | awk '{print $1}')
            elif command -v md5 >/dev/null 2>&1; then
                CURRENT_HASH=$(md5 -q "$FILE_PATH" 2>/dev/null)
            else
                log_warning "  ⚠ MD5 command not available - skipping verification"
                break
            fi
            
            if [ "$EXPECTED_HASH" = "$CURRENT_HASH" ]; then
                VERIFIED_COUNT=$((VERIFIED_COUNT + 1))
            else
                log_error "  ✗ Integrity check failed for: $FILE_PATH"
                log_error "    Expected: $EXPECTED_HASH"
                log_error "    Found:    $CURRENT_HASH"
                VERIFICATION_FAILED=true
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        else
            log_warning "  ⚠ Missing file: $FILE_PATH"
            MISSING_COUNT=$((MISSING_COUNT + 1))
        fi
    done < "$MANIFEST_PATH"
    cd - >/dev/null
    
    # Summary of verification
    log_info "Integrity verification summary:"
    log_success "  ✓ Verified: $VERIFIED_COUNT files"
    [ $FAILED_COUNT -gt 0 ] && log_error "  ✗ Failed: $FAILED_COUNT files"
    [ $MISSING_COUNT -gt 0 ] && log_warning "  ⚠ Missing: $MISSING_COUNT files"
    
    if [ "$VERIFICATION_FAILED" = true ] || [ $MISSING_COUNT -gt 0 ]; then
        log_error "⚠️  Integrity verification found issues!"
        log_warning "Restore completed but some files may be corrupted or missing."
    else
        log_success "✓ All files passed integrity verification"
    fi
else
    log_warning "⚠ No integrity manifest found - skipping verification"
    log_gray "  (Manifest would be available if backup was created with MD5 support)"
fi

RESTORED_FILES=$(find "$PRODUCTION_PATH" -type f | wc -l)

# Create restoration log
RESTORATION_TIME=$(date '+%Y-%m-%d %H:%M:%S')
cat > "$PRODUCTION_PATH/restoration-log.json" << EOF
{
  "timestamp": "$RESTORATION_TIME",
  "restored_from": "$BACKUP_PATH",
  "destination": "$PRODUCTION_PATH",
  "pre_restore_backup": "$PRE_RESTORE_BACKUP",
  "restored_files": $RESTORED_FILES,
  "platform": "$(uname -s)",
  "hostname": "$(hostname)"
}
EOF

echo
log_success "✓ Configuration restored successfully!"
log_gray "  Restored from: $BACKUP_PATH"
log_gray "  Files restored: $RESTORED_FILES"

# Clean up pre-restore backup since restoration was successful
if [ ! -z "$PRE_RESTORE_BACKUP" ] && [ -d "$PRE_RESTORE_BACKUP" ]; then
    rm -rf "$PRE_RESTORE_BACKUP"
    log_gray "  Cleaned up temporary pre-restore backup"
fi