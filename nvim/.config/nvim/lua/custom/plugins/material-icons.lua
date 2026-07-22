vim.pack.add{'https://github.com/DaikyXendo/nvim-material-icon'}

-- Configure nvim-web-devicons to use the material icons
require('nvim-web-devicons').setup {
  -- Globally enable different highlight colors per icon
  color_icons = true,
  -- Globally enable default fallback icons
  default = true,
}
