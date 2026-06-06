```markdown
# 📱 SS JULIA CRIADOR - GUIA COMPLETO DE INSTALAÇÃO E USO NO TERMUX

## ⚠️ PRÉ-REQUISITOS

- Termux instalado no seu Android
- Acesso root (opcional, mas recomendado)
- Conexão WiFi ativa
- Free Fire Normal ou Max instalado (para funções FF)

---

## 🔧 PASSO 1: INSTALAR DEPENDÊNCIAS

### 1.1 Abra o Termux e atualize pacotes:
```bash
pkg update
pkg upgrade
```

### 1.2 Instale os pacotes necessários:
```bash
pkg install git php openssh android-tools curl wget
```

**O que cada um faz:**
- `git` - Controle de versão
- `php` - Para executar o script
- `openssh` - Conexão SSH segura
- `android-tools` - ADB (depuração USB/WiFi)
- `curl` - Baixar arquivos
- `wget` - Download de URL

### 1.3 Verifique as instalações:
```bash
git --version
php --version
adb --version
ssh -V
```

---

## 📥 PASSO 2: CLONAR O REPOSITÓRIO

### 2.1 Escolha um diretório (exemplo: Documents)
```bash
cd ~
mkdir -p Documents
cd Documents
```

### 2.2 Clone o repositório:
```bash
git clone https://github.com/breikalmeida-dev/SS-Julia-.git
cd SS-Julia-
```

**Resultado esperado:**
```
Cloning into 'SS-Julia-'...
remote: Counting objects: X, done.
remote: Compressing objects: 100% (X/X), done.
Receiving objects: 100% (X/X), done.
```

### 2.3 Liste os arquivos:
```bash
ls -la
```

**Você deve ver:**
- `ss_julia_criador.php` ✅
- `ss_julia_criador.sh` (versão anterior)
- `README.md`

---

## ⚙️ PASSO 3: PREPARAR O SCRIPT

### 3.1 Dar permissão de execução:
```bash
chmod +x ss_julia_criador.php
chmod +x ss_julia_criador.sh
```

### 3.2 Verificar se está pronto:
```bash
file ss_julia_criador.php
```

**Resultado esperado:**
```
ss_julia_criador.php: PHP script, ASCII text executable
```

---

## 🎮 PASSO 4: CONECTAR ADB (WiFi DEBUG)

### 4.1 No seu Android (Celular):

**Para Free Fire Normal:**
1. Abra `Configurações` → `Sobre o Telefone`
2. Toque 7 vezes em `Número da Compilação`
3. Volte para Configurações → `Opções do Desenvolvedor`
4. Ative `Depuração via USB`
5. Ative `Depuração WiFi` (se houver)
6. Anote o IP: `192.168.x.x`

**Para Free Fire Max:**
- Mesmo processo acima

### 4.2 No Termux (Seu Computador/Termux):

```bash
# Inicie o servidor ADB
adb start-server

# Conecte via WiFi (coloque o IP do seu celular)
adb connect 192.168.X.X:5555
```

**Resultado esperado:**
```
* daemon not running; starting now at tcp:5037
* daemon started successfully
connected to 192.168.X.X:5555
```

### 4.3 Autorize no celular:
- Você receberá um aviso no seu celular
- Toque em "Autorizar" ou "Permitir"

### 4.4 Verifique a conexão:
```bash
adb devices
```

**Resultado esperado:**
```
List of attached devices
192.168.X.X:5555    device
```

---

## 🚀 PASSO 5: EXECUTAR O SCRIPT

### 5.1 Execução básica (repositório atual):
```bash
cd ~/Documents/SS-Julia-
php ss_julia_criador.php
```

### 5.2 Execução com caminho específico:
```bash
php ss_julia_criador.php /path/to/repo 5
```

### 5.3 Você verá o banner:
```
           SS JULIA CRIADOR - Based on KellerSS - WiFi Debug Edition
            
                            )       (     (          (     
                        ( /(       )\ )  )\ )       )\ )  
                        )\()) (   (()/( (()/(  (   (()/(  
                        |((_)\  )\   /(_)) /(_)) )\   /(_)) 
                        |_ ((_)((_) (_))  (_))  ((_) (_))   
                        | |/ / | __|| |   | |   | __|| _ \  
                        ' <  | _| | |__ | |__ | _| |   /  
                        _|\_\ |___||____||____||___||_|_\  

                    {C} Coded By - Julia Criador | Baseado em KellerSS
```

**Aguarde 3 segundos...**

---

## 📋 PASSO 6: USAR O MENU INTERATIVO

Após a tela inicial, você verá:

```
╔════ MENU PRINCIPAL ════╗
GIT MONITOR:
  1) Verificar Status
  2) Monitorar Mudanças

FREE FIRE:
  3) Selecionar Modo (Normal/Max)
  4) Debug WiFi Free Fire
  5) Monitor Performance

