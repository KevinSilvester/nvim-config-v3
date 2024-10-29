-- local m = require('core.mapper')

return {
   ---------------------------------
   --         lsp plugins         --
   ---------------------------------
   {
      'neovim/nvim-lspconfig',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
         'williamboman/mason.nvim',
         'williamboman/mason-lspconfig.nvim',
         'hrsh7th/cmp-nvim-lsp',
         'lvimuser/lsp-inlayhints.nvim',
         { 'b0o/schemastore.nvim', version = false },
         'folke/neodev.nvim',
         'folke/neoconf.nvim',
         'SmiteshP/nvim-navic',
         'Hoffs/omnisharp-extended-lsp.nvim',
         'antosha417/nvim-lsp-file-operations',
      },
      init = require('modules.cmp_lsp.setup.nvim-lspconfig').init,
      config = require('modules.cmp_lsp.setup.nvim-lspconfig').config,
      keys = require('modules.cmp_lsp.setup.nvim-lspconfig').keys,
   },
   {
      'folke/neodev.nvim',
      event = { 'BufReadPre *.lua', 'BufNewFile *.lua' },
      opts = require('modules.cmp_lsp.setup.neodev').opts,
   },
   {
      'folke/neoconf.nvim',
      config = true,
      cmd = 'Neoconf',
   },
   {
      'williamboman/mason.nvim',
      opts = require('modules.cmp_lsp.setup.mason').opts,
      keys = require('modules.cmp_lsp.setup.mason').keys,
   },
   {
      'williamboman/mason-lspconfig.nvim',
      opts = {
         ensure_installed = DEFAULT_LSP_SERVERS,
         automatic_installation = true,
      },
   },
   {
      'antosha417/nvim-lsp-file-operations',
      config = true,
   },
   {
      -- 'nvimdev/lspsaga.nvim',
      'KevinSilvester/lspsaga.nvim',
      branch = 'code-action-server',
      dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-treesitter/nvim-treesitter' },
      event = 'LspAttach',
      opts = require('modules.cmp_lsp.setup.lspsaga').opts,
      keys = require('modules.cmp_lsp.setup.lspsaga').keys,
   },
   -- {
   --    'jose-elias-alvarez/typescript.nvim',
   --    event = { 'BufReadPre *.{ts,tsx,js,cjs,mjs}', 'BufNewFile *.{ts,tsx,js,cjs,mjs}' },
   --    config = require('modules.cmp_lsp.setup.typescript').config,
   -- },
   {
      'pmizio/typescript-tools.nvim',
      event = { 'BufReadPre *.{ts,tsx,js,cjs,mjs}', 'BufNewFile *.{ts,tsx,js,cjs,mjs}' },
      dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
      config = require('modules.cmp_lsp.setup.typescript-tools').config,
   },
   {
      'simrat39/rust-tools.nvim',
      event = { 'BufReadPre *.rs', 'BufNewFile *.rs' },
      dependencies = { 'neovim/nvim-lspconfig' },
      opts = require('modules.cmp_lsp.setup.rust-tools').opts,
      config = require('modules.cmp_lsp.setup.rust-tools').config,
   },
   -- {
   --    'ray-x/go.nvim',
   --    dependencies = {
   --       'ray-x/guihua.lua',
   --       'neovim/nvim-lspconfig',
   --    },
   --    config = true,
   --    event = { 'CmdlineEnter' },
   --    ft = { 'go', 'gomod' },
   --    build = ':lua require("go.install").update_all_sync()',
   -- },

   { 'hrsh7th/cmp-nvim-lsp', dependencies = 'hrsh7th/nvim-cmp' },

   ---------------------------------
   --         cmp plugins         --
   ---------------------------------
   {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {
         'hrsh7th/cmp-nvim-lsp',
         'hrsh7th/cmp-nvim-lua',
         'hrsh7th/cmp-buffer',
         'hrsh7th/cmp-path',
         'saadparwaiz1/cmp_luasnip',
         'f3fora/cmp-spell',
         'windwp/nvim-autopairs',
      },
      opts = require('modules.cmp_lsp.setup.cmp').opts,
      config = require('modules.cmp_lsp.setup.cmp').config,
   },
   {
      'L3MON4D3/LuaSnip',
      tag = 'v2.1.1',
      build = 'make install_jsregexp',
      event = 'InsertEnter',
      dependencies = 'rafamadriz/friendly-snippets',
      config = require('modules.cmp_lsp.setup.luasnip').config,
   },
   {
      'windwp/nvim-autopairs',
      opts = {
         check_ts = true, -- treesitter integration
         disable_filetype = { 'TelescopePrompt' },
      },
   },

   ---------------------------------
   --           copilot           --
   ---------------------------------
   {
      'zbirenbaum/copilot.lua',
      enabled = not HOST.is_mac,
      dependencies = 'neovim/nvim-lspconfig',
      cmd = 'Copilot',
      opts = require('modules.cmp_lsp.setup.copilot').opts,
   },
   {
      'zbirenbaum/copilot-cmp',
      enabled = not HOST.is_mac,
      dependencies = { 'hrsh7th/nvim-cmp', 'zbirenbaum/copilot.lua' },
      event = 'InsertEnter',
      config = require('modules.cmp_lsp.setup.copilot-cmp').config,
   },

   ---------------------------------
   --      formatter+linter       --
   ---------------------------------
   {
      'nvimtools/none-ls.nvim',
      event = 'BufReadPost',
      config = require('modules.cmp_lsp.setup.null-ls').config,
   },

   {
      'smjonas/inc-rename.nvim',
      -- opts = { input_buffer_type = 'dressing' },
      enabled = false,
      config = true,
      event = 'VeryLazy',
      -- keys = { { '<leader>lr', m.cmd('IncRename'), desc = '[inc-rename] Rename' } },
   },
}
