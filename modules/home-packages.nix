{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # --- Web browsers ---
    google-chrome
    tor-browser
    firefox

    # --- Theming ---
    dunst # Notification daemon
    libsForQt5.qtstyleplugin-kvantum # Kvantum style for Qt5
    kdePackages.qtstyleplugin-kvantum # Kvantum style for Qt6
    libsForQt5.qt5ct # Qt5 settings tool
    qt6Packages.qt6ct # Qt6 settings tool
    qt6.qtwayland # Wayland support for Qt6
    qt5.qtwayland # Wayland support for Qt5
    apple-cursor # macOS-style cursors
    graphite-cursors # Graphite cursors
    dracula-icon-theme # Dracula icons
    qogir-theme # Qogir GTK theme and cursors
    papirus-icon-theme # Papirus icons
    papirus-folders # Change Papirus folder colors

    # --- Multimedia ---
    mpv # Media player
    yt-dlp # Video downloader
    qbittorrent # Torrent client

    # --- Communication ---
    (discord.override {
      withVencord = true;
    })

    # --- Games ---
    pcsx2 # PS2 emulator

    # --- Productivity ---
    obsidian # Markdown notes
    zathura # PDF/document viewer
    libreoffice-qt # Office suite

    # --- Editors ---
    code-cursor # Cursor AI editor
    vscode # Visual Studio Code
    antigravity-ide # Google Antigravity AI IDE
    neovim # Main editor
    opencode # Terminal AI coding agent

    # --- Terminal and shell ---
    tmux # Terminal multiplexer
    tty-clock # Terminal clock
    btop # Resource monitor
    cmatrix # Matrix screensaver
    krabby # Pokémon sprites in the terminal
    fastfetch # System info on shell start
    zsh-powerlevel10k # Zsh theme (unused, prompt is Starship)

    # --- CLI utilities ---
    fzf # Fuzzy finder
    ripgrep # Fast text search
    jq # JSON processor
    wget # File downloader
    unzip # Extract ZIP files
    unrar # Extract RAR files
    curl # HTTP client
    atuin # Searchable shell history
    eza # 'ls' replacement
    bat # 'cat' with syntax highlighting
    zoxide # Smarter 'cd'
    sesh # tmux session manager
    fd # Fast file finder
    # Terminal file manager, with RAR support in 7-Zip
    (yazi.override {
      _7zz = _7zz-rar;
    })

    # --- Hyprland and Wayland ---
    hyprland # Compositor
    hyprpaper # Wallpaper daemon (unused, replaced by awww)
    hyprlock # Lock screen
    hyprshot # Screenshots
    hyprpicker # Color picker
    rofi # App launcher and menus

    # --- Languages and dev tools ---
    gcc # GNU Compiler Collection
    git # Version control system
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.debugpy
    python3Packages.pyzmq # ZeroMQ Python bindings
    zeromq # ZeroMQ C library

    nodejs_22 # Node.js runtime
    cargo # Rust build tool and package manager
    python3Packages.ninja # Ninja build system
    lazygit # Git TUI
    lua-language-server # Lua LSP
    gnumake # GNU Make
    go # Go toolchain
    gopls # Go language server
    nil # Nix LSP
    yarn # Node.js package manager
    nixpkgs-fmt # Nix formatter
    mariadb # MariaDB client tools (server in configuration.nix)
    dbeaver-bin # Database GUI

    # --- Terminals and prompt ---
    starship # Shell prompt
    ghostty # Terminal emulator
    kitty # Main terminal emulator
    epub-thumbnailer # EPUB thumbnails for file managers

    # --- AI ---
    claude-code # Claude Code CLI
    codex # OpenAI Codex CLI
  ];

  # Audio visualizer
  programs.cava = {
    enable = true;
    settings = {
      general = {
        framerate = 60;
        bars = 0;
      };
      color = {
        gradient = 1;
        gradient_count = 6;
        gradient_color_1 = "'#59C2FF'";
        gradient_color_2 = "'#39BAE6'";
        gradient_color_3 = "'#C2D94C'";
        gradient_color_4 = "'#E6B450'";
        gradient_color_5 = "'#FFB454'";
        gradient_color_6 = "'#F07178'";
      };
      smoothing = {
        monstercat = 1;
        waves = 1;
      };
    };
  };
}
