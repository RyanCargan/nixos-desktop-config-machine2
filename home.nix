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
    defaultKeymap = "vi";

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

  # ---- neovim (config only; lazy.nvim self-manages plugins) ----
  programs.neovim = {
    enable = true;

    # All editor settings + keymaps + autocmds from lua/ryan/{set,remap,init}.lua
    extraConfig = ''
      " --- Options (from lua/ryan/set.lua) ---
      set guicursor=""
      set number relativenumber
      set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
      set smartindent
      set nowrap
      set noswapfile nobackup
      set undofile undodir=/home/ryan/.vim/undodir
      set nohlsearch incsearch
      set termguicolors
      set scrolloff=8 signcolumn=yes
      set isfname+=@-@
      set updatetime=50
      set colorcolumn=80

      " --- Leader + keymaps (from lua/ryan/remap.lua + init.lua) ---
      let mapleader = " "

      " File explorer
      nnoremap <leader>pv :Ex<CR>

      " Move lines in visual mode
      vnoremap J :m '>+1<CR>gv=gv
      vnoremap K :m '<-2<CR>gv=gv

      " Center cursor on scroll/search
      nnoremap <C-d> <C-d>zz
      nnoremap <C-u> <C-u>zz
      nnoremap n nzzzv
      nnoremap N Nzzzv
      nnoremap <C-k> :cnext<CR>zz
      nnoremap <C-j> :cprev<CR>zz
      nnoremap <leader>k :lnext<CR>zz
      nnoremap <leader>j :lprev<CR>zz

      " Paste without overwriting register
      xnoremap <leader>p "_dP

      " System clipboard
      nnoremap <leader>y "+y
      vnoremap <leader>y "+y
      nnoremap <leader>Y "+Y
      nnoremap <leader>d "_d

      " Esc in insert mode
      inoremap <C-c> <Esc>

      " Disable Ex mode
      nnoremap Q <nop>

      " Search/replace word under cursor
      nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

      " Make executable
      nnoremap <leader>x :!chmod +x %<CR>

      " Go error templates
      nnoremap <leader>ee oif err != nil {<CR>}<Esc>Oreturn err<Esc>
      nnoremap <leader>ea oassert.NoError(err, "")<Esc>F\";a
      nnoremap <leader>ef oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\n", err.Error())<Esc>jj
      nnoremap <leader>el oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i

      " Source current file
      nnoremap <leader><leader> :so %<CR>

      " LSP keymaps (set on LspAttach)
      autocmd LspAttach * nested call s:SetupLspKeymaps()
      function! s:SetupLspKeymaps() abort
        nnoremap <buffer> gd <cmd>lua vim.lsp.buf.definition()<CR>
        nnoremap <buffer> K <cmd>lua vim.lsp.buf.hover()<CR>
        nnoremap <buffer> <leader>vws <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
        nnoremap <buffer> <leader>vd <cmd>lua vim.diagnostic.open_float()<CR>
        nnoremap <buffer> <leader>vca <cmd>lua vim.lsp.buf.code_action()<CR>
        nnoremap <buffer> <leader>vrr <cmd>lua vim.lsp.buf.references()<CR>
        nnoremap <buffer> <leader>vrn <cmd>lua vim.lsp.buf.rename()<CR>
        inoremap <buffer> <C-h> <cmd>lua vim.lsp.buf.signature_help()<CR>
        nnoremap <buffer> [d <cmd>lua vim.diagnostic.goto_next()<CR>
        nnoremap <buffer> ]d <cmd>lua vim.diagnostic.goto_prev()<CR>
      endfunction

      " Yank highlight
      autocmd TextYankPost * lua vim.highlight.on_yank({ higroup = "IncSearch", timeout = 40 })

      " Trim trailing whitespace on save
      autocmd BufWritePre * %s/\s\+$//e

      " Colorscheme per filetype
      autocmd BufEnter * if &ft == "zig" | colorscheme tokyonight-night | else | colorscheme rose-pine-moon | endif

      " Netrw tweaks
      let g:netrw_browse_split = 0
      let g:netrw_banner = 0
      let g:netrw_winsize = 25
    '';

    # Plugins are managed by lazy.nvim on first launch (self-managed).
    # extraPackages = with pkgs.vimPlugins; [ plenary cellular-automaton ];
  };

  # ---- git (minimal; you can expand) ----
  programs.git = {
    enable = true;
    userName = "Ryan Cargan";
    userEmail = "ryan@codinghermit.net";
    extraConfig = {
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
    nixfmt-rfc-style

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
    z.lua
  ];

  # XDG configs not covered by programs.* modules
  xdg.configFile = {
    "maki/init.lua".text = ''
      -- maki config (placeholder; copy from dotfiles if needed)
    '';
    "sqls/config.yml".text = ''
      # sqls config (placeholder; copy from dotfiles if needed)
    '';
    "luarc.json".text = builtins.readFile ./luarc.json;
  };
}