{ pkgs, ... }: {

  # System-wide packages
  environment.systemPackages = with pkgs; [

    # --- System & Performance Tools ---
    polkit # Privilege authorization framework
    brightnessctl # Screen brightness control
    wl-clipboard # Wayland clipboard CLI (wl-copy/wl-paste)
    cliphist # Clipboard history for Wayland
    hyprsunset # Night light for Hyprland
    hyprpolkitagent # Polkit agent for Hyprland
    marksman # Markdown language server
    home-manager # Home Manager CLI
    imagemagick # Image conversion and editing
    mermaid-cli # Render Mermaid diagrams
    sqlite # SQLite CLI and library
    ghostscript # PostScript/PDF interpreter
    stylua # Lua formatter
    #nwg-look # GTK theme configurator
    networkmanagerapplet # NetworkManager tray applet (nm-applet)
    efibootmgr # Manage UEFI boot entries
    os-prober # Detect other OSes for GRUB
    pamixer # CLI volume mixer (PulseAudio/PipeWire)
    libnotify # Desktop notifications (notify-send)
    proton-vpn # Proton VPN client

    # --- Audio & Multimedia ---
    pavucontrol # Volume control GUI
    playerctl # MPRIS media player control

    # --- GUI Applications & Desktop Enhancements ---
    kdePackages.qtsvg # Qt SVG library
    kdePackages.plasma-workspace # Plasma workspace components
    xdg-desktop-portal-gtk # GTK portal (its service is disabled in configuration.nix)
    xdg-desktop-portal-hyprland # Desktop portal for Hyprland

    # --- SDDM Theme ---
    where-is-my-sddm-theme
  ];
}

