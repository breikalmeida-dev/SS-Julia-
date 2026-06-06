#!/bin/bash

################################################################################
# SS JULIA CRIADOR - Git Monitor para Termux com WiFi Debug
# Verifica modificações e etc via conexão WiFi
# Desenvolvido para Android Termux
################################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
REPO_PATH="${1:-.}"
MONITOR_INTERVAL="${2:-5}"
LOG_FILE="$HOME/.ss_julia_criador/logs.txt"
CONFIG_FILE="$HOME/.ss_julia_criador/config.conf"

# Criar diretório de logs se não existir
mkdir -p "$HOME/.ss_julia_criador"

################################################################################
# Função: Exibir Banner
################################################################################
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           SS JULIA CRIADOR - Git Monitor Termux               ║
║           WiFi Debug Connection Monitor                        ║
║                                                                ║
║  Monitora modificações, commits e mudanças em repositórios    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

################################################################################
# Função: Log de eventos
################################################################################
log_event() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${message}" >> "$LOG_FILE"
    echo -e "${YELLOW}[LOG]${NC} ${message}"
}

################################################################################
# Função: Verificar Git
################################################################################
check_git_installed() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}[ERRO]${NC} Git não está instalado!"
        echo -e "${CYAN}Instale com: pkg install git${NC}"
        exit 1
    fi
    echo -e "${GREEN}[OK]${NC} Git encontrado"
}

################################################################################
# Função: Verificar SSH
################################################################################
check_ssh_connection() {
    echo -e "${BLUE}[*]${NC} Verificando conexão SSH..."
    
    if ! command -v ssh &> /dev/null; then
        echo -e "${RED}[ERRO]${NC} SSH não está instalado!"
        echo -e "${CYAN}Instale com: pkg install openssh${NC}"
        return 1
    fi
    
    echo -e "${GREEN}[OK]${NC} SSH disponível"
    return 0
}

################################################################################
# Função: Verificar Conexão WiFi
################################################################################
check_wifi_connection() {
    echo -e "${BLUE}[*]${NC} Verificando conexão WiFi..."
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        local ip=$(hostname -I 2>/dev/null || echo "N/A")
        echo -e "${GREEN}[OK]${NC} Conectado à rede"
        echo -e "${CYAN}IP local: ${ip}${NC}"
        log_event "WiFi conectado - IP: $ip"
        return 0
    else
        echo -e "${RED}[ERRO]${NC} Sem conexão de rede"
        log_event "Erro: Sem conexão de rede"
        return 1
    fi
}

################################################################################
# Função: Verificar Status do Repositório
################################################################################
check_repo_status() {
    if [ ! -d "$REPO_PATH/.git" ]; then
        echo -e "${RED}[ERRO]${NC} Não é um repositório Git válido: $REPO_PATH"
        return 1
    fi
    
    cd "$REPO_PATH" || return 1
    
    echo -e "\n${BLUE}╔════ STATUS DO REPOSITÓRIO ════╗${NC}"
    
    # Branch atual
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    echo -e "${CYAN}Branch:${NC} ${current_branch}"
    log_event "Branch atual: $current_branch"
    
    # Remote
    local remote=$(git config --get remote.origin.url 2>/dev/null)
    echo -e "${CYAN}Remoto:${NC} ${remote}"
    
    # Mudanças não commitadas
    local changes=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$changes" -gt 0 ]; then
        echo -e "${RED}Mudanças:${NC} ${changes} arquivo(s) modificado(s)"
        log_event "Detectadas $changes mudanças não commitadas"
        git status --short
    else
        echo -e "${GREEN}Mudanças:${NC} Nenhuma (limpo)"
    fi
    
    # Commits não pusheados
    local unpushed=$(git log --oneline origin/HEAD..HEAD 2>/dev/null | wc -l)
    if [ "$unpushed" -gt 0 ]; then
        echo -e "${YELLOW}Não pusheados:${NC} ${unpushed} commit(s)"
        log_event "$unpushed commits aguardando push"
    fi
    
    # Hash do último commit
    local last_commit=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null)
    echo -e "${CYAN}Último commit:${NC} ${last_commit}"
    
    echo -e "${BLUE}╚════════════════════════════╝${NC}\n"
}

################################################################################
# Função: Monitorar Mudanças em Tempo Real
################################################################################
monitor_changes() {
    echo -e "${BLUE}[*]${NC} Iniciando monitoramento (intervalo: ${MONITOR_INTERVAL}s)"
    echo -e "${YELLOW}Pressione Ctrl+C para parar${NC}\n"
    
    log_event "Monitoramento iniciado"
    
    local last_status=""
    local last_changes=""
    
    while true; do
        if [ ! -d "$REPO_PATH/.git" ]; then
            echo -e "${RED}[ERRO]${NC} Repositório não encontrado!"
            break
        fi
        
        cd "$REPO_PATH" || break
        
        # Verificar mudanças
        local current_status=$(git status --porcelain 2>/dev/null | md5sum)
        local current_changes=$(git status --porcelain 2>/dev/null | wc -l)
        
        if [ "$current_status" != "$last_status" ]; then
            local timestamp=$(date '+%H:%M:%S')
            
            if [ "$current_changes" -gt 0 ]; then
                echo -e "${RED}[${timestamp}] ⚠ Mudanças detectadas! (${current_changes} arquivo(s))${NC}"
                git status --short
                log_event "Mudanças detectadas: $current_changes arquivo(s)"
            else
                echo -e "${GREEN}[${timestamp}] ✓ Repositório limpo${NC}"
                log_event "Repositório sincronizado"
            fi
            
            last_status="$current_status"
            last_changes="$current_changes"
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}

