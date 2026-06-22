{ pkgs, config, ... }:

{

  home.packages = with pkgs; [
    # Web Browsers
    google-chrome
    tor-browser
    firefox

    # Customization Tools
    dunst #Notifications
    libsForQt5.qtstyleplugin-kvantum #plugin for Qt5 to use Kvantum themes
    kdePackages.qtstyleplugin-kvantum #plugin for KDE to use Kvantum themes
    libsForQt5.qt5ct #customize Qt5 
    qt6Packages.qt6ct #customize of Qt6 
    qt6.qtwayland #wayland support for Qt6 applications
    qt5.qtwayland #wayland support for Qt5 applications
    dracula-theme #Theme for various applications
    apple-cursor #Cursor theme inspired by macOS
    graphite-cursors #Cursor theme with a graphite color scheme
    dracula-icon-theme #Icon theme that complements 
    qogir-theme #Theme for various applications
    papirus-icon-theme #Papirus icon theme 
    papirus-folders #Icon theme with a focus on folder icons

    # Multimedia Tools
    mpv #Multimedia player
    yt-dlp #Downloader for YouTube and other video platforms
    qbittorrent #Torrent client

    # Communication and Social Networks
    discord
    betterdiscordctl

    # Games
    pcsx2 #P2 emulator

    # Productivity Tools
    obsidian #Productivity and note-taking app
    zathura #Reading PDF and other document formats
    libreoffice-qt6-fresh #Suite of office applications

    # Development Tools
    code-cursor #Editor for code snippets and quick edits
    vscode #Visual Studio Code editor
    antigravity #Text editor with a focus on simplicity and fun
    neovim


    # Terminal and Shell Utilities
    tmux #Terminal multiplexer
    tty-clock
    btop #Control system resources in the terminal
    cmatrix #Matrix-style terminal screensaver
    zsh-autosuggestions #suggest commands as you type based on history and completions
    zsh-syntax-highlighting #syntax highlighting for the Zsh command line
    krabby #Pokemon-themed terminal prompt
    fastfetch #Information tool for the terminal
    zsh-powerlevel10k #Theme for Zsh with a focus on speed and customization
    ncspot #Spotify client for the terminal

    # --- Command-Line Utilities ---
    fzf # Fuzzy finder for the terminal
    ripgrep # Fast search tool
    jq # JSON processor
    wget # Command-line file downloader
    unzip # Extract ZIP files
    curl # URL downloader 
    atuin # Command-line shell history
    eza # Enhanced 'ls' command
    bat # 'cat' alternative with syntax highlighting
    zoxide # Directory jumping tool
    sesh #tmux advanced 
    fd # search folders faster
    (yazi.override {
      _7zz = _7zz-rar; # Support for RAR extraction
    }) #search and extract archives with a focus on speed and simplicity

    # --- Hyprland & Wayland Setup ---
    hyprland # Hyprland Wayland compositor
    waybar # Status bar for Wayland
    hyprpaper # Wallpaper manager for Hyprland
    rofi # Rofi launcher for Wayland
    hyprlock #Lockscreen
    hyprshot # Screenshot tool for Wayland

    # --- Language and runtimes ---
    gcc # GNU Compiler Collection
    git # Version control system
    python3 # Python programming language
    python312Packages.pip # Python package manager
    nodejs_22 # Node.js JavaScript runtime
    cargo # Rust package manager
    python312Packages.ninja # Ninja build system
    python312Packages.debugpy # Python debugger
    lazygit # Git terminal UI
    lua-language-server
    gnumake # Build automation tool
    go # Go programming language
    gopls # Go language server
    nil # nil programming language
    yarn # Node.js package manager
    nixpkgs-fmt # Nix formatter
    mariadb #Database server
    dbeaver-bin #mysql emulator

    # Terminal Emulators
    starship #Customizable prompt for the terminal
    epub-thumbnailer #Epobuntu thumbnailer for ePub files
    ghostty #Terminal emulator with a focus on performance and simplicity

    # AI
    gemini-cli #Gemini AI CLI client
    claude-code #Claude AI CLI client
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/luibi/.config/nvim";

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
