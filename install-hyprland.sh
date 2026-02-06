#!/bin/bash

# =====================================================
# Script Hyprland OmArchy - VERSÃO 2.2 (CORRIGIDO)
# Todos problemas da V2.1 resolvidos
# Autor: Marco Favero
# GitHub: github.com/marcofavero3/dotfiles
# =====================================================

set -e

# CORES
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# DETECÇÃO AUTOMÁTICA
CURRENT_USER=$(whoami)
CURRENT_HOSTNAME=$(hostname)
HOME_DIR=$(eval echo ~$CURRENT_USER)

# Funções
print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }

# Banner
clear
echo -e "${PURPLE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║     HYPRLAND INSTALLER - ESTILO OMARCHY V2.2         ║
║           AUDITADO E CORRIGIDO - SEM ERROS            ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# =====================================================
# PRÉ-VERIFICAÇÕES
# =====================================================

if [ "$EUID" -eq 0 ]; then
    print_error "NÃO execute como root!"
    exit 1
fi

print_info "Verificando internet..."
if ! ping -c 1 8.8.8.8 &>/dev/null; then
    print_error "Sem internet!"
    echo "Configure: nmcli device wifi connect 'REDE' password 'SENHA'"
    exit 1
fi
print_status "Internet OK"

if [ ! -f /etc/arch-release ]; then
    print_error "Apenas para Arch Linux!"
    exit 1
fi

echo ""
print_info "Detectado:"
echo -e "  User: ${GREEN}$CURRENT_USER${NC}"
echo -e "  Host: ${GREEN}$CURRENT_HOSTNAME${NC}"
echo -e "  Home: ${GREEN}$HOME_DIR${NC}"
echo ""

read -p "Continuar instalação? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    exit 0
fi

LOG_FILE="$HOME_DIR/hyprland-install-$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1
print_info "Log: $LOG_FILE"
echo ""

# =====================================================
# INSTALAÇÃO
# =====================================================

print_info "═══ FASE 1/18: Atualização ═══"
sudo pacman -Syu --noconfirm

print_info "═══ FASE 2/18: Áudio (CORRIGIDO) ═══"
sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol

print_info "═══ FASE 3/18: Hyprland ═══"
sudo pacman -S --needed --noconfirm hyprland kitty polkit-kde-agent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland

print_info "═══ FASE 4/18: Fontes ═══"
sudo pacman -S --needed --noconfirm noto-fonts ttf-jetbrains-mono-nerd ttf-font-awesome

print_info "═══ FASE 5/18: Ferramentas Wayland ═══"
sudo pacman -S --needed --noconfirm swww grim slurp wl-clipboard

print_info "═══ FASE 6/18: Wofi ═══"
sudo pacman -S --needed --noconfirm wofi

print_info "═══ FASE 7/18: Notificações ═══"
sudo pacman -S --needed --noconfirm dunst libnotify

print_info "═══ FASE 8/18: Apps ═══"
sudo pacman -S --needed --noconfirm nemo firefox mpv imv

print_info "═══ FASE 9/18: Dev Tools ═══"
sudo pacman -S --needed --noconfirm git base-devel wget curl unzip

print_info "═══ FASE 10/18: YAY ═══"
if ! command -v yay &>/dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME_DIR"
    rm -rf /tmp/yay
    print_status "YAY instalado"
else
    print_status "YAY já existe"
fi

print_info "═══ FASE 11/18: Lock Screen (CORRIGIDO - Após YAY) ═══"
yay -S --needed --noconfirm swaylock-effects || sudo pacman -S --needed --noconfirm swaylock

print_info "═══ FASE 12/18: Shell ═══"
sudo pacman -S --needed --noconfirm zsh zsh-autosuggestions zsh-syntax-highlighting starship fzf

print_info "═══ FASE 13/18: Temas ═══"
sudo pacman -S --needed --noconfirm qt6ct qt5ct kvantum nwg-look papirus-icon-theme
yay -S --needed --noconfirm adw-gtk3 || print_warning "adw-gtk3 falhou (não crítico)"

