#!/bin/bash

################################################################################
# SS JULIA CRIADOR v2.0 - Versão Simplificada
# Git Monitor + Free Fire Scanner para Termux
# Reescrito em um único script - Simples, rápido e eficiente
################################################################################

# Cores ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuração
REPO="${1:-.}"
INTERVAL="${2:-5}"
GAME=""
LOG_DIR="$HOME/.ss_julia"
LOG_FILE="$LOG_DIR/logs.txt"

mkdir -p "$LOG_DIR"

# ============================================================================
# FUNÇÕES BÁSICAS
# ============================================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[OK]${NC} $*"
    log "SUCCESS: $*"
}

error() {
    echo -e "${RED}[ERRO]${NC} $*" >&2
    log "ERROR: $*"
}

info() {
    echo -e "${BLUE}[*]${NC} $*"
    log "INFO: $*"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $*"
    log "WARN: $*"
}

banner() {
    clear
    echo -e "${CYAN}${MAGENTA}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║         SS JULIA CRIADOR v2.0 - Git Monitor Termux           ║
║            WiFi Debug + Free Fire (Normal/Max)                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

pause() {
    read -rp "$(echo -e "${YELLOW}[Enter] continuar...${NC}")" _
}

# ============================================================================
# VERIFICAÇÕES INICIAIS
# ============================================================================

check_git() {
    if ! command -v git &> /dev/null; then
        error "Git não instalado!"
        echo "Execute: pkg install git"
        exit 1
    fi
    success "Git encontrado"
}

check_ssh() {
    info "Verificando SSH..."
    if command -v ssh &> /dev/null; then
        success "SSH disponível"
        return 0
    fi
    warn "SSH não instalado (opcional)"
    return 1
}

check_wifi() {
    info "Verificando WiFi..."
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        local ip=$(hostname -I 2>/dev/null || echo "N/A")
        success "Conectado - IP: $ip"
        log "WiFi: Conectado - IP: $ip"
        return 0
    fi
    error "Sem conexão WiFi"
    log "ERROR: Sem conexão WiFi"
    return 1
}

initial_checks() {
    echo ""
    check_git
    check_ssh
    check_wifi
    echo ""
    sleep 1
}

# ============================================================================
# VALIDAÇÃO
# ============================================================================

validate_repo() {
    if [ ! -d "$REPO/.git" ]; then
        error "Não é um repositório Git: $REPO"
        echo "Uso: $0 [repo_path] [intervalo]"
        echo "Ex:  $0 . 5"
        exit 1
    fi
}

# ============================================================================
# OPERAÇÕES GIT
# ============================================================================

git_status() {
    if [ ! -d "$REPO/.git" ]; then
        error "Repositório não encontrado"
        return 1
    fi
    
    echo -e "\n${BLUE}════ STATUS DO REPOSITÓRIO ════${NC}\n"
    
    cd "$REPO" || return 1
    
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local remote=$(git config --get remote.origin.url 2>/dev/null || echo "N/A")
    local changes=$(git status --porcelain 2>/dev/null | wc -l)
    local unpushed=$(git rev-list --count @{u}.. 2>/dev/null || echo "0")
    local last=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null || echo "N/A")
    
    echo -e "${CYAN}Branch:${NC} $branch"
    echo -e "${CYAN}Remoto:${NC} $remote"
    
    if [ "$changes" -gt 0 ]; then
        echo -e "${RED}Mudanças:${NC} $changes arquivo(s)"
        echo ""
        git status --short 2>/dev/null
    else
        echo -e "${GREEN}Mudanças:${NC} Nenhuma"
    fi
    
    if [ "$unpushed" -gt 0 ]; then
        echo -e "${YELLOW}Não pusheados:${NC} $unpushed commit(s)"
    fi
    
    echo -e "${CYAN}Último commit:${NC} $last"
    echo ""
    
    log "Git Status: Branch=$branch, Mudanças=$changes"
    pause
}