SISTEMA:
  6) Modo Debug Geral
  7) Ver Logs
  0) Sair
╚═══════════════════════╝
Escolha uma opção:
```

### 6.1 OPÇÃO 1 - Verificar Status Git:

```bash
Escolha uma opção: 1
```

**Resultado:**
```
╔════ STATUS DO REPOSITÓRIO ════╗
Branch: main
Remoto: https://github.com/breikalmeida-dev/SS-Julia-.git
Mudanças: Nenhuma (limpo)
Último commit: abc1234 - Recriar SS JULIA CRIADOR
╚════════════════════════════╝
```

### 6.2 OPÇÃO 3 - Selecionar Modo Free Fire:

```bash
Escolha uma opção: 3
```

**Você verá:**
```
╔════════════════════════════════════════════════════════════════╗
║                   SELEÇÃO DE MODO FREE FIRE                  ║
╚════════════════════════════════════════════════════════════════╝

1) Free Fire Normal
   - Versão padrão do jogo
   - Requisitos: 700MB RAM
   - Graficos: Médios

2) Free Fire Max
   - Versão ultra HD
   - Requisitos: 2GB RAM
   - Graficos: Ultra

0) Cancelar

Escolha uma opção: 
```

**Digite 1 ou 2:**
```bash
Escolha uma opção: 1
```

**Resultado:**
```
[OK] Modo: Free Fire Normal

╔════ FREE FIRE NORMAL ════╗
Informações do Jogo:
  Pacote: com.mobile.legends
  Nome: Free Fire
  Tamanho: ~650 MB
  RAM mínima: 700 MB
  Android mínimo: 4.4

Caminhos Principais:
  Data: /data/data/com.mobile.legends
  OBB: /sdcard/Android/obb/com.mobile.legends

Verificando instalação...
[OK] Free Fire Normal está instalado
Versão: 1.XX.XX
╚═════════════════════════╝
```

### 6.3 OPÇÃO 4 - Debug WiFi Free Fire:

```bash
Escolha uma opção: 4
```

**Resultado:**
```
╔════ DEBUG WiFi FREE FIRE (NORMAL) ════╗

Processo do Jogo:
u0_a123    1234   567 1234567890 123456 S com.mobile.legends

Conexão de Rede:
15 conexões estabelecidas

Conectividade:
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 time=25.3 ms

IP Local:
192.168.1.100

Latência:
64 bytes from 8.8.8.8: icmp_seq=1 time=25.3 ms

╚════════════════════════════════════════╝
```

### 6.4 OPÇÃO 5 - Monitor de Performance:

```bash
Escolha uma opção: 5
```

**Resultado (monitora por 30 segundos):**
```
[*] Monitorando Free Fire (normal)...
Pressione Ctrl+C para parar

[14:30:45] Jogo rodando
  Memória: 524288K
  Conexões: 12

[14:30:48] Jogo rodando
  Memória: 524512K
  Conexões: 14

[14:30:51] Jogo rodando
  Memória: 524800K
  Conexões: 15
```

### 6.5 OPÇÃO 6 - Debug Geral do Sistema:

```bash
Escolha uma opção: 6
```

**Resultado:**
```
╔════ MODO DEBUG GERAL ════╗

Hostname:
localhost

Endereços IP:
192.168.1.100

Versão Android:
11

Kernel:
Linux localhost 4.14.xxx #1 SMP PREEMPT

Memória Total:
MemTotal:        3954492 kB
MemFree:         1234567 kB

SSH Status:
SSH disponível

Git Status:
git version 2.XX.XX

Modo Free Fire:
Selecionado: normal

