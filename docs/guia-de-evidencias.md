# 📸 Guia de Evidências (Capturas de Tela)

Checklist de prints para documentar a jornada. Salve as imagens na pasta `images/`
com os nomes sugeridos — o `README.md` já referencia esses arquivos.

| Arquivo sugerido | O que capturar |
|---|---|
| `images/00-rede.png` | Configuração de Rede Interna/Host-Only das duas VMs no VirtualBox |
| `images/01-nmap.png` | Saída do `nmap` mostrando as portas 21, 80, 139, 445 abertas |
| `images/02-ftp-success.png` | Linha `ACCOUNT FOUND ... [SUCCESS]` do ataque FTP |
| `images/03-dvwa-form.png` | Página "Brute Force" do DVWA + saída do Medusa/Hydra |
| `images/04-smb-enum.png` | Enumeração de usuários (`enum4linux`) e sucesso do spray SMB |
| `images/05-validacao.png` | Login real com a credencial descoberta (`ftp` ou `smbclient`) |

## Dicas
- Use `Ctrl+Shift+PrtSc` no Kali (ferramenta de captura) ou o atalho do seu SO.
- Oculte/edite qualquer informação sensível real antes de publicar.
- Prefira recortes focados no terminal/relevante — prints legíveis valem mais que a tela inteira.
- Opcional: grave um GIF curto do ataque em execução para enriquecer o portfólio.
