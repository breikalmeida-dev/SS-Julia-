#!/bin/bash

################################################################################
# SS JULIA CRIADOR - Git Monitor para Termux com WiFi Debug
# Verifica modificações e etc conectando pela depuração wifi do celular
# Com suporte para Free Fire Normal e Max
################################################################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configurações
REPO_PATH="${1:-.}"
MONITOR_INTERVAL="${2:-5}"
LOG_FILE="$HOME/.ss_julia_criador/logs.txt"
CONFIG_FILE="$HOME/.ss_julia_criador/config.conf"
GAME_MODE="" # normal ou max

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
║           WiFi Debug + Free Fire (Normal/Max)                 ║
║                                                                ║
║  Monitora modificações, commits e mudanças em repositórios    ║
║  Com suporte para debug de Free Fire                          ║
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
# Função: Menu de Seleção Free Fire
################################################################################
select_game_mode() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              SELEÇÃO DE MODO FREE FIRE                        ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}1${NC}) Free Fire Normal"
    echo -e "   - Versão padrão do jogo"
    echo -e "   - Requisitos: 700MB RAM"
    echo -e "   - Graficos: Médios"
    echo ""
    
    echo -e "${CYAN}2${NC}) Free Fire Max"
    echo -e "   - Versão ultra HD"
    echo -e "   - Requisitos: 2GB RAM"
    echo -e "   - Graficos: Ultra"
    echo ""
    
    echo -e "${CYAN}0${NC}) Cancelar"
    echo ""
    echo -n -e "${YELLOW}Escolha uma opção:${NC} "
    read -r game_choice
    
    case $game_choice in
        1)
            GAME_MODE="normal"
            echo -e "${GREEN}[OK]${NC} Modo selecionado: Free Fire Normal"
            log_event "Modo selecionado: Free Fire Normal"
            show_ff_normal_info
            ;;
        2)
            GAME_MODE="max"
            echo -e "${GREEN}[OK]${NC} Modo selecionado: Free Fire Max"
            log_event "Modo selecionado: Free Fire Max"
            show_ff_max_info
            ;;
        0)
            return 1
            ;;
        *)
            echo -e "${RED}[ERRO]${NC} Opção inválida!"
            select_game_mode
            ;;
    esac
}

################################################################################
# Função: Informações Free Fire Normal
################################################################################
show_ff_normal_info() {
    echo -e "\n${BLUE}╔════ FREE FIRE NORMAL ════╗${NC}"
    echo -e "${CYAN}Informações do Jogo:${NC}"
    echo -e "  Pacote: com.mobile.legends"
    echo -e "  Nome: Free Fire"
    echo -e "  Tamanho: ~650 MB"
    echo -e "  RAM mínima: 700 MB"
    echo -e "  Android mínimo: 4.4"
    
    echo -e "\n${YELLOW}Caminhos Principais:${NC}"
    echo -e "  Data: /data/data/com.mobile.legends"
    echo -e "  OBB: /sdcard/Android/obb/com.mobile.legends"
    
    echo -e "\n${CYAN}Verificando instalação...${NC}"
    check_game_installed "com.mobile.legends" "Free Fire Normal"
    
    echo -e "${BLUE}╚═════════════════════════╝${NC}\n"
}

################################################################################
# Função: Informações Free Fire Max
################################################################################
show_ff_max_info() {
    echo -e "\n${BLUE}╔════ FREE FIRE MAX ════╗${NC}"
    echo -e "${CYAN}Informações do Jogo:${NC}"
    echo -e "  Pacote: com.mobile.legends.ffmax"
    echo -e "  Nome: Free Fire Max"
    echo -e "  Tamanho: ~1.8 GB"
    echo -e "  RAM mínima: 2 GB"
    echo -e "  Android mínimo: 5.0"
    
    echo -e "\n${YELLOW}Caminhos Principais:${NC}"
    echo -e "  Data: /data/data/com.mobile.legends.ffmax"
    echo -e "  OBB: /sdcard/Android/obb/com.mobile.legends.ffmax"
    
    echo -e "\n${CYAN}Verificando instalação...${NC}"
    check_game_installed "com.mobile.legends.ffmax" "Free Fire Max"
    
    echo -e "${BLUE}╚══════════════════════╝${NC}\n"
}

