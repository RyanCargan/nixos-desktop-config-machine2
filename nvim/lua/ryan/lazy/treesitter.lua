-- Buffers larger than this get no treesitter highlight (entry parse is
-- synchronous). 0 = always highlight.
local MAX_HIGHLIGHT_BYTES = 20 * 1024 * 1024

vim.filetype.add({
    extension = {
        bend = "bend",
        slang = "hlsl",
        hlsl = "hlsl",
        wat = "wat",
        wasm = "wat",
    },
})

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        init = function()
            local parsers = {
                "c",
                "cpp",
                "lua",
                "nix",
                "zig",
                "javascript",
                "html",
                "css",
                "json",
                "vim",
                "vimdoc",
                "query",
                "gitignore",
                "markdown",
                "markdown_inline",
                "sql",
                "scheme",
                "bash",
                "wgsl",
                "hlsl",
                "rust",
                "asm",
            }

            local group = vim.api.nvim_create_augroup("RyanTreesitter", { clear = true })
            vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
                group = group,
                callback = function()
                    if vim.bo.buftype ~= "" then
                        return
                    end
                    if vim.bo.filetype == "wat" then
                        return
                    end

                    -- Megafiles: parsing multi-MB buffers blocks the UI on
                    -- first attach (single-threaded parse). Treesitter itself
                    -- is incremental after that, so the cap only governs
                    -- entry; 20 MiB costs ~1-3s once, then stays interactive.
                    -- Set to 0 to disable the check entirely.
                    local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
                    if MAX_HIGHLIGHT_BYTES > 0 and stat and stat.size > MAX_HIGHLIGHT_BYTES then
                        return
                    end

                    pcall(vim.treesitter.start, 0)
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    require("nvim-treesitter").install(parsers)
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = false,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                    },
                },
            })
        end,
    },
}
