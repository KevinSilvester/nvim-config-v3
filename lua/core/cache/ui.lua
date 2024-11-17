local helpers = require('core.cache.ui-helpers')

---@class CustomNuiTreeNode: NuiTree.Node
---@field _bufnr number
---@field _type 'parent'|'child'|'blank'
---@field active? boolean
---@field file? string
---@field key? string
---@field value? boolean|string|string[]
---@field id? string
---@field text? string

---@alias ChildData { _bufnr: number, id: string, child: boolean, key: string, value: boolean|string[] }
---@alias ParentData { _bufnr: number, text: string, file: string, active: boolean }
---@alias BlankData { _bufnr: number, id: string, blank: boolean }
---@alias NodeTable  { parent: ParentData, children: ChildData[], blank: BlankData }

---@class Core.BufCache.Ui
---@field _hl_created boolean
---@field _aborted boolean
---@field buffers Core.BufCache.Buffers
---@field bufnr_list number[]
---@field popup NuiPopup
---@field tree NuiTree
local Ui = {}
Ui.__index = Ui

---Must be called before creating Tree
---@return nui_popup_options
---@private
Ui.__POPUP_OPTIONS = function()
   return {
      enter = true,
      focusable = true,
      zindex = 1000,
      border = { style = 'rounded', text = { top = 'BufCache', bottom = "'?' for help" } },
      relative = 'editor',
      position = '50%',
      size = { height = '50%', width = 60 },
      buf_options = {
         modifiable = false,
         readonly = false,
         filetype = 'bufcache',
         buftype = 'nofile',
         bufhidden = 'wipe',
      },
   }
end

---Must be called after creating Popup
---@param popup_bufnr number
---@param bufnr_list number[]
---@param buffers Core.BufCache.Buffers
---@return nui_tree_options
---@private
Ui.__TREE_OPTIONS = function(popup_bufnr, bufnr_list, buffers)
   ---@type NodeTable[]
   local nodes_table = {}

   for _, bufnr in ipairs(bufnr_list) do
      local active = buffers.active.bufnr == bufnr
      nodes_table[bufnr] = helpers.gen_node_table(buffers.list[bufnr](), active)
   end

   local tree_nodes = helpers.gen_tree_nodes(nodes_table, bufnr_list)

   ---@type nui_tree_options
   return {
      bufnr = popup_bufnr,
      nodes = tree_nodes,
      prepare_node = helpers.prepare_node,
   }
end

---Initialise Ui
---@param buffers Core.BufCache.Buffers
---@return Core.BufCache.Ui
function Ui:init(buffers)
   local popup_ok, Popup = pcall(require, 'nui.popup')
   local tree_ok, Tree = pcall(require, 'nui.tree')

   local ui = setmetatable({
      _aborted = false,
      _hl_created = false,
      tree = nil,
      popup = nil,
      buffers = buffers,
      bufnr_list = vim.tbl_keys(buffers.list),
   }, self)

   if not (popup_ok or tree_ok) then
      log:error('core.cache.ui', 'failed to load `nui.nvim`')
      ui._aborted = true
      return ui
   end

   ui.popup = Popup(ui.__POPUP_OPTIONS())
   ui.tree = Tree(ui.__TREE_OPTIONS(ui.popup.bufnr, ui.bufnr_list, ui.buffers))

   return ui
end

---Create highlight groups
---@private
function Ui:__create_hl()
   -- stylua: ignore
   local hl_groups = {
      text           = { link = 'Normal' },
      brackets       = { fg = '#6c7086' },
      brackets_value = { fg = '#caa6f7' },
      arrows         = { link = 'GitSignsChange' },
      active         = { fg = '#64f5b8', bold = true },
      inactive       = { fg = '#f54a47', bold = true },
      boolean        = { link = '@boolean' },
      virt_text      = { link = 'Folded' },
   }

   for name, value in pairs(hl_groups) do
      vim.api.nvim_set_hl(0, 'core.cache.' .. name, value)
   end
end

