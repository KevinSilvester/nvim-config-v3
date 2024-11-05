local M = {}

M.opts = {
   options = {
      always_show_bufferline = true,
      mode = 'buffers',
      numbers = 'none',
      close_command = function(n)
         require('mini.bufremove').delete(n, false)
      end,
      right_mouse_command = function(n)
         require('mini.bufremove').delete(n, false)
      end,
      separator_style = 'thin', -- | "thick" | "thin" | { 'any', 'any' },
      show_tab_indicators = true,
      offsets = {
         {
            filetype = 'NvimTree',
            text_align = 'center',
            text = 'File Explorer',
         },
         {
            filetype = 'neo-tree',
            text_align = 'center',
            text = 'File Explorer',
         },
      },
   },
   highlights = {
      -- fill = {
      --    fg = { attribute = 'fg', highlight = '#ff0000' },
      --    bg = { attribute = 'bg', highlight = 'TabLine' },
      -- },
      background = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      buffer_visible = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      close_button = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      close_button_visible = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      tab_selected = {
         fg = { attribute = 'fg', highlight = 'Normal' },
         bg = { attribute = 'bg', highlight = 'Normal' },
      },
      tab = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      tab_close = {
         fg = { attribute = 'fg', highlight = 'TabLineSel' },
         bg = { attribute = 'bg', highlight = 'Normal' },
      },
      duplicate_selected = {
         fg = { attribute = 'fg', highlight = 'TabLineSel' },
         bg = { attribute = 'bg', highlight = 'TabLineSel' },
         italic = true,
      },
      duplicate_visible = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
         italic = true,
      },
      duplicate = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
         italic = true,
      },
      modified = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      modified_selected = {
         fg = { attribute = 'fg', highlight = 'Normal' },
         bg = { attribute = 'bg', highlight = 'Normal' },
      },
      modified_visible = {
         fg = { attribute = 'fg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      separator = {
         fg = { attribute = 'bg', highlight = 'TabLine' },
         bg = { attribute = 'bg', highlight = 'TabLine' },
      },
      separator_selected = {
         fg = { attribute = 'bg', highlight = 'Normal' },
         bg = { attribute = 'bg', highlight = 'Normal' },
      },
      indicator_selected = {
         fg = { attribute = 'fg', highlight = 'LspDiagnosticsDefaultHint' },
         bg = { attribute = 'bg', highlight = 'Normal' },
      },
   },
}
return M
