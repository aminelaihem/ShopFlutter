#!/bin/bash

# Script de vérification de la couverture de code
# Usage: ./scripts/check-coverage.sh [--min-coverage=50]

set -e

# Configuration par défaut
MIN_COVERAGE=50
COVERAGE_FILE="coverage/lcov.info"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --min-coverage=N    Couverture minimale requise (défaut: 50)"
    echo "  --coverage-file=F   Fichier de couverture à analyser (défaut: coverage/lcov.info)"
    echo "  --help              Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 --min-coverage=60"
    echo "  $0 --coverage-file=custom/coverage.info"
}

# Traitement des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --min-coverage=*)
            MIN_COVERAGE="${1#*=}"
            shift
            ;;
        --coverage-file=*)
            COVERAGE_FILE="${1#*=}"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    # Vérifier que le fichier de couverture existe
    if [[ ! -f "$COVERAGE_FILE" ]]; then
        error "Le fichier de couverture $COVERAGE_FILE n'existe pas"
        error "Exécutez d'abord: flutter test --coverage"
        exit 1
    fi
    
    # Vérifier que lcov est installé
    if ! command -v lcov &> /dev/null; then
        warning "lcov n'est pas installé, tentative d'installation..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y lcov
        elif command -v brew &> /dev/null; then
            brew install lcov
        else
            error "Impossible d'installer lcov automatiquement. Installez-le manuellement."
            exit 1
        fi
    fi
    
    success "Prérequis vérifiés"
}

# Analyser la couverture
analyze_coverage() {
    log "Analyse de la couverture de code..."
    
    # Générer le rapport de couverture
    local coverage_report=$(lcov --summary "$COVERAGE_FILE" 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        error "Impossible d'analyser le fichier de couverture"
        exit 1
    fi
    
    # Extraire le pourcentage de couverture
    local coverage_percent=$(echo "$coverage_report" | grep -o '[0-9]*\.[0-9]*%' | head -1 | sed 's/%//')
    
    if [[ -z "$coverage_percent" ]]; then
        error "Impossible d'extraire le pourcentage de couverture"
        exit 1
    fi
    
    # Afficher le rapport détaillé
    echo ""
    echo "📊 Rapport de couverture de code:"
    echo "=================================="
    echo "$coverage_report"
    echo ""
    
    # Vérifier si la couverture est suffisante
    local coverage_int=$(echo "$coverage_percent" | cut -d. -f1)
    
    if [[ $coverage_int -ge $MIN_COVERAGE ]]; then
        success "✅ Couverture de code: ${coverage_percent}% (>= ${MIN_COVERAGE}%)"
        return 0
    else
        error "❌ Couverture de code: ${coverage_percent}% (< ${MIN_COVERAGE}%)"
        return 1
    fi
}

# Générer un rapport HTML (optionnel)
generate_html_report() {
    local html_dir="coverage/html"
    
    log "Génération du rapport HTML..."
    
    if [[ -d "$html_dir" ]]; then
        rm -rf "$html_dir"
    fi
    
    if genhtml "$COVERAGE_FILE" -o "$html_dir" --quiet; then
        success "Rapport HTML généré dans: $html_dir/index.html"
        log "Ouvrez le rapport avec: open $html_dir/index.html"
    else
        warning "Impossible de générer le rapport HTML"
    fi
}

# Fonction principale
main() {
    log "🔍 Vérification de la couverture de code"
    log "Couverture minimale requise: ${MIN_COVERAGE}%"
    log "Fichier de couverture: $COVERAGE_FILE"
    
    # Vérifications préliminaires
    check_prerequisites
    
    # Analyse de la couverture
    if analyze_coverage; then
        # Générer le rapport HTML si la couverture est suffisante
        generate_html_report
        success "🎉 La couverture de code est suffisante !"
        exit 0
    else
        error "💥 La couverture de code est insuffisante !"
        exit 1
    fi
}

# Exécution
main "$@"
