require('lze').load {
  {
    "nvim-lint",
    enable = nixCats("lint"),
    -- cmd = { "" },
    event = "FileType",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function ()
      require('lint').linters_by_ft = {
        -- NOTE: download some linters in lspsAndRuntimeDeps
        -- and configure them here
        -- markdown = {'vale',},
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
