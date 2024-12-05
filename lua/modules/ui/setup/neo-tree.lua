local m = require('core.mapper')
local i = require('modules.ui.icons')
local ufn = require('utils.fn')
local M = {}

M.opts = {
   sources = { 'filesystem', 'git_status' },
   source_selector = {
      winbar = true,
      content_layout = 'center',
      sources = { { source = 'filesystem' }, { source = 'git_status' } },
   },
   close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
   popup_border_style = 'rounded',
   enable_git_status = true,
   enable_diagnostics = true,
   open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' }, -- when opening files, do not use windows containing these filetypes or buftypes
   sort_case_insensitive = false, -- used when sorting files and directories in the tree
   -- sort_function = nil, -- use a custom function for sorting files and directories in the tree
   default_component_configs = {
      container = {
         enable_character_fade = true,
      },
      indent = {
         indent_size = 2,
         padding = 1, -- extra padding on left hand side
         with_markers = true,
         highlight = 'NeoTreeIndentMarker',
         with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
         expander_collapsed = '',
         expander_expanded = '',
      },
      icon = {
         folder_closed = i.fs.DirClosed,
         folder_open = i.fs.DirOpen,
         folder_empty = i.fs.DirEmptyClosed,
         -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
         -- then these will never be used.
         default = '',
         highlight = 'NeoTreeDimText' --[[ 'NeoTreeFileIcon' ]],
      },
      modified = {
         symbol = '[+]',
         highlight = 'NeoTreeModified',
      },
      name = {
         trailing_slash = false,
         use_git_status_colors = true,
         highlight = 'NeoTreeFileName',
      },
      git_status = {
         symbols = {
            added = i.git.Add,
            modified = i.git.Mod,
            deleted = i.git.Remove,
            renamed = i.git.Rename,
            untracked = i.git.Untracked,
            ignored = i.git.Ignore,
            unstaged = i.git.Unstaged,
            staged = i.git.Staged,
            conflict = i.git.Unmerged,
         },
      },
   },
   commands = {
      trash = function(state)
         local inputs = require('neo-tree.ui.inputs')
         local path = state.tree:get_node().path
         local msg = 'Are you sure you want to delete ' .. path
         inputs.confirm(msg, function(confirmed)
            if not confirmed then
               return
            end

            -- luacheck: ignore 311
            local trash = {}

            if HOST.is_win then
               trash = {
                  cmd = 'pwsh.exe',
                  args = { '-c', 'Remove-ItemSafely', path },
               }
            else
               trash = {
                  cmd = 'trash-put',
                  args = { path },
               }
            end

            ufn.spawn(trash.cmd, trash.args, function(code, _signal)
               if code ~= 0 then
                  log:error('neo-tree ~ trash', 'Failed to trash the file/directory: ' .. path)
                  return
               end
               require('neo-tree.sources.manager').refresh(state)
            end)
         end)
      end,
   },
   window = {
      position = 'left',
      width = 40,
      mapping_options = {
         noremap = true,
         nowait = true,
      },
      mappings = {
         ['<space>'] = {
            'toggle_node',
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
         },
         ['<2-LeftMouse>'] = 'open',
         ['<cr>'] = 'open',
         ['l'] = 'open',
         ['h'] = 'close_node',
         -- ['<S-l>'] = 'expand_all_nodes',
         -- ['<S-h>'] = 'close_all_nodes',
         ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
         ['P'] = { 'toggle_preview', config = { use_float = true, use_image_nvim = true } },
         ['t'] = 'focus_preview',
         ['S'] = 'open_split',
         ['s'] = 'open_vsplit',
         -- ['t'] = 'open_tabnew',
         ['w'] = 'open_with_window_picker',
         ['z'] = 'close_all_nodes',
         ['a'] = {
            'add',
            config = {
               show_path = 'none', -- "none", "relative", "absolute"
            },
         },
         ['A'] = 'add_directory', -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
         ['d'] = 'trash',
         ['D'] = 'delete',
         ['r'] = 'rename',
         ['y'] = 'copy_to_clipboard',
         ['x'] = 'cut_to_clipboard',
         ['p'] = 'paste_from_clipboard',
         ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
         ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
         ['q'] = 'close_window',
         ['R'] = 'refresh',
         ['?'] = 'show_help',
         ['<'] = 'prev_source',
         ['>'] = 'next_source',
         ['i'] = 'show_file_details',
      },
   },
   nesting_rules = {},
   filesystem = {
      filtered_items = {
         visible = false, -- when true, they will just be displayed differently than normal items
         hide_dotfiles = false,
         hide_gitignored = false,
         hide_hidden = false, -- only works on Windows for hidden files/directories
         hide_by_name = {
            'node_modules',
            '.git',
            'target',
            '.idea',
            '.expo',
         },
         hide_by_pattern = { -- uses glob style patterns
            '\\.cache',
         },
         always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
         },
         always_show_by_pattern = { -- uses glob style patterns
            --".env*",
         },
         never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
         },
         never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
         },
      },
      follow_current_file = {
         enabled = false, -- This will find and focus the file in the active buffer every time
         --               -- the current file is changed while the tree is open.
         leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
      group_empty_dirs = false, -- when true, empty folders will be grouped together
      hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
      -- in whatever position is specified in window.position
      -- "open_current",  -- netrw disabled, opening a directory opens within the
      -- window like netrw would, regardless of window.position
      -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
      use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
      -- instead of relying on nvim autocmd events.
      window = {
         mappings = {
            ['<bs>'] = 'navigate_up',
            ['.'] = 'set_root',
            ['H'] = 'toggle_hidden',
            ['/'] = 'fuzzy_finder',
            ['?'] = 'fuzzy_finder_directory',
            ['#'] = 'fuzzy_sorter', -- fuzzy sorting using the fzy algorithm
            -- ["D"] = "fuzzy_sorter_directory",
            ['f'] = 'filter_on_submit',
            ['<c-x>'] = 'clear_filter',
            ['[g'] = 'prev_git_modified',
            [']g'] = 'next_git_modified',
            ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
            ['oc'] = { 'order_by_created', nowait = false },
            ['od'] = { 'order_by_diagnostics', nowait = false },
            ['og'] = { 'order_by_git_status', nowait = false },
            ['om'] = { 'order_by_modified', nowait = false },
            ['on'] = { 'order_by_name', nowait = false },
            ['os'] = { 'order_by_size', nowait = false },
            ['ot'] = { 'order_by_type', nowait = false },
         },
         fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            ['<down>'] = 'move_cursor_down',
            ['<C-n>'] = 'move_cursor_down',
            ['<up>'] = 'move_cursor_up',
            ['<C-p>'] = 'move_cursor_up',
         },
      },
      commands = {
         toggle_hidden = function(state)
            state.filtered_items.visible = not state.filtered_items.visible
            require('neo-tree.sources.filesystem.commands').refresh(state)
         end,
      },
   },
   buffers = {
      follow_current_file = {
         enabled = true, -- This will find and focus the file in the active buffer every time
         --              -- the current file is changed while the tree is open.
         leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
      group_empty_dirs = true, -- when true, empty folders will be grouped together
      show_unloaded = true,
      window = {
         mappings = {
            ['bd'] = 'buffer_delete',
            ['<bs>'] = 'navigate_up',
            ['.'] = 'set_root',
            ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
            ['oc'] = { 'order_by_created', nowait = false },
            ['od'] = { 'order_by_diagnostics', nowait = false },
            ['om'] = { 'order_by_modified', nowait = false },
            ['on'] = { 'order_by_name', nowait = false },
            ['os'] = { 'order_by_size', nowait = false },
            ['ot'] = { 'order_by_type', nowait = false },
         },
      },
   },
   git_status = {
      window = {
         position = 'float',
         mappings = {
            ['A'] = 'git_add_all',
            ['gu'] = 'git_unstage_file',
            ['ga'] = 'git_add_file',
            ['gr'] = 'git_revert_file',
            ['gc'] = 'git_commit',
            ['gp'] = 'git_push',
            ['gg'] = 'git_commit_and_push',
            ['o'] = { 'show_help', nowait = false, config = { title = 'Order by', prefix_key = 'o' } },
            ['oc'] = { 'order_by_created', nowait = false },
            ['od'] = { 'order_by_diagnostics', nowait = false },
            ['om'] = { 'order_by_modified', nowait = false },
            ['on'] = { 'order_by_name', nowait = false },
            ['os'] = { 'order_by_size', nowait = false },
            ['ot'] = { 'order_by_type', nowait = false },
         },
      },
   },
}

