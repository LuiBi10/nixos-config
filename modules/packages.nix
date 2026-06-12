{ pkgs, ... }: {

  # System packages
  environment.systemPackages = with pkgs; [

    # --- System & Performance Tools ---
    polkit # Authorization framework
    brightnessctl # Control display brightness
    wl-clipboard # Wayland clipboard manager
    cliphist #clipboard history manager for Wayland
    hyprsunset #Night light adjustment for Hyprland
    hyprpolkitagent # Polkit agent for Hyprland
    marksman # Bookmark manager for the terminal
    home-manager # Dotfile manager for NixOS
    imagemagick # Convert images
    mermaid-cli # Diagrams Mermaed
    sqlite # Frencuency historial storage database
    ghostscript # Render PDF files
    stylua # Linter para Lua
    #nwg-look # GTK theme configurator
    networkmanagerapplet #network manager applet for Wayland
    efibootmgr #Boot manager for UEFI systems
    os-prober #Program to detect other operating systems on the machine
    pamixer # Command-line mixer for PulseAudio
    libnotify # Desktop notifications library
    proton-vpn #Proton GUI
    # --- Audio & Multimedia ---
    pavucontrol # PulseAudio volume control
    playerctl # Media player controller

    # --- GUI Applications & Desktop Enhancements ---
    kdePackages.qtsvg # Qt SVG library
    kdePackages.plasma-workspace #plasma workspace components
    xdg-desktop-portal-gtk # Desktop portal for GTK apps
    xdg-desktop-portal-hyprland # Desktop portal for Hyprland

    # --- SDDM Theme ---
    where-is-my-sddm-theme


  ];
}

