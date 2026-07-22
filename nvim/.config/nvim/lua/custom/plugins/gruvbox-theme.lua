 vim.pack.add {
    'https://github.com/ellisonleao/gruvbox.nvim',
  }

  require('gruvbox').setup {
    italic = {
      strings = true,
      emphasis = true,
      comments = true,
      operators = false,
      folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,

    contrast = 'hard',
  }
  vim.cmd.colorscheme 'gruvbox'
