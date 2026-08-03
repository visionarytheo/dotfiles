vim.pack.add({
    'https://github.com/stevearc/oil.nvim',
})

require('oil').setup({
  default_file_explorer = true,
  columns = {
    "icon",
    "permissions",
    "size",
  },

  float = {
    padding = 2,
    max_width = 80,
    max_height = 20,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "-", "<CMD>lua require('oil').open_float()<CR>", { desc = "Open parent directory in floating Oil" })