╚════════════════════════╝
```

### 6.6 OPÇÃO 7 - Ver Logs:

```bash
Escolha uma opção: 7
```

**Resultado:**
```
╔════ ÚLTIMOS LOGS ════╗
[2026-06-06 22:30:15] WiFi conectado - IP: 192.168.1.100
[2026-06-06 22:30:16] Branch atual: main
[2026-06-06 22:30:17] Modo selecionado: Free Fire Normal
[2026-06-06 22:30:18] Free Fire Normal encontrado instalado
[2026-06-06 22:30:45] Debug WiFi executado para Free Fire (normal)
╚════════════════════╝
```

---

## 🔄 FLUXO COMPLETO DE EXEMPLO

### Cenário: Verificar o jogo e WiFi

```bash
# 1. Abra Termux
# 2. Digite:
cd ~/Documents/SS-Julia-
php ss_julia_criador.php

# 3. Na tela inicial, aguarde 3 segundos
# 4. Escolha opção 3 para selecionar Free Fire
Escolha uma opção: 3

# 5. Escolha Free Fire Max
Escolha uma opção: 2

# 6. Escolha opção 4 para Debug WiFi
╔════ MENU PRINCIPAL ════╗
...
Escolha uma opção: 4

# 7. Veja os resultados do WiFi
# 8. Escolha opção 5 para monitorar performance
Escolha uma opção: 5

# 9. Pressione Ctrl+C para parar o monitoramento
# 10. Escolha opção 0 para sair
Escolha uma opção: 0
Até logo!
```

---

## 📂 ESTRUTURA DE DIRETÓRIOS

Após seguir os passos, sua estrutura será:

```
/root/
├── Documents/
│   └── SS-Julia-/
│       ├── ss_julia_criador.php      ← SCRIPT PRINCIPAL
│       ├── ss_julia_criador.sh        ← VERSÃO BASH
│       └── README.md
│
└── .ss_julia_criador/                  ← CRIADO AUTOMATICAMENTE
    └── logs.txt                        ← ARQUIVO DE LOGS
```

---

## 🐛 TROUBLESHOOTING (RESOLUÇÃO DE PROBLEMAS)

### Problema: "Command not found: php"

**Solução:**
```bash
pkg install php
```

### Problema: "adb: command not found"

**Solução:**
```bash
pkg install android-tools
```

### Problema: "Permission denied"

**Solução:**
```bash
chmod +x ss_julia_criador.php
```

### Problema: "Nenhum dispositivo encontrado"

**Solução:**
```bash
# Reinicie o servidor ADB
adb kill-server
adb start-server

# Reconecte seu dispositivo
adb connect 192.168.X.X:5555
```

### Problema: "Free Fire não encontrado"

**Solução:**
- Certifique-se que o Free Fire está instalado
- Abra o Free Fire uma vez
- Tente novamente

### Problema: "Sem conexão de rede"

**Solução:**
```bash
# Verifique conexão WiFi
ping 8.8.8.8

# Reinicie a rede
settings set global airplane_mode_on 0
```

---

## 📊 COMANDOS ÚTEIS NO TERMUX

```bash
# Ver histórico de comandos
history

# Limpar tela
clear

# Ver diretório atual
pwd

# Listar arquivos
ls -la

# Ir para o diretório inicial
cd ~

# Criar novo diretório
mkdir nomedapasta

# Remover arquivo
rm arquivo.txt

# Ver conteúdo de arquivo
cat arquivo.txt

# Editar arquivo (nano)
nano arquivo.txt
```

---

## ✅ CHECKLIST FINAL

- [ ] Termux instalado e atualizado
- [ ] Git instalado e funcionando
- [ ] PHP instalado e funcionando
- [ ] ADB conectado ao dispositivo
- [ ] Repositório clonado
- [ ] Script com permissão de execução
- [ ] Free Fire instalado no celular
- [ ] WiFi ativa
- [ ] Opções do Desenvolvedor ativadas

---

## 📞 SUPORTE

Se tiver problemas:

1. Verifique se todos os pacotes estão instalados
2. Tente desconectar e reconectar ADB
3. Reinicie o Termux
4. Verifique os logs com opção 7

**Log de erros:**
```bash
cat ~/.ss_julia_criador/logs.txt
```

---

## 🎯 PRÓXIMOS PASSOS

Após dominar o básico:

1. Crie um alias para facilitar:
```bash
echo "alias julia='cd ~/Documents/SS-Julia- && php ss_julia_criador.php'" >> ~/.bashrc
source ~/.bashrc

# Agora você pode usar apenas:
julia
```

2. Automatize tarefas com cron (se tiver root)
3. Integre com suas análises de segurança

---

**Desenvolvido por: Julia Criador**
**Baseado em: Keller SS**
**Versão: 1.0 - WiFi Debug Edition**

```
