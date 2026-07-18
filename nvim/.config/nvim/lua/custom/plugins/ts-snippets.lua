local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Helper function to get the current file name for the component name
local function get_file_name()
  local name = vim.fn.expand('%:t:r')
  if name == '' or name == 'index' then
    return 'Component'
  end
  -- Capitalise first letter
  return name:gsub("^%l", string.upper)
end

-- 1. Register snippets ONLY for javascript
ls.add_snippets('javascript', {
  -- rfc: React Functional Component
  s('rfc', {
    t('export default function '), f(get_file_name), t('() {'), t({ '', '  return (', '    <div>' }), f(get_file_name), t({ '</div>', '  )', '', '}' }),
  }),

  -- afc: Async Function Component
  s('afc', {
    t('export async function '), i(1, 'fnName'), t('() {'), t({ '', '  return ' }), i(2, 'null'), t({ '', '}' }),
  }),

  -- clg: Console Log
  s('clg', {
    t('console.log('), i(1, 'log'), t(')'),
  }),

  -- cle: Console Error
  s('cle', {
    t('console.error('), i(1, 'error'), t(')'),
  }),
})

-- 2. Link JavaScript snippets to TypeScript and React filetypes safely
ls.filetype_extend('typescript', { 'javascript' })
ls.filetype_extend('javascriptreact', { 'javascript' })
ls.filetype_extend('typescriptreact', { 'javascript' })