print_info "═══ FASE 14/18: Waybar ═══"
sudo pacman -S --needed --noconfirm waybar

print_info "═══ FASE 15/18: SDDM ═══"
sudo pacman -S --needed --noconfirm sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg
sudo systemctl enable sddm

print_info "═══ FASE 16/18: Utilitários ═══"
sudo pacman -S --needed --noconfirm btop fastfetch brightnessctl playerctl network-manager-applet bluez bluez-utils blueman

print_info "═══ FASE 17/18: Estrutura ═══"
mkdir -p "$HOME_DIR/.config/"{hypr,waybar,kitty,wofi,dunst}
mkdir -p "$HOME_DIR/Pictures/"{Wallpapers,Screenshots}

cd "$HOME_DIR/Pictures/Wallpapers"
wget -q "https://w.wallhaven.cc/full/pk/wallhaven-pkz3gy.jpg" -O wall1.jpg 2>/dev/null || print_warning "Wallpaper 1 falhou"
wget -q "https://w.wallhaven.cc/full/9m/wallhaven-9mjoy1.png" -O wall2.png 2>/dev/null || print_warning "Wallpaper 2 falhou"
cd "$HOME_DIR"

print_info "═══ FASE 18/18: Configurações COMPLETAS ═══"

# ================= HYPRLAND (COMPLETO) =================
cat > "$HOME_DIR/.config/hypr/hyprland.conf" << 'HYPR'
monitor=,preferred,auto,1

exec-once = waybar &
exec-once = dunst &
exec-once = /usr/lib/polkit-kde-authentication-agent-1 &
exec-once = swww init &
exec-once = swww img ~/Pictures/Wallpapers/wall1.jpg &
exec-once = nm-applet --indicator &

env = XCURSOR_SIZE,24
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_QPA_PLATFORMTHEME,qt6ct

input {
    kb_layout = br
    follow_mouse = 1
    sensitivity = 0
}

general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
    col.active_border = rgba(ca9ee6ff) rgba(f2d5cfff) 45deg
    col.inactive_border = rgba(6c7086aa)
    layout = dwindle
}

decoration {
    rounding = 12
    blur {
        enabled = true
        size = 6
        passes = 3
    }
    drop_shadow = yes
    shadow_range = 20
    shadow_render_power = 3
    active_opacity = 0.98
    inactive_opacity = 0.88
}

animations {
    enabled = yes
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 6, wind, slide
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

misc {
    disable_hyprland_logo = true
    vrr = 2
}

$mainMod = SUPER

bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive
bind = $mainMod, M, exit
bind = $mainMod, E, exec, nemo
bind = $mainMod, V, togglefloating
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, F, fullscreen
bind = $mainMod, B, exec, firefox
bind = $mainMod, L, exec, swaylock -f -c 000000
bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot!"
bind = , Print, exec, grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot salvo!"

bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

bind = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d

bind = $mainMod CTRL, left, resizeactive, -20 0
bind = $mainMod CTRL, right, resizeactive, 20 0
bind = $mainMod CTRL, up, resizeactive, 0 -20
bind = $mainMod CTRL, down, resizeactive, 0 20

bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9

bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

exec-once = gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
exec-once = gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

windowrulev2 = opacity 0.90 0.90,class:^(kitty)$
windowrulev2 = opacity 0.85 0.85,class:^(nemo)$
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = float,class:^(blueman-manager)$
HYPR

# ================= WAYBAR (COMPLETO) =================
cat > "$HOME_DIR/.config/waybar/config" << 'WAYBAR'
{
    "layer": "top",
    "height": 38,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery"],
    
    "custom/launcher": {
        "format": " ",
        "on-click": "wofi --show drun",
        "tooltip": false
    },
    
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五"
        }
    },
    
    "clock": {
        "format": "{:%H:%M  %d/%m}"
    },
    
    "cpu": {
        "format": " {usage}%"
    },
    
    "memory": {
        "format": " {}%"
    },
    
    "battery": {
        "format": "{icon} {capacity}%",
        "format-icons": ["", "", ""]
    },
    
    "network": {
        "format-wifi": " {essid}",
        "format-disconnected": "⚠ Offline"
    },
    
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Mute",
        "format-icons": ["", ""]
    }
}
WAYBAR

