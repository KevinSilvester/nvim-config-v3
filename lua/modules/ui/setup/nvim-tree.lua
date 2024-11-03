local m = require('core.mapper')
local icons = require('modules.ui.icons')
local M = {}

M.opts = {
   on_attach = 'disable',
   view = {
      adaptive_size = false,
      width = 40,
   },
   renderer = {
      highlight_git = true,
      highlight_opened_files = 'none',
      -- root_folder_label = ':t',
      indent_markers = {
         enable = true,
         icons = {
            corner = '╰',
            edge = '│ ',
            item = '├ ',
            none = '  ',
         },
      },
      icons = {
         symlink_arrow = ' -> ',
         git_placement = 'before',
         glyphs = {
            default = icons.fs.File,
            symlink = icons.fs.FileSymlink,
            bookmark = icons.fs.BookMark,
            folder = {
               arrow_closed = '',
               arrow_open = '',
               default = icons.fs.DirClosed,
               open = icons.fs.DirOpen,
               empty = icons.fs.DirEmptyClosed,
               empty_open = icons.fs.DirEmptyOpen,
               symlink = icons.fs.DirSymlink,
               symlink_open = icons.fs.DirOpen,
            },
            git = {
               unstaged = icons.git.Unstaged,
               staged = icons.git.Staged,
               unmerged = icons.git.Unmerged,
               renamed = icons.git.Rename,
               untracked = icons.git.Untracked,
               deleted = icons.git.Remove,
               ignored = icons.git.Ignore,
               -- ignored = "◌",
            },
         },
      },
      special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md', 'package.json' },
   },
   hijack_directories = {
      enable = false, -- true
      auto_open = true,
   },
   update_focused_file = {
      enable = true, -- false
      debounce_delay = 15, -- missing
      update_root = false,
      update_cwd = true,
   },
   diagnostics = {
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
      icons = {
         hint = icons.diagnostics.Hint,
         info = icons.diagnostics.Info,
         warning = icons.diagnostics.Warning,
         error = icons.diagnostics.Error,
      },
   },
   filters = {
      custom = { 'node_modules', '\\.cache', '^.git$', 'target', '\\.idea' }, -- {}
   },
   live_filter = {
      prefix = '[FILTER]: ',
      always_show_folders = false,
   },
   git = {
      enable = true,
      ignore = false,
      show_on_dirs = true,
      show_on_open_dirs = true,
      timeout = 200, -- 400
   },
   actions = {
      file_popup = {
         open_win_config = {
            border = 'rounded', -- rounded
         },
      },
      open_file = {
         resize_window = false, -- true
         window_picker = {
            exclude = {
               filetype = { 'notify', 'lazy', 'lir', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
               buftype = { 'nofile', 'terminal', 'help' },
            },
         },
      },
   },
   trash = {
      cmd = HOST.is_win and 'pwsh -c Remove-ItemSafely' or 'trash-put',
      require_confirm = true, -- missing
   },
}

M.config = function(_, opts)
   local api = require('nvim-tree.api')
   require('nvim-web-devicons').refresh()

   opts.on_attach = function(bufnr)
      api.config.mappings.default_on_attach(bufnr)

      -- stylua: ignore
      m.buf_nmap(bufnr, {
         -- { 'A', api.tree.expand_all, k_opts(silent, noremap, nowait, 'Expand All') },
         { 'd', api.fs.trash,                   m.opts(m.silent, m.noremap, m.nowait, 'Trash') },
         { 'D', api.fs.remove,                  m.opts(m.silent, m.noremap, m.nowait, 'Remove') },
         { 'h', api.node.navigate.parent_close, m.opts(m.silent, m.noremap, m.nowait, 'Close') },
         { 'H', api.tree.collapse_all,          m.opts(m.silent, m.noremap, m.nowait, 'Collapse All') },
         { '?', api.tree.toggle_help,           m.opts(m.silent, m.noremap, m.nowait, 'Help') },
         { 't', api.tree.toggle_custom_filter,  m.opts(m.silent, m.noremap, m.nowait, 'Toggle Filter') },
         { 'C', api.tree.change_root_to_node,   m.opts(m.silent, m.noremap, m.nowait, 'CD') },
         {
            'P',
            function()
               require('utils.fn').inspect(api.tree.get_node_under_cursor())
            end,
            m.opts(m.silent, m.noremap, m.nowait, 'Print Node Path'),
         },
         { 'Z', api.node.run.system, m.opts(m.silent, m.noremap, m.nowait, 'Run System') },
         {
            'l',
            api.node.open.edit,
            m.opts(m.silent, m.noremap, m.nowait, 'Edit Or Open'),
         },
         {
            'L',
            function()
               local node = api.tree.get_node_under_cursor()
               if node ~= nil and node.nodes ~= nil then
                  api.node.open.edit()
               else
                  api.node.open.preview()
               end
               api.tree.focus()
            end,
            m.opts(m.silent, m.noremap, m.nowait, 'Vsplit Preview'),
         },
      })
   end

   require('nvim-tree').setup(opts)
end

-- stylua: ignore
M.keys = {
   { '<leader>ne', m.cmd('NvimTreeToggle'),  desc = 'Toggle NvimTree' },
   { '<leader>nr', m.cmd('NvimTreeRefresh'), desc = 'Refresh NvimTree' },
}

return M
