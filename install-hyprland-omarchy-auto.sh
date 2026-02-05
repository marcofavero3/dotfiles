#!/bin/bash

# =====================================================
# Script Hyprland OmArchy - Auto-detect user/hostname
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

# Banner
clear
echo -e "${PURPLE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║     HYPRLAND INSTALLER - ESTILO OMARCHY              ║
║     Detecção automática de usuário e hostname        ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Verificar se NÃO é root
if [ "$EUID" -eq 0 ]; then 
    print_error "NÃO execute como root!"
    print_info "Use: ./install-hyprland-omarchy-auto.sh"
    exit 1
fi

# Mostrar informações detectadas
echo ""
print_info "Informações detectadas:"
echo -e "  ${BLUE}→${NC} Usuário: ${GREEN}$CURRENT_USER${NC}"
echo -e "  ${BLUE}→${NC} Hostname: ${GREEN}$CURRENT_HOSTNAME${NC}"
echo -e "  ${BLUE}→${NC} Home: ${GREEN}$HOME_DIR${NC}"
echo ""

# Confirmação
echo "Este script vai instalar:"
echo "  ✨ Hyprland com visual OmArchy"
echo "  🎨 Temas Catppuccin Mocha"
echo "  🚀 SDDM (tela de login)"
echo "  📊 Waybar estilizada"
echo "  🔍 Wofi launcher"
echo "  🖼️  Papirus icons"
echo ""
read -p "Continuar instalação? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_warning "Instalação cancelada."
    exit 1
fi

# =====================================================
# FASE 1: PACOTES BASE
# =====================================================
print_info "═══ FASE 1/18: Pacotes Base ═══"

print_status "Atualizando sistema..."
sudo pacman -Syu --noconfirm

print_status "Instalando Pipewire (áudio)..."
sudo pacman -S --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol

print_status "Instalando Hyprland..."
sudo pacman -S --noconfirm hyprland kitty polkit-kde-agent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland

print_status "Instalando fontes..."
sudo pacman -S --noconfirm noto-fonts ttf-jetbrains-mono-nerd ttf-font-awesome ttf-fira-code

print_status "Instalando ferramentas Wayland..."
sudo pacman -S --noconfirm swww grim slurp wl-clipboard

print_status "Instalando Wofi..."
sudo pacman -S --noconfirm wofi

print_status "Instalando notificações..."
sudo pacman -S --noconfirm dunst libnotify

print_status "Instalando Swaylock..."
sudo pacman -S --noconfirm swaylock-effects

print_status "Instalando apps essenciais..."
sudo pacman -S --noconfirm nemo firefox mpv imv

print_status "Instalando ferramentas de desenvolvimento..."
sudo pacman -S --noconfirm git base-devel wget curl unzip

# =====================================================
# FASE 2: YAY
# =====================================================
print_info "═══ FASE 2/18: Instalando YAY ═══"

if ! command -v yay &> /dev/null; then
    print_status "Compilando YAY..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME_DIR"
    rm -rf /tmp/yay
else
    print_status "YAY já instalado!"
fi

# =====================================================
# FASE 3: SHELL
# =====================================================
print_info "═══ FASE 3/18: Configurando Shell ═══"

print_status "Instalando ZSH..."
sudo pacman -S --noconfirm zsh zsh-autosuggestions zsh-syntax-highlighting

print_status "Instalando Starship..."
sudo pacman -S --noconfirm starship

print_status "Instalando FZF..."
sudo pacman -S --noconfirm fzf

# =====================================================
# FASE 4: TEMAS
# =====================================================
print_info "═══ FASE 4/18: Instalando Temas ═══"

print_status "Instalando ferramentas de tema..."
sudo pacman -S --noconfirm qt6ct qt5ct kvantum nwg-look lxappearance

print_status "Instalando ícones Papirus..."
sudo pacman -S --noconfirm papirus-icon-theme

print_status "Instalando temas GTK..."
yay -S --noconfirm adw-gtk3 catppuccin-gtk-theme-mocha || print_warning "Alguns temas AUR podem ter falha - não é crítico"

