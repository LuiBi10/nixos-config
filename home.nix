{ config, pkgs, inputs, lib, ... }:
let
  draculaSrc = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "gtk";
    rev = "71640b9456110f3bac2130d0b387a3154a9fb4d2"; # master @ 2026-09-26
    hash = "sha256-95Lfr4yiu7Yyff/pVgLCyKRX/btjdTASIqJ785XePG0=";
  };
in
{
  home.username = "luibi";
  home.homeDirectory = "/home/luibi";
  home.stateVersion = "26.05";

  # Weekly cleanup of old user profile generations (system nix.gc runs as root and skips these)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  imports = [
    ./modules/hyprland.nix
    ./modules/zshrc.nix
    ./modules/home-packages.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # Dracula colors for Kvantum, qt5ct/qt6ct and KDE
  xdg.configFile = {
    "Kvantum/Dracula".source = "${draculaSrc}/kde/kvantum/Dracula";

    "qt5ct/colors/Dracula.conf".source = "${draculaSrc}/kde/color-schemes/Dracula.colors";
    "qt6ct/colors/Dracula.conf".source = "${draculaSrc}/kde/color-schemes/Dracula.colors";
  };

  home.file.".local/share/color-schemes/Dracula.colors".source = "${draculaSrc}/kde/color-schemes/Dracula.colors";

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.text;
      colorScheme = "Spotify";
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
        keyboardShortcut
      ];
    };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Luibi";
        email = "luferbrito96@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "hyprland-session.target" ];
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.stdenvNoCC.mkDerivation {
        pname = "dracula-gtk-theme";
        version = "master";
        src = draculaSrc;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/themes/Dracula
          cp -r * $out/share/themes/Dracula/
        '';
      };
    };
    iconTheme = {
      name = "dracula";
      package = pkgs.dracula-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
  };
}
