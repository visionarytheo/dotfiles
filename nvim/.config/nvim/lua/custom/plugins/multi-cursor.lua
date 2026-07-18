vim.pack.add { 'https://github.com/jake-stewart/multicursor.nvim' }

require('multicursor-nvim').setup()

-- Standard Multi-cursor Keymaps (Normal and Visual Modes)
vim.keymap.set({ 'n', 'v' }, '<C-n>', function() require('multicursor-nvim').matchAddCursor(1) end, { desc = 'Add cursor at next matching word' })
vim.keymap.set({ 'n', 'v' }, '<C-s>', function() require('multicursor-nvim').matchSkipCursor(1) end, { desc = 'Skip current match and go to next' })
vim.keymap.set({ 'n', 'v' }, '<leader>x', function() require('multicursor-nvim').deleteCursor() end, { desc = 'Delete current cursor' })
vim.keymap.set("n", "<C-LeftMouse>", function() require("multicursor-nvim").handleMouse() end, { desc = "Add cursor with mouse click" })


-- Clear all extra cursors on Escape press
vim.keymap.set('n', '<Esc>', function()
  if require('multicursor-nvim').hasCursors() then
    require('multicursor-nvim').clearCursors()
  else
    vim.cmd 'noh'
  end
end)
