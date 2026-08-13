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
    *   `zshrc.nix` - Zsh shell configuration.
    *   `scripts/` - Custom shell scripts (keyboard layout, volume control, wallpaper management).

## Key Workflows & Commands

### 1. Rebuilding and Switching System Configuration
Always rebuild the system configuration using the Nix Flake:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

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

## Session Preferences
*   **Language**: All explanations, code, and notes must be in **English**, even if the user communicates in Spanish.
