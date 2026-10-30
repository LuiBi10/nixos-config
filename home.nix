{ config, pkgs, inputs, lib, ... }:
let
  draculaSrc = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "gtk";
    rev = "71640b9456110f3bac2130d0b387a3154a9fb4d2"; # master @ 2026-09-26
    hash = "sha256-95Lfr4yiu7Yyff/pVgLCyKRX/btjdTASIqJ785XePG0=";
  };

  # Waybar master needs libcava 1.0.0 (nixpkgs vendors 0.10.7-beta for 0.15.0).
  # Vendor it here so meson does not try to download it inside the sandbox.
  libcava = {
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "LukashonakV";
      repo = "cava";
      tag = "1.0.0";
      hash = "sha256-0r5aAmTs+FcmS501tNYKxG9H+Pq6i32BDRBEjWW6M74=";
    };
  };

  waybarGit = pkgs.waybar.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "16843896794a9c595139318420f81f40e84f8c78"; # master @ 2026-09-26
      hash = "sha256-Y/bf7OmtwrEhdRDTkh4OVAEZX5ixL+io0W/UPJuto+g=";
    };
    # Extra dependency and flags required by master
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.modemmanager ];
    mesonFlags = (oldAttrs.mesonFlags or [ ]) ++ [ "-Dtests=disabled" ];
    postUnpack = ''
      pushd "$sourceRoot"
      cp -R --no-preserve=mode,ownership ${libcava.src} subprojects/cava-${libcava.version}
      patchShebangs .
      popd
    '';
    doCheck = false;
  });
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
    package = waybarGit;
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
