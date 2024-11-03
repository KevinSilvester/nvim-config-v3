local M = {}

--[[
   ╭─────────────────────────────────────────────────────────────────────────╮
   │ INSPIRED BY:                                                            │
   │   - https://github.com/Wansmer/nvim-config                              │
   │   - https://www.reddit.com/r/neovim/comments/1gghjvt/comment/luq9x27/   │
   │   - https://www.reddit.com/r/neovim/comments/1ggwaho/comment/luszaju/   │
   ╰─────────────────────────────────────────────────────────────────────────╯
]]

---
---

-- Ref: <https://github.com/Wansmer/nvim-config/blob/fe7a8243656807f13b13e9f129aec107735c2613/lua/utils.lua#L55>
local function char_on_pos(pos)
   pos = pos or vim.fn.getpos('.')
   return tostring(vim.fn.getline(pos[1])):sub(pos[2], pos[2])
end

-- Ref: <https://github.com/Wansmer/nvim-config/blob/fe7a8243656807f13b13e9f129aec107735c2613/lua/utils.lua#L64>
local function char_byte_count(s, i)
   if not s or s == '' then
      return 1
   end

   local char = string.byte(s, i or 1)

   -- Get byte count of unicode character (RFC 3629)
   if char > 0 and char <= 127 then
      return 1
   elseif char >= 194 and char <= 223 then
      return 2
   elseif char >= 224 and char <= 239 then
      return 3
   elseif char >= 240 and char <= 244 then
      return 4
   end
end

-- Ref: <https://github.com/Wansmer/nvim-config/blob/fe7a8243656807f13b13e9f129aec107735c2613/lua/utils.lua#L83>
local function get_visual_range()
   local sr, sc = unpack(vim.fn.getpos('v'), 2, 3)
   local er, ec = unpack(vim.fn.getpos('.'), 2, 3)

   -- To correct work with non-single byte chars
   local byte_c = char_byte_count(char_on_pos({ er, ec }))
   ec = ec + (byte_c - 1)

   -- luacheck: ignore 311
   local range = {}

   if sr == er then
      local cols = sc >= ec and { ec, sc } or { sc, ec }
      range = { sr, cols[1] - 1, er, cols[2] }
   elseif sr > er then
      range = { er, ec - 1, sr, sc }
   else
      range = { sr, sc - 1, er, ec }
   end

   return range
end

-- Ref: <https://www.reddit.com/r/neovim/comments/1ggwaho/comment/luszaju>
local function get_num_wraps(args)
   -- Calculate the actual buffer width, accounting for splits, number columns, and other padding
   local wrapped_lines = vim.api.nvim_win_call(0, function()
      local winid = vim.api.nvim_get_current_win()

      -- get the width of the buffer
      local winwidth = vim.api.nvim_win_get_width(winid)
      local numberwidth = (vim.wo.number or vim.wo.relativenumber) and 1 or 0
      local signwidth = 2 -- are there `signcolumns` for this buffer, if yes 2
      local foldwidth = 1 -- the `foldcolumn`

      -- calculate buffer width
      local bufferwidth = winwidth - numberwidth - signwidth - foldwidth

      -- fetch the line and calculate its display width (accounts for display cells used by tabs)
      local line = vim.fn.getline(args.lnum)
      local line_length = vim.fn.strdisplaywidth(line)

      return math.floor(line_length / bufferwidth)
   end)

   return wrapped_lines
end

local function visual_hl(args)
   local mode = vim.fn.strtrans(vim.fn.mode()):lower():gsub('%W', '')
   local cur = vim.api.nvim_win_get_cursor(0)
   local is_in_range = false

   if mode == 'v' and cur[1] ~= args.lnum then
      local v_range = get_visual_range()
      is_in_range = args.lnum >= v_range[1] and args.lnum <= v_range[3]
   end

   return is_in_range and '%#CursorLineNr#' or ''
end

---Modified version of `status.builtin.lnumfunc`
---Return line number and adds visual highlight if line is in visual selection
---Ref: <https://github.com/Wansmer/nvim-config/blob/fe7a8243656807f13b13e9f129aec107735c2613/lua/modules/status/components.lua#L6>
---@param args table
local function lnumfunc(args)
   if (not args.rnu and not args.nu) or args.virtnum < 0 then
      return ''
   end

   -- Calculate the actual buffer width, accounting for splits, number columns, and other padding
   local v_hl = visual_hl(args)

   if vim.wo.wrap then
      local wrapped_lines = get_num_wraps(args)
      if args.virtnum > 0 and (vim.wo.number or vim.wo.relativenumber) then
         if args.virtnum == wrapped_lines then
            return '%=' .. v_hl .. '╰'
         else
            return '%=' .. v_hl .. '├'
         end
      end
   end

   local lnum = args.rnu and (args.relnum > 0 and args.relnum or (args.nu and args.lnum or 0)) or args.lnum
   return '%=' .. v_hl .. lnum
end

M.config = function()
   local builtin = require('statuscol.builtin')
   require('statuscol').setup({
      -- foldunc = 'builtin',
      -- setopt = true,
      relculright = true,
      segments = {
         { text = { '%s' }, click = 'v:lua.ScSa' },
         {
            text = { lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
         },
         { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
      },
   })
end

return M
