-- llm-ls (huggingface): AI ghost-text completion only. No parsing, no
-- diagnostics, no project indexing — nothing that falls over on the
-- multi-MB megafiles that killed the old mason server fleet
-- (lua_ls/zls/vtsls/pyright/clangd/nixd/... — see git history for lsp.lua).
--
-- llm-ls exposes only custom methods (llm-ls/getCompletions etc.), so
-- llm.nvim is its required client and ghost-text UI. Accept <Tab>,
-- dismiss <S-Tab> (llm.nvim defaults).
return {
    {
        "huggingface/llm.nvim",
        config = function()
            -- Binary from nixpkgs (home.packages). Without bin_path,
            -- llm.nvim curl-downloads its own copy to stdpath("data").
            local llm_ls = vim.fn.exepath("llm-ls")

            require("llm").setup({
                -- llama-server on :8080 — same endpoint the old cmp-ai used.
                -- llm-ls appends /v1/completions itself; llama-server serves
                -- it and does not care about the model name.
                backend = "llamacpp",
                url = "http://127.0.0.1:8080",
                model = "local",
                -- FIM tokens must match the served model (check llama-server
                -- /props). StarCoder-style defaults; tune when swapping models.
                tokens_to_clear = {},
                fim = {
                    enabled = true,
                    prefix = "<fim_prefix>",
                    middle = "<fim_middle>",
                    suffix = "<fim_suffix>",
                },
                -- nil tokenizer: llm-ls counts characters instead of tokens,
                -- so nothing gets downloaded from the HF hub.
                tokenizer = nil,
                context_window = 4096,
                debounce_ms = 300,
                enable_suggestions_on_startup = true,
                lsp = {
                    bin_path = llm_ls ~= "" and llm_ls or nil,
                },
            })
        end,
    },
}
