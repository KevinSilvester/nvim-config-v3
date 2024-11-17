local cmd = require('core.mapper').cmd

-- plugin({
--    'rcarriga/nvim-dap-ui',
--    opt = true,
--    after = 'nvim-dap',
--    config = conf.dapui,
-- })

return {
   -- session+project management
   {
      'folke/persistence.nvim',
      event = 'BufReadPre',
      opts = {
         dir = PATH.cache .. '/session/',
         options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals' },
         pre_save = function()
            log:info('modules.tools.persistence', 'Session saved')
         end,
      },
      -- stylua: ignore
      keys = {
         {
            "<leader>qs",
            function() require("persistence").load() end,
            desc = "[persistence] Restore Session"
         },
         {
            "<leader>ql",
            function() require("persistence").load({ last = true }) end,
            desc = "[persistence] Restore Last Session"
         },
         {
            "<leader>qd",
            function() require("persistence").stop() end,
            desc = "[persistence] Don't Save Current Session"
         },
      },
   },
   {
      'ahmedkhalf/project.nvim',
      event = 'VeryLazy',
      opts = {
         detection_methods = { 'pattern' },
         patterns = { '.git', 'Makefile', 'package.json', 'Cargo.toml' },
      },
      config = function(_, opts)
         require('project_nvim').setup(opts)
      end,
   },
   {
      'ThePrimeagen/git-worktree.nvim',
      dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
      config = function()
         require('git-worktree').setup()
         require('telescope').load_extension('git_worktree')
      end,
      keys = {
         {
            '<leader>gww',
            cmd('lua require("telescope").extensions.git_worktree.git_worktrees()'),
            desc = '[git-worktree] Git Worktrees',
         },
         {
            '<leader>gwc',
            cmd('lua require("telescope").extensions.git_worktree.create_git_worktree()'),
            desc = '[git-worktree] Create Git Worktree',
         },
      },
   },
   {
      'tpope/vim-fugitive',
      lazy = true,
      cmd = {
         'Git',
         'Gedit',
         'Gsplit',
         'Gdiffsplit',
         'Gvdiffsplit',
         'Gread',
         'Gwrite',
         'Ggrep',
         'Glgrep',
         'GMove',
         'GRename',
         'GDelete',
         'GRemove',
         'GBrowse',
      },
   },

   -- fuzzy finder
   {
      'nvim-telescope/telescope.nvim',
      -- tag = '0.1.1',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = require('modules.tools.setup.telescope').config,
      keys = require('modules.tools.setup.telescope').keys,
      cmd = 'Telescope',
   },
   {
      'nvim-telescope/telescope-file-browser.nvim',
      dependencies = { 'nvim-telescope/telescope.nvim' },
      config = function()
         require('telescope').load_extension('file_browser')
      end,
   },
   {
      'nvim-telescope/telescope-fzf-native.nvim',
      dependencies = { 'nvim-telescope/telescope.nvim' },
      build = 'make',
      config = function()
         require('telescope').load_extension('file_browser')
      end,
   },

   -- keymap helper
   {
      'folke/which-key.nvim',
      event = 'VeryLazy',
      opts = require('modules.tools.setup.which-key').opts,
      config = require('modules.tools.setup.which-key').config,
   },

   -- search and replace
   {
      'nvim-pack/nvim-spectre',
      dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
      opts = require('modules.tools.setup.spectre').opts,
      keys = require('modules.tools.setup.spectre').keys,
   },

   -- nerd font icons + emoji picker
   {
      'ziontee113/icon-picker.nvim',
      opts = { disable_legacy_commands = true },
      keys = {
         { '<leader>ii', cmd('IconPickerNormal'), desc = 'Pick Icons' },
         { '<leader>iy', cmd('IconPickerYank'), desc = 'Yank Icons' },
      },
   },

   -- better yank
   {
      'gbprod/yanky.nvim',
      dependencies = { 'nvim-telescope/telescope.nvim' },
      config = require('modules.tools.setup.yanky').config,
      keys = require('modules.tools.setup.yanky').keys,
   },

   -- Paste Images
   {
      'HakonHarnes/img-clip.nvim',
      event = 'BufEnter',
      keys = {
         { '<leader>P', '<cmd>PasteImage<cr>', desc = 'Paste image' },
      },
      cmd = 'PasteImage',
   },

   -- useful text objects
   {
      'chrisgrieser/nvim-various-textobjs',
      lazy = false,
      opts = { useDefaultKeymaps = true },
   },

   -- snippet maker
   {
      'chrisgrieser/nvim-scissors',
      dependencies = 'nvim-telescope/telescope.nvim',
      opts = { jsonFormatter = 'jq' },
      config = true,
      -- stylua: ignore
      keys = {
         {
            '<leader>;a',
            function() require('scissors').addNewSnippet() end,
            desc = 'Add Snippet',
            mode = { 'n', 'x' }
         },
         { '<leader>;e', function() require('scissors').editSnippet() end, desc = 'Edit Snippet' },
      },
   },

   -- WARNNING: Cursor disappears after using plugin
   -- colour picker
   -- {
   --    'max397574/colortils.nvim',
   --    cmd = 'Colortils',
   --    opts = {
   --       default_format = 'hsl'
   --    },
   --    config = true
   -- },

   -- HARPOON
   {
      'ThePrimeagen/harpoon',
      -- dir = '/home/kevin/projects/harpoon',
      dependencies = { 'nvim-lua/plenary.nvim' },
      enabled = true,
      branch = 'harpoon2',
      config = require('modules.tools.setup.harpoon').config,
      keys = require('modules.tools.setup.harpoon').keys,
   },

   -- package info
   {
      'vuki656/package-info.nvim',
      event = { 'BufReadPre package.json', 'BufNewFile package.json' },
      dependencies = 'MunifTanjim/nui.nvim',
      opts = require('modules.tools.setup.package-info').opts,
      config = require('modules.tools.setup.package-info').config,
   },
   {
      'saecki/crates.nvim',
      tag = 'v0.3.0',
      event = { 'BufReadPre Cargo.toml', 'BufNewFile Cargo.toml' },
      dependencies = 'nvim-lua/plenary.nvim',
      opts = require('modules.tools.setup.crates').opts,
   },

   -- terminal in neovim
   {
      'akinsho/toggleterm.nvim',
      cmd = {
         'ToggleTerm',
         'TermExec',
         'ToggleTermToggleAll',
         'ToggleTermSendCurrentLine',
         'ToggleTermSendVisualLines',
         'ToggleTermSendVisualSelection',
      },
      opts = require('modules.tools.setup.toggleterm').opts,
      keys = require('modules.tools.setup.toggleterm').keys,
   },

   -- debugger
   -- TODO: Setup Dap
   {
      'mfussenegger/nvim-dap',
      cmd = {
         'DapSetLogLevel',
         'DapShowLog',
         'DapContinue',
         'DapToggleBreakpoint',
         'DapToggleRepl',
         'DapStepOver',
         'DapStepInto',
         'DapStepOut',
         'DapTerminate',
      },
   },

   -- hide .env file variables
   {
      'laytan/cloak.nvim',
      event = { 'BufReadPre .env*', 'BufNewFile .env*' },
      cmd = { 'CloakEnable', 'CloakDisable', 'CloakToggle' },
      config = true,
   },

   -- colour picker
   { 'NvChad/volt', lazy = true },
   {
      'NvChad/minty',
      cmd = { 'Shades', 'Huefy' },
      -- dir = '/home/kevin/projects/minty',
      lazy = true,
   },

   -- show keys
   { 'NvChad/showkeys', cmd = { 'ShowkeysToggle' }, opts = { position = 'top-center' } },

   -- misc
   {
      'iamcco/markdown-preview.nvim',
      build = function()
         vim.fn['mkdp#util#install']()
      end,
      commit = 'a923f5fc5ba36a3b17e289dc35dc17f66d0548ee',
      cmd = {
         'MarkdownPreview',
         'MarkdownPreviewStop',
         'MarkdownPreviewToggle',
      },
      -- ft = 'markdown',
      event = { 'BufReadPost *.md', 'BufNewFile *.md' },
      init = function()
         vim.g.mkdp_filetypes = { 'markdown' }
         vim.g.mkdp_echo_preview_url = 1
      end,
   },
   {
      'monaqa/dial.nvim',
      keys = { '<C-a>', '<C-x>' },
   },
   {
      'folke/zen-mode.nvim',
      config = true,
      cmd = 'ZenMode',
      keys = {
         {
            '<leader>z',
            function()
               require('zen-mode').toggle({ window = { width = 0.55 } })
            end,
            desc = 'Zen Mode',
         },
      },
   },

   -- image preview
   {
      '3rd/image.nvim',
      config = true,
      enabled = not HOST.is_win,
   },
}
