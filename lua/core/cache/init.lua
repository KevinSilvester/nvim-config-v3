local Buffers = require('core.cache.buffers')
local Ui = require('core.cache.ui')

local function augroup(name)
   return vim.api.nvim_create_augroup('core.cache.' .. name, { clear = true })
end

---@class Core.BufCache
---@field buffers Core.BufCache.Buffers
---@field _excluded_ft string[]
---@field _hl_created boolean
local BufCache = {}
BufCache.__index = BufCache

---Initialise BufCache
---@private
function BufCache:init()
   local buf_cache_ = setmetatable({
      buffers = Buffers:new(),
      _hl_created = false,
      _excluded_ft = {
         -- 'help',
         'netrw',
         'NvimTree',
         'neo-tree',
         'mason',
         'lazy',
         'toggleterm',
         'alpha',
         'TelescopePropmt',
         'sagaoutline',
         'sagaoufinder',
         'undotree',
         'diff',
         'DiffviewFile',
         'DiffviewFileHistory',
         'fugitiveblame',
      },
   }, self)

   return buf_cache_
end

---Start BufCache and create global `buf_cache`
function BufCache:start()
   self:__create_autocmds()
   _G.buf_cache = self
end

---Create autocmds
---@private
function BufCache:__create_autocmds()
   vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
      group = augroup('active-buffer'),
      desc = 'Update/Insert active buffer + check treesitter',
      callback = function(event)
         if self:__is_excluded(vim.bo[event.buf].filetype) then
            return
         end
         if event.file ~= '' then
            self.buffers:insert(event.buf)
            self.buffers.list[event.buf]:check_treesitter()
            self.buffers:update_active(event.buf)
         end
      end,
   })

   vim.api.nvim_create_autocmd({ 'BufLeave', 'BufHidden', 'BufDelete' }, {
      group = augroup('delete-excluded'),
      desc = 'Delete buffer if excluded filetype',
      callback = function(event)
         if self.buffers:exists(event.buf) and self:__is_excluded(vim.bo[event.buf].filetype) then
            self.buffers:delete(event.buf)
         end
      end,
   })

   vim.api.nvim_create_autocmd({ 'BufDelete' }, {
      group = augroup('delete-buffer'),
      desc = 'Delete buffer',
      callback = vim.schedule_wrap(function(event)
         self.buffers:delete(event.buf)
      end),
   })

   vim.api.nvim_create_autocmd({ 'LspAttach' }, {
      group = augroup('add-lsp'),
      desc = 'Add LSP/formatter attached to buffer',
      callback = vim.schedule_wrap(function(event)
         if event.file ~= '' then
            -- for edge cases caused by opening lsp references windows with lspsaga
            if not self.buffers:exists(event.buf) then
               return
            end

            self.buffers.list[event.buf]:add_lsp(event.data.client_id)

            if event.buf == self.buffers.active.bufnr then
               vim.defer_fn(function()
                  self.buffers:update_active(event.buf)
               end, 5)
            end
         end
      end),
   })

   vim.api.nvim_create_autocmd({ 'LspDetach' }, {
      group = augroup('remove-lsp'),
      desc = 'Remove LSP/formatter detached from buffer',
      callback = vim.schedule_wrap(function(event)
         -- for when buffer is deleted
         if not self.buffers:exists(event.buf) then
            return
         end

         self.buffers.list[event.buf]:remove_lsp(event.data.client_id)

         if event.buf == self.buffers.active.bufnr then
            vim.defer_fn(function()
               self.buffers:update_active(event.buf)
            end, 5)
         end
      end),
   })
end

---Check if filetype is excluded
---@private
---@param ft string
---@return boolean
function BufCache:__is_excluded(ft)
   return vim.tbl_contains(self._excluded_ft, ft)
end

---Refresh buf cache for active buffer
function BufCache:refresh()
   ---@type number
   local bufnr = vim.api.nvim_get_current_buf()
   self.buffers:refresh(bufnr)
   vim.defer_fn(function()
      self.buffers:update_active(bufnr)
   end, 5)
end

---Refresh buf cache for all buffers
function BufCache:refresh_all()
   ---@type number[]
   local bufnr_list = vim.tbl_keys(self.buffers.list)

   for _, bufnr in ipairs(bufnr_list) do
      self.buffers:refresh(bufnr)
   end
   if self.buffers.active.bufnr == vim.api.nvim_get_current_buf() then
      vim.defer_fn(function()
         self.buffers:update_active(self.buffers.active.bufnr)
      end, 5)
   end
end

---Render BufCache info to popup window
function BufCache:render()
   local ui = Ui:init(self.buffers)
   ui:render()
end

local buf_cache_ = BufCache:init()
return buf_cache_