################################################################################
# Função: Modo Debug WiFi
################################################################################
debug_mode() {
    echo -e "\n${BLUE}╔════ MODO DEBUG ════╗${NC}"
    echo -e "${CYAN}Informações do Sistema:${NC}"
    
    echo -e "\n${YELLOW}Hostname:${NC}"
    hostname
    
    echo -e "\n${YELLOW}Endereços IP:${NC}"
    hostname -I
    
    echo -e "\n${YELLOW}Versão Android (getprop):${NC}"
    getprop ro.build.version.release 2>/dev/null || echo "N/A"
    
    echo -e "\n${YELLOW}Kernel:${NC}"
    uname -a
    
    echo -e "\n${YELLOW}SSH Status:${NC}"
    if command -v sshd &> /dev/null; then
        echo "SSH disponível"
    else
        echo "SSH não instalado"
    fi
    
    echo -e "\n${YELLOW}Git Status:${NC}"
    git --version
    
    echo -e "\n${BLUE}╚════════════════════╝${NC}\n"
}

################################################################################
# Função: Exibir Logs
################################################################################
show_logs() {
    echo -e "\n${BLUE}╔════ ÚLTIMOS LOGS ════╗${NC}"
    if [ -f "$LOG_FILE" ]; then
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}Nenhum log encontrado${NC}"
    fi
    echo -e "${BLUE}╚════════════════════╝${NC}\n"
}

################################################################################
# Função: Menu Interativo
################################################################################
show_menu() {
    echo -e "\n${BLUE}╔════ MENU PRINCIPAL ════╗${NC}"
    echo -e "${CYAN}1${NC}) Verificar Status"
    echo -e "${CYAN}2${NC}) Monitorar Mudanças"
    echo -e "${CYAN}3${NC}) Modo Debug"
    echo -e "${CYAN}4${NC}) Ver Logs"
    echo -e "${CYAN}5${NC}) Configurações"
    echo -e "${CYAN}0${NC}) Sair"
    echo -e "${BLUE}╚═══════════════════════╝${NC}"
    echo -n -e "${YELLOW}Escolha uma opção:${NC} "
}

################################################################################
# Função: Configurações
################################################################################
show_config() {
    echo -e "\n${BLUE}╔════ CONFIGURAÇÕES ════╗${NC}"
    
    echo -e "${CYAN}Caminho do repositório:${NC}"
    echo "  $REPO_PATH"
    
    echo -e "\n${CYAN}Intervalo de monitoramento:${NC}"
    echo "  ${MONITOR_INTERVAL}s"
    
    echo -e "\n${CYAN}Arquivo de log:${NC}"
    echo "  $LOG_FILE"
    
    echo -e "\n${CYAN}Editar intervalo? (s/n):${NC} "
    read -r edit_interval
    if [[ "$edit_interval" == "s" ]] || [[ "$edit_interval" == "S" ]]; then
        echo -n "Novo intervalo (segundos): "
        read -r new_interval
        MONITOR_INTERVAL="$new_interval"
        echo -e "${GREEN}[OK]${NC} Intervalo atualizado para ${MONITOR_INTERVAL}s"
    fi
    
    echo -e "${BLUE}╚════════════════════════╝${NC}\n"
}

################################################################################
# Função: Verificação Inicial
################################################################################
initial_checks() {
    echo -e "${BLUE}[*]${NC} Realizando verificações iniciais..."
    
    check_git_installed
    check_ssh_connection
    check_wifi_connection
    
    echo -e "${GREEN}[OK]${NC} Todas as verificações concluídas\n"
    log_event "Verificações iniciais completadas"
}

################################################################################
# Main - Programa Principal
################################################################################
main() {
    show_banner
    
    # Validar repositório
    if [ ! -d "$REPO_PATH/.git" ]; then
        echo -e "${RED}[ERRO]${NC} Caminho inválido ou não é um repositório Git"
        echo "Uso: $0 [caminho_repo] [intervalo_segundos]"
        echo "Exemplo: $0 . 5"
        exit 1
    fi
    
    initial_checks
    
    # Menu principal
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                check_repo_status
                ;;
            2)
                monitor_changes
                ;;
            3)
                debug_mode
                ;;
            4)
                show_logs
                ;;
            5)
                show_config
                ;;
            0)
                echo -e "${GREEN}Até logo!${NC}"
                log_event "Programa finalizado"
                exit 0
                ;;
            *)
                echo -e "${RED}Opção inválida!${NC}"
                ;;
        esac
    done
}

# Executar
main "$@"
