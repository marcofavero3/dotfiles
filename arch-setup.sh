#!/bin/bash

# =====================================================
# Arch Linux + Hyprland Setup (Estável e Corrigido)
# Autor: Marco Favero
# =====================================================

set -e

# ===== CORES =====
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERRO]${NC} $1"; }

# ===== VERIFICAÇÕES =====
if [ "$EUID" -eq 0 ]; then
  err "Não execute como root"
  exit 1
fi

if ! ping -c 1 8.8.8.8 &>/dev/null; then
  err "Sem internet"
  exit 1
fi

info "Atualizando sistema"
sudo pacman -Syu --noconfirm

# ===== PACOTES BASE =====
info "Instalando base"
sudo pacman -S --needed --noconfirm \
  hyprland kitty waybar wofi dunst \
  pipewire pipewire-pulse wireplumber pavucontrol \
  nemo firefox mpv imv \
  grim slurp wl-clipboard swww \
  polkit-kde-agent xdg-desktop-portal-hyprland \
  noto-fonts ttf-jetbrains-mono-nerd ttf-font-awesome \
  qt5-wayland qt6-wayland \
  network-manager-applet \
  brightnessctl playerctl \
  git base-devel curl wget unzip

# ===== YAY =====
if ! command -v yay &>/dev/null; then
  info "Instalando yay"
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
  rm -rf /tmp/yay
fi

# ===== AUR =====
yay -S --needed --noconfirm swaylock-effects adw-gtk3 || true

# ===== SDDM =====
sudo pacman -S --needed --noconfirm sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg
sudo systemctl enable sddm

# ===== SHELL =====
sudo pacman -S --needed --noconfirm zsh zsh-autosuggestions zsh-syntax-highlighting starship fzf
chsh -s /usr/bin/zsh

# ===== CONFIGS =====
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,dunst}
mkdir -p ~/Pictures/{Wallpapers,Screenshots}

# ===== HYPRLAND =====
cat > ~/.config/hypr/hyprland.conf << 'HYPR'
monitor=,preferred,auto,1

exec-once = waybar
exec-once = dunst
exec-once = nm-applet --indicator
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = swww init
exec-once = swww img ~/Pictures/Wallpapers/wall.jpg

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
  rounding = 10
  blur {
    enabled = true
    size = 6
    passes = 3
  }
}

animations {
  enabled = true
}

$mainMod = SUPER
bind = $mainMod, Return, exec, kitty
bind = $mainMod, E, exec, nemo
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, Q, killactive
bind = $mainMod, L, exec, swaylock
bind = , Print, exec, grim ~/Pictures/Screenshots/shot.png
HYPR

# ===== WAYBAR =====
cat > ~/.config/waybar/config << 'WAY'
{
  "layer": "top",
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio","network","battery"]
}
WAY

cat > ~/.config/waybar/style.css << 'WAYCSS'
* {
  font-family: JetBrainsMono Nerd Font;
  font-size: 13px;
}
window#waybar {
  background: rgba(30,30,46,0.9);
  border-radius: 10px;
}
WAYCSS

# ===== ZSH =====
cat > ~/.zshrc << 'ZSH'
eval "$(starship init zsh)"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
alias ll='ls -lah'
ZSH

ok "Instalação concluída"
echo "Reinicie o sistema: sudo reboot"
