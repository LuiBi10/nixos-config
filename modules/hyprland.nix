{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    # CRÍTICO: con home.stateVersion = "26.05", HM genera por defecto
    # hyprland.lua (formato Lua nuevo), que no soporta variables tipo $mainMod.
    # Esto fuerza el formato hyprlang clásico -> ~/.config/hypr/hyprland.conf
    configType = "hyprlang";

    settings = {
      monitor = [ ",preferred,auto,auto" ];

      "$mainMod" = "SUPER";

      env = [
        "QT_QPA_PLATFORM,wayland"
        "QT_QPA_PLATFORMTHEME,kvantum"
        "GTK_THEME,Dracula"
        "QT_STYLE_OVERRIDE,kvantum"
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Qogir Cursors"
        "HYPRCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,Qogir Cursors"
      ];

      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "ghostty"
        "nm-applet"
        "waybar"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      general = {
        gaps_in = 2;
        gaps_out = 8;
        border_size = 1;
        "col.active_border" = "rgb(b4befe)";
        "col.inactive_border" = "rgba(a7c080aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        active_opacity = 0.9;
        inactive_opacity = 0.8;

        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          vibrancy = 0.15;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # pseudotile fue ELIMINADO en Hyprland 0.55
      dwindle = {
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = false;
      };

      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
      ];

      windowrule = [
        "opacity 0.85 override, match:class ^(discord)$"
        "opacity 0.85 override, match:class ^(org.kde.dolphin)$"
        "opacity 0.90 0.85 override, match:class ^(zen-twilight)$"
        "workspace 3, match:class ^(obsidian)$"
        "workspace 3, match:class ^(org.kde.dolphin)$"
        "workspace 3, match:class ^(Spotify)$"
        "workspace 2, match:class ^(zen-twilight)$"
        "workspace 4, match:class ^(org.pwmt.zathura)$"
        "float on, match:title ^(Save File)$"
        "float on, size 700 600, center on, match:title ^(ghostty-floating)$"
        "opacity 1.0 override, match:class ^(VirtualBox Machine)$"
        "opacity 1.0 override, match:class ^(virtualbox)$"
        "float on, center on, match:class ^(VirtualBox Machine)$"
      ];

      bind = [
        # --- Navegación entre Ventanas (Foco) ---
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # --- Gestión de Sesión y Waybar ---
        "$mainMod SHIFT, R, exec, pkill waybar && waybar"
        "$mainMod SHIFT, Q, exit"

        # Window management
        "$mainMod, F, fullscreen"
        "$mainMod, Q, killactive"
        "$mainMod, Space, togglefloating"
        "$mainMod CTRL, P, pin" # movido: antes chocaba con el script de wallpaper

        # Launch apps
        "$mainMod, Return, exec, ghostty"
        "$mainMod CTRL, Return, exec, ghostty --title=ghostty-floating"
        "$mainMod SHIFT, B, exec, ghostty -e btop"
        "ALT, Space, exec, rofi -show drun"
        "$mainMod SHIFT, F, exec, XDG_CURRENT_DESKTOP=KDE dolphin"
        "$mainMod SHIFT, K, exec, XDG_CURRENT_DESKTOP=KDE kate"
        "$mainMod, R, exec, ghostty -e yazi"
        "$mainMod, V, exec, ghostty -e nvim"
        "$mainMod SHIFT, V, exec, code"
        "$mainMod, B, exec, zen-twilight"
        "$mainMod, D, exec, discord"
        "$mainMod, M, exec, spotify"
        "$mainMod, O, exec, obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland"
        "ALT CTRL, C, exec, zsh -l -c 'cursor'"
        "$mainMod CTRL, Space, exec, bash /etc/nixos/modules/scripts/change-wall.sh"
        "$mainMod, C, exec, ~/.config/hypr/scripts/cliphist.sh c"

        # Workspaces y Screenshots
        "$mainMod CTRL, S, movetoworkspace, special"
        "$mainMod, S, togglespecialworkspace"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod, TAB, workspace, previous"
        "$mainMod CTRL, J, workspace, -1"
        "$mainMod CTRL, K, workspace, +1"
        "$mainMod CTRL, 1, movetoworkspace, 1"
        "$mainMod CTRL, 2, movetoworkspace, 2"
        "$mainMod CTRL, 3, movetoworkspace, 3"
        "$mainMod CTRL, 4, movetoworkspace, 4"
        "$mainMod CTRL, 5, movetoworkspace, 5"
        "$mainMod CTRL, 6, movetoworkspace, 6"
        "$mainMod CTRL, 7, movetoworkspace, 7"
        "$mainMod CTRL, 8, movetoworkspace, 8"
        "$mainMod CTRL, 9, movetoworkspace, 9"
        "$mainMod CTRL, 0, movetoworkspace, 10"
        "$mainMod ALT, right, movetoworkspace, +1"
        "$mainMod ALT, left, movetoworkspace, -1"
        "$mainMod ALT, k, movetoworkspace, +1"
        "$mainMod ALT, j, movetoworkspace, -1"
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod SHIFT, S, exec, hyprshot -m region"
        "$mainMod, Print, exec, hyprshot -m window"
        "SHIFT, Print, exec, hyprshot -m output"
      ];

      binde = [
        "$mainMod SHIFT, left, resizeactive, -50 0"
        "$mainMod SHIFT, right, resizeactive, 50 0"
        "$mainMod SHIFT, up, resizeactive, 0 -50"
        "$mainMod SHIFT, down, resizeactive, 0 50"
      ];

      bindel = [
        "ALT, F11, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "ALT, F10, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  # --- HYPRIDLE CONFIGURATION ---
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # --- HYPRLOCK CONFIGURATION ---
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "/home/luibi/Pictures/main/bluestairs.png";
          blur_passes = 2;
          contrast = 0.8916;
          brightness = 0.8172;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgb(151515)";
          inner_color = "rgb(200, 200, 200)";
          font_color = "rgb(10, 10, 10)";
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 64;
          font_family = "Noto Sans";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # --- HYPRPAPER CONFIGURATION (formato nuevo, hyprpaper >= 0.8) ---
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "/home/luibi/Pictures/lu/verde.jpg";
          fit_mode = "cover";
        }
      ];
    };
  };
}