local M = {}

-- luacheck: ignore
local handler = function(virtText, lnum, endLnum, width, truncate)
   local newVirtText = {}
   local suffix = (' 󰁂 %d '):format(endLnum - lnum)
   local sufWidth = vim.fn.strdisplaywidth(suffix)
   local targetWidth = width - sufWidth
   local curWidth = 0
   for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
         table.insert(newVirtText, chunk)
      else
         chunkText = truncate(chunkText, targetWidth - curWidth)
         local hlGroup = chunk[2]
         table.insert(newVirtText, { chunkText, hlGroup })
         chunkWidth = vim.fn.strdisplaywidth(chunkText)
         -- str width returned from truncate() may less than 2nd argument, need padding
         if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
         end
         break
      end
      curWidth = curWidth + chunkWidth
   end
   table.insert(newVirtText, { suffix, 'MoreMsg' })
   return newVirtText
end

M.opts = {
   ---@diagnostic disable-next-line: unused-local
   provider_selector = function(bufnr, filetype, buftype)
      return { 'treesitter', 'indent' }
   end,
   fold_virt_text_handler = handler,
}

-- stylua: ignore
M.keys = {
   { 'zR', function() require('ufo').openAllFolds() end,         desc = '[ufo] Open all folds' },
   { 'zM', function() require('ufo').closeAllFolds() end,        desc = '[ufo] Close all folds' },
   { 'zr', function() require('ufo').openFoldsExceptKinds() end, desc = '[ufo] Openfolds except kinds' },
   { 'zm', function() require('ufo').closeFoldsWith() end,       desc = '[ufo] Close fold' },
   {
      '[f',
      function()
         require('ufo').goPreviousClosedFold()
         require('ufo').peekFoldedLinesUnderCursor()
      end,
      desc = '[ufo] Goto Prev Fold'
   },
   {
      ']f',
      function()
         require('ufo').goNextClosedFold()
         require('ufo').peekFoldedLinesUnderCursor()
      end,
      desc = '[ufo] Goto Prev Fold'
   }
}

return M
