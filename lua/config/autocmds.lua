local function augroup(name)
   return vim.api.nvim_create_augroup('config.autocmd.' .. name, { clear = true })
end

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
   group = augroup('resize'),
   desc = 'Resize splits if window got resized',
   callback = function()
      vim.cmd('tabdo wincmd =')
   end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
   group = augroup('last-loc'),
   callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
         pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
   end,
})

-- Use 'q' to quit from common plugins
vim.api.nvim_create_autocmd({ 'FileType' }, {
   group = augroup('keymap'),
   desc = 'Use "q" to quit from common plugins',
   pattern = {
      'PlenaryTestPopup',
      'help',
      'lspinfo',
      'man',
      'notify',
      'qf',
      'spectre_panel',
      'startuptime',
      'tsplayground',
      'checkhealth',
   },
   callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
   end,
})

vim.api.nvim_create_autocmd({ 'Filetype' }, {
   group = vim.api.nvim_create_augroup('CustomShebangDetection', {}),
   desc = 'Set the filetype based on the shebang header',
   callback = function()
      local line = vim.fn.getline(1)
      local pattern1, pattern2 = '^#!.*/bin/env%s+(%w+)', '^#!.*/bin/(%w+)'
      local interpreter = line:match(pattern1) or line:match(pattern2)
      if interpreter then
         vim.api.nvim_set_option_value('filetype', interpreter, { buf = 0 })
      end
   end,
})

-- Set `filetype` to `license` for `LICENSE*` files (for cmp snippets to appear)
vim.api.nvim_create_autocmd({ 'FileType' }, {
   group = augroup('license'),
   desc = 'Set `filetype` to `license` for `LICENSE*` files',
   pattern = { 'text', 'markdown' },
   callback = function(event)
      local filename = vim.fn.expand('%:t')
      if filename:match('^LICENSE') then
         vim.bo[event.buf].filetype = 'license'
      end
   end,
})

-- Remove statusline and tabline when in Alpha
vim.api.nvim_create_autocmd({ 'User' }, {
   group = augroup('options-bars'),
   pattern = { 'AlphaReady' },
   callback = function()
      vim.cmd([[
      set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
      set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3
    ]])
   end,
})

-- Highlight Yanked Text
vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
   group = augroup('hightlight-yank'),
   desc = 'Highlight yanked text',
   callback = function()
      vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
   end,
})

-- vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
--    callback = function()
--       if not vim.g.neovide then
--          vim.cmd('hi Normal guibg=NONE')
--          vim.cmd('hi NormalNC guibg=NONE')
--       end
--    end,
-- })

-- Autocmd to close nvim if nvim-tree is the last buffer
-- ref: https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#ppwwyyxx
vim.api.nvim_create_autocmd('QuitPre', {
   group = augroup('neo-tree-quit'),
   desc = 'Autoclose if neo-tree is last window',
   callback = function()
      local invalid_win = {}
      local wins = vim.api.nvim_list_wins()

      for _, w in ipairs(wins) do
         local bufnr = vim.api.nvim_win_get_buf(w)
         local bufname = vim.api.nvim_buf_get_name(bufnr)
         local bufft = vim.bo[bufnr].ft
         if bufname == '' or (bufft == 'neo-tree' or bufft == 'NvimTree') then
            table.insert(invalid_win, w)
         end
      end

      if #invalid_win == #wins - 1 then
         for _, w in ipairs(invalid_win) do
            vim.api.nvim_win_close(w, true)
         end
      end
   end,
})
