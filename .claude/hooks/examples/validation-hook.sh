#!/bin/bash
# Example validation hook
# This hook checks for certain patterns in the prompt

echo "🔍 Validation Hook: Checking prompt..." >&2

# Lire le prompt depuis stdin ou arguments
PROMPT="$*"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
    PROMPT=$(cat)
fi

# Checks
if echo "$PROMPT" | grep -q "password\|secret\|token"; then
    echo "⚠️  WARNING: Prompt contains sensitive information" >&2
    echo "Do you want to continue? (y/N)" >&2
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Hook: Stopped by user request" >&2
        exit 1
    fi
fi

# Success
echo "✅ Hook: Validation successful" >&2
exit 0