monitor_changes() {
    info "Monitorando (Ctrl+C para parar)"
    echo ""
    
    local last_hash=""
    log "Monitoramento iniciado"
    
    while true; do
        cd "$REPO" || break
        
        local curr_hash=$(git status --porcelain 2>/dev/null | md5sum | cut -d' ' -f1)
        local count=$(git status --porcelain 2>/dev/null | wc -l)
        
        if [ "$curr_hash" != "$last_hash" ]; then
            local ts=$(date '+%H:%M:%S')
            
            if [ "$count" -gt 0 ]; then
                echo -e "${RED}[$ts]${NC} ⚠ $count mudança(s)"
                git status --short 2>/dev/null
                log "Mudanças detectadas: $count"
            else
                echo -e "${GREEN}[$ts]${NC} ✓ Limpo"
                log "Repositório sincronizado"
            fi
            
            last_hash="$curr_hash"
        fi
        
        sleep "$INTERVAL"
    done
    
    echo ""
    log "Monitoramento encerrado"
}

# ============================================================================
# FREE FIRE
# ============================================================================

select_game() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                   SELEÇÃO FREE FIRE                           ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}1${NC}) Free Fire Normal"
    echo "   • Versão padrão"
    echo "   • ~700 MB RAM"
    echo "   • com.mobile.legends"
    echo ""
    
    echo -e "${CYAN}2${NC}) Free Fire Max"
    echo "   • Versão Ultra HD"
    echo "   • ~2 GB RAM"
    echo "   • com.mobile.legends.ffmax"
    echo ""
    
    echo -e "${CYAN}0${NC}) Cancelar"
    echo ""
    
    read -rp "$(echo -e "${YELLOW}Escolha:${NC} ")" choice
    
    case $choice in
        1)
            GAME="normal"
            success "Free Fire Normal selecionado"
            show_ff_info "normal"
            log "Modo selecionado: Free Fire Normal"
            ;;
        2)
            GAME="max"
            success "Free Fire Max selecionado"
            show_ff_info "max"
            log "Modo selecionado: Free Fire Max"
            ;;
        0)
            return
            ;;
        *)
            error "Opção inválida"
            sleep 1
            select_game
            ;;
    esac
}

show_ff_info() {
    local mode=$1
    
    if [ "$mode" = "normal" ]; then
        echo -e "\n${BLUE}╔════ FREE FIRE NORMAL ════╗${NC}"
        echo -e "${CYAN}Pacote:${NC} com.mobile.legends"
        echo -e "${CYAN}Tamanho:${NC} ~650 MB"
        echo -e "${CYAN}RAM Min:${NC} 700 MB"
        echo -e "${CYAN}Android:${NC} 4.4+"
        echo -e "\n${YELLOW}Caminhos:${NC}"
        echo "  /data/data/com.mobile.legends"
        echo "  /sdcard/Android/obb/com.mobile.legends"
    else
        echo -e "\n${BLUE}╔════ FREE FIRE MAX ════╗${NC}"
        echo -e "${CYAN}Pacote:${NC} com.mobile.legends.ffmax"
        echo -e "${CYAN}Tamanho:${NC} ~1.8 GB"
        echo -e "${CYAN}RAM Min:${NC} 2 GB"
        echo -e "${CYAN}Android:${NC} 5.0+"
        echo -e "\n${YELLOW}Caminhos:${NC}"
        echo "  /data/data/com.mobile.legends.ffmax"
        echo "  /sdcard/Android/obb/com.mobile.legends.ffmax"
    fi
    
    echo -e "${BLUE}╚═════════════════════════╝${NC}\n"
    pause
}

debug_ff_wifi() {
    if [ -z "$GAME" ]; then
        error "Selecione um modo Free Fire primeiro"
        return 1
    fi
    
    echo -e "\n${BLUE}════ DEBUG WiFi FREE FIRE (${GAME^^}) ════${NC}\n"
    
    echo -e "${CYAN}Status de Conectividade:${NC}"
    if ping -c 4 -W 2 8.8.8.8 2>&1; then
        success "Conectado ao servidor"
    else
        warn "Offline ou lento"
    fi
    
    echo -e "\n${CYAN}IP Local:${NC}"
    hostname -I 2>/dev/null || echo "N/A"
    
    echo -e "\n${CYAN}Conexões Ativas:${NC}"
    local conn=$(netstat -an 2>/dev/null | grep -c ESTABLISHED || echo "0")
    echo "$conn conexão(ões) estabelecida(s)"
    
    echo -e "\n${CYAN}Latência (ms):${NC}"
    ping -c 1 -W 2 8.8.8.8 2>&1 | grep "time=" || echo "N/A"
    
    echo ""
    log "Debug WiFi Free Fire ($GAME) executado"
    pause
}

