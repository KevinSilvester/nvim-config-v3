if vim.fn.expand('%:t') ~= 'Cargo.toml' then
   return
end

local wk = require('which-key')
local m = require('core.mapper')

wk.add({
   { '<leader>p', group = 'crates' },
   { '<leader>po', group = 'open' },
   { '<leader>ps', group = 'show' },
})


-- stylua: ignore
m.buf_nmap(vim.api.nvim_get_current_buf(), {
   { '<leader>poh', require('crates').open_homepage,           m.opts(m.silent, m.noremap, 'Open Homepage') },
   { '<leader>por', require('crates').open_repository,         m.opts(m.silent, m.noremap, 'Open Repository') },
   { '<leader>pod', require('crates').open_documentation,      m.opts(m.silent, m.noremap, 'Open Documentation') },
   { '<leader>poc', require('crates').open_crates_io,          m.opts(m.silent, m.noremap, 'Open crates.io') },
   { '<leader>pr',  require('crates').reload,                  m.opts(m.silent, m.noremap, 'Reload Data') },
   { '<leader>psd', require('crates').show_dependencies_popup, m.opts(m.silent, m.noremap, 'Show Dependencies'), },
   { '<leader>psi', require('crates').show_crate_popup,        m.opts(m.silent, m.noremap, 'Show Details'), },
   { '<leader>psf', require('crates').show_features_popup,     m.opts(m.silent, m.noremap, 'Show Features'), },
   { '<leader>psv', require('crates').show_versions_popup,     m.opts(m.silent, m.noremap, 'Show Versions'), },
   { '<leader>pt',  require('crates').toggle,                  m.opts(m.silent, m.noremap, 'Toggle virtual text'), },
   { '<leader>pu',  require('crates').update_crate,            m.opts(m.silent, m.noremap, 'Update Crate') },
   { '<leader>pU',  require('crates').update_all_crates,       m.opts(m.silent, m.noremap, 'Update all Crates'), },
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufLeave' }, {
   group = vim.api.nvim_create_augroup('ftplugin.toml', { clear = true }),
   desc = 'Clear <leader>p which-key mappings',
   buffer = vim.api.nvim_get_current_buf(),
   callback = function(args)
      if args.event == 'BufEnter' then
         log:debug('ftplugin.toml', 'Setting <leader>p mappings', true)
         wk.add({
            { '<leader>p', group = 'crates' },
            { '<leader>po', group = 'open' },
            { '<leader>ps', group = 'show' },
         })
      end

      if args.event == 'BufLeave' then
         log:debug('ftplugin.toml', 'Clearing <leader>p mappings', true)
         wk.add({
            { '<leader>', group = '' },
            { '<leader>po', group = '' },
            { '<leader>ps', group = '' },
         })
      end
   end,
})
