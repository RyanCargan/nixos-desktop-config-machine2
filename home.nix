{ config, pkgs, inputs, ... }:

{
  # Set once to current release branch; never change. Upgrading this
  # value triggers migration logic; bump only when reading release notes
  # and intentionally migrating config.
  home.stateVersion = "26.05";

  # Your user; must match the username on the live system.
  home.username = "ryan";

  # Standard Linux home directory.
  home.homeDirectory = "/home/ryan";

  # ---- neovim (config only; lazy.nvim self-manages plugins) ----
  programs.neovim = {
    enable = true;

    # Editor settings from lua/ryan/set.lua
    vimOptions = {
      guicursor = "";
      number = true;
      relativenumber = true;
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      undodir = "/home/ryan/.vim/undodir";
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      isfname = "@-@";
      updatetime = 50;
      colorcolumn = "80";
    };

    # Leader + keymaps from lua/ryan/remap.lua + init.lua autocmds
    extraConfig = ''
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
      nnoremap <leader>x :!chmod +x %<CR><CR>

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
    # If you want HM to pin specific plugin versions, use extraPackages.
    # extraPackages = with pkgs.vimPlugins; [ plenary cellular-automaton ];
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
  ];

  # ---- zsh (skeleton; expand with actual config from .zshrc) ----
  programs.zsh = {
    enable = true;
    # Full config will be migrated from .zshrc incrementally
  };
}