# 🚀 Dotfiles - Arch Linux + Hyprland

Instalação automatizada do Arch Linux com Hyprland e visual OmArchy.

## 📥 Instalação Rápida
```bash
wget https://raw.githubusercontent.com/SEU_USER/dotfiles/main/install-hyprland-omarchy-auto.sh
chmod +x install-hyprland-omarchy-auto.sh
./install-hyprland-omarchy-auto.sh
```

## 📚 Documentação

- [Guia Completo](GUIA_COMPLETO_DO_ZERO.md)
- [PDF - Instalação Arch](docs/Guia_Instalacao_Arch_Hyprland.pdf)
- [PDF - Estilo OmArchy](docs/Guia_Hyprland_OmArchy_Style.pdf)

## ✨ Features

- Hyprland compositor
- Tema Catppuccin Mocha
- Waybar customizada
- SDDM login screen
- Auto-detecção de usuário/hostname
```

---

## ⚠️ RESUMO IMPORTANTE:

| Pergunta | Resposta |
|----------|----------|
| **Script instala Arch do zero?** | ❌ NÃO! Só Hyprland após Arch base |
| **Preciso instalar algo antes?** | ✅ SIM! Arch base + Git |
| **Posso colocar PDFs no GitHub?** | ✅ SIM! Organize em pasta `docs/` |
| **PDFs vão atrapalhar?** | ❌ NÃO! Ajuda a documentar |
| **Como uso depois de formatar?** | Instala Arch base → Git → wget script → executa |

---

## 🎯 CHECKLIST PÓS-FORMATAÇÃO:
```
□ 1. Boot pendrive Arch
□ 2. archinstall (hostname=arch, user=favero)
□ 3. Reboot
□ 4. nmcli wifi connect
□ 5. sudo pacman -S git
□ 6. wget https://raw.githubusercontent.com/.../install-hyprland-omarchy-auto.sh
□ 7. chmod +x install-hyprland-omarchy-auto.sh
□ 8. ./install-hyprland-omarchy-auto.sh
□ 9. sudo reboot
□ 10. ✨ Pronto!
