local M = {}

---@alias Catppuccino 'catppuccin' | 'catppuccin-mocha' | 'catppuccin-macchiato' | 'catppuccin-latte' | 'catppuccin-frappe'

---set colorscheme
---@param colorscheme Catppuccino|'kanagawa'|'material'|'tokyonight'|'zephyr'|'darkplus'|'onedarker'|'poimandres'|'everforest'
M.setup = function(colorscheme)
   xpcall(function()
      vim.cmd('colorscheme ' .. colorscheme)
   end, function()
      log:warn('modules.ui.colorscheme', 'colorscheme ' .. colorscheme .. ' not found!')
   end)
end

return M
