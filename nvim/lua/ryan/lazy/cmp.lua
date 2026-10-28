-- Plain nvim-cmp: buffer words, paths, snippets. No LSP source, no AI
-- source (cmp-ai removed). The only attached servers are llm-ls (custom
-- methods, no standard completion) and bend2-fmt-lsp (formatting only),
-- so a completion-capable LSP source would be dead weight.
return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                sources = cmp.config.sources({
                    { name = "luasnip", max_item_count = 5 },
                    { name = "path" },
                }, {
                    { name = "buffer", max_item_count = 6 },
                }),
                sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.length,
                    },
                },
                formatting = {
                    format = function(entry, vim_item)
                        local names = {
                            luasnip = "[Snip]",
                            buffer = "[Buf]",
                            path = "[Path]",
                        }
                        vim_item.menu = names[entry.source.name] or ""
                        return vim_item
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
            })
        end,
    },
}
