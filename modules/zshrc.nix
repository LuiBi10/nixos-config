{ config, pkgs, lib, ... }:

let plugins = [ ]; # Zsh plugins: empty list to avoid conflicts
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = plugins;
      theme = "miloshadzic";
    };

    shellAliases = {
      # Custom aliases
      hyp = "sudo -E nvim /etc/nixos/modules/hyprland.nix";
      zh = "sudo -E nvim /etc/nixos/modules/zshrc.nix";
      way = "/etc/nixos/modules/hyprland.nix";
      home = "sudo -E nvim /etc/nixos/home.nix";
      flake = "sudo -E nvim /etc/nixos/flake.nix";
      pack = "sudo -E nvim /etc/nixos/modules/packages.nix";
      homepack = "sudo -E nvim /etc/nixos/modules/home-packages.nix";
      conf = "sudo -E nvim /etc/nixos/configuration.nix";
      build = "[ -f ~/.gtkrc-2.0 ] && rm ~/.gtkrc-2.0; sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      garbage = "sudo nix-collect-garbage -d";
      cat = "bat --theme=base16";
      ls = "eza --icons=always --color=always -a";
      ll = "eza --icons=always --color=always -la";
      reload = "source ~/.zshrc && echo 'Reloaded ~/.zshrc'";
      shut = "sudo shutdown now";
      y = "yazi";
    };

    initContent = ''
      # 🚀 Environment variables
      export VISUAL="nvim"
      export EDITOR="nvim"
      export PATH="$HOME/.local/bin:/usr/local/opt:/usr/bin:$PATH"
      export PATH="$PATH:$HOME/.cargo/bin"
      export NODE_EXTRA_CA_CERTS=""
      export SUDO_PROMPT=" Password: "
      export BAT_THEME="base16"
      export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
      export PATH="$HOME/Scripts:$PATH"

      export QT_QPA_PLATFORMTHEME=gtk2
      export KDE_USE_WALLET=false

      # 🚀 API Keys
      if [ -f ~/.zsh_secrets ]; then
        source ~/.zsh_secrets
      fi

      # 🧠 Zsh history settings
      HISTFILE=~/.zhistory
      HISTSIZE=5000
      SAVEHIST=5000
      HISTDUP=erase
      setopt appendhistory sharehistory hist_ignore_space \
             hist_ignore_all_dups hist_save_no_dups \
             hist_find_no_dups extended_history inc_append_history

      # ❌ Initialize completion (must be done before binding keys)
      autoload -U compinit && compinit

      # 🚀 Zoxide & Atuin initialization
      if command -v zoxide &> /dev/null; then
        eval "$(zoxide init zsh)"
      fi
      if command -v atuin &> /dev/null; then
        eval "$(atuin init zsh)"
      fi

      # 🚀 Function yz to open yazi with zoxide query
      unalias yz 2>/dev/null
      yz() {
        yazi "$(zoxide query "$@")"
      }

      # 🎯 Smart blank space (Pro Tip)
      typeset -g FIRST_PROMPT=1
      precmd() {
        if [[ -z "$FIRST_PROMPT" ]]; then
          print ""
        else
          unset FIRST_PROMPT
        fi
      }

      # IDEs detection and auto-start logic
      if [[ -o interactive && 
            -z "$VSCODE_INJECTION" && 
            -z "$CURSOR_SESSION" && 
            "$TERM_PROGRAM" != "vscode" && 
            -z "$VSCODE_PID" &&
            "$PWD" != *cursor* &&
            "$0" != *cursor* ]]; then
       
       if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
          exec tmux new-session
       fi
        fastfetch
      fi

      # 🎯 Completion style
      zstyle ':completion:*' menu select=1

      # ✅ KEY REBINDING
      bindkey -r '^I'
      bindkey '^I' autosuggest-accept
      # 2. Shift + Tab for traditional expansion menu fallback
      bindkey '^[[Z' menu-expand-or-complete

      # 3. Ctrl + E to edit the current command line in Neovim
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^e' edit-command-line

      # 4. Alt + C to navigate directories via Zoxide
      bindkey -s '^[c' 'zi^M'

      # 5. Smart history search using Arrow keys
      bindkey '^[[A' up-line-or-search
      bindkey '^[[B' down-line-or-search
    '';
  };

  home.sessionVariables = {
    ZSH_AUTOSUGGEST_STRATEGY = "match_prev_cmd";
    ZSH_AUTOSUGGEST_USE_ASYNC = "1";
  };
}

