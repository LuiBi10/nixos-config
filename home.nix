{ config, pkgs, inputs, lib, ... }:
let
  draculaSrc = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "gtk";
    rev = "master";
    hash = "sha256-gbotOIGG55oqQZZNDkc9s5fPXvJQr+YHqxt5ZWS5bF8=";
  };

  waybarGit = pkgs.waybar.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "master";
      hash = "sha256-POvwObPOp6O14n6KYWNLp2Y3paunA5f8U1NCaodNFcc=";
    };
    # Nuevas dependencias y flags requeridos por la rama master
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.modemmanager ];
    mesonFlags = (oldAttrs.mesonFlags or [ ]) ++ [ "-Dcava=disabled" ];
  });
in
{
  home.username = "luibi";
  home.homeDirectory = "/home/luibi";
  home.stateVersion = "26.05";
  imports = [
    ./modules/hyprland.nix
    ./modules/zshrc.nix
    ./modules/home-packages.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

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
      targets = [ "graphical-session.target" ];
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
