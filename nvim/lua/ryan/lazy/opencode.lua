-- OpenCode integration: ask/select from inside nvim, edits flow back into
-- buffers via the OpenCode server (binary on PATH via HM envExtra).
return {
    {
        "nickjvandyke/opencode.nvim",
        config = function()
            vim.keymap.set({ "n", "x" }, "<C-a>", function()
                require("opencode").ask("@this: ")
            end, { desc = "Ask OpenCode" })
            vim.keymap.set({ "n", "x" }, "<C-x>", function()
                require("opencode").select()
            end, { desc = "Select OpenCode" })
            vim.keymap.set({ "n", "x" }, "go", function()
                return require("opencode").operator("@this")
            end, { expr = true, desc = "Send range to OpenCode" })
        end,
    },
}
