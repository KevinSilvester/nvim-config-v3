local ufn = require('utils.fn')

-- command to act as alias for custom inspect function
vim.api.nvim_create_user_command('Inspect', function(opts)
   local args = vim.split(opts.args, '|')
   local expr = args[1]
   local yank = args[2] == 'true' and 'true' or 'false'
   vim.cmd("lua require('utils.fn').inspect(" .. expr .. ',' .. yank .. ')')
end, {
   nargs = 1,
   complete = 'lua',
})

-- command to get the hex colour values for Hl group
vim.api.nvim_create_user_command('InspectHl', function(opts)
   local args = vim.split(opts.args, '|')
   local expr = args[1]
   local yank = args[2] == 'true'
   local success, hl = pcall(require('utils.colours').get_hl, expr)

   log:info('InspectHl', hl)

   if not success then
      log:error('config.cmds.inspecthl', 'Invalid highlight group: ' .. expr)
      return
   end

   ufn.inspect(hl, yank)
end, {
   nargs = 1,
   complete = 'highlight',
})

-- set the tab options for specific work repos
vim.api.nvim_create_user_command('Tab', function(opts)
   local augroup_name = 'config.cmds.tab'

   local tab_ok, tab = pcall(tonumber, opts.args)
   if not tab_ok then
      log:error('config.cmds.tab', 'Invalid value: ' .. opts.args)
      return
   end

   ---@cast tab number

   ufn.tab_opts(tab, vim.api.nvim_get_current_buf())
   vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
      group = vim.api.nvim_create_augroup(augroup_name, { clear = true }),
      pattern = '*',
      desc = 'Set tabstop, shiftwidth to 2 for js,md,ts files',
      callback = function(args)
         ufn.tab_opts(tab, args.buf)
      end,
   })
end, {
   nargs = 1,
   complete = function(_, line)
      local subcommands = { '2', '3', '4' }
      local args = vim.split(line, '%s+')
      if #args ~= 2 then
         return {}
      end

      return vim.tbl_filter(function(subcommand)
         return vim.startswith(subcommand, args[2])
      end, subcommands)
   end,
})

vim.api.nvim_create_user_command('Tab', function(opts)
   local val = string.gsub(opts.args, ' ', '')
   if val:match('^%d+$') then
      ---@diagnostic disable-next-line: param-type-mismatch
      ufn.tab_opts(tonumber(val))
   else
      log:error('config.cmds.tab', 'Invalid value!')
   end
end, {
   nargs = 1,
   complete = function(_, line)
      local args = vim.split(line, '%s+')
      if #args ~= 2 then
         return {}
      end

      return { tostring(vim.o.tabstop) }
   end,
})

vim.api.nvim_create_user_command('LogClear', function(opts)
   log:clear(opts.bang)
end, { nargs = 0, bang = true })

vim.api.nvim_create_user_command('LogDump', function()
   log:dump()
end, { nargs = 0 })

vim.api.nvim_create_user_command('StatusCol', function()
   require('modules.ui.setup.statuscol').config()
end, { nargs = 0 })

vim.api.nvim_create_user_command('Ibr', function()
   vim.cmd('IBLDisable')
   vim.cmd('IBLEnable')
end, { nargs = 0 })
