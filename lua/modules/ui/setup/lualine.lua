local i = require('modules.ui.icons')
local M = {}

M.opts = {
   options = {
      icons_enabled = true,
      globalstatus = true,
      omponent_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = { 'alpha', 'dashboard', 'Outline' },
      always_divide_middle = true,
      theme = 'auto',
   },
}

M.config = function(_, opts)
   --stylua: ignore
   local colours = {
      red       = '#f38ba8',
      turqouise = '#92CDE7',
      green     = '#8FCDA9',
      grey_bg   = '#212430',
      grey_fg   = '#b4befe',
      black     = '#121319',
      navy      = '#0f111a'
   }

   --stylua: ignore
   local separators = {
      none  = { left = '', right = '' },
      left  = { left = i.misc.SemiCircleLeft, right = '' },
      right = { left = '', right = i.misc.SemiCircleRight },
      both  = { left = i.misc.SemiCircleLeft, right = i.misc.SemiCircleRight },
   }

   local icons = {
      mode = i.misc.Ghost,
      filename = i.fs.File, -- ,
      branch = i.git.Branch,
      diff = {
         added = ' ' .. i.git.Add .. ' ',
         modified = i.git.Mod .. ' ',
         removed = i.git.Remove .. ' ',
      },
      info = i.misc.Info,
      diagnostic = {
         error = i.diagnostics.Error .. ' ',
         warn = i.diagnostics.Warning .. ' ',
         hint = i.diagnostics.Hint .. ' ',
         info = i.diagnostics.Info .. ' ',
      },
      copilot = i.custom.Octoface,
      treesitter = i.custom.Tree,
      fmt = i.misc.Formatter,
      lsp = i.misc.LSP,
      fileformat = {
         unix = i.os.Unix,
         mac = i.os.Mac .. ' ',
         dos = i.os.Dos .. ' ',
      },
      filesize = i.misc.FileSize,
      location = i.misc.Location,
   }

   ---@param tbl table
   ---@return string
   local function table_to_string(tbl)
      local str_tokens = {}
      for idx, val in ipairs(tbl) do
         table.insert(str_tokens, idx .. '. ' .. val)
      end
      return table.concat(str_tokens, '\n')
   end

   local mode = {
      function()
         return icons.mode
      end,
      separator = separators.both,
   }

   local filename = {
      'filename',
      icon = icons.filename,
      color = { bg = colours.grey_bg, fg = colours.grey_fg, gui = 'bold' },
      separator = separators.none,
   }

   local branch = {
      'branch',
      icon = icons.branch,
      color = { bg = colours.grey_bg, fg = colours.grey_fg, gui = 'bold' },
      separator = { left = '', right = '' },
   }

   local diff = {
      'diff',
      source = function()
         ---@diagnostic disable-next-line: undefined-field
         local gitstats = vim.b.gitsigns_status_dict
         if gitstats then
            return {
               added = gitstats.added,
               modified = gitstats.changed,
               removed = gitstats.removed,
            }
         end
      end,
      colored = true,
      padding = { left = 0, right = 1 },
      symbols = icons.diff,
      color = { bg = colours.grey_bg },
      separator = separators.none,
   }

   local info = {
      function()
         return '󰓥'
      end,
      color = { bg = colours.green, fg = colours.black },
      separator = separators.both,
   }

   local diagnostics = {
      'diagnostics',
      sources = { 'nvim_lsp' },
      sections = {
         'info',
         'error',
         'warn',
         'hint',
      },
      diagnostic_color = {
         error = { fg = 'DiaganosticError', bg = colours.navy },
         warn = { fg = 'DiagnosticWarn', bg = colours.navy },
         info = { fg = 'DiaganosticInfo', bg = colours.navy },
         hint = { fg = 'DiaganosticHint', bg = colours.navy },
      },
      colored = true,
      update_in_insert = true,
      always_visible = true,
      symbols = icons.diagnostic,
      separator = separators.both,
   }

   local copilot = {
      function()
         return icons.copilot
      end,
      separator = '',
      padding = { right = 1 },
      color = function()
         return { fg = buf_cache.active.copilot and colours.turqouise or colours.red }
      end,
   }

   local treesitter = {
      function()
         return icons.treesitter
      end,
      separator = '',
      padding = 1,
      color = function()
         return { fg = buf_cache.active.treesitter and colours.turqouise or colours.red, gui = 'bold' }
      end,
   }

   local fmt = {
      function()
         return icons.fmt .. ' ' .. #(buf_cache.active.fmt or {})
      end,
      color = function()
         return { fg = #(buf_cache.active.fmt or {}) > 0 and colours.turqouise or colours.red, gui = 'bold' }
      end,
      padding = 0,
      separator = '',
      on_click = function()
         if #(buf_cache.active.fmt or {}) > 0 then
            local str = table_to_string(buf_cache.active.fmt)
            vim.notify(str, vim.log.levels.INFO, { title = 'Active Formatter' })
         else
            vim.notify('No formatters active', vim.log.levels.ERROR, { title = 'Active Formatter' })
         end
      end,
   }

   local lsp = {
      function()
         return icons.lsp .. ' ' .. #(buf_cache.active.lsp or {})
      end,
      color = function()
         return { fg = #(buf_cache.active.lsp or {}) > 0 and colours.turqouise or colours.red, gui = 'bold' }
      end,
      separator = '',
      on_click = function()
         if #(buf_cache.active.lsp or {}) > 0 then
            local str = table_to_string(buf_cache.active.lsp)
            vim.notify(str, vim.log.levels.INFO, { title = 'Active LSP' })
         else
            vim.notify('No LSP active', vim.log.levels.ERROR, { title = 'Active LSP' })
         end
      end,
   }

   local fileformat = {
      'fileformat',
      symbols = icons.fileformat,
      color = { bg = colours.green, fg = colours.black },
      separator = separators.both,
   }

   local filesize = {
      'filesize',
      icon = ' ' .. icons.filesize,
      color = { bg = colours.grey_bg, fg = colours.grey_fg, gui = 'bold' },
      separator = separators.none,
   }

   local filetype = {
      'filetype',
      colored = true,
      color = { bg = colours.grey_bg, fg = colours.grey_fg, gui = 'bold' },
      separator = separators.none,
   }

   local location = {
      function()
         local line = vim.fn.line('.')
         local total = vim.fn.line('$')
         return string.format(icons.location .. ' %d/%d', line, total)
      end,
      on_click = function()
         local line = vim.fn.line('.')
         local col = vim.fn.virtcol('.')
         local total = vim.fn.line('$')
         local str = string.format('line: %d\ncol: %d\ntotal: %d', line, col, total)
         vim.notify(str, vim.log.levels.INFO, { title = 'Location', icon = icons.location })
      end,
      padding = 0,
      separator = separators.both,
      color = { gui = 'bold' },
   }

   opts.sections = {
      lualine_a = { mode },
      lualine_b = { filename, branch, diff },
      lualine_c = { info, diagnostics },
      lualine_x = { copilot, treesitter, fmt, lsp, fileformat },
      lualine_y = { filesize, filetype },
      lualine_z = { location },
   }

   opts.inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
   }

   require('lualine').setup(opts)
end

return M
