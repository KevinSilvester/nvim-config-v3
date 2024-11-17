local m = require('core.mapper')

--
-- LEADER
vim.keymap.set('', '<Space>', '<Nop>', m.opts(m.noremap, m.silent))

--
-- NORMAL MODE --
m.nmap({
   { '<leader>L',  m.cmd('Lazy'),                          m.opts(m.noremap, m.silent, 'Lazy') },
   { '<leader>D',  function() log:dump() end,              m.opts(m.noremap, m.silent, 'Log Dump'), },
   { '<leader>br', function() buf_cache:refresh() end,     m.opts(m.noremap, m.silent, '[bufcache] Refresh current buffer cache'), },
   { '<leader>bR', function() buf_cache:refresh_all() end, m.opts(m.noremap, m.silent, '[bufcache] Refresh all buffer cache'), },
   { '<leader>bs', function() buf_cache:render() end,      m.opts(m.noremap, m.silent, '[bufcache] Render cache blocks'), },

   -- Better window navigation
   { '<C-h>',      '<C-w>h',                               m.opts(m.noremap, m.silent, 'Focus window (left)') },
   { '<C-j>',      '<C-w>j',                               m.opts(m.noremap, m.silent, 'Focus window (below)') },
   { '<C-k>',      '<C-w>k',                               m.opts(m.noremap, m.silent, 'Focus window (top)') },
   { '<C-l>',      '<C-w>l',                               m.opts(m.noremap, m.silent, 'Focus window (right)') },

   -- Resize with arrows
   { '<A-J>',      m.cmd('resize -2'),                     m.opts(m.noremap, m.silent, 'Resize -2 (Horizontal)') },
   { '<A-K>',      m.cmd('resize +2'),                     m.opts(m.noremap, m.silent, 'Resize +2 (Horizontal)') },
   { '<A-H>',      m.cmd('vertical resize -2'),            m.opts(m.noremap, m.silent, 'Resize -2 (Vertical)') },
   { '<A-L>',      m.cmd('vertical resize +2'),            m.opts(m.noremap, m.silent, 'Resize +2 (Vertical)') },

   -- Navigate buffers
   { '<S-l>',      m.cmd('bnext'),                         m.opts(m.noremap, m.silent, 'Switch buffer (right)') },
   { '<S-h>',      m.cmd('bprevious'),                     m.opts(m.noremap, m.silent, 'Switch buffer (left)') },

   -- Move text up and down
   { '<A-j>',      '<Esc>:m .+1<CR>==',                    m.opts(m.noremap, m.silent, 'Move line down') },
   { '<A-k>',      '<Esc>:m .-2<CR>==',                    m.opts(m.noremap, m.silent, 'Move line up') },

   -- Delete Word
   { '<C-BS>',     '<C-W>',                                m.opts(m.noremap, m.silent) },

   -- Delete Word
   { '<leader>H',  m.cmd('nohlsearch'),                    m.opts(m.noremap, m.silent) },

   -- Fancy Menu
   {
      '<C-t>',
      function() require('menu').open('default') end,
      m.opts(m.noremap, m.silent, '[menu] open'),
   },
   {
      '<RightMouse>',
      function()
         vim.cmd.exec('"normal! \\<RightMouse>"')
         local option = vim.bo.ft == 'NvimTree' and 'nvimtree' or 'default'
         require('menu').open(option, { mouse = true })
      end,
      m.opts(m.noremap, m.silent, '[menu] open'),
   },
   {
      '<C-RightMouse>',
      function()
         vim.cmd.exec('"normal! \\<RightMouse>"')
         if vim.tbl_contains(buf_cache._excluded_ft, vim.bo.ft) then
            return
         end
         require('menu').open('gitsigns', { mouse = true })
      end,
      m.opts(m.noremap, m.silent, '[menu] open'),
   }
})

if HOST.is_mac then
   m.nmap({
      -- Resize with arrows
      { '<D-J>',    m.cmd('resize -2'),                                     m.opts(m.noremap, m.silent) },
      { '<D-K>',    m.cmd('resize +2'),                                     m.opts(m.noremap, m.silent) },
      { '<D-H>',    m.cmd('vertical resize -2'),                            m.opts(m.noremap, m.silent) },
      { '<D-L>',    m.cmd('vertical resize +2'),                            m.opts(m.noremap, m.silent) },

      -- Move text up and down
      { '<D-j>',    '<Esc>:m .+1<CR>==',                                    m.opts(m.noremap, m.silent) },
      { '<D-k>',    '<Esc>:m .-2<CR>==',                                    m.opts(m.noremap, m.silent) },
      { '<D-Up>',   m.cmd('call vm#commands#add_cursor_up(0, v:count1)'),   m.opts(m.noremap, m.silent) },
      { '<D-Down>', m.cmd('call vm#commands#add_cursor_down(0, v:count1)'), m.opts(m.noremap, m.silent) },
   })
end

--
-- INSERT MODE --
m.imap({
   -- Move text up and down
   { '<A-j>', '<Esc>:m .+1<CR>==gi', m.opts(m.noremap, m.silent) },
   { '<A-k>', '<Esc>:m .-2<CR>==gi', m.opts(m.noremap, m.silent) },

   -- Icon Picker
   -- { '<C-I>', m.cmd('IconPickerInsert'), m.opts(m.noremap, m.silent) },
})

--
-- VISUAL MODE --
m.vmap({
   -- Stay in indent mode
   { '<',      '<gv',   m.opts(m.noremap, m.silent) },
   { '>',      '>gv',   m.opts(m.noremap, m.silent) },

   -- Better paste
   { 'p',      '"_dP',  m.opts(m.noremap, m.silent) },

   -- Delete Word
   { '<C-BS>', '<C-W>', m.opts(m.noremap, m.silent) },
})

--
-- VISUAL BLOCK MODE --
m.xmap({
   -- move selected line / block of text in visual mode
   { 'J',     m.cmd("move '>+1<CR>gv-gv"), m.opts(m.noremap, m.silent) },
   { 'K',     m.cmd("move '<-2<CR>gv-gv"), m.opts(m.noremap, m.silent) },
   { '<A-j>', m.cmd("move '>+<CR>gv-gv"),  m.opts(m.noremap, m.silent) },
   { '<A-k>', m.cmd("move '<-2<CR>gv-gv"), m.opts(m.noremap, m.silent) },

   -- Better paste
   { 'p',     '"_dP',                      m.opts(m.noremap, m.silent) },
})