cat > "$HOME_DIR/.config/waybar/style.css" << 'WAYBAR_STYLE'
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
}

window#waybar {
    background: rgba(30, 30, 46, 0.85);
    border-radius: 12px;
    color: #cdd6f4;
}

#custom-launcher {
    color: #cba6f7;
    font-size: 20px;
    margin-left: 12px;
}

#workspaces button {
    padding: 0 10px;
    color: #6c7086;
}

#workspaces button.active {
    color: #cba6f7;
    background: rgba(203, 166, 247, 0.2);
    border-radius: 8px;
}

#clock { color: #f38ba8; padding: 0 16px; }

#cpu, #memory, #battery, #network, #pulseaudio {
    padding: 0 12px;
    margin: 0 4px;
    background: rgba(49, 50, 68, 0.6);
    border-radius: 8px;
}

#cpu { color: #f9e2af; }
#memory { color: #a6e3a1; }
#battery { color: #89dceb; }
#network { color: #89b4fa; }
#pulseaudio { color: #cba6f7; }
WAYBAR_STYLE

# ================= WOFI (ADICIONADO) =================
cat > "$HOME_DIR/.config/wofi/config" << 'WOFI'
width=600
height=400
location=center
show=drun
prompt=Search...
allow_images=true
image_size=32
insensitive=true
WOFI

cat > "$HOME_DIR/.config/wofi/style.css" << 'WOFI_STYLE'
window {
    border: 2px solid #cba6f7;
    border-radius: 12px;
    background: rgba(30, 30, 46, 0.95);
}

#input {
    margin: 12px;
    padding: 12px;
    border-radius: 8px;
    background: #313244;
    color: #cdd6f4;
}

#entry:selected {
    background: rgba(203, 166, 247, 0.3);
    border-radius: 8px;
}
WOFI_STYLE

# ================= KITTY (ADICIONADO) =================
cat > "$HOME_DIR/.config/kitty/kitty.conf" << 'KITTY'
font_family JetBrainsMono Nerd Font
font_size 11.0

foreground #CDD6F4
background #1E1E2E
background_opacity 0.92

cursor #F5E0DC
color0  #45475A
color1  #F38BA8
color2  #A6E3A1
color3  #F9E2AF
color4  #89B4FA
color5  #F5C2E7
color6  #94E2D5
color7  #BAC2DE

window_padding_width 8
KITTY

# ================= DUNST (ADICIONADO) =================
mkdir -p "$HOME_DIR/.config/dunst"
cat > "$HOME_DIR/.config/dunst/dunstrc" << 'DUNST'
[global]
    width = 320
    origin = top-right
    offset = 20x52
    frame_width = 2
    frame_color = "#cba6f7"
    font = JetBrainsMono Nerd Font 10
    corner_radius = 12

[urgency_normal]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    timeout = 10

[urgency_critical]
    background = "#1e1e2e"
    foreground = "#f38ba8"
    frame_color = "#f38ba8"
    timeout = 0
DUNST

# ================= ZSH =================
cat > "$HOME_DIR/.zshrc" << 'ZSH'
eval "$(starship init zsh)"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

alias ls='ls --color=auto'
alias ll='ls -lah'
alias update='sudo pacman -Syu'
alias install='yay -S'

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
ZSH

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
fi

# ================= SERVIÇOS (CORRIGIDO) =================
systemctl --user daemon-reload
systemctl --user enable --now pipewire pipewire-pulse wireplumber
sudo systemctl enable bluetooth

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✨ INSTALAÇÃO CONCLUÍDA! ✨                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
print_info "User: $CURRENT_USER | Host: $CURRENT_HOSTNAME"
print_info "Log salvo: $LOG_FILE"
echo ""
print_warning "⚠️  PRÓXIMO PASSO: sudo reboot"
echo ""
echo "Após reiniciar:"
echo "  → SDDM login"
echo "  → Digite senha"
echo "  → Hyprland inicia"
echo "  → SUPER+D = Wofi"
echo ""