################################################################################
# Função: Verificar se Jogo está Instalado
################################################################################
check_game_installed() {
    local package="$1"
    local game_name="$2"
    
    if command -v pm &> /dev/null; then
        if pm list packages | grep -q "$package"; then
            echo -e "${GREEN}[OK]${NC} $game_name está instalado"
            log_event "$game_name encontrado instalado"
            
            # Obter versão
            local version=$(pm dump "$package" 2>/dev/null | grep versionName | head -1 | cut -d'=' -f2)
            if [ -n "$version" ]; then
                echo -e "${CYAN}Versão:${NC} $version"
            fi
        else
            echo -e "${RED}[AVISO]${NC} $game_name não está instalado"
            log_event "$game_name não encontrado"
        fi
    fi
}

################################################################################
# Função: Debug WiFi Free Fire
################################################################################
debug_ff_wifi() {
    if [ -z "$GAME_MODE" ]; then
        echo -e "${RED}[ERRO]${NC} Primeiro selecione um modo Free Fire"
        return 1
    fi
    
    echo -e "\n${BLUE}╔════ DEBUG WiFi FREE FIRE (${GAME_MODE^^}) ════╗${NC}"
    
    # Definir package baseado no modo
    local package
    if [ "$GAME_MODE" = "normal" ]; then
        package="com.mobile.legends"
    else
        package="com.mobile.legends.ffmax"
    fi
    
    echo -e "${CYAN}Processo do Jogo:${NC}"
    if command -v ps &> /dev/null; then
        ps -A | grep "$package" || echo "Jogo não está rodando"
    fi
    
    echo -e "\n${CYAN}Conexão de Rede:${NC}"
    if command -v netstat &> /dev/null; then
        netstat -an | grep ESTABLISHED | wc -l
        echo "conexões estabelecidas"
    fi
    
    echo -e "\n${CYAN}Verificar conectividade:${NC}"
    ping -c 4 -W 2 8.8.8.8 || echo "Sem conectividade"
    
    echo -e "\n${CYAN}IP Local:${NC}"
    hostname -I
    
    echo -e "\n${CYAN}Latência estimada (ping):${NC}"
    ping -c 1 -W 2 8.8.8.8 | grep time= || echo "N/A"
    
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
    
    log_event "Debug WiFi executado para Free Fire ($GAME_MODE)"
}

################################################################################
# Função: Monitor de Performance Free Fire
################################################################################
monitor_ff_performance() {
    if [ -z "$GAME_MODE" ]; then
        echo -e "${RED}[ERRO]${NC} Primeiro selecione um modo Free Fire"
        return 1
    fi
    
    local package
    if [ "$GAME_MODE" = "normal" ]; then
        package="com.mobile.legends"
    else
        package="com.mobile.legends.ffmax"
    fi
    
    echo -e "\n${BLUE}[*]${NC} Monitorando Free Fire ($GAME_MODE)..."
    echo -e "${YELLOW}Pressione Ctrl+C para parar${NC}\n"
    
    log_event "Monitoramento de performance Free Fire ($GAME_MODE) iniciado"
    
    while true; do
        local timestamp=$(date '+%H:%M:%S')
        
        # Verificar se o jogo está rodando
        if command -v pgrep &> /dev/null && pgrep -f "$package" > /dev/null; then
            echo -e "${GREEN}[${timestamp}]${NC} Jogo rodando"
            
            # Tentar obter uso de memória se disponível
            if command -v dumpsys &> /dev/null; then
                local mem=$(dumpsys meminfo | grep "$package" | awk '{print $2}' | head -1)
                if [ -n "$mem" ]; then
                    echo -e "  Memória: ${mem}K"
                fi
            fi
            
            # Verificar conexão
            local connections=$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
            echo -e "  Conexões: $connections"
            
        else
            echo -e "${YELLOW}[${timestamp}]${NC} Jogo não está rodando"
        fi
        
        sleep 3
    done
}

