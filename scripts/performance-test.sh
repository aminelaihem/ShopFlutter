#!/bin/bash

# Script de test de performance pour l'application web
# Usage: ./scripts/performance-test.sh [URL]

set -e

# Configuration
DEFAULT_URL="http://localhost:8000"
TEST_URL=${1:-$DEFAULT_URL}
LIGHTHOUSE_SCORE_MIN=90

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

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    # Vérifier Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js n'est pas installé"
        exit 1
    fi
    
    # Vérifier npm
    if ! command -v npm &> /dev/null; then
        error "npm n'est pas installé"
        exit 1
    fi
    
    # Vérifier que l'URL est accessible
    if ! curl -s -o /dev/null -w "%{http_code}" "$TEST_URL" | grep -q "200"; then
        error "L'URL $TEST_URL n'est pas accessible"
        error "Assurez-vous que l'application est démarrée"
        exit 1
    fi
    
    success "Prérequis vérifiés"
}

# Installation de Lighthouse
install_lighthouse() {
    log "Installation de Lighthouse..."
    
    if ! command -v lighthouse &> /dev/null; then
        log "Installation de Lighthouse globalement..."
        npm install -g lighthouse
    else
        log "Lighthouse déjà installé"
    fi
    
    success "Lighthouse prêt"
}

# Test de performance avec Lighthouse
run_lighthouse_test() {
    log "Exécution du test Lighthouse sur $TEST_URL..."
    
    local output_file="lighthouse-report.json"
    local html_report="lighthouse-report.html"
    
    # Exécution de Lighthouse
    if lighthouse "$TEST_URL" \
        --output=json,html \
        --output-path=./lighthouse-report \
        --chrome-flags="--headless" \
        --quiet; then
        
        success "Test Lighthouse terminé"
    else
        error "Échec du test Lighthouse"
        exit 1
    fi
    
    # Analyse des résultats
    analyze_lighthouse_results "./lighthouse-report.json"
}

# Analyse des résultats Lighthouse
analyze_lighthouse_results() {
    local report_file=$1
    
    log "Analyse des résultats Lighthouse..."
    
    if [[ ! -f "$report_file" ]]; then
        error "Fichier de rapport Lighthouse introuvable"
        exit 1
    fi
    
    # Extraction des scores
    local performance_score=$(jq -r '.categories.performance.score * 100' "$report_file" 2>/dev/null || echo "0")
    local accessibility_score=$(jq -r '.categories.accessibility.score * 100' "$report_file" 2>/dev/null || echo "0")
    local best_practices_score=$(jq -r '.categories."best-practices".score * 100' "$report_file" 2>/dev/null || echo "0")
    local seo_score=$(jq -r '.categories.seo.score * 100' "$report_file" 2>/dev/null || echo "0")
    
    # Affichage des scores
    echo ""
    echo "📊 Résultats Lighthouse:"
    echo "========================"
    echo "Performance:      ${performance_score}%"
    echo "Accessibilité:    ${accessibility_score}%"
    echo "Bonnes pratiques: ${best_practices_score}%"
    echo "SEO:              ${seo_score}%"
    echo ""
    
    # Vérification du score minimum
    local overall_score=$(( (performance_score + accessibility_score + best_practices_score + seo_score) / 4 ))
    
    if [[ $overall_score -ge $LIGHTHOUSE_SCORE_MIN ]]; then
        success "✅ Score global: ${overall_score}% (>= ${LIGHTHOUSE_SCORE_MIN}%)"
    else
        error "❌ Score global: ${overall_score}% (< ${LIGHTHOUSE_SCORE_MIN}%)"
        return 1
    fi
    
    # Recommandations
    echo ""
    echo "💡 Recommandations:"
    echo "==================="
    
    if [[ $performance_score -lt 90 ]]; then
        warning "Performance: Optimiser les images et le code JavaScript"
    fi
    
    if [[ $accessibility_score -lt 90 ]]; then
        warning "Accessibilité: Améliorer les contrastes et les labels"
    fi
    
    if [[ $best_practices_score -lt 90 ]]; then
        warning "Bonnes pratiques: Vérifier la sécurité et les bonnes pratiques"
    fi
    
    if [[ $seo_score -lt 90 ]]; then
        warning "SEO: Améliorer les métadonnées et la structure"
    fi
}

# Test de charge simple
run_load_test() {
    log "Exécution du test de charge..."
    
    # Test avec curl (simple)
    local response_times=()
    local success_count=0
    local total_requests=10
    
    for i in $(seq 1 $total_requests); do
        local start_time=$(date +%s%N)
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$TEST_URL")
        local end_time=$(date +%s%N)
        
        if [[ "$http_code" == "200" ]]; then
            ((success_count++))
            local response_time=$(( (end_time - start_time) / 1000000 )) # en millisecondes
            response_times+=($response_time)
        fi
        
        log "Requête $i/$total_requests - Code: $http_code"
    done
    
    # Calcul des statistiques
    if [[ ${#response_times[@]} -gt 0 ]]; then
        local total_time=0
        for time in "${response_times[@]}"; do
            total_time=$((total_time + time))
        done
        
        local avg_time=$((total_time / ${#response_times[@]}))
        local success_rate=$((success_count * 100 / total_requests))
        
        echo ""
        echo "📈 Test de charge:"
        echo "=================="
        echo "Taux de succès: ${success_rate}%"
        echo "Temps de réponse moyen: ${avg_time}ms"
        echo "Requêtes réussies: ${success_count}/${total_requests}"
        echo ""
        
        if [[ $success_rate -ge 95 ]]; then
            success "✅ Test de charge réussi"
        else
            warning "⚠️  Test de charge: taux de succès faible"
        fi
    else
        error "❌ Aucune requête réussie"
        return 1
    fi
}

# Test de taille du bundle
test_bundle_size() {
    log "Test de la taille du bundle..."
    
    local build_dir="build/web"
    
    if [[ ! -d "$build_dir" ]]; then
        warning "Répertoire de build introuvable: $build_dir"
        return 0
    fi
    
    # Calcul de la taille totale
    local total_size=$(du -sh "$build_dir" | cut -f1)
    local js_size=$(du -sh "$build_dir"/*.js 2>/dev/null | awk '{sum+=$1} END {print sum "K"}' || echo "0K")
    local css_size=$(du -sh "$build_dir"/*.css 2>/dev/null | awk '{sum+=$1} END {print sum "K"}' || echo "0K")
    
    echo ""
    echo "📦 Taille du bundle:"
    echo "===================="
    echo "Taille totale: $total_size"
    echo "JavaScript: $js_size"
    echo "CSS: $css_size"
    echo ""
    
    # Vérification des limites
    local js_size_kb=$(echo "$js_size" | sed 's/K//')
    if [[ $js_size_kb -gt 1000 ]]; then
        warning "⚠️  Bundle JavaScript volumineux: ${js_size}"
    else
        success "✅ Bundle JavaScript optimisé: ${js_size}"
    fi
}

# Fonction principale
main() {
    log "🚀 Démarrage des tests de performance"
    log "URL de test: $TEST_URL"
    log "Score minimum Lighthouse: $LIGHTHOUSE_SCORE_MIN"
    
    # Vérifications préliminaires
    check_prerequisites
    
    # Tests
    install_lighthouse
    run_lighthouse_test
    run_load_test
    test_bundle_size
    
    success "🎉 Tests de performance terminés !"
    log "Rapport HTML disponible: lighthouse-report.html"
}

# Gestion des erreurs
trap 'error "Script interrompu par l'\''utilisateur"; exit 1' INT TERM

# Exécution
main "$@"
