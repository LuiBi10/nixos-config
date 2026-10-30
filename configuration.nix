{ config, pkgs, inputs, lib, ... }:
{
  # Hardware and system-wide packages
  imports = [
    ./hardware-configuration.nix
    ./modules/packages.nix
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # GRUB (EFI) with os-prober and the distro-grub-themes NixOS theme
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

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # DConf over D-Bus, needed by GTK apps for settings
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];

  # GLib/GSettings schemas for GTK apps
  environment.systemPackages = with pkgs; [
    glib
    gsettings-desktop-schemas
  ];

  # Time zone and locale (Colombian date/time format)
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

  # Dual-function keys (tap/hold), mappings in dual-function-keys.yaml
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

  # Display manager (SDDM on Wayland) and Plasma 6
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
    theme = "where_is_my_sddm_theme";
  };
  services.desktopManager.plasma6.enable = true;

  # Keyboard layout (X11 and TTY)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  console.keyMap = "us";

  # Audio via PipeWire; switch to new sinks when they connect
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

  # Ollama API, listening on all interfaces
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "0.0.0.0";
    port = 11434;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User account
  users.users.luibi = {
    isNormalUser = true;
    description = "luibi";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = [ ];
  };

  # Default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # GVFS: trash, MTP and network mounts in file managers
  services.gvfs.enable = true;

  # Polkit: let wheel users in an active local session unlock/mount internal
  # disks (e.g. the Omarchy LUKS partition) without an admin prompt per action.
  # The LUKS passphrase itself is still required.
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var udisksActions = [
        "org.freedesktop.udisks2.filesystem-mount",
        "org.freedesktop.udisks2.filesystem-mount-system",
        "org.freedesktop.udisks2.filesystem-mount-other-seat",
        "org.freedesktop.udisks2.filesystem-unmount-others",
        "org.freedesktop.udisks2.encrypted-unlock",
        "org.freedesktop.udisks2.encrypted-unlock-system",
        "org.freedesktop.udisks2.encrypted-unlock-other-seat",
        "org.freedesktop.udisks2.encrypted-lock-others",
        "org.freedesktop.udisks2.eject-media",
        "org.freedesktop.udisks2.eject-media-system",
        "org.freedesktop.udisks2.power-off-drive",
        "org.freedesktop.udisks2.power-off-drive-system"
      ];
      if (udisksActions.indexOf(action.id) >= 0 &&
          subject.isInGroup("wheel") && subject.local && subject.active) {
        return polkit.Result.YES;
      }
    });
  '';

  # Permitted insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
    "qtwebengine-5.15.19"
  ];

  # Hyprland compositor (user config in modules/hyprland.nix)
  programs.hyprland.enable = true;

  # XDG portals: Hyprland first, KDE as fallback (no GTK portal)
  xdg.portal = {
    enable = true;
    extraPortals = [
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

  # Never start xdg-desktop-portal-gtk
  systemd.user.services.xdg-desktop-portal-gtk = {
    enable = false;
    unitConfig.RefuseManualStart = true;
  };

  # Run unpatched dynamically linked binaries
  programs.nix-ld.enable = true;

  # MariaDB with a local 'curso' database and user
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

  # Weekly garbage collection and store optimisation
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true;

  services.flatpak.enable = true;

  # Wayland session, GTK and Qt environment variables
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

  # Nerd Fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.monoid
  ];

  # SSH and Ollama
  networking.firewall.allowedTCPPorts = [ 22 11434 ];

  # Tor daemon
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

  # Rootless Docker
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "luibi" ];

  # Waydroid (Android container)
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Release of the first install; do not change
  system.stateVersion = "26.05";

  # Bluetooth, powered on at boot
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Plasma application menu, so KDE apps (e.g. Dolphin) can list apps outside Plasma
  environment.etc."xdg/menus/applications.menu".source =
    "/run/current-system/sw/etc/xdg/menus/plasma-applications.menu";
}
