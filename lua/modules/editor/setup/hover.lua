---@diagnostic disable: missing-parameter
local M = {}

M.config = function()
   require('hover').setup({
      init = function()
         -- Require providers
         require('hover.providers.lsp')
         require('hover.providers.gh')
         require('hover.providers.gh_user')
         require('hover.providers.dap')
         require('hover.providers.man')
         -- require('hover.providers.dictionary')
      end,
      preview_opts = {
         border = 'rounded',
      },
   })
end

M.keys = {
   {
      'K',
      function()
         local winid = require('ufo').peekFoldedLinesUnderCursor()
         if not winid then
            vim.lsp.buf.hover()
            require('hover').hover()
         end
      end,
      desc = '[hover/ufo] hover / peak fold',
   },
   {
      'gK',
      function()
         require('hover').hover_select()
      end,
      desc = '[hover] select hover',
   },
   {
      '<C-p>',
      function()
         require('hover').hover_switch('previous')
      end,
      desc = '[hover] previous source',
   },
   {
      '<C-n>',
      function()
         require('hover').hover_switch('next')
      end,
      desc = '[hover] next source',
   },
}

return M
