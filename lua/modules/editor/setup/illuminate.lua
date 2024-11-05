local M = {}

M.opts = {
   providers = { 'lsp', 'treesitter', 'regex' },
   delay = 200,
   filetypes_denylist = {
      'dirvish',
      'fugitive',
      'alpha',
      'NvimTree',
      'neo-tree',
      'lazy',
      'neogitstatus',
      'Trouble',
      'lir',
      'Outline',
      'spectre_panel',
      'toggleterm',
      'DressingSelect',
      'TelescopePrompt',
   },
}

M.config = function(_, opts)
   require('illuminate').configure(opts)
end

M.keys = {
   {
      '[r',
      function()
         require('illuminate').goto_prev_reference(true)
      end,
      desc = '[illuminate] Goto previous reference',
   },
   {
      ']r',
      function()
         require('illuminate').goto_next_reference(true)
      end,
      desc = '[illuminate] Goto next reference',
   },
}

return M
