-- Single source of truth for formatting. All binaries come from the nix
-- closure (home.packages) — no mason. Chosen for speed on large files:
-- biome/clang-format/ruff/alejandra are Rust/C and chew through MB-sized
-- buffers that make prettier-style JS tooling crawl.
return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                -- Web: Biome (fast) replaces prettier for JS/TS/JSON/CSS/HTML
                javascript = { "biome" },
                typescript = { "biome" },
                javascriptreact = { "biome" },
                typescriptreact = { "biome" },
                json = { "biome" },
                html = { "biome" },
                css = { "biome" },
                -- Biome's markdown/yaml support is still experimental
                markdown = { "prettier" },
                yaml = { "prettier" },
                -- C/C++
                c = { "clang_format" },
                cpp = { "clang_format" },
                -- Python: format + import sort in one binary
                python = { "ruff_format" },
                -- Nix: alejandra (fast, zero config)
                nix = { "alejandra" },
                -- Lua
                lua = { "stylua" },
                -- Shells
                sh = { "shfmt" },
                bash = { "shfmt" },
                zsh = { "shfmt" },
                -- Bend: no CLI formatter exists. bend2-fmt-lsp (started on
                -- FileType below) formats; lsp_format = "fallback" picks it
                -- up since no conform formatter is registered for bend.
            },
            format_on_save = {
                timeout_ms = 5000,
                lsp_format = "fallback",
            },
        })

        -- Capital F: f-prefix is reserved for Telescope (telescope.lua).
        vim.keymap.set("n", "<leader>F", function()
            require("conform").format({ bufnr = 0 })
        end, { desc = "Format buffer" })

        -- Bend 2 formatter server: formatting only, no diagnostics/completion.
        -- Runs on Node 22+; binary from home.packages (built from
        -- bendlang/bend tools/bend-fmt-lsp).
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "bend",
            callback = function()
                vim.lsp.start({
                    name = "bend2-fmt-lsp",
                    cmd = { "bend2-fmt-lsp", "--stdio" },
                    root_dir = vim.fs.root(0, { ".git" }),
                })
            end,
        })
    end,
}
