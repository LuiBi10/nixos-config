# NixOS Workspace Context & Instructions

This workspace manages the NixOS system and Home Manager configuration for the user `luibi`.

## Project Structure
All NixOS configuration files are located under `/etc/nixos` and its subdirectories:
*   `/etc/nixos/flake.nix` - Main system entrypoint using Nix Flakes.
*   `/etc/nixos/configuration.nix` - Core NixOS system configuration.
*   `/etc/nixos/home.nix` - Home Manager configuration.
*   `/etc/nixos/modules/` - Modular configuration imports:
    *   `hyprland.nix` - Hyprland window manager configuration (using Lua).
    *   `packages.nix` - System-wide package declarations.
    *   `home-packages.nix` - User-level package declarations.
    *   `zshrc.nix` - Zsh shell configuration (also enables Starship).
    *   `starship-aqua.toml` - Custom Starship prompt theme, loaded by `zshrc.nix`.
    *   `scripts/` - Custom shell scripts (keyboard layout, volume control, wallpaper management).

## Key Workflows & Commands

### 1. Rebuilding and Switching System Configuration
Always rebuild the system configuration using the Nix Flake:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```
The user's zsh alias `build` does this (it first removes `~/.gtkrc-2.0`, see below).

**Flakes only see files tracked by git.** After creating a new file under `/etc/nixos`, run `git -C /etc/nixos add <file>` or the build will fail to find it.

### 2. Standard Diagnostics
To dry-build and verify the system configuration compiles without switching:
```bash
nixos-rebuild build --flake /etc/nixos#nixos
```

## Architecture & Conventions

### Hyprland Lua Configuration (`hyprland.nix`)
Hyprland is configured using a custom Lua generator (`configType = "lua"`). It uses Nix helpers (`b`, `be`, `bel`, `bl`, `bm`) to generate bindings written to `~/.config/hypr/hyprland.lua`.

*   **Quoting Rule**: When nesting strings inside Nix double-quotes, use outer single-quotes (`'`) for the generated Lua command and escaped double-quotes (`\"`) inside it to avoid syntax issues.
    *   *Correct*: `(b "SUPER + P" "hl.dsp.exec_cmd('cliphist list | rofi -dmenu -p \"Clipboard\" | cliphist decode | wl-copy')")`
    *   *Incorrect*: Using nested single-quotes (`\'`), which evaluates to raw single-quotes (`'`) and breaks Lua string parsing.

### Home Manager Backup Clobbering
Home Manager is configured with `backupFileExtension = "backup"`. If activation fails with an error like:
```
Existing file '/home/luibi/...backup' would be clobbered
```
Manually delete the conflicting backup file from the home directory and re-run the rebuild switch command:
```bash
rm -f /home/luibi/<conflicting_file>.backup
```
The usual culprit is `~/.gtkrc-2.0`, which KDE's kded6 `gtkconfig` module used to rewrite as a regular file (see "KDE / GTK conflict" below).

### Starship prompt ("Aqua" theme)
*   Custom theme in `modules/starship-aqua.toml`, loaded in `zshrc.nix` with `builtins.fromTOML (builtins.readFile ./starship-aqua.toml)`. It replaced the `tokyo-night` preset.
*   Colors come from the kitty theme (`~/.config/kitty/current-theme.conf`) and are defined once in `[palettes.aqua]`: `teal #54ceb4`, `mint #88f2dc`, `deep #1c3530`, `shade #15201e`, `night #2e4a44` (time/duration segment, lightened on purpose so it is visible), `muted #6272a4`.
*   `add_newline = true`: the user wants a blank line between commands.
*   Test a change without rebuilding: `STARSHIP_CONFIG=/etc/nixos/modules/starship-aqua.toml starship prompt`.

### Wallpapers: awww (not hyprpaper)
*   `services.awww.enable = true` in `hyprland.nix` replaced `services.hyprpaper`.
*   Reason: hyprpaper 0.8 removed the current wallpaper and decoded the full-size image (3000-5640 px wide, screen is 1366x768) before showing it, so the Hyprland default background flashed for a while. Also `hyprctl hyprpaper preload` no longer exists in 0.8 ("invalid hyprpaper request").
*   `~/.config/hypr/scripts/change-wall-final.sh` (bound to `SUPER + CTRL + Space`, also run every 5 min by `hypr-wallpaper-auto.service`) now calls `awww img "$WALLPAPER" --resize crop --transition-type fade --transition-duration 0.8 --transition-fps 60`.
*   The `hyprpaper` package is still listed in `home-packages.nix` but its service is no longer enabled.

### KDE / GTK conflict (Dolphin crashing waybar and Zen)
*   **Symptom**: the first time Dolphin opened in a Hyprland session, waybar restarted and Zen browser (and nm-applet) crashed. Later launches were fine.
*   **Cause**: Dolphin D-Bus-activates `kded6`. Its `gtkconfig` module rewrote `~/.config/gtk-3.0/gtk.css`, `gtk-4.0/gtk.css`, `colors.css`, `xsettingsd.conf` and `~/.gtkrc-2.0`. GTK apps watching those files crashed in `g_file_monitor_source_dispatch`. It also broke Home Manager activation (clobbered `~/.gtkrc-2.0`).
*   **Fix**: `gtkconfig` autoload disabled in **`~/.config/kded5rc`** (`[Module-gtkconfig] autoload=false`). kded6 (KF6) still reads `kded5rc`, NOT `kded6rc`. Safest way to change it: `busctl --user call org.kde.kded6 /kded org.kde.kded6 setModuleAutoloading sb gtkconfig false`; verify with `isModuleAutoloaded s gtkconfig`.
*   Side effect: in a Plasma session, GTK apps no longer follow Plasma theme changes.
*   The `rm ~/.gtkrc-2.0` in the `build` alias was a workaround for this; it may become unnecessary.

### Zsh (`zshrc.nix`)
*   Oh My Zsh already runs `compinit`; do not call it again in `initContent`.
*   `QT_QPA_PLATFORMTHEME` is set only by Hyprland (`env` in `hyprland.nix`), not in zsh, so terminal and launcher apps get the same Qt theme.
*   Code comments in `hyprland.nix` and `zshrc.nix` are in English and should stay that way.

## Change Log
*   **2026-09-26**: Starship "Aqua" theme; awww replaces hyprpaper; comments in `hyprland.nix`/`zshrc.nix` rewritten in English; fixed `way` alias (was missing `sudo -E nvim`), removed duplicate `compinit`, removed `QT_QPA_PLATFORMTHEME=gtk2` and dead `KDE_USE_WALLET` line from zsh; disabled kded6 `gtkconfig` module.

## Session Preferences
*   **Language**: All explanations, code, and notes must be in **English**, even if the user communicates in Spanish.
