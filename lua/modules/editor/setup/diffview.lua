local cmd = require('core.mapper').cmd
local M = {}

M.opts = function()
   local actions = require('diffview.actions')
   return {
      diff_binaries = false, -- Show diffs for binaries
      enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
      git_cmd = { 'git' }, -- The git executable followed by default args.
      use_icons = true, -- Requires nvim-web-devicons
      icons = {
         folder_closed = '',
         folder_open = '',
      },
      signs = {
         fold_closed = '',
         fold_open = '',
      },
      file_panel = {
         listing_style = 'tree', -- 'list'|'tree'
         tree_options = {
            flatten_dirs = true, -- Flatten dirs that only contain one single dir
            folder_statuses = 'only_folded', --  'never'|'only_folded'|'always'
         },
         win_config = {
            position = 'left',
            width = 35,
         },
      },
      file_history_panel = {
         git = {
            log_options = {
               single_file = { diff_merges = 'combined' },
               multi_file = { diff_merges = 'first-parent' },
            },
            win_config = {
               position = 'bottom',
               height = 16,
            },
         },
      },
      commit_log_panel = { win_config = {} },
      default_args = {
         DiffviewOpen = {},
         DiffviewFileHistory = {},
      },
      hooks = {},
      keymaps = {
         disable_defaults = false, -- Disable the default keymaps
         view = {
            ['<tab>'] = actions.select_next_entry, -- Open the diff for the next file
            ['<s-tab>'] = actions.select_prev_entry, -- Open the diff for the previous file
            ['gf'] = actions.goto_file, -- Open the file in a new split in the previous tabpage
            ['<C-w><C-f>'] = actions.goto_file_split, -- Open the file in a new split
            ['<C-w>gf'] = actions.goto_file_tab, -- Open the file in a new tabpage
            ['<leader>e'] = actions.focus_files, -- Bring focus to the files panel
            ['<leader>b'] = actions.toggle_files, -- Toggle the files panel.
            ['q'] = function()
               actions.close()
               vim.cmd('tabclose')
            end,
         },
         file_panel = {
            ['j'] = actions.next_entry, -- Bring the cursor to the next file entry
            ['<down>'] = actions.next_entry,
            ['k'] = actions.prev_entry, -- Bring the cursor to the previous file entry.
            ['<up>'] = actions.prev_entry,
            ['<cr>'] = actions.select_entry, -- Open the diff for the selected entry.
            ['o'] = actions.select_entry,
            ['<2-LeftMouse>'] = actions.select_entry,
            ['-'] = actions.toggle_stage_entry, -- Stage / unstage the selected entry.
            ['S'] = actions.stage_all, -- Stage all entries.
            ['U'] = actions.unstage_all, -- Unstage all entries.
            ['X'] = actions.restore_entry, -- Restore entry to the state on the left side.
            ['R'] = actions.refresh_files, -- Update stats and entries in the file list.
            ['L'] = actions.open_commit_log, -- Open the commit log panel.
            ['<c-b>'] = actions.scroll_view(-0.25), -- Scroll the view up
            ['<c-f>'] = actions.scroll_view(0.25), -- Scroll the view down
            ['<tab>'] = actions.select_next_entry,
            ['<s-tab>'] = actions.select_prev_entry,
            ['gf'] = actions.goto_file,
            ['<C-w><C-f>'] = actions.goto_file_split,
            ['<C-w>gf'] = actions.goto_file_tab,
            ['i'] = actions.listing_style, -- Toggle between 'list' and 'tree' views
            ['f'] = actions.toggle_flatten_dirs, -- Flatten empty subdirectories in tree listing style.
            ['<leader>e'] = actions.focus_files,
            ['<leader>b'] = actions.toggle_files,
            ['q'] = function()
               actions.close()
               vim.cmd('tabclose')
            end,
         },
         -- stylua: ignore
         file_history_panel = {
            ['g!'] = actions.options,               -- Open the option panel
            ['<C-A-d>'] = actions.open_in_diffview, -- Open the entry under the cursor in a diffview
            ['y'] = actions.copy_hash,              -- Copy the commit hash of the entry under the cursor
            ['L'] = actions.open_commit_log,
            ['zR'] = actions.open_all_folds,
            ['zM'] = actions.close_all_folds,
            ['j'] = actions.next_entry,
            ['<down>'] = actions.next_entry,
            ['k'] = actions.prev_entry,
            ['<up>'] = actions.prev_entry,
            ['<cr>'] = actions.select_entry,
            ['o'] = actions.select_entry,
            ['<2-LeftMouse>'] = actions.select_entry,
            ['<c-b>'] = actions.scroll_view(-0.25),
            ['<c-f>'] = actions.scroll_view(0.25),
            ['<tab>'] = actions.select_next_entry,
            ['<s-tab>'] = actions.select_prev_entry,
            ['gf'] = actions.goto_file,
            ['<C-w><C-f>'] = actions.goto_file_split,
            ['<C-w>gf'] = actions.goto_file_tab,
            ['<leader>e'] = actions.focus_files,
            ['<leader>b'] = actions.toggle_files,
            ['q'] = function()
               actions.close()
               vim.cmd('tabclose')
            end,
         },
         option_panel = {
            ['<tab>'] = actions.select_entry,
            ['q'] = actions.close,
         },
      },
   }
end

-- stylua: ignore
M.keys = {
   { '<leader>gdh', cmd('DiffviewFileHistory %'), desc = '[diffview] Current File History' },
   { '<leader>gdo', cmd('DiffviewOpen'),          desc = '[diffview] Open DiffView' },
   { '<leader>gdr', cmd('DiffviewRefresh'),       desc = '[diffview] Refresh DiffView' },
}

return M
