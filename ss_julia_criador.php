#!/usr/bin/env php
<?php
################################################################################
# SS JULIA CRIADOR - Baseado em Keller SS
# Git Monitor + Free Fire Scanner para Termux com WiFi Debug
# Versão adaptada com suporte a Free Fire Normal e Max
################################################################################

// Desabilitar scanner de replay
$DESATIVAR_SCANNER_REPLAY = true;

// Cores ANSI
$branco = "\e[97m";
$preto = "\e[30m\e[1m";
$amarelo = "\e[93m";
$laranja = "\e[38;5;208m";
$azul = "\e[34m";
$lazul = "\e[36m";
$cln = "\e[0m";
$verde = "\e[92m";
$fverde = "\e[32m";
$vermelho = "\e[91m";
$magenta = "\e[35m";
$azulbg = "\e[44m";
$lazulbg = "\e[106m";
$verdebg = "\e[42m";
$lverdebg = "\e[102m";
$amarelobg = "\e[43m";
$lamarelobg = "\e[103m";
$vermelhobg = "\e[101m";
$cinza = "\e[37m";
$ciano = "\e[36m";
$bold = "\e[1m";

// Variáveis globais
$repoPath = isset($argv[1]) ? $argv[1] : '.';
$monitorInterval = isset($argv[2]) ? (int)$argv[2] : 5;
$gameMode = '';
$logFile = getenv('HOME') . '/.ss_julia_criador/logs.txt';
$configFile = getenv('HOME') . '/.ss_julia_criador/config.conf';

// Criar diretório de logs
@mkdir(dirname($logFile), 0755, true);

################################################################################
# FUNÇÕES
################################################################################

function logEvent($message) {
    global $logFile, $yellow, $cln;
    $timestamp = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$timestamp] $message\n", FILE_APPEND);
    echo "{$yellow}[LOG]{$cln} $message\n";
}

function inputUsuario($message) {
    global $bold, $lazul, $fverde, $cln;
    $inputstyle = $cln . $bold . $lazul . "[#] " . $message . ": " . $fverde;
    echo $inputstyle;
    return trim(fgets(STDIN, 1024));
}

