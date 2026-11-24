#!/usr/bin/env bash
# =============================================================================
# 00-recon-nmap.sh
# Reconhecimento do alvo antes dos ataques de força bruta.
# Uso: ./00-recon-nmap.sh <IP_ALVO>
# Exemplo: ./00-recon-nmap.sh 192.168.56.102
# =============================================================================
set -euo pipefail

ALVO="${1:-192.168.56.102}"
SAIDA="recon_${ALVO//./_}.txt"

echo "[*] Varredura de portas e serviços em ${ALVO}..."

# -sV  : detecta versão dos serviços
# -sC  : executa scripts NSE padrão (seguros)
# -p-  : varre todas as 65535 portas (remova se quiser apenas as comuns)
# -oN  : salva saída em formato legível
nmap -sV -sC -p 21,80,139,445 -oN "${SAIDA}" "${ALVO}"

echo "[+] Resultado salvo em ${SAIDA}"
echo
echo "[*] Foco deste lab:"
echo "    21/tcp   -> FTP   (Cenário 1)"
echo "    80/tcp   -> HTTP  (DVWA - Cenário 2)"
echo "    139,445  -> SMB   (Cenário 3)"
