#!/bin/bash

# =====================================================
# Script Hyprland OmArchy - VERSÃO 2.3 (UPGRADE)
# Base: V2.2 do Marco Favero
# Correções:
# - Remove opções depreciadas do Hyprland
# - Waybar com ícones estáveis
# - SDDM com tema e fonte corrigidos
# =====================================================

set -e

# CORES
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

CURRENT_USER=$(whoami)
CURRENT_HOSTNAME=$(hostname)
HOME_DIR=$(eval echo ~$CURRENT_USER)

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }

clear
echo -e "${PURPLE}
╔═══════════════════════════════════════════════════════╗
║     HYPRLAND INSTALLER - OMARCHY STYLE V2.3           ║
║        PATCH DE ESTABILIDADE (SEM QUEBRAS)            ║
╚═══════════════════════════════════════════════════════╝
${NC}"

if [ "$EUID" -eq 0 ]; then
    print_error "Não execute como root"
    exit 1
fi

print_info "Verificando internet..."
ping -c 1 8.8.8.8 &>/dev/null || { print_error "Sem internet"; exit 1; }

LOG_FILE="$HOME_DIR/hyprland-install-v2.3.log"
exec > >(tee -a "$LOG_FILE") 2>&1

print_info "Atualizando sistema"
sudo pacman -Syu --noconfirm

print_info "Pacotes base"
sudo pacman -S --needed --noconfirm hyprland kitty waybar wofi dunst nemo firefox mpv imv pipewire pipewire-pulse wireplumber pavucontrol grim slurp wl-clipboard swww polkit-kde-agent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland noto-fonts ttf-jetbrains-mono-nerd ttf-font-awesome git base-devel wget curl unzip brightnessctl playerctl network-manager-applet bluez bluez-utils blueman

if ! command -v yay &>/dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME_DIR"
    rm -rf /tmp/yay
fi

yay -S --needed --noconfirm swaylock-effects adw-gtk3 sddm-theme-sugar-dark || true

sudo pacman -S --needed --noconfirm sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg
sudo systemctl enable sddm bluetooth

sudo pacman -S --needed --noconfirm zsh zsh-autosuggestions zsh-syntax-highlighting starship fzf
[ "$SHELL" != "/usr/bin/zsh" ] && chsh -s /usr/bin/zsh

mkdir -p "$HOME_DIR/.config/"{hypr,waybar,kitty,wofi,dunst}
mkdir -p "$HOME_DIR/Pictures/"{Wallpapers,Screenshots}

# ================= HYPRLAND (CORRIGIDO) =================
cat > "$HOME_DIR/.config/hypr/hyprland.conf" << 'HYPR'
monitor=,preferred,auto,1

exec-once = waybar
exec-once = dunst
exec-once = nm-applet --indicator
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = swww init

env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt6ct

input {
  kb_layout = br
}

general {
  gaps_in = 6
  gaps_out = 12
  border_size = 2
  layout = dwindle
}

decoration {
  rounding = 12
  blur {
    enabled = true
    size = 6
    passes = 3
    new_optimizations = true
  }
  active_opacity = 0.98
  inactive_opacity = 0.90
}

animations {
  enabled = true
}

$mainMod = SUPER
bind = $mainMod, Return, exec, kitty
bind = $mainMod, E, exec, nemo
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, Q, killactive
bind = $mainMod, L, exec, swaylock -f -c 000000
HYPR

# ================= WAYBAR (ESTÁVEL) =================
cat > "$HOME_DIR/.config/waybar/config" << 'WAYBAR'
{
  "layer": "top",
  "height": 38,
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["tray","pulseaudio","network","cpu","memory","battery"],

  "hyprland/workspaces": {
    "format": "{name}"
  },

  "clock": {
    "format": "{:%H:%M  %d/%m}"
  },

  "battery": {
    "format": "{capacity}%"
  },

  "pulseaudio": {
    "format": "{volume}%"
  }
}
WAYBAR

cat > "$HOME_DIR/.config/waybar/style.css" << 'WAYBAR_STYLE'
* {
  font-family: JetBrainsMono Nerd Font;
  font-size: 13px;
}
window#waybar {
  background: rgba(30,30,46,0.85);
  border-radius: 12px;
}
WAYBAR_STYLE

# ================= SDDM (CORRIGIDO) =================
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf >/dev/null << 'SDDM'
[Theme]
Current=sugar-dark

[General]
Font=JetBrainsMono Nerd Font
SDDM

# ================= ZSH =================
cat > "$HOME_DIR/.zshrc" << 'ZSH'
eval "$(starship init zsh)"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
alias ll='ls -lah'
ZSH

echo ""
print_status "Instalação V2.3 concluída"
print_warning "Reinicie: sudo reboot"
