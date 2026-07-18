vim.pack.add { 'https://github.com/windwp/nvim-ts-autotag' }

require('nvim-ts-autotag').setup {
  opts = {
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs
    enable_close_on_slash = true, -- Auto close on trailing slash
  },

  per_filetype = {
    ['html'] = {
      enable_close = false,
    },
  },
}
