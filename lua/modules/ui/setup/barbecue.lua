local M = {}

M.opts = {
   attach_navic = false,
   create_autocmd = true,
   include_buftypes = { '' },
   exclude_filetypes = { 'netrw', 'toggleterm', 'lazy', 'alpha', 'NvimTree', 'neo-tree' },
   modifiers = {
      dirname = ':~:.',
      basename = '',
   },
   show_dirname = true,
   show_basename = true,
   show_modified = true,
   modified = function(bufnr)
      return vim.bo[bufnr].modified
   end,
   show_navic = true,
   context_follow_icon_color = true,
   symbols = {
      modified = '●',
      ellipsis = '…',
      separator = '',
   },
   kinds = require('modules.ui.icons').kind,
   theme = 'auto',
}

return M
