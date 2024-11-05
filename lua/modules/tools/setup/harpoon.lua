local m = require('core.mapper')
local uv = vim.uv
local M = {}

M.config = function()
   local harpoon = require('harpoon')

   ---@param delay number
   local function refresh_harpoon(delay)
      vim.defer_fn(function()
         HARPOON_LIST = {}
         for idx, item in ipairs(harpoon:list().items) do
            HARPOON_LIST[item.value] = idx
         end
      end, delay)
   end

   local harpoon_events = {
      SETUP_CALLED = function(_)
         refresh_harpoon(10)
      end,
      ADD = function(cx)
         HARPOON_LIST[cx.item.value] = cx.idx
      end,
      REMOVE = function(cx)
         HARPOON_LIST[cx.item.value] = nil
      end,
      LIST_CHANGE = function(_)
         refresh_harpoon(50)
      end,
   }

   harpoon:extend({
      SETUP_CALLED = harpoon_events.SETUP_CALLED,
      ADD = harpoon_events.ADD,
      REMOVE = harpoon_events.REMOVE,
      LIST_CHANGE = harpoon_events.LIST_CHANGE,
   })

   harpoon:setup({
      default = {
         ---@param list_item HarpoonListItem
         display = function(list_item)
            local cwd = uv.cwd()
            if not cwd then
               return list_item.value
            end
            local value = list_item.value
            -- local value = list_item.value:gsub(cwd .. ufs.path_separator, '')
            return value
         end,

         create_list_item = function(_, _name)
            local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
            ---@diagnostic disable-next-line: param-type-mismatch
            local bufnr = vim.fn.bufnr(name, false)

            local pos = { 1, 0 }
            if bufnr ~= -1 then
               pos = vim.api.nvim_win_get_cursor(0)
            end

            return {
               value = name,
               context = {
                  row = pos[1],
                  col = pos[2],
               },
            }
         end,
      },
   })

   local conf = require('telescope.config').values
   local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
         table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
         .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table({
               results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
         })
         :find()
   end

   m.nmap({
      {
         '<leader>fh',
         function()
            toggle_telescope(require('harpoon'):list())
         end,
         m.opts(m.noremap, m.silent, '[harpoon] Find'),
      },
      {
         '<leader>hr',
         function()
            refresh_harpoon(50)
         end,
         m.opts(m.noremap, m.silent, '[harpoon] Find'),
      },
   })
end

-- stylua: ignore
M.keys = {
   { '<leader>a',  function() require('harpoon'):list():add() end,     desc = 'Harpoon Append', },
   { '<C-[>',      function() require('harpoon'):list():prev() end,    desc = 'Harpoon Previous', },
   { '<C-]>',      function() require('harpoon'):list():next() end,    desc = 'Harpoon Next', },
   { '<leader>h1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon Select 1', },
   { '<leader>h2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon Select 2', },
   { '<leader>h3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon Select 3', },
   { '<leader>h4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon Select 4', },
   { '<leader>h5', function() require('harpoon'):list():select(5) end, desc = 'Harpoon Select 5', },
   {
      '<leader>hs',
      function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end,
      desc = 'Harpoon Quick Menu',
   },
   { '<leader>hd', function() log:dump(require('harpoon').logger.lines) end, desc = 'Harpoon Dump Logs' },
   { '<leader>hr', desc = 'Harpoon Dump Logs' },
   { '<leader>fh', desc = '[harpoon] Find' },
}

return M