---Set keymaps for popup
---@private
function Ui:__set_keymaps()
   ---@param next boolean
   local function next_prev_buffer(next)
      return function()
         local nodes = self.tree:get_nodes()
         local current_node = self.tree:get_node()
         if current_node == nil then
            return
         end

         local jump_list = {}
         local current_node_index = 1

         for _, n in ipairs(nodes) do
            if n._type == 'parent' then
               table.insert(jump_list, n._id)
            end
         end

         for i, id in ipairs(jump_list) do
            if id == current_node._id then
               current_node_index = i
            end
         end

         if current_node_index == 1 and not next then
            log:debug('core.cache.ui', 'current node is first node')
            return
         end

         if current_node_index == #nodes then
            log:debug('core.cache.ui', 'current node is last node')
            return
         end

         local target_idx = next and current_node_index + 1 or current_node_index - 1

         local _, target_linenr = self.tree:get_node(jump_list[target_idx])
         if target_linenr == nil then
            return
         end

         vim.api.nvim_win_set_cursor(self.popup.winid, { target_linenr, 0 })
      end
   end

   ---@param expand boolean
   local function expand_collapse_buffer(expand)
      return function()
         local node, linenr = self.tree:get_node()
         if node == nil or linenr == nil then
            return
         end

         -- luacheck: ignore 311
         local updated = false
         if expand then
            updated = node:expand()
         else
            updated = node:collapse()
         end

         if updated then
            vim.api.nvim_win_set_cursor(self.popup.winid, { linenr, 0 })
            vim.schedule(function()
               self.tree:render()
            end)
         end
      end
   end

   ---@param expand boolean
   local function expand_collapse_all(expand)
      return function()
         local nodes = self.tree:get_nodes()
         local node = self.tree:get_node()
         if node == nil then
            return
         end

         for _, n in ipairs(nodes) do
            if n:has_children() then
               if expand then
                  n:expand()
               else
                  n:collapse()
               end
            end
         end
         vim.schedule(function()
            self.tree:render()
            local _, linenr = self.tree:get_node(node._id)
            if linenr == nil then
               return
            end
            vim.api.nvim_win_set_cursor(self.popup.winid, { linenr, 0 })
         end)
      end
   end

   ---@param force boolean
   local function delete_buffer(force)
      return function()
         local nodes = self.tree:get_nodes()
         local node = self.tree:get_node()
         if node == nil then
            return
         end

         local jump_list = {}
         local delete_list = {}
         local current_node_index = 1

         ---@cast node CustomNuiTreeNode
         ---@cast nodes CustomNuiTreeNode[]

         for _, n in ipairs(nodes) do
            if n._type == 'parent' then
               table.insert(jump_list, n._id)
            end
            if n._bufnr == node._bufnr then
               table.insert(delete_list, n._id)
            end
         end

         for i, id in ipairs(jump_list) do
            if id == node._id then
               current_node_index = i
            end
         end

         local target_idx = current_node_index > 1 and current_node_index - 1 or current_node_index

         if node.file then
            vim.schedule(function()
               xpcall(function()
                  vim.api.nvim_buf_delete(node._bufnr, { force = force })
               end, function()
                  log:error(
                     'core.cache.ui',
                     'failed to delete buffer ' .. node._bufnr .. '(' .. self.buffers.list[node._bufnr].file
                  )
               end)

               if self.buffers:exists(node._bufnr) then
                  self.buffers:delete(node._bufnr)
               end

               for _, id in ipairs(delete_list) do
                  self.tree:remove_node(id)
               end

               self.tree:render()

               local _, target_linenr = self.tree:get_node(jump_list[target_idx])
               if target_linenr == nil then
                  return
               end
               vim.api.nvim_win_set_cursor(self.popup.winid, { target_linenr, 0 })
            end)
         end
      end
   end

   -- Close/exit
   self.popup:map('n', { 'q', '<esc>' }, function()
      vim.schedule(function()
         self.popup:unmount()
      end)
   end, { noremap = true, silent = true })

   -- Next/Prev buffer
   self.popup:map('n', 'k', next_prev_buffer(false), { noremap = true, silent = true })
   self.popup:map('n', 'j', next_prev_buffer(true), { noremap = true, silent = true })

   -- Expand/Collapse buffer
   self.popup:map('n', 'l', expand_collapse_buffer(true), { noremap = true, silent = true })
   self.popup:map('n', '<cr>', expand_collapse_buffer(true), { noremap = true, silent = true })
   self.popup:map('n', 'h', expand_collapse_buffer(false), { noremap = true, silent = true })

   -- Expand/Collapse all
   self.popup:map('n', 'L', expand_collapse_all(true), { noremap = true, silent = true })
   self.popup:map('n', 'H', expand_collapse_all(false), { noremap = true, silent = true })

   -- Open buffer
   self.popup:map('n', 'o', function()
      local node = self.tree:get_node()
      if node == nil then
         return
      end

      ---@cast node CustomNuiTreeNode
      if node.file then
         vim.schedule(function()
            self.popup:unmount()
            vim.api.nvim_set_current_buf(node._bufnr)
         end)
      end
   end, { noremap = true, silent = true })

   -- Delete buffer
   self.popup:map('n', 'd', delete_buffer(false), { noremap = true, silent = true })
   self.popup:map('n', 'D', delete_buffer(true), { noremap = true, silent = true })

   -- Refresh
   self.popup:map('n', 'r', function()
      vim.notify('Refreshing buffer info...', 'info', { title = 'core.cache' })
      buf_cache:refresh_all()
      vim.defer_fn(function()
         ---@type NodeTable[]
         local nodes_table = {}
         local nodes = self.tree:get_nodes()

         for _, bufnr in ipairs(self.bufnr_list) do
            local active = self.buffers.active.bufnr == bufnr
            nodes_table[bufnr] = helpers.gen_node_table(self.buffers.list[bufnr](), active)
         end

         for _, node in ipairs(nodes) do
            if node._type == 'parent' then
               local children = self.tree:get_nodes(node._id)
               for i, child in ipairs(children) do
                  ---@cast child CustomNuiTreeNode
                  child.value = nodes_table[node._bufnr].children[i].value
               end
            end
         end

         vim.schedule(function()
            self.tree:render()
         end)
      end, 5)
   end, { noremap = true, silent = true })

   -- Go to bottom
   self.popup:map('n', 'G', function()
      local nodes = self.tree:get_nodes()
      local last_parent_node = nil

      for _, node in ipairs(nodes) do
         if node._type == 'parent' then
            last_parent_node = node
         end
      end

      if last_parent_node == nil then
         return
      end
      local _, linenr = self.tree:get_node(last_parent_node._id)
      if linenr == nil then
         return
      end
      vim.api.nvim_win_set_cursor(self.popup.winid, { linenr, 0 })
   end, { noremap = true, silent = true })

   -- Help
   self.popup:map('n', '?', function()
      local help_text = {
         'Buffer Info',
         '',
         'Keybindings:',
         '',
         '  <esc> or q: Close',
         '  <cr>: Expand',
         '  l: Expand',
         '  L: Expand all',
         '  h: Collapse',
         '  H: Collapse all',
         '  o: Open buffer',
         '  r: Refresh all buffer info',
         '  d: Delete buffer',
         '  D: Force delete buffer',
      }

      local Popup = require('nui.popup')

      local help_popup = Popup({
         enter = true,
         focusable = true,
         zindex = 2000,
         border = { style = 'rounded', text = { top = 'BufCache Help' } },
         relative = 'editor',
         position = '50%',
         size = { height = #help_text + 2, width = 35 },
         buf_options = { modifiable = true, readonly = true },
      })

      vim.api.nvim_buf_set_lines(help_popup.bufnr, 0, -1, false, help_text)
      vim.api.nvim_set_option_value('modifiable', false, { buf = help_popup.bufnr })

      help_popup:on({ 'BufLeave', 'BufDelete', 'BufWinLeave' }, function()
         vim.schedule(function()
            help_popup:unmount()
         end)
      end, { once = true })

      help_popup:map('n', { 'q', '<esc>' }, function()
         help_popup:unmount()
      end, { noremap = true, silent = true })

      vim.schedule(function()
         help_popup:mount()
      end)
   end, { noremap = true, silent = true })
end

---Render Buffer Info
function Ui:render()
   if self._aborted then
      return
   end

   if not self._hl_created then
      self:__create_hl()
      self._hl_created = true
   end

   self:__set_keymaps()
   self.popup:mount()
   self.tree:render()
end

return Ui
