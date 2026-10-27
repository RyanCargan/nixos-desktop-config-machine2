{ config, pkgs, inputs, ... }:

{
  home.stateVersion = "26.05";
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  # ---- zsh (full migration from .zshrc) ----
  programs.zsh = {
    enable = true;

    # History & completion
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    # Vi mode
    defaultKeymap = "viins";

    # Session variables (exports)
    sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      ANDROID_HOME = "$HOME/Android/Sdk";
      BROWSER = "firefox-nightly";
      PGUSER = "admin";
      PGDATABASE = "central";
      UV_LINK_MODE = "clone";
      UV_CACHE_DIR = "/run/media/ryan/nixos/.cache/uv/";
      UV_PYTHON_PREFERENCE = "only-managed";
      UV_CONCURRENT_DOWNLOADS = "3";
      UV_NATIVE_TLS = "1";
      FZF_DEFAULT_COMMAND = "fd --type f";
      BUN_INSTALL = "$HOME/.bun";
    };

    # Path additions
    envExtra = ''
      export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$HOME/.npm-packages/bin:$HOME/.deno/bin:$HOME/.cargo/bin:$HOME/Tools:$HOME/Tools/cabbage/bin:$HOME/.local/bin:$HOME/.opencode/bin:$BUN_INSTALL/bin:$HOME/.elan/bin:$PATH"
    '';

    # Shell aliases
    shellAliases = {
      "man-web" = "man --html";
      "nix-stray-roots" = "nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\\w+-system|\\{memory)\"";
      "set-key" = "eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa";
      "setup-ssh" = "eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa";
      "list-path" = "tr ':' '\\n' <<< \"$PATH\"";
      "refresh-desktop" = "xfce4-panel -r && xfwm4 --replace &";
      "unlock_ssh" = "ssh-add ~/.ssh/id_rsa";
      "unlock_ssh2" = "ssh-add ~/.ssh/id_rsa2";
      "unlock_ssh3" = "ssh-add ~/.ssh/id_rsa3";
      "unlock_ssh4" = "ssh-add ~/.ssh/id_rsa4";
      "lock_ssh" = "ssh-add -d ~/.ssh/id_rsa";
      "lock_ssh2" = "ssh-add -d ~/.ssh/id_rsa2";
      "lock_ssh3" = "ssh-add -d ~/.ssh/id_rsa3";
      "lock_ssh4" = "ssh-add -d ~/.ssh/id_rsa4";
      "unlock_ed25519" = "ssh-add ~/.ssh/id_ed25519";
      "lock_ed25519" = "ssh-add -d ~/.ssh/id_ed25519";
      "nvg" = "nvim -c 'tab Git'";
    };

    # Interactive shell init (functions, hooks, evals)
    initContent = builtins.readFile ./shell/zsh-interactive-init.sh;
  };

  # ---- bash (fallback shell; from .bashrc/.bash_profile) ----
  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ./bash/.bashrc;
    profileExtra = builtins.readFile ./bash/.bash_profile;
  };

  # ---- neovim (config only; lazy.nvim self-manages plugins) ----
  # Lua config files are managed via xdg.configFile below (readDir of ./nvim).
  # extraConfig deliberately omitted: nvim prefers init.lua over HM's init.vim,
  # so a vimscript port would be dead code.
  programs.neovim.enable = true;

  # ---- git (minimal; you can expand) ----
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Ryan Cargan";
        email = "ryan@codinghermit.net";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      merge.tool = "nvimdiff";
    };
  };

  # ---- starship (from .config/starship.toml) ----
  programs.starship = {
    enable = true;
    settings = {
      aws = { disabled = true; };
      # Add more modules as needed
    };
  };

  # ---- wezterm (from .wezterm.lua) ----
  programs.wezterm = {
    enable = true;
    # Wezterm config is Lua; use extraConfig to pass it through
    extraConfig = ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.initial_cols = 120
      config.initial_rows = 28
      config.font_size = 10
      config.color_scheme = 'AdventureTime'
      config.window_background_opacity = 0.85
      config.automatically_reload_config = true
      config.enable_scroll_bar = true
      config.colors = config.colors or {}
      config.colors.scrollbar_thumb = '#888888'
      wezterm.on("update-status", function(window, pane)
        local overrides = window:get_config_overrides() or {}
        overrides.enable_scroll_bar = not pane:is_alt_screen_active()
        window:set_config_overrides(overrides)
      end)
      config.keys = config.keys or {}
      table.insert(config.keys, { key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) })
      table.insert(config.keys, { key = "Tab", mods = "SHIFT|CTRL", action = wezterm.action.ActivateTabRelative(-1) })
      table.insert(config.keys, { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") })
      return config
    '';
  };

  # ---- packages: formatters/tools from dev-pkgs.nix (incremental) ----
  home.packages = with pkgs; [
    # Formatter stack (replaces mason-managed prettier/stylua/ruff/shfmt/nixfmt)
    ruff
    biome
    clang-tools       # includes clang-format, clang-tidy
    prettier
    stylua
    shfmt
    nixfmt

    # Core dev tools
    git
    jq
    fzf
    ripgrep
    fd
    tree
    shellcheck
    go
    soupault

    # Additional from dev-pkgs.nix
    yt-dlp
    tcpdump
    rsync
    direnv
    lua5_1
    starship
    z-lua
  ];

  # XDG configs not covered by programs.* modules
  xdg.configFile = {
    "maki/init.lua".text = "";  # 0 bytes in dotfiles and live — declare ownership only
    "sqls/config.yml".source = ./sqls/config.yml;
    "luarc.json".text = builtins.readFile ./luarc.json;

    # Hyprland is the default session (configuration.nix); waybar its bar.
    "hypr/hyprland.conf".source = ./hypr/hyprland.conf;
    "hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    "waybar/config".source = ./waybar/config;
    "waybar/style.css".source = ./waybar/style.css;

    # Neovim lua config: every file under ./nvim except lazy-lock.json
    # (state — lazy.nvim rewrites it on install/update).
  } // pkgs.lib.listToAttrs (
    map
      (f: {
        name = "nvim/" + pkgs.lib.removePrefix (toString ./nvim + "/") (toString f);
        value.source = f;
      })
      (pkgs.lib.filesystem.listFilesRecursive ./nvim)
  );

  # LLM/ASR scripts (deployed to ~/models/ per sync-dotfiles.zsh mapping)
  home.file = {
    "models/asr-hold.zsh".source = ./scripts/asr-hold.zsh;
    "models/run-llm.zsh".source = ./scripts/run-llm.zsh;
  };
}