################################################################################
# Função: Modo Debug Geral
################################################################################
debug_mode() {
    echo -e "\n${BLUE}╔════ MODO DEBUG GERAL ════╗${NC}"
    echo -e "${CYAN}Informações do Sistema:${NC}"
    
    echo -e "\n${YELLOW}Hostname:${NC}"
    hostname
    
    echo -e "\n${YELLOW}Endereços IP:${NC}"
    hostname -I
    
    echo -e "\n${YELLOW}Versão Android:${NC}"
    getprop ro.build.version.release 2>/dev/null || echo "N/A"
    
    echo -e "\n${YELLOW}Kernel:${NC}"
    uname -a
    
    echo -e "\n${YELLOW}Memória Total:${NC}"
    free -h 2>/dev/null || echo "N/A"
    
    echo -e "\n${YELLOW}SSH Status:${NC}"
    if command -v sshd &> /dev/null; then
        echo "SSH disponível"
    else
        echo "SSH não instalado"
    fi
    
    echo -e "\n${YELLOW}Git Status:${NC}"
    git --version
    
    if [ -n "$GAME_MODE" ]; then
        echo -e "\n${YELLOW}Modo Free Fire:${NC}"
        echo "Selecionado: $GAME_MODE"
    fi
    
    echo -e "\n${BLUE}╚════════════════════════╝${NC}\n"
}

################################################################################
# Função: Exibir Logs
################################################################################
show_logs() {
    echo -e "\n${BLUE}╔════ ÚLTIMOS LOGS ════╗${NC}"
    if [ -f "$LOG_FILE" ]; then
        tail -30 "$LOG_FILE"
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
    echo -e "${CYAN}GIT MONITOR:${NC}"
    echo -e "  ${CYAN}1${NC}) Verificar Status"
    echo -e "  ${CYAN}2${NC}) Monitorar Mudanças"
    echo ""
    echo -e "${MAGENTA}FREE FIRE:${NC}"
    echo -e "  ${CYAN}3${NC}) Selecionar Modo (Normal/Max)"
    echo -e "  ${CYAN}4${NC}) Debug WiFi Free Fire"
    echo -e "  ${CYAN}5${NC}) Monitor Performance"
    echo ""
    echo -e "${CYAN}SISTEMA:${NC}"
    echo -e "  ${CYAN}6${NC}) Modo Debug Geral"
    echo -e "  ${CYAN}7${NC}) Ver Logs"
    echo -e "  ${CYAN}8${NC}) Configurações"
    echo -e "  ${CYAN}0${NC}) Sair"
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
    
    echo -e "\n${CYAN}Modo Free Fire:${NC}"
    if [ -z "$GAME_MODE" ]; then
        echo "  Nenhum selecionado"
    else
        echo "  $GAME_MODE"
    fi
    
    echo -e "\n${CYAN}Arquivo de log:${NC}"
    echo "  $LOG_FILE"
    
    echo -e "\n${CYAN}Editar intervalo? (s/n):${NC} "
    read -r edit_interval
    if [[ "$edit_interval" == "s" ]] || [[ "$edit_interval" == "S" ]]; then
        echo -n "Novo intervalo (segundos): "
        read -r new_interval
        MONITOR_INTERVAL="$new_interval"
        echo -e "${GREEN}[OK]${NC} Intervalo atualizado para ${MONITOR_INTERVAL}s"
        log_event "Intervalo de monitoramento alterado para $MONITOR_INTERVAL segundos"
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
                select_game_mode
                ;;
            4)
                debug_ff_wifi
                ;;
            5)
                monitor_ff_performance
                ;;
            6)
                debug_mode
                ;;
            7)
                show_logs
                ;;
            8)
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
