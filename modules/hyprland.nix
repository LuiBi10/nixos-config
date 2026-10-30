{ config, pkgs, lib, ... }:

let
  # User home directory, used to build absolute paths
  home = config.home.homeDirectory;

  # Helper to write raw Lua inline
  lua = lib.generators.mkLuaInline;

  # Bind helpers: b = normal, be = repeats while held, bl = also works on the
  # lock screen, bel = both, bm = mouse button
  b = keys: disp: { _args = [ keys (lua disp) ]; };
  be = keys: disp: { _args = [ keys (lua disp) { repeating = true; } ]; };
  bel = keys: disp: { _args = [ keys (lua disp) { repeating = true; locked = true; } ]; };
  bl = keys: disp: { _args = [ keys (lua disp) { locked = true; } ]; };
  bm = keys: disp: { _args = [ keys (lua disp) { mouse = true; } ]; };

  # Workspace binds for keys 1-9 and 0 (= workspace 10): focus, move window,
  # move window without following it
  wsBinds = builtins.concatLists (
    builtins.genList
      (i:
        let
          key = toString (if i == 9 then 0 else i + 1);
          ws = toString (i + 1);
        in
        [
          (b "SUPER + ${key}" "hl.dsp.focus({ workspace = ${ws} })")
          (b "SUPER + CTRL + ${key}" "hl.dsp.window.move({ workspace = ${ws} })")
          (b "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${ws}, follow = false })")
        ]
      ) 10
  );
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    settings = {
      monitor = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        }
      ];

      env = [
        { _args = [ "QT_QPA_PLATFORM" "wayland" ]; }
        { _args = [ "QT_QPA_PLATFORMTHEME" "kvantum" ]; }
        { _args = [ "GTK_THEME" "Dracula" ]; }
        { _args = [ "QT_STYLE_OVERRIDE" "kvantum" ]; }
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "XCURSOR_THEME" "Qogir Cursors" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
        { _args = [ "HYPRCURSOR_THEME" "Qogir Cursors" ]; }
      ];

      # Programs started with Hyprland
      on = {
        _args = [
          "hyprland.start"
          (lua ''
            function()
              hl.exec_cmd("${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent")
              hl.exec_cmd("kitty")
              hl.exec_cmd("nm-applet")
              hl.exec_cmd("crow")
              hl.exec_cmd("wl-paste --type text --watch cliphist store")
              hl.exec_cmd("wl-paste --type image --watch cliphist store")
              hl.exec_cmd("dbus-update-activation-environment --systemd --all && systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS GIO_EXTRA_MODULES && systemctl --user start hyprland-session.target")
              hl.exec_cmd("${home}/.config/hypr/scripts/spotify_notifier.sh")
            end
          '')
        ];
      };

      config = {
        input = {
          kb_layout = "us,es";
          kb_options = "grp:alt_shift_toggle";
          follow_mouse = 1;
          touchpad.natural_scroll = false;
          sensitivity = 0;
        };

        general = {
          gaps_in = 2;
          gaps_out = 9;
          border_size = 1;
          "col.active_border" = "rgb(b4befe)";
          "col.inactive_border" = "rgba(a7c080aa)";
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 4;
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

        dwindle.preserve_split = true;

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = false;
        };
      };

      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
      ];

      # Layer rules: blur behind rofi's translucent background
      layer_rule = [
        {
          blur = true;
          ignore_alpha = 0.3;
          match = { namespace = "^rofi$"; };
        }
      ];

      # Window rules: per-app workspace, opacity, floating and size
      window_rule = [
        {
          opacity = "0.85 override";
          workspace = "4";
          match = { class = "^(discord)$"; };
        }
        {
          opacity = "0.85 override";
          workspace = "3";
          match = { class = "^(org.kde.dolphin)$"; };
        }
        {
          opacity = "0.95 0.90 override";
          workspace = "2";
          match = { class = "^(zen-twilight)$"; };
        }
        {
          workspace = "3";
          match = { class = "^(md.Obsidian)$"; };
        }
        {
          workspace = "3";
          match = { class = "^(Spotify)$"; };
        }
        {
          workspace = "4";
          match = { class = "^(org.pwmt.zathura)$"; };
        }
        {
          float = true;
          match = { title = "^(Save File)$"; };
        }
        {
          float = true;
          size = [ 700 600 ];
          center = true;
          match = { title = "^(kitty-floating)$"; };
        }
        {
          float = true;
          center = true;
          opacity = "1.0 override";
          match = { class = "^([Vv]irtual[Bb]ox Manager)$"; };
        }
        {
          float = true;
          size = [ "75%" "75%" ];
          center = true;
          match = { class = "^(kitty-yazi)$"; };
        }
        {
          float = true;
          size = [ "85%" "85%" ];
          center = true;
          match = { class = "^(kitty-nvim)$"; };
        }
      ];

      bind = [
        # --- Window focus ---
        (b "SUPER + left" "hl.dsp.focus({ direction = 'left' })")
        (b "SUPER + right" "hl.dsp.focus({ direction = 'right' })")
        (b "SUPER + up" "hl.dsp.focus({ direction = 'up' })")
        (b "SUPER + down" "hl.dsp.focus({ direction = 'down' })")

        # --- Session and Waybar ---
        (b "SUPER + SHIFT + R" "hl.dsp.exec_cmd('pkill waybar && waybar')")
        (b "SUPER + SHIFT + Q" "hl.dsp.exit()")

        # --- Window management ---
        (b "SUPER + W" "hl.dsp.window.fullscreen()")
        (b "SUPER + Q" "hl.dsp.window.close()")
        (b "ALT + Space" "hl.dsp.window.float({ action = 'toggle' })")
        (b "SUPER + CTRL + P" "hl.dsp.window.pin({ action = 'toggle' })")

        # --- Apps and tools ---
        (b "SUPER + Return" "hl.dsp.exec_cmd('kitty')")
        (b "SUPER + CTRL + Return" "hl.dsp.exec_cmd('kitty --title=kitty-floating')")
        (b "SUPER + SHIFT + B" "hl.dsp.exec_cmd('kitty -e btop')")
        (b "SUPER + Space" "hl.dsp.exec_cmd('rofi -show drun')")
        (b "SUPER + F" "hl.dsp.exec_cmd('XDG_CURRENT_DESKTOP=KDE dolphin')")
        (b "SUPER + SHIFT + K" "hl.dsp.exec_cmd('XDG_CURRENT_DESKTOP=KDE kate')")
        (b "SUPER + Y" "hl.dsp.exec_cmd('kitty --class kitty-yazi -e yazi')")
        (b "SUPER + N" "hl.dsp.exec_cmd('kitty --class kitty-nvim -e nvim')")
        (b "SUPER + SHIFT + V" "hl.dsp.exec_cmd('code')")
        (b "SUPER + B" "hl.dsp.exec_cmd('zen-twilight')")
        (b "SUPER + D" "hl.dsp.exec_cmd('discord')")
        (b "SUPER + M" "hl.dsp.exec_cmd('spotify')")
        (b "SUPER + O" "hl.dsp.exec_cmd('obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland')")
        (b "ALT + CTRL + C" "hl.dsp.exec_cmd(\"zsh -l -c 'cursor'\")")
        (b "SUPER + CTRL + Space" "hl.dsp.exec_cmd('${home}/.config/hypr/scripts/change-wall-final.sh')")
        (b "SUPER + C" "hl.dsp.exec_cmd('hyprpicker -a')")
        (b "SUPER + L" "hl.dsp.exec_cmd('hyprlock')")
        (b "SUPER + K" "hl.dsp.exec_cmd('/etc/nixos/modules/scripts/keyboard.sh')")
        (b "SUPER + T" "hl.dsp.exec_cmd('/etc/nixos/modules/scripts/crow-translate.sh')")
        (b "SUPER + P" "hl.dsp.exec_cmd('cliphist list | rofi -dmenu -no-show-icons -p \"Clipboard\" | cliphist decode | wl-copy')")
        (b "SUPER + ALT + space" "hl.dsp.exec_cmd('${home}/.config/hypr/scripts/powermenu.sh')")

        # Universal paste: terminals take CTRL + SHIFT + V, everything else CTRL + V
        (b "SUPER + V" ''
          function()
            local w = hl.get_active_window()
            local class = (w and w.class or ""):lower()
            local terminals = { "^kitty", "alacritty", "foot", "wezterm", "ghostty", "konsole" }
            local mods = "CTRL"
            for _, pattern in ipairs(terminals) do
              if class:find(pattern) then mods = "CTRL SHIFT" break end
            end
            hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = "V" }))
          end
        '')

        # --- Workspaces and screenshots ---
        (b "SUPER + CTRL + S" "hl.dsp.window.move({ workspace = 'special' })")
        (b "SUPER + S" "hl.dsp.workspace.toggle_special()")
        (b "SUPER + Tab" "hl.dsp.focus({ workspace = 'previous' })")
        (b "SUPER + CTRL + J" "hl.dsp.focus({ workspace = 'r-1' })")
        (b "SUPER + CTRL + K" "hl.dsp.focus({ workspace = 'r+1' })")
        (b "SUPER + ALT + right" "hl.dsp.window.move({ workspace = 'r+1' })")
        (b "SUPER + ALT + left" "hl.dsp.window.move({ workspace = 'r-1' })")
        (b "SUPER + ALT + k" "hl.dsp.window.move({ workspace = 'r+1' })")
        (b "SUPER + ALT + j" "hl.dsp.window.move({ workspace = 'r-1' })")
        (b "SUPER + SHIFT + S" "hl.dsp.exec_cmd('hyprshot -m region -o ~/Pictures/Screenshots')")
        (b "SUPER + Print" "hl.dsp.exec_cmd('hyprshot -m window -o ~/Pictures/Screenshots')")
        (b "SHIFT + Print" "hl.dsp.exec_cmd('hyprshot -m output -o ~/Pictures/Screenshots')")

        # --- Resize active window (repeats while held) ---
        (be "SUPER + SHIFT + left" "hl.dsp.window.resize({ x = -50, y = 0, relative = true })")
        (be "SUPER + SHIFT + right" "hl.dsp.window.resize({ x = 50, y = 0, relative = true })")
        (be "SUPER + SHIFT + up" "hl.dsp.window.resize({ x = 0, y = -50, relative = true })")
        (be "SUPER + SHIFT + down" "hl.dsp.window.resize({ x = 0, y = 50, relative = true })")

        # --- Volume (repeats while held, works when locked) ---
        (bel "ALT + F11" "hl.dsp.exec_cmd('/etc/nixos/modules/scripts/volumecontrol.sh --inc')")
        (bel "ALT + F10" "hl.dsp.exec_cmd('/etc/nixos/modules/scripts/volumecontrol.sh --dec')")

        # --- Media keys (work when locked) ---
        (bl "XF86AudioMute" "hl.dsp.exec_cmd('/etc/nixos/modules/scripts/volumecontrol.sh --toggle')")
        (bl "XF86AudioPlay" "hl.dsp.exec_cmd('playerctl play-pause')")
        (bl "XF86AudioNext" "hl.dsp.exec_cmd('playerctl next')")
        (bl "XF86AudioPrev" "hl.dsp.exec_cmd('playerctl previous')")

        # --- Mouse: SUPER + left drag moves, SUPER + right drag resizes ---
        (bm "SUPER + mouse:272" "hl.dsp.window.drag()")
        (bm "SUPER + mouse:273" "hl.dsp.window.resize()")
      ] ++ wsBinds; # Generated workspace binds (see let block)
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
        # Lock after 5 minutes idle
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        # Turn the screen off 30 seconds later
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
      general = {
        no_fade_in = false;
        no_fade_out = false;
        hide_cursor = true;
        grace = 0;
        disable_loading = true;
      };

      background = [
        {
          monitor = "";
          path = "${home}/Pictures/main/hyprlock.jpg";
          color = "rgba(23, 27, 33, 1.0)";
          blur_passes = 2;
          blur_size = 5;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(80, 188, 223, 1.0)";
          inner_color = "rgba(23, 27, 33, 0.5)";
          font_color = "rgba(166, 172, 205, 1.0)";
          fade_on_empty = false;
          placeholder_text = "<span foreground=\"##a6accd\">Password...</span>";
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
          color = "rgba(166, 172, 205, 1.0)";
          font_size = 120;
          font_family = "JetBrainsMono Nerd Font ExtraBold";
          position = "0, -100";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:43200000] echo \"$(date +\"%A, %d %B %Y\")\"";
          color = "rgba(166, 172, 205, 0.8)";
          font_size = 25;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "Welcome back, $USER";
          color = "rgba(166, 172, 205, 1.0)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "        󰤄";
          color = "rgba(166, 172, 205, 0.6)";
          font_size = 25;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 50";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };

  # --- WALLPAPER DAEMON (awww) ---
  # Keeps the current wallpaper visible while the next one loads and
  # animates the change; restores the last wallpaper on login.
  services.awww.enable = true;
}
