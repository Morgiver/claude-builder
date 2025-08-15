#!/bin/bash
# CLAUDE_COMMAND_NAME: hello
# CLAUDE_COMMAND_DESC: Display a personalized greeting message
# CLAUDE_COMMAND_ARGS: [name] [language]

# Parameters
NAME=${1:-"Developer"}
LANG=${2:-"fr"}

# Multilingual messages
case $LANG in
    "en")
        echo "🌍 Hello $NAME! Welcome to Claude Code commands!"
        echo "Current time: $(date)"
        echo "Working directory: $(pwd)"
        ;;
    "es")
        echo "🌍 ¡Hola $NAME! ¡Bienvenido a los comandos de Claude Code!"
        echo "Hora actual: $(date)"
        echo "Directorio de trabajo: $(pwd)"
        ;;
    *)
        echo "🌍 Hello $NAME! Welcome to Claude Code commands!"
        echo "Current time: $(date)"
        echo "Working directory: $(pwd)"
        ;;
esac

# System information
echo ""
echo "📊 System information:"
echo "   OS: $(uname -s)"
echo "   Version: $(uname -r)"
echo "   Architecture: $(uname -m)"

exit 0