vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2

if vim.fn.expand('%:t') ~= 'package.json' then
   return
end

vim.opt_local.shiftwidth = 3
vim.opt_local.softtabstop = 3
vim.opt_local.tabstop = 3

local wk = require('which-key')
local m = require('core.mapper')

wk.add({ { '<leader>p', group = 'package-info' } })

-- stylua: ignore
m.buf_nmap(vim.api.nvim_get_current_buf(), {
   { '<leader>pt', require('package-info').toggle,         m.opts(m.silent, m.noremap, 'Toggle dependency versions'), },
   { '<leader>pu', require('package-info').update,         m.opts(m.silent, m.noremap, 'Update dependency'), },
   { '<leader>pd', require('package-info').delete,         m.opts(m.silent, m.noremap, 'Delete dependency'), },
   { '<leader>pi', require('package-info').install,        m.opts(m.silent, m.noremap, 'Install new dependency'), },
   { '<leader>pv', require('package-info').change_version, m.opts(m.silent, m.noremap, 'Change dependency version'), },
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufLeave' }, {
   group = vim.api.nvim_create_augroup('ftplugin.json', { clear = true }),
   desc = 'Clear <leader>p which-key mappings',
   buffer = vim.api.nvim_get_current_buf(),
   callback = function(args)
      if args.event == 'BufEnter' then
         log:debug('ftplugin.json', 'Setting <leader>p mappings', true)
         wk.add({ { '<leader>p', group = 'package-info' } })
      end

      if args.event == 'BufLeave' then
         log:debug('ftplugin.json', 'Clearing <leader>p mappings', true)
         wk.add({ { '<leader>p', group = '' } })
      end
   end,
})
