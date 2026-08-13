{ config, pkgs, inputs, lib, ... }:
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

  # DConf and DBus settings for desktop compatibility
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];

  # Inject GLib schemas globally
  environment.systemPackages = with pkgs; [
    glib
    gsettings-desktop-schemas
  ];

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
    wireplumber.extraConfig = {
      "10-switch-on-connect" = {
        "wireplumber.settings" = {
          "device.routes.default-sink-switch" = true;
        };
      };
    };
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

  # Enable GVFS for file manager virtual filesystems
  services.gvfs.enable = true;

  # Permitted insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
    "qtwebengine-5.15.19"
  ];

  # Hyprland settings for Wayland compositor
  programs.hyprland.enable = true;

  # XDG desktop portal setup using Hyprland + KDE backends exclusively
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default = [ "hyprland" "kde" ];
      };
      hyprland = {
        default = [ "hyprland" "kde" ];
      };
    };
  };

  # Prevent systemd from ever starting xdg-desktop-portal-gtk
  systemd.user.services.xdg-desktop-portal-gtk = {
    enable = false;
    unitConfig.RefuseManualStart = true;
  };

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true;

  services.flatpak.enable = true;

  # System-wide environment variables for Qt, GTK, and Wayland session
  environment.variables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    TRACKER_DISABLE_AUTO_START = "1";

    GDK_BACKEND = "wayland,x11";

    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "kde";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
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

  # Sudo insults
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults insults
    '';
  };

  # Docker setup
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # VirtualBox setup
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "luibi" ];

  # Waydroid setup
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  system.stateVersion = "26.05";

  # Bluetooth settings
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # KDE/Plasma menu integration
  environment.etc."xdg/menus/applications.menu".source =
    "/run/current-system/sw/etc/xdg/menus/plasma-applications.menu";
}
