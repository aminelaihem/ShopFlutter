#!/bin/bash

# Script de build pour le web
# Usage: ./scripts/build-web.sh [--release|--debug]

set -e

# Configuration
BUILD_MODE="release"
OUTPUT_DIR="build/web"

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
    echo "  --release    Build en mode release (défaut)"
    echo "  --debug      Build en mode debug"
    echo "  --help       Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 --release"
    echo "  $0 --debug"
}

# Traitement des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            BUILD_MODE="release"
            shift
            ;;
        --debug)
            BUILD_MODE="debug"
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
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        error "Flutter n'est pas installé ou n'est pas dans le PATH"
        exit 1
    fi
    
    # Vérifier la version de Flutter
    local flutter_version=$(flutter --version | head -n 1)
    log "Version Flutter: $flutter_version"
    
    # Vérifier que nous sommes dans un projet Flutter
    if [[ ! -f "pubspec.yaml" ]]; then
        error "Ce script doit être exécuté depuis la racine du projet Flutter"
        exit 1
    fi
    
    success "Prérequis vérifiés"
}

# Nettoyage
cleanup() {
    log "Nettoyage des builds précédents..."
    
    if [[ -d "$OUTPUT_DIR" ]]; then
        rm -rf "$OUTPUT_DIR"
        log "Ancien build supprimé"
    fi
    
    # Nettoyer le cache Flutter
    flutter clean
    log "Cache Flutter nettoyé"
}

# Récupération des dépendances
get_dependencies() {
    log "Récupération des dépendances..."
    
    if flutter pub get; then
        success "Dépendances récupérées"
    else
        error "Échec de la récupération des dépendances"
        exit 1
    fi
}

# Vérification du code
validate_code() {
    log "Validation du code..."
    
    # Vérification du formatage
    log "Vérification du formatage..."
    if flutter format --set-exit-if-changed; then
        success "Formatage OK"
    else
        error "Le code n'est pas correctement formaté"
        error "Exécutez: flutter format ."
        exit 1
    fi
    
    # Analyse statique
    log "Analyse statique..."
    if flutter analyze; then
        success "Analyse statique OK"
    else
        error "L'analyse statique a échoué"
        exit 1
    fi
}

# Exécution des tests
run_tests() {
    log "Exécution des tests..."
    
    if flutter test --coverage; then
        success "Tests exécutés avec succès"
    else
        error "Les tests ont échoué"
        exit 1
    fi
}

# Build pour le web
build_web() {
    log "Build pour le web en mode $BUILD_MODE..."
    
    local build_command="flutter build web"
    
    if [[ "$BUILD_MODE" == "release" ]]; then
        build_command="$build_command --release"
    else
        build_command="$build_command --debug"
    fi
    
    # Ajouter des optimisations pour la production
    if [[ "$BUILD_MODE" == "release" ]]; then
        build_command="$build_command --web-renderer html"
    fi
    
    if eval "$build_command"; then
        success "Build web réussi"
    else
        error "Échec du build web"
        exit 1
    fi
}

# Vérification du build
verify_build() {
    log "Vérification du build..."
    
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        error "Le répertoire de build $OUTPUT_DIR n'existe pas"
        exit 1
    fi
    
    if [[ ! -f "$OUTPUT_DIR/index.html" ]]; then
        error "Le fichier index.html n'existe pas dans le build"
        exit 1
    fi
    
    # Vérifier la taille du build
    local build_size=$(du -sh "$OUTPUT_DIR" | cut -f1)
    log "Taille du build: $build_size"
    
    # Vérifier les fichiers essentiels
    local essential_files=("index.html" "main.dart.js" "flutter.js")
    for file in "${essential_files[@]}"; do
        if [[ -f "$OUTPUT_DIR/$file" ]]; then
            log "✅ $file présent"
        else
            warning "⚠️  $file manquant"
        fi
    done
    
    success "Build vérifié"
}

# Optimisation du build (optionnel)
optimize_build() {
    if [[ "$BUILD_MODE" == "release" ]]; then
        log "Optimisation du build..."
        
        # Compression des fichiers CSS et JS (si disponible)
        if command -v gzip &> /dev/null; then
            find "$OUTPUT_DIR" -name "*.js" -o -name "*.css" | while read file; do
                gzip -c "$file" > "$file.gz"
                log "Compressé: $(basename "$file")"
            done
        fi
        
        success "Build optimisé"
    fi
}

# Fonction principale
main() {
    log "🚀 Démarrage du build web"
    log "Mode: $BUILD_MODE"
    log "Répertoire de sortie: $OUTPUT_DIR"
    
    # Étapes du build
    check_prerequisites
    cleanup
    get_dependencies
    validate_code
    run_tests
    build_web
    verify_build
    optimize_build
    
    success "🎉 Build web terminé avec succès !"
    success "Build disponible dans: $OUTPUT_DIR"
    
    if [[ "$BUILD_MODE" == "release" ]]; then
        log "Pour tester localement:"
        log "  cd $OUTPUT_DIR && python -m http.server 8000"
        log "  Puis ouvrez: http://localhost:8000"
    fi
}

# Gestion des erreurs
trap 'error "Script interrompu par l'\''utilisateur"; exit 1' INT TERM

# Exécution
main "$@"