# =====================================================
# FASE 5: WAYBAR
# =====================================================
print_info "═══ FASE 5/18: Instalando Waybar ═══"

sudo pacman -S --noconfirm waybar

# =====================================================
# FASE 6: SDDM
# =====================================================
print_info "═══ FASE 6/18: Instalando SDDM ═══"

print_status "Instalando SDDM..."
sudo pacman -S --noconfirm sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg

print_status "Configurando tema SDDM..."
# Criar tema simples caso sugar-candy falhe
sudo mkdir -p /usr/share/sddm/themes/sugar-candy
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << 'SDDM_CONF'
[Theme]
Current=breeze

[General]
InputMethod=
SDDM_CONF

print_status "Habilitando SDDM..."
sudo systemctl enable sddm

# =====================================================
# FASE 7: UTILITÁRIOS
# =====================================================
print_info "═══ FASE 7/18: Utilitários ═══"

sudo pacman -S --noconfirm btop fastfetch brightnessctl playerctl network-manager-applet bluez bluez-utils blueman

# =====================================================
# FASE 8: ESTRUTURA DE PASTAS
# =====================================================
print_info "═══ FASE 8/18: Criando estrutura ═══"

mkdir -p "$HOME_DIR/.config/"{hypr,waybar,kitty,wofi,dunst,gtk-3.0,gtk-4.0}
mkdir -p "$HOME_DIR/Pictures/"{Wallpapers,Screenshots}
mkdir -p "$HOME_DIR/.local/share/icons"
mkdir -p "$HOME_DIR/.themes"

# =====================================================
# FASE 9: WALLPAPERS
# =====================================================
print_info "═══ FASE 9/18: Baixando wallpapers ═══"

cd "$HOME_DIR/Pictures/Wallpapers"
wget -q "https://w.wallhaven.cc/full/pk/wallhaven-pkz3gy.jpg" -O wallpaper1.jpg 2>/dev/null || print_warning "Wallpaper 1 falhou"
wget -q "https://w.wallhaven.cc/full/9m/wallhaven-9mjoy1.png" -O wallpaper2.png 2>/dev/null || print_warning "Wallpaper 2 falhou"
cd "$HOME_DIR"

# =====================================================
# FASE 10: HYPRLAND CONFIG
# =====================================================
print_info "═══ FASE 10/18: Configurando Hyprland ═══"

cat > "$HOME_DIR/.config/hypr/hyprland.conf" << 'HYPR_EOF'
# Hyprland Config - OmArchy Style

monitor=,preferred,auto,1

# Autostart
exec-once = waybar &
exec-once = dunst &
exec-once = /usr/lib/polkit-kde-authentication-agent-1 &
exec-once = swww init &
exec-once = swww img ~/Pictures/Wallpapers/wallpaper1.jpg --transition-fps 60 --transition-type wipe &
exec-once = nm-applet --indicator &
exec-once = blueman-applet &

# Environment
env = XCURSOR_SIZE,24
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt6ct

# Input
input {
    kb_layout = br
    follow_mouse = 1
    sensitivity = 0
    
    touchpad {
        natural_scroll = yes
    }
}

# General
general {
    gaps_in = 6
    gaps_out = 12
    border_size = 2
    col.active_border = rgba(ca9ee6ff) rgba(f2d5cfff) 45deg
    col.inactive_border = rgba(6c7086aa)
    layout = dwindle
    resize_on_border = true
}

# Decoration
decoration {
    rounding = 12
    
    blur {
        enabled = true
        size = 6
        passes = 3
        new_optimizations = true
    }
    
    drop_shadow = yes
    shadow_range = 20
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
    
    active_opacity = 0.98
    inactive_opacity = 0.88
    
    dim_inactive = true
    dim_strength = 0.1
}

# Animations
animations {
    enabled = yes
    
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.0
    bezier = winOut, 0.3, -0.3, 0, 1
    
    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    vrr = 2
}

# Keybinds
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

# Screenshot
bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copiado!"
bind = , Print, exec, grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot salvo!"

