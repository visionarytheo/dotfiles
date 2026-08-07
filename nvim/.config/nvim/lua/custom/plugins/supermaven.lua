-- Add Supermaven using Neovim's native vim.pack
vim.pack.add {
  'https://github.com/supermaven-inc/supermaven-nvim',
}

-- Configure and initialize Supermaven
require('supermaven-nvim').setup {
  keymaps = {
    accept_suggestion = '<Tab>',
    clear_suggestion = '<C-]>',
    accept_word = '<C-j>',
  },
  ignore_filetypes = { cpp = true },
  color = {
    suggestion_color = '#89b4fa', -- Catppuccin Mocha accent (or "#ffffff" for crisp white)
    cterm = 244,
  },
  log_level = 'info',
  disable_inline_completion = false,
  disable_keymaps = false,
  condition = function()
    -- Return true to STOP Supermaven from running
    return false
  end,
}
