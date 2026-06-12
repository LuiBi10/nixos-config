{ config, pkgs, inputs, lib, ... }:

{
  home.username = "luibi";
  home.homeDirectory = "/home/luibi";
  home.stateVersion = "26.05"; # Ensure this matches your initial install version

  imports = [
    ./modules/hyprland.nix
    ./modules/zshrc.nix
    ./modules/home-packages.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # This is now empty and clean. 
  # Your configurations are managed inside the imported modules above.
  xdg.configFile = { };

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.text;
      colorScheme = "TokyoNight";

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
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };
}