# Media
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move windows
bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Themes
exec-once = gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
exec-once = gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
exec-once = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

windowrulev2 = opacity 0.90 0.90,class:^(kitty)$
windowrulev2 = opacity 0.85 0.85,class:^(nemo)$
windowrulev2 = float,class:^(pavucontrol)$
HYPR_EOF

# =====================================================
# FASE 11-17: CONFIGS WAYBAR, WOFI, KITTY, DUNST, ZSH
# =====================================================
print_info "═══ FASES 11-17: Configurando apps ═══"

# WAYBAR
cat > "$HOME_DIR/.config/waybar/config" << 'WAYBAR_CFG'
{
    "layer": "top",
    "position": "top",
    "height": 38,
    "spacing": 4,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery"],
    
    "custom/launcher": {
        "format": " ",
        "on-click": "wofi --show drun"
    },
    
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "一", "2": "二", "3": "三", "4": "四", "5": "五"
        }
    },
    
    "clock": {
        "format": "{:%H:%M  %d/%m}"
    },
    
    "cpu": {"format": " {usage}%"},
    "memory": {"format": " {}%"},
    "battery": {"format": "{icon} {capacity}%", "format-icons": ["", "", ""]},
    "network": {"format-wifi": " {essid}"},
    "pulseaudio": {"format": "{icon} {volume}%", "format-icons": ["", ""]}
}
WAYBAR_CFG

cat > "$HOME_DIR/.config/waybar/style.css" << 'WAYBAR_STYLE'
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
}

window#waybar {
    background-color: rgba(30, 30, 46, 0.85);
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
    background-color: rgba(203, 166, 247, 0.2);
    border-radius: 8px;
}

#clock { color: #f38ba8; font-weight: bold; padding: 0 16px; }
#cpu, #memory, #battery, #network, #pulseaudio {
    padding: 0 12px;
    margin: 0 4px;
    background-color: rgba(49, 50, 68, 0.6);
    border-radius: 8px;
}
WAYBAR_STYLE

# WOFI
cat > "$HOME_DIR/.config/wofi/config" << 'WOFI_CFG'
width=600
height=400
location=center
show=drun
prompt=Search...
allow_images=true
image_size=32
WOFI_CFG

cat > "$HOME_DIR/.config/wofi/style.css" << 'WOFI_STYLE'
window {
    border: 2px solid #cba6f7;
    border-radius: 12px;
    background-color: rgba(30, 30, 46, 0.95);
}

#input {
    margin: 12px;
    padding: 12px;
    border-radius: 8px;
    background-color: #313244;
    color: #cdd6f4;
}

#entry:selected {
    background-color: rgba(203, 166, 247, 0.3);
    border-radius: 8px;
}
WOFI_STYLE

# KITTY
cat > "$HOME_DIR/.config/kitty/kitty.conf" << 'KITTY_CFG'
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
KITTY_CFG

# DUNST
mkdir -p "$HOME_DIR/.config/dunst"
cat > "$HOME_DIR/.config/dunst/dunstrc" << 'DUNST_CFG'
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
DUNST_CFG

# ZSH
cat > "$HOME_DIR/.zshrc" << 'ZSH_CFG'
eval "$(starship init zsh)"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

alias ls='ls --color=auto'
alias ll='ls -lah'
alias update='sudo pacman -Syu'
ZSH_CFG

# =====================================================
# FASE 18: FINALIZAÇÃO
# =====================================================
print_info "═══ FASE 18/18: Finalizando ═══"

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
fi

systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable bluetooth 2>/dev/null || true

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║          ✨ INSTALAÇÃO CONCLUÍDA! ✨                  ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
print_info "Usuário: $CURRENT_USER"
print_info "Hostname: $CURRENT_HOSTNAME"
echo ""
print_warning "⚠️  PRÓXIMO PASSO: sudo reboot"
echo ""
echo "Após reiniciar:"
echo "  1. Tela SDDM aparecerá"
echo "  2. Login → Hyprland inicia automaticamente"
echo ""
print_status "Atalhos: SUPER+D (launcher) | SUPER+Return (terminal)"
echo ""