monitor_ff_performance() {
    if [ -z "$GAME" ]; then
        error "Selecione um modo Free Fire primeiro"
        return 1
    fi
    
    local pkg
    if [ "$GAME" = "normal" ]; then
        pkg="com.mobile.legends"
    else
        pkg="com.mobile.legends.ffmax"
    fi
    
    info "Monitorando Free Fire ($GAME) - Ctrl+C para parar"
    echo ""
    
    log "Monitor FF Performance ($GAME) iniciado"
    
    for i in {1..10}; do
        local ts=$(date '+%H:%M:%S')
        
        if pgrep -f "$pkg" > /dev/null 2>&1; then
            echo -e "${GREEN}[$ts]${NC} Jogo rodando"
        else
            echo -e "${YELLOW}[$ts]${NC} Jogo não ativo"
        fi
        
        sleep 3
    done
    
    echo ""
    log "Monitor FF Performance finalizado"
}

# ============================================================================
# SISTEMA
# ============================================================================

debug_system() {
    echo -e "\n${BLUE}════ DEBUG DO SISTEMA ════${NC}\n"
    
    echo -e "${YELLOW}Hostname:${NC}"
    hostname
    
    echo -e "${YELLOW}IP Local:${NC}"
    hostname -I 2>/dev/null || echo "N/A"
    
    echo -e "${YELLOW}Versão Android:${NC}"
    getprop ro.build.version.release 2>/dev/null || echo "N/A"
    
    echo -e "${YELLOW}Kernel:${NC}"
    uname -a
    
    echo -e "${YELLOW}Memória:${NC}"
    free -h 2>/dev/null || echo "N/A"
    
    echo -e "${YELLOW}SSH:${NC}"
    command -v sshd &> /dev/null && echo "Instalado" || echo "Não instalado"
    
    echo -e "${YELLOW}Git:${NC}"
    git --version
    
    if [ -n "$GAME" ]; then
        echo -e "${YELLOW}Modo FF Ativo:${NC} $GAME"
    fi
    
    echo ""
    log "Debug Sistema executado"
    pause
}

show_logs() {
    echo -e "\n${BLUE}════ ÚLTIMOS LOGS ════${NC}\n"
    
    if [ -f "$LOG_FILE" ]; then
        tail -20 "$LOG_FILE"
    else
        echo "Nenhum log disponível"
    fi
    
    echo ""
    pause
}

# ============================================================================
# MENU
# ============================================================================

show_menu() {
    echo -e "\n${BLUE}════ MENU PRINCIPAL ════${NC}\n"
    
    echo -e "${MAGENTA}GIT MONITOR:${NC}"
    echo -e "  ${CYAN}1${NC}) Status do Repositório"
    echo -e "  ${CYAN}2${NC}) Monitorar Mudanças"
    echo ""
    
    echo -e "${MAGENTA}FREE FIRE:${NC}"
    echo -e "  ${CYAN}3${NC}) Selecionar Modo (Normal/Max)"
    echo -e "  ${CYAN}4${NC}) Debug WiFi"
    echo -e "  ${CYAN}5${NC}) Monitor Performance"
    echo ""
    
    echo -e "${MAGENTA}SISTEMA:${NC}"
    echo -e "  ${CYAN}6${NC}) Debug do Sistema"
    echo -e "  ${CYAN}7${NC}) Ver Logs"
    echo -e "  ${CYAN}0${NC}) Sair"
    echo ""
    
    read -rp "$(echo -e "${YELLOW}Escolha:${NC} ")" choice
}

main_loop() {
    while true; do
        show_menu
        
        case $choice in
            1) git_status ;;
            2)
                trap 'echo ""; info "Monitoramento parado"; echo ""' INT
                monitor_changes
                trap - INT
                ;;
            3) select_game ;;
            4) debug_ff_wifi ;;
            5) monitor_ff_performance ;;
            6) debug_system ;;
            7) show_logs ;;
            0)
                success "Até logo!"
                log "Programa finalizado"
                exit 0
                ;;
            *)
                error "Opção inválida"
                sleep 1
                ;;
        esac
    done
}

# ============================================================================
# MAIN
# ============================================================================

banner
sleep 2

validate_repo
initial_checks

main_loop
