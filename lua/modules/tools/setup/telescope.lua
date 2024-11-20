local ufn = require('utils.fn')
local cmd = require('core.mapper').cmd
local M = {}

M.config = function()
   local actions = require('telescope.actions')
   local preview_width = 60

   require('telescope').setup({
      defaults = {
         prompt_prefix = '  ',
         selection_caret = ' ',
         path_display = { 'truncate' },
         file_ignore_patterns = { 'node_modules', '^.git/', 'target' },
         sorting_strategy = 'ascending',
         layout_strategy = 'horizontal',
         layout_config = {
            width = 0.75,
            preview_cutoff = 120,
            horizontal = {
               prompt_position = 'top',
               preview_width = function(_, cols, _)
                  preview_width = (cols < 120) and math.floor(cols * 0.5) or math.floor(cols * 0.6)
                  return preview_width
               end,
               mirror = false,
            },
            vertical = { mirror = false },
         },
         vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!.git/*',
         },
         set_env = { ['COLORTERM'] = 'truecolor' },
         border = {},
         mappings = {
            i = {
               ['<Down>'] = actions.cycle_history_next,
               ['<Up>'] = actions.cycle_history_prev,
               ['<C-j>'] = actions.move_selection_next,
               ['<C-k>'] = actions.move_selection_previous,
            },
            n = { ['q'] = actions.close },
         },
         file_previewer = require('telescope.previewers').vim_buffer_cat.new,
         grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
         qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
         -- buffer_previewer_maker = preview_maker,
      },
      pickers = {
         find_files = {
            hidden = true,
            find_command = {
               'rg',
               '--files',
               '--color=never',
               '--no-heading',
               '--line-number',
               '--column',
               '--smart-case',
               '--hidden',
               '--glob=!{.git/*,.svelte-kit/*,target/*,node_modules/*}',
               '--path-separator',
               '/',
            },
         },
         live_grep = { only_sort_text = true },
         buffers = {
            sort_lastused = true,
            theme = 'dropdown',
            previewer = false,
            mappings = {
               i = { ['<C-d>'] = 'delete_buffer' },
               n = { ['<C-d>'] = 'delete_buffer' },
            },
         },
         colorscheme = { enable_preview = true },
      },
      extensions = {
         fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case', ---@type 'smart_case'|'ignore_case'|'respect_case'
         },
      },
   })
   require('telescope').load_extension('fzf')
   require('telescope').load_extension('notify')
   require('telescope').load_extension('projects')
end

-- stylua: ignore
M.keys = {
   {
      '<leader>ff',
      ufn.telescope('files', { enable_preview = true }),
      desc = '[telescope] Files'
   },
   { '<leader>fb',  cmd('Telescope buffers'),                       desc = '[telescope] Buffers' },
   { '<leader>fB',  cmd('Telescope buffers show_all_buffers=true'), desc = '[telescope] Switch Buffer' },
   { '<leader>ft',  cmd('Telescope live_grep'),                     desc = '[telescope] Text' },
   { '<leader>fw',  cmd('Telescope grep_string'),                   desc = '[telescope] Word' },
   { '<leader>fr',  cmd('Telescope oldfiles'),                      desc = '[telescope] Recent File' },

   -- git
   { '<leader>gcb', cmd('Telescope git_branch'),                    desc = '[telescope] Checkout Branch' },
   { '<leader>gcc', cmd('Telescope git_commits'),                   desc = '[telescope] Checkout Commit' },
   { '<leader>go',  cmd('Telescope git_status'),                    desc = '[telescope] Git status' },

   -- search
   { '<leader>sa',  cmd('Telescope autocommands'),                  desc = '[telescope] Auto Commands' },
   { '<leader>sb',  cmd('Telescope current_buffer_fuzzy_find'),     desc = '[telescope] Buffer' },
   { '<leader>sC',  cmd('Telescope command_history'),               desc = '[telescope] Command History' },
   { '<leader>sc',  cmd('Telescope commands'),                      desc = '[telescope] Commands' },
   { '<leader>sd',  cmd('Telescope diagnostics bufnr=0'),           desc = '[telescope] Document diagnostics', },
   { '<leader>sD',  cmd('Telescope diagnostics'),                   desc = '[telescope] Workspace diagnostics', },
   { '<leader>sh',  cmd('Telescope help_tags'),                     desc = '[telescope] Help Tags' },
   { '<leader>sH',  cmd('Telescope highlights'),                    desc = '[telescope] Search Highlight Groups', },
   { '<leader>sk',  cmd('Telescope keymaps'),                       desc = '[telescope] Key Maps' },
   { '<leader>sM',  cmd('Telescope man_pages'),                     desc = '[telescope] Man Pages' },
   { '<leader>sm',  cmd('Telescope marks'),                         desc = '[telescope] Jump to Mark' },
   { '<leader>so',  cmd('Telescope vim_options'),                   desc = '[telescope] Options' },
   { '<leader>sR',  cmd('Telescope resume'),                        desc = '[telescope] Resume' },
   {
      '<leader>sp',
      ufn.telescope('colorscheme', { enable_preview = true }),
      desc = '[telescope] Colorscheme with preview',
   },
}

return M