M.config = function(_, opts)
   local neo_tree = require('neo-tree')
   local default_opts = require('neo-tree.defaults')

   opts.renderers = {}
   opts.renderers.directory = default_opts.renderers.directory
   opts.renderers.file = default_opts.renderers.file

   opts.renderers.directory[1] = {
      'indent',
      with_markers = true,
      indent_marker = '│',
      last_indent_marker = '╰',
      indent_size = 2,
   }
   opts.renderers.file[1] = {
      'indent',
      with_markers = true,
      indent_marker = '│',
      -- indent_marker = '├',
      last_indent_marker = '╰',
      indent_size = 2,
   }

   neo_tree.setup(opts)

   vim.api.nvim_create_autocmd({ 'VimResume', 'FocusGained', 'TermLeave' }, {
      desc = 'Update git_status in tree after fg',
      callback = function()
         require('neo-tree.sources.git_status').refresh()
      end,
   })

   vim.api.nvim_create_autocmd('FileType', {
      desc = 'Remove statuscolumn for NeoTree window',
      pattern = 'neo-tree',
      callback = function()
         vim.schedule(function()
            local winid = vim.api.nvim_get_current_win()
            if vim.wo[winid] ~= '' then
               vim.wo[winid].statuscolumn = ''
               vim.wo[winid].foldcolumn = '0'
            end
         end)
      end,
   })

   vim.api.nvim_create_autocmd('User', {
      desc = 'Close NeoTree on exit before session is saved',
      pattern = 'PersistenceSavePre',
      callback = function()
         vim.cmd([[Neotree close]])
      end,
   })
end

M.keys = {
   { '<leader>ne', m.cmd('Neotree toggle'), desc = 'Toggle Neotree' },
   {
      '<leader>nr',
      function()
         require('neo-tree.sources.git_status').refresh()
      end,
      desc = 'Refresh Neotree',
   },
}

return M
