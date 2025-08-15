#!/bin/bash
# CLAUDE_COMMAND_NAME: quick-test
# CLAUDE_COMMAND_DESC: Lance rapidement les tests du projet avec détection automatique
# CLAUDE_COMMAND_ARGS: [test-pattern] [coverage]

set -e

PROJECT_ROOT=$(pwd)
TEST_PATTERN=${1:-""}
COVERAGE=${2:-"false"}

echo "🧪 Quick Test - Détection automatique du framework de test"
echo "📁 Répertoire: $PROJECT_ROOT"

# Fonction pour détecter et lancer les tests
detect_and_run_tests() {
    # Node.js / npm
    if [ -f "package.json" ]; then
        echo "📦 Projet Node.js détecté"
        
        # Vérifier les scripts disponibles
        if npm run-script 2>/dev/null | grep -q "test"; then
            echo "▶️  Lancement: npm test"
            if [ "$COVERAGE" = "true" ]; then
                npm run test:coverage 2>/dev/null || npm test -- --coverage
            else
                npm test
            fi
            return 0
        fi
    fi
    
    # Python
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        echo "🐍 Projet Python détecté"
        
        # pytest
        if command -v pytest &> /dev/null; then
            echo "▶️  Lancement: pytest"
            if [ "$COVERAGE" = "true" ]; then
                pytest --cov=. ${TEST_PATTERN}
            else
                pytest ${TEST_PATTERN}
            fi
            return 0
        fi
        
        # unittest
        if [ -d "tests" ] || find . -name "*test*.py" | head -1 | grep -q .; then
            echo "▶️  Lancement: python -m unittest"
            python -m unittest discover ${TEST_PATTERN}
            return 0
        fi
    fi
    
    # Go
    if [ -f "go.mod" ]; then
        echo "🚀 Projet Go détecté"
        echo "▶️  Lancement: go test"
        if [ "$COVERAGE" = "true" ]; then
            go test -coverprofile=coverage.out ./...
            go tool cover -html=coverage.out -o coverage.html
            echo "📊 Couverture générée: coverage.html"
        else
            go test ./... ${TEST_PATTERN}
        fi
        return 0
    fi
    
    # Rust
    if [ -f "Cargo.toml" ]; then
        echo "🦀 Projet Rust détecté"
        echo "▶️  Lancement: cargo test"
        cargo test ${TEST_PATTERN}
        return 0
    fi
    
    # Java / Maven
    if [ -f "pom.xml" ]; then
        echo "☕ Projet Maven détecté"
        echo "▶️  Lancement: mvn test"
        mvn test ${TEST_PATTERN}
        return 0
    fi
    
    # Java / Gradle
    if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "☕ Projet Gradle détecté"
        echo "▶️  Lancement: ./gradlew test"
        ./gradlew test ${TEST_PATTERN}
        return 0
    fi
    
    # PHP / Composer
    if [ -f "composer.json" ]; then
        echo "🐘 Projet PHP détecté"
        
        if [ -f "phpunit.xml" ] || [ -f "phpunit.xml.dist" ]; then
            echo "▶️  Lancement: phpunit"
            ./vendor/bin/phpunit ${TEST_PATTERN}
            return 0
        fi
    fi
    
    # Recherche générique de tests
    echo "🔍 Recherche de fichiers de test..."
    
    TEST_FILES=$(find . -name "*test*" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) | head -5)
    if [ -n "$TEST_FILES" ]; then
        echo "📝 Fichiers de test trouvés:"
        echo "$TEST_FILES"
        echo "❓ Aucun framework de test reconnu automatiquement"
        return 1
    fi
    
    echo "❌ Aucun test détecté dans ce projet"
    return 1
}

# Lancer les tests
echo ""
if detect_and_run_tests; then
    echo ""
    echo "✅ Tests terminés avec succès!"
    
    # Statistiques rapides si possible
    if command -v find &> /dev/null; then
        TEST_COUNT=$(find . -name "*test*" -type f | wc -l)
        echo "📊 $TEST_COUNT fichier(s) de test trouvé(s)"
    fi
else
    echo ""
    echo "❌ Impossible de lancer les tests automatiquement"
    echo "💡 Essayez de spécifier manuellement la commande de test"
    exit 1
fi