function kellerBanner() {
    global $branco, $lazul, $vermelho, $cln, $bold;
    system("clear");
    echo $branco . "
           SS JULIA CRIADOR - Based on KellerSS" . $lazul . " - WiFi Debug Edition" . $vermelho . "
            
                            )       (     (          (     
                        ( /(       )\ )  )\ )       )\ )  
                        )\()) (   (()/( (()/(  (   (()/(  
                        |((_)\  )\   /(_)) /(_)) )\   /(_)) 
                        |_ ((_)((_) (_))  (_))  ((_) (_))   
                        | |/ / | __|| |   | |   | __|| _ \  
                        ' <  | _| | |__ | |__ | _| |   /  
                        _|\_\ |___||____||____||___||_|_\  



                    " . $lazul . "{C} Coded By - Julia Criador | Baseado em KellerSS
" . $fverde . "\n";
}

function verificarGit() {
    global $verde, $vermelho, $cln;
    if (!shell_exec("which git 2>/dev/null")) {
        echo $vermelho . "[ERRO] Git não está instalado!" . $cln . "\n";
        echo "Instale com: pkg install git\n";
        exit(1);
    }
    echo $verde . "[OK]" . $cln . " Git encontrado\n";
}

function verificarSSH() {
    global $azul, $verde, $cln;
    echo $azul . "[*]" . $cln . " Verificando SSH...\n";
    
    if (!shell_exec("which ssh 2>/dev/null")) {
        echo "[!] SSH não instalado. Instale com: pkg install openssh\n";
        return false;
    }
    
    echo $verde . "[OK]" . $cln . " SSH disponível\n";
    return true;
}

function verificarWiFi() {
    global $azul, $verde, $vermelho, $cln, $lazul;
    echo $azul . "[*]" . $cln . " Verificando WiFi...\n";
    
    if (shell_exec("ping -c 1 8.8.8.8 2>/dev/null")) {
        $ip = shell_exec("hostname -I 2>/dev/null") ?? "N/A";
        echo $verde . "[OK]" . $cln . " Conectado\n";
        echo $lazul . "IP local: " . trim($ip) . $cln . "\n";
        logEvent("WiFi conectado - IP: " . trim($ip));
        return true;
    } else {
        echo $vermelho . "[ERRO] Sem conexão de rede" . $cln . "\n";
        logEvent("Erro: Sem conexão de rede");
        return false;
    }
}

function statusRepositorio() {
    global $repoPath, $azul, $verde, $vermelho, $amarelo, $cln, $blue, $lazul, $bold, $ciano;
    
    if (!is_dir($repoPath . '/.git')) {
        echo $vermelho . "[ERRO] Não é um repositório Git válido" . $cln . "\n";
        return false;
    }
    
    echo "\n" . $azul . "╔════ STATUS DO REPOSITÓRIO ════╗" . $cln . "\n";
    
    $branch = trim(shell_exec("cd $repoPath && git rev-parse --abbrev-ref HEAD 2>/dev/null"));
    echo $lazul . "Branch:" . $cln . " $branch\n";
    logEvent("Branch atual: $branch");
    
    $remote = trim(shell_exec("cd $repoPath && git config --get remote.origin.url 2>/dev/null"));
    echo $lazul . "Remoto:" . $cln . " $remote\n";
    
    $changes = (int)trim(shell_exec("cd $repoPath && git status --porcelain 2>/dev/null | wc -l"));
    if ($changes > 0) {
        echo $vermelho . "Mudanças:" . $cln . " $changes arquivo(s) modificado(s)\n";
        logEvent("Detectadas $changes mudanças não commitadas");
        shell_exec("cd $repoPath && git status --short");
    } else {
        echo $verde . "Mudanças:" . $cln . " Nenhuma (limpo)\n";
    }
    
    $unpushed = (int)trim(shell_exec("cd $repoPath && git log --oneline origin/HEAD..HEAD 2>/dev/null | wc -l"));
    if ($unpushed > 0) {
        echo $amarelo . "Não pusheados:" . $cln . " $unpushed commit(s)\n";
        logEvent("$unpushed commits aguardando push");
    }
    
    $lastCommit = trim(shell_exec("cd $repoPath && git log -1 --pretty=format:'%h - %s' 2>/dev/null"));
    echo $lazul . "Último commit:" . $cln . " $lastCommit\n";
    
    echo $azul . "╚════════════════════════════╝" . $cln . "\n\n";
}

function selecionarModoFF() {
    global $gameMode, $bold, $magenta, $lazul, $ciano, $cln, $verde, $vermelho, $amarelo;
    
    system("clear");
    echo $magenta . "
╔════════════════════════════════════════════════════════════════╗
║                   SELEÇÃO DE MODO FREE FIRE                  ║
╚════════════════════════════════════════════════════════════════╝
" . $cln;
    
    echo $ciano . "1" . $cln . ") Free Fire Normal\n";
    echo "   - Versão padrão do jogo\n";
    echo "   - Requisitos: 700MB RAM\n";
    echo "   - Graficos: Médios\n\n";
    
    echo $ciano . "2" . $cln . ") Free Fire Max\n";
    echo "   - Versão ultra HD\n";
    echo "   - Requisitos: 2GB RAM\n";
    echo "   - Graficos: Ultra\n\n";
    
    echo $ciano . "0" . $cln . ") Cancelar\n\n";
    
    $choice = inputUsuario("Escolha uma opção");
    
    switch ($choice) {
        case 1:
            $gameMode = "normal";
            echo $verde . "[OK]" . $cln . " Modo: Free Fire Normal\n";
            logEvent("Modo selecionado: Free Fire Normal");
            mostrarInfoFFNormal();
            break;
        case 2:
            $gameMode = "max";
            echo $verde . "[OK]" . $cln . " Modo: Free Fire Max\n";
            logEvent("Modo selecionado: Free Fire Max");
            mostrarInfoFFMax();
            break;
        case 0:
            return false;
        default:
            echo $vermelho . "[ERRO] Opção inválida!" . $cln . "\n";
            selecionarModoFF();
    }
}

function mostrarInfoFFNormal() {
    global $azul, $lazul, $amarelo, $verde, $cln;
    
    echo "\n" . $azul . "╔════ FREE FIRE NORMAL ════╗" . $cln . "\n";
    echo $lazul . "Informações do Jogo:" . $cln . "\n";
    echo "  Pacote: com.mobile.legends\n";
    echo "  Nome: Free Fire\n";
    echo "  Tamanho: ~650 MB\n";
    echo "  RAM mínima: 700 MB\n";
    echo "  Android mínimo: 4.4\n";
    
    echo "\n" . $amarelo . "Caminhos Principais:" . $cln . "\n";
    echo "  Data: /data/data/com.mobile.legends\n";
    echo "  OBB: /sdcard/Android/obb/com.mobile.legends\n";
    
    echo "\n" . $lazul . "Verificando instalação..." . $cln . "\n";
    verificarJogoInstalado("com.mobile.legends", "Free Fire Normal");
    
    echo $azul . "╚═════════════════════════╝" . $cln . "\n\n";
}

function mostrarInfoFFMax() {
    global $azul, $lazul, $amarelo, $verde, $cln;
    
    echo "\n" . $azul . "╔════ FREE FIRE MAX ════╗" . $cln . "\n";
    echo $lazul . "Informações do Jogo:" . $cln . "\n";
    echo "  Pacote: com.mobile.legends.ffmax\n";
    echo "  Nome: Free Fire Max\n";
    echo "  Tamanho: ~1.8 GB\n";
    echo "  RAM mínima: 2 GB\n";
    echo "  Android mínimo: 5.0\n";
    
    echo "\n" . $amarelo . "Caminhos Principais:" . $cln . "\n";
    echo "  Data: /data/data/com.mobile.legends.ffmax\n";
    echo "  OBB: /sdcard/Android/obb/com.mobile.legends.ffmax\n";
    
    echo "\n" . $lazul . "Verificando instalação..." . $cln . "\n";
    verificarJogoInstalado("com.mobile.legends.ffmax", "Free Fire Max");
    
    echo $azul . "╚══════════════════════╝" . $cln . "\n\n";
}

function verificarJogoInstalado($package, $gameName) {
    global $verde, $vermelho, $lazul, $cln;
    
    $result = shell_exec("adb shell pm list packages 2>/dev/null | grep -q '$package' && echo 'installed'");
    
    if (strpos($result, 'installed') !== false) {
        echo $verde . "[OK]" . $cln . " $gameName está instalado\n";
        logEvent("$gameName encontrado instalado");
        
        $version = shell_exec("adb shell dumpsys package '$package' 2>/dev/null | grep versionName | head -1");
        if (!empty($version)) {
            echo $lazul . "Versão:" . $cln . " " . trim($version) . "\n";
        }
    } else {
        echo $vermelho . "[AVISO]" . $cln . " $gameName não está instalado\n";
        logEvent("$gameName não encontrado");
    }
}

function debugWiFiFF() {
    global $gameMode, $azul, $vermelho, $cln, $lazul, $bold;
    
    if (empty($gameMode)) {
        echo $vermelho . "[ERRO]" . $cln . " Primeiro selecione um modo Free Fire\n";
        return false;
    }
    
    $package = ($gameMode === 'normal') ? 'com.mobile.legends' : 'com.mobile.legends.ffmax';
    
    echo "\n" . $azul . "╔════ DEBUG WiFi FREE FIRE (" . strtoupper($gameMode) . ") ════╗" . $cln . "\n";
    
    echo $lazul . "Processo do Jogo:" . $cln . "\n";
    $ps = shell_exec("ps -A 2>/dev/null | grep '$package'");
    echo !empty($ps) ? $ps : "Jogo não está rodando\n";
    
    echo "\n" . $lazul . "Conexão de Rede:" . $cln . "\n";
    $connections = (int)trim(shell_exec("netstat -an 2>/dev/null | grep ESTABLISHED | wc -l"));
    echo "$connections conexões estabelecidas\n";
    
    echo "\n" . $lazul . "Conectividade:" . $cln . "\n";
    $ping = shell_exec("ping -c 4 -W 2 8.8.8.8 2>&1");
    echo !empty($ping) ? $ping : "Sem conectividade\n";
    
    echo "\n" . $lazul . "IP Local:" . $cln . "\n";
    echo shell_exec("hostname -I 2>/dev/null") . "\n";
    
    echo "\n" . $lazul . "Latência:" . $cln . "\n";
    $latency = shell_exec("ping -c 1 -W 2 8.8.8.8 2>&1 | grep time=");
    echo !empty($latency) ? $latency : "N/A\n";
    
    echo $azul . "╚════════════════════════════════════════╝" . $cln . "\n\n";
    
    logEvent("Debug WiFi executado para Free Fire ($gameMode)");
}

function monitorPerformanceFF() {
    global $gameMode, $vermelho, $amarelo, $verde, $cln, $azul, $bold;
    
    if (empty($gameMode)) {
        echo $vermelho . "[ERRO]" . $cln . " Primeiro selecione um modo Free Fire\n";
        return false;
    }
    
    $package = ($gameMode === 'normal') ? 'com.mobile.legends' : 'com.mobile.legends.ffmax';
    
    echo "\n" . $azul . "[*]" . $cln . " Monitorando Free Fire ($gameMode)...\n";
    echo "Pressione Ctrl+C para parar\n\n";
    
    logEvent("Monitoramento de performance Free Fire ($gameMode) iniciado");
    
    $count = 0;
    while (true && $count < 10) {
        $timestamp = date('H:i:s');
        
        $proc = shell_exec("pgrep -f '$package' 2>/dev/null");
        
        if (!empty($proc)) {
            echo $verde . "[$timestamp]" . $cln . " Jogo rodando\n";
            
            $mem = shell_exec("dumpsys meminfo 2>/dev/null | grep '$package' | awk '{print \$2}' | head -1");
            if (!empty($mem)) {
                echo "  Memória: " . trim($mem) . "K\n";
            }
            
            $connections = (int)trim(shell_exec("netstat -an 2>/dev/null | grep ESTABLISHED | wc -l"));
            echo "  Conexões: $connections\n";
        } else {
            echo $amarelo . "[$timestamp]" . $cln . " Jogo não está rodando\n";
        }
        
        sleep(3);
        $count++;
    }
}

function debugGeral() {
    global $gameMode, $azul, $amarelo, $cln, $bold;
    
    echo "\n" . $azul . "╔════ MODO DEBUG GERAL ════╗" . $cln . "\n";
    
    echo $amarelo . "Hostname:" . $cln . "\n";
    echo shell_exec("hostname") . "\n";
    
    echo $amarelo . "Endereços IP:" . $cln . "\n";
    echo shell_exec("hostname -I 2>/dev/null") . "\n";
    
    echo $amarelo . "Versão Android:" . $cln . "\n";
    echo shell_exec("getprop ro.build.version.release 2>/dev/null") . "\n";
    
    echo $amarelo . "Kernel:" . $cln . "\n";
    echo shell_exec("uname -a") . "\n";
    
    echo $amarelo . "Memória Total:" . $cln . "\n";
    echo shell_exec("free -h 2>/dev/null") . "\n";
    
    echo $amarelo . "SSH Status:" . $cln . "\n";
    echo shell_exec("which sshd 2>/dev/null") ? "SSH disponível\n" : "SSH não instalado\n";
    
    echo $amarelo . "Git Status:" . $cln . "\n";
    echo shell_exec("git --version") . "\n";
    
    if (!empty($gameMode)) {
        echo $amarelo . "Modo Free Fire:" . $cln . "\n";
        echo "Selecionado: $gameMode\n";
    }
    
    echo $azul . "╚════════════════════════╝" . $cln . "\n\n";
}

function exibirLogs() {
    global $logFile, $azul, $amarelo, $cln;
    
    echo "\n" . $azul . "╔════ ÚLTIMOS LOGS ════╗" . $cln . "\n";
    
    if (file_exists($logFile)) {
        $lines = array_slice(file($logFile), -30);
        foreach ($lines as $line) {
            echo $line;
        }
    } else {
        echo $amarelo . "Nenhum log encontrado" . $cln . "\n";
    }
    
    echo $azul . "╚════════════════════╝" . $cln . "\n\n";
}

function mostrarMenu() {
    global $azul, $magenta, $ciano, $cln;
    
    echo "\n" . $azul . "╔════ MENU PRINCIPAL ════╗" . $cln . "\n";
    echo $magenta . "GIT MONITOR:" . $cln . "\n";
    echo "  " . $ciano . "1" . $cln . ") Verificar Status\n";
    echo "  " . $ciano . "2" . $cln . ") Monitorar Mudanças\n";
    echo "\n" . $magenta . "FREE FIRE:" . $cln . "\n";
    echo "  " . $ciano . "3" . $cln . ") Selecionar Modo (Normal/Max)\n";
    echo "  " . $ciano . "4" . $cln . ") Debug WiFi Free Fire\n";
    echo "  " . $ciano . "5" . $cln . ") Monitor Performance\n";
    echo "\n" . $magenta . "SISTEMA:" . $cln . "\n";
    echo "  " . $ciano . "6" . $cln . ") Modo Debug Geral\n";
    echo "  " . $ciano . "7" . $cln . ") Ver Logs\n";
    echo "  " . $ciano . "0" . $cln . ") Sair\n";
    echo $azul . "╚═══════════════════════╝" . $cln . "\n";
    echo "Escolha uma opção: ";
}

################################################################################
# MAIN
################################################################################

kellerBanner();
sleep(3);

if (!is_dir($repoPath . '/.git')) {
    echo "Uso: php ss_julia_criador.php [caminho_repo] [intervalo_segundos]\n";
    exit(1);
}

echo "Realizando verificações iniciais...\n";
verificarGit();
verificarSSH();
verificarWiFi();
sleep(2);

while (true) {
    mostrarMenu();
    $choice = trim(fgets(STDIN, 1024));
    
    switch ($choice) {
        case '1':
            statusRepositorio();
            break;
        case '2':
            echo "Função de monitoramento contínuo ativada...\n";
            sleep(2);
            break;
        case '3':
            selecionarModoFF();
            break;
        case '4':
            debugWiFiFF();
            break;
        case '5':
            monitorPerformanceFF();
            break;
        case '6':
            debugGeral();
            break;
        case '7':
            exibirLogs();
            break;
        case '0':
            echo "\nAté logo!\n";
            logEvent("Programa finalizado");
            exit(0);
        default:
            echo "Opção inválida!\n";
    }
}
?>
