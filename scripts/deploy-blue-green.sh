#!/bin/bash

# Script de déploiement Blue-Green pour Firebase Hosting
# Usage: ./scripts/deploy-blue-green.sh [--dry-run]

set -e

# Configuration
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-"shopflutter-d3308"}
DRY_RUN=false

# Vérification des arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🔍 Mode dry-run activé"
fi

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
    
    # Vérifier Firebase CLI
    if ! command -v firebase &> /dev/null; then
        error "Firebase CLI n'est pas installé. Installez-le avec: npm install -g firebase-tools"
        exit 1
    fi
    
    # Vérifier que nous sommes connectés à Firebase
    if ! firebase projects:list &> /dev/null; then
        error "Vous n'êtes pas connecté à Firebase. Exécutez: firebase login"
        exit 1
    fi
    
    # Vérifier que le projet existe
    if ! firebase use $FIREBASE_PROJECT_ID &> /dev/null; then
        error "Le projet Firebase $FIREBASE_PROJECT_ID n'existe pas ou n'est pas accessible"
        exit 1
    fi
    
    success "Prérequis vérifiés"
}

# Obtenir le canal actuel
get_current_channel() {
    local current_channel=$(firebase hosting:channel:list --json | jq -r '.channels[] | select(.status == "live") | .channelId' 2>/dev/null || echo "")
    echo "$current_channel"
}

# Obtenir le prochain canal
get_next_channel() {
    local current_channel=$1
    if [[ "$current_channel" == "blue" ]]; then
        echo "green"
    else
        echo "blue"
    fi
}

# Déployer sur un canal
deploy_to_channel() {
    local channel=$1
    log "Déploiement sur le canal $channel..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Déploiement simulé sur le canal $channel"
        return 0
    fi
    
    if firebase hosting:channel:deploy $channel --only hosting; then
        success "Déploiement réussi sur le canal $channel"
        return 0
    else
        error "Échec du déploiement sur le canal $channel"
        return 1
    fi
}

# Exécuter les smoke tests
run_smoke_tests() {
    local channel=$1
    local url="https://$FIREBASE_PROJECT_ID--$channel.web.app"
    
    log "Exécution des smoke tests sur $url..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Smoke tests simulés"
        return 0
    fi
    
    # Attendre que le déploiement soit accessible
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
            success "L'application est accessible sur $url"
            break
        else
            log "Tentative $attempt/$max_attempts - Attente de l'accessibilité..."
            sleep 10
            ((attempt++))
        fi
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        error "L'application n'est pas accessible après $max_attempts tentatives"
        return 1
    fi
    
    # Tests basiques
    log "Exécution des tests de base..."
    
    # Test 1: Vérifier que la page se charge
    if ! curl -s "$url" | grep -q "flutter"; then
        error "La page ne contient pas de contenu Flutter"
        return 1
    fi
    
    # Test 2: Vérifier les ressources statiques
    if ! curl -s -o /dev/null -w "%{http_code}" "$url/favicon.png" | grep -q "200"; then
        warning "Le favicon n'est pas accessible"
    fi
    
    success "Smoke tests réussis"
    return 0
}

# Promouvoir un canal vers live
promote_to_live() {
    local channel=$1
    
    log "Promotion du canal $channel vers live..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Promotion simulée vers live"
        return 0
    fi
    
    if firebase hosting:channel:deploy live --only hosting; then
        success "Canal $channel promu vers live avec succès"
        return 0
    else
        error "Échec de la promotion du canal $channel vers live"
        return 1
    fi
}

# Nettoyer l'ancien canal
cleanup_old_channel() {
    local old_channel=$1
    
    if [[ -z "$old_channel" ]]; then
        log "Aucun ancien canal à nettoyer"
        return 0
    fi
    
    log "Nettoyage de l'ancien canal $old_channel..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN: Nettoyage simulé du canal $old_channel"
        return 0
    fi
    
    if firebase hosting:channel:delete $old_channel --force; then
        success "Ancien canal $old_channel supprimé"
    else
        warning "Impossible de supprimer l'ancien canal $old_channel"
    fi
}

# Fonction principale
main() {
    log "🚀 Démarrage du déploiement Blue-Green"
    
    # Vérifications préliminaires
    check_prerequisites
    
    # Obtenir le canal actuel
    local current_channel=$(get_current_channel)
    local next_channel=$(get_next_channel "$current_channel")
    
    log "Canal actuel: $current_channel"
    log "Prochain canal: $next_channel"
    
    # Déploiement sur le nouveau canal
    if ! deploy_to_channel "$next_channel"; then
        error "Échec du déploiement sur le canal $next_channel"
        exit 1
    fi
    
    # Smoke tests
    if ! run_smoke_tests "$next_channel"; then
        error "Les smoke tests ont échoué sur le canal $next_channel"
        exit 1
    fi
    
    # Promotion vers live
    if ! promote_to_live "$next_channel"; then
        error "Échec de la promotion vers live"
        exit 1
    fi
    
    # Nettoyage
    cleanup_old_channel "$current_channel"
    
    success "🎉 Déploiement Blue-Green terminé avec succès !"
    success "Application disponible sur: https://$FIREBASE_PROJECT_ID.web.app"
}

# Gestion des erreurs
trap 'error "Script interrompu par l'\''utilisateur"; exit 1' INT TERM

# Exécution
main "$@"
