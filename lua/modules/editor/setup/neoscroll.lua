local m = require('core.mapper')
local M = {}

M.opts = {
   mappings = {
      nil, --[[ '<C-u>', ]]
      nil, --[[ '<C-d>', ]]
      nil, --[[ '<C-b>', ]]
      nil, --[[ '<C-f>', ]]
      nil, --[[ '<C-y>', ]]
      nil, --[[ '<C-e>', ]]
      nil, --[[ 'zt', ]]
      nil, --[[ 'zz', ]]
      nil, --[[ 'zb', ]]
   },
}

M.config = function(_, opts)
   local neoscroll = require('neoscroll')

   local sc = function(lines, duration)
      return function()
         neoscroll.scroll(lines, { duration = duration, move_cursor = true })
      end
   end

   neoscroll.setup(opts)
   m.nmap({
      {
         '<C-u>',
         sc(-vim.wo.scroll, 100),
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll up'),
      },
      {
         '<C-d>',
         sc(vim.wo.scroll, 100),
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll down'),
      },

      {
         '<C-b>',
         function()
            neoscroll.ctrl_b({ duration = 400 })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll up buffer height'),
      },
      {
         '<C-f>',
         function()
            neoscroll.ctrl_f({ duration = 400 })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll down buffer height'),
      },
      {
         '<C-y>',
         function()
            neoscroll.scroll(-1, { duration = 100, move_cursor = false })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll up one line (no cursor movement)')
      },
      {
         '<C-e>',
         function()
            neoscroll.scroll(1, { duration = 100, move_cursor = false })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll down one line (no cursor movement)'),
      },

      {
         '(',
         sc(-1, 0),
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll up one line'),
      },
      {
         ')',
         sc(1, 0),
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll down one line'),
      },
      {
         'zt',
         function()
            neoscroll.zt({ half_win_duration = 200 })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll to top'),
      },
      {
         'zz',
         function()
            neoscroll.zz({ half_win_duration = 200 })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll to middle'),
      },
      {
         'zb',
         function()
            neoscroll.zb({ half_win_duration = 200 })
         end,
         m.opts(m.noremap, m.silent, '[neoscroll] Scroll to bottom'),
      },
   })
end

return M
