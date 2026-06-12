{ config, pkgs, inputs, ... }:

{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
    ./modules/packages.nix
  ];

  # Enable experimental Nix features for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      devices = [ "nodev" ];
      useOSProber = true;
      gfxmodeEfi = "1920x1080";

      theme = pkgs.stdenv.mkDerivation {
        pname = "distro-grub-theme";
        version = "3.1";
        src = pkgs.fetchFromGitHub {
          owner = "AdisonCavani";
          repo = "distro-grub-themes";
          rev = "v3.1";
          hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
        };
        installPhase = "cp -r customize/nixos $out";
      };
    };
  };
  # Hostname and networking configuration
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone and localization settings
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };

  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.dual-function-keys ];

    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/nixos/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_MENU, KEY_RIGHTALT]
    '';
  };
  # X server and desktop environment settings
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
    theme = "where_is_my_sddm_theme";
  };
  services.desktopManager.plasma6.enable = true;

  # Keyboard layout settings
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  console.keyMap = "us";

  # Audio configuration using PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "0.0.0.0";
    port = 11434;
  };
  # Allow unfree packages 
  nixpkgs.config.allowUnfree = true;

  # User configuration
  users.users.luibi = {
    isNormalUser = true;
    description = "luibi";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = [ ];
  };

  # Default shell configuration
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enable Firefox browser
  services.gvfs.enable = true;

  # Permitir específicamente el paquete de Qt que causa el error
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
    "qtwebengine-5.15.19"
  ];

  # Activa el servicio de almacenamiento de contraseñas
  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.login.enableGnomeKeyring = true;

  # Hyprland settings for Wayland compositor
  programs.hyprland.enable = true;

  # Nix-ld settings
  programs.nix-ld.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialDatabases = [{ name = "curso"; }];
    initialScript = pkgs.writeText "mysql-init.sql" ''
      CREATE USER IF NOT EXISTS 'luibi'@'localhost' IDENTIFIED BY '4712';
      GRANT ALL PRIVILEGES ON *.* TO 'luibi'@'localhost' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
    '';
  };

  services.flatpak.enable = true;

  environment.variables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland";
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.monoid
  ];

  networking.firewall.allowedTCPPorts = [ 22 11434 ];

  # Tor Service
  services.tor = {
    enable = true;
    openFirewall = true;
  };

  # --- Sudo with insults enabled XD ---
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults insults
    '';
  };

  # Enable Docker
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "luibi" ];

  system.stateVersion = "26.05";

  # Bluetooth settings
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable XDG portal services
  environment.etc."xdg/menus/applications.menu".source =
    "/run/current-system/sw/etc/xdg/menus/plasma-applications.menu";
}

