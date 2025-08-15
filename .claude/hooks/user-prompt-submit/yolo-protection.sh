#!/bin/bash
# YOLO Mode Protection Hook
# Protège contre les commandes de suppression dangereuses en mode YOLO

echo "🛡️  YOLO Protection: Scanning for dangerous commands..." >&2

# Lire le prompt depuis stdin ou arguments
PROMPT="$*"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
    PROMPT=$(cat)
fi

# Vérifier si Claude est lancé avec --dangerously-skip-permissions
YOLO_MODE=false
if ps -ef | grep -q "claude.*--dangerously-skip-permissions" 2>/dev/null; then
    YOLO_MODE=true
elif pgrep -f "claude.*--dangerously-skip-permissions" >/dev/null 2>&1; then
    YOLO_MODE=true
elif [ "$CLAUDE_YOLO_MODE" = "true" ]; then
    # Fallback pour tests manuels
    YOLO_MODE=true
fi

if [ "$YOLO_MODE" != "true" ]; then
    echo "✅ Hook: Not in YOLO mode (--dangerously-skip-permissions), protection inactive" >&2
    exit 0
fi

echo "🚨 YOLO MODE DETECTED - Protection active" >&2

# Patterns de commandes dangereuses
DANGEROUS_PATTERNS=(
    "rm -rf"
    "rm -r"
    "rmdir"
    "del /s"
    "rd /s"
    "Remove-Item.*-Recurse"
    "Get-ChildItem.*Remove-Item"
    "find.*-delete"
    "find.*-exec rm"
    "shred"
    "wipe"
    "srm"
    "unlink"
    "format"
    "mkfs"
    "dd if=/dev/zero"
    "dd if=/dev/random"
    "> /dev/sda"
    "truncate.*--size=0"
    "git reset --hard HEAD"
    "git clean -fd"
    "docker system prune -a"
    "kubectl delete"
    "terraform destroy"
    "ansible.*state=absent"
    "DROP DATABASE"
    "DROP TABLE"
    "TRUNCATE TABLE"
    "DELETE FROM.*WHERE"
)

# Vérifier les patterns dangereux
FOUND_DANGEROUS=false
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$PROMPT" | grep -iq "$pattern"; then
        echo "🚨 DANGEROUS COMMAND DETECTED: $pattern" >&2
        FOUND_DANGEROUS=true
    fi
done

# Si commande dangereuse détectée
if [ "$FOUND_DANGEROUS" = true ]; then
    echo "" >&2
    echo "❌ YOLO PROTECTION: Dangerous deletion command detected!" >&2
    echo "🛡️  This command could cause irreversible data loss." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  1. Disable YOLO mode: unset CLAUDE_YOLO_MODE" >&2
    echo "  2. Bypass protection: set CLAUDE_YOLO_BYPASS=true" >&2
    echo "  3. Review and modify your request" >&2
    echo "" >&2
    
    # Vérifier si bypass est activé
    if [ "$CLAUDE_YOLO_BYPASS" = "true" ]; then
        echo "⚠️  BYPASS ACTIVE - Allowing dangerous command" >&2
        echo "🔄 Resetting bypass flag..." >&2
        unset CLAUDE_YOLO_BYPASS
        exit 0
    fi
    
    echo "Do you want to proceed anyway? (type 'DANGEROUS' to confirm): " >&2
    read -r response
    if [ "$response" != "DANGEROUS" ]; then
        echo "❌ Hook: Execution blocked for safety" >&2
        exit 1
    else
        echo "⚠️  User confirmed dangerous operation" >&2
    fi
fi

# Success
echo "✅ Hook: YOLO protection check passed" >&2
exit 0