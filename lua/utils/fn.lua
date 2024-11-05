local ufs = require('utils.fs')
local fn = vim.fn
local uv = vim.uv

local M = {}

---check whether executable is callable
---@param name string name of executable
---@return boolean
M.executable = function(name)
   return fn.executable(name) == 1
end

---check whether a feature exists in Nvim
---@param feat string the feature name, like `nvim-0.7` or `unix`
---@return boolean
M.has = function(feat)
   return fn.has(feat) == 1
end

---print vim.inspect output to a popup window/buffer
---@param input any input can by anything that vim.inspect is able to parse
---@param yank? boolean wheather to copy the ouput to clipboard
---@param ft? string filetype (default `lua`)
---@param open_split? boolean whether to use popup window
M.inspect = function(input, yank, ft, open_split)
   local popup_ok, Popup = pcall(require, 'nui.popup')
   local split_ok, Split = pcall(require, 'nui.split')

   if input == nil then
      log:warn('utils.fn.inspect', 'No input provided')
      return
   end
   if not popup_ok or not split_ok then
      log:error('utils.fn.inspect', 'Failed to load plugin `nui`')
      return
   end

   local output = vim.inspect(input)
   local buf_options = {
      modifiable = true,
      readonly = false,
      filetype = ft or 'lua',
      buftype = 'nofile',
      bufhidden = 'wipe',
   }
   local component

   if open_split then
      component = Split({
         enter = true,
         relative = 'win',
         position = 'bottom',
         size = '20%',
         buf_options = buf_options,
      })
   else
      component = Popup({
         enter = true,
         focusable = true,
         border = { style = 'rounded' },
         relative = 'editor',
         position = '50%',
         size = { width = '80%', height = '60%' },
         buf_options = buf_options,
      })
   end

   vim.schedule(function()
      component:mount()

      component:map('n', 'q', function()
         component:unmount()
      end, { noremap = true, silent = true })

      component:on({ 'BufLeave', 'BufDelete', 'BufWinLeave' }, function()
         vim.schedule(function()
            component:unmount()
         end)
      end, { once = true })

      vim.api.nvim_buf_set_lines(component.bufnr, 0, 1, false, vim.split(output, '\n', {}))

      if yank then
         vim.cmd(component.bufnr .. 'b +%y')
      end
   end)
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
-- * ref: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua#L49
---@return string
M.get_root = function()
   ---@type string?
   local path = vim.api.nvim_buf_get_name(0)
   path = path ~= '' and uv.fs_realpath(path) or nil
   ---@type string[]
   local roots = {}

   if path then
      for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
         local workspace = client.config.workspace_folders
         local paths = workspace
               and vim.tbl_map(function(ws)
                  return vim.uri_to_fname(ws.uri)
               end, workspace)
            or client.config.root_dir and { client.config.root_dir }
            or {}
         for _, p in ipairs(paths) do
            local r = uv.fs_realpath(p)

            ---@cast r string
            if path:find(r, 1, true) then
               roots[#roots + 1] = r
            end
         end
      end
   end
   table.sort(roots, function(a, b)
      return #a > #b
   end)
   ---@type string?
   local root = roots[1]
   if not root then
      path = path and vim.fs.dirname(path) or uv.cwd()
      ---@type string?
      root = vim.fs.find({ '.git', 'lua' }, {
         path = path,
         upward = true,
         type = 'directory',
         limit = 10,
         stop = '',
      })[1]
      root = root and vim.fs.dirname(root) or uv.cwd()
   end
   ---@cast root string
   return root
end

-- this will return a function that calls telescope.
-- cwd will default to util.get_root
-- for `files`, git_files or find_files will be chosen depending on .git
-- ref: https://github.com/LazyVim/LazyVim/blob/879e29504d43e9f178d967ecc34d482f902e5a91/lua/lazyvim/util/telescope.lua#L20
---@param builtin string
---@param opts table
M.telescope = function(builtin, opts)
   local params = { builtin = builtin, opts = opts }

   return function()
      builtin = params.builtin
      opts = params.opts
      opts = vim.tbl_deep_extend('force', { cwd = M.get_root() }, opts or {})

      if builtin == 'files' then
         if uv.fs_stat((opts.cwd or uv.cwd()) .. '/.git') then
            opts.show_untracked = true
            builtin = 'git_files'
         else
            builtin = 'find_files'
         end
      end
      require('telescope.builtin')[builtin](opts)
   end
end

M.on_very_lazy = function(func)
   vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
         func()
      end,
   })
end

---Run shell command with callbackc for stderr|stdout
---@param command string
---@param args table<integer|string>
---@param on_exit fun(code: number, signal: number)|nil
---@param out {fn?: fun(data: string), log?: boolean}|nil
---@param err {fn?: fun(data: string), log?: boolean}|nil
M.spawn = function(command, args, on_exit, out, err)
   local stdout = uv.new_pipe(false)
   local stderr = uv.new_pipe(false)

   if not stdout or not stderr then
      log:error('utils.fn.spawn', '[command: ' .. command .. ']: Failed to create pipes for stdout/stderr')
      return
   end

   assert(stdout)
   assert(stderr)

   local proc
   proc = uv.spawn(
      command,
      ---@diagnostic disable-next-line: missing-fields
      { args = args, stdio = { nil, stdout, stderr } },
      vim.schedule_wrap(function(code, signal)
         stdout:read_stop()
         stderr:read_stop()
         stdout:close()
         stderr:close()

         ---@cast proc uv.uv_process_t
         proc:close()
         if type(on_exit) == 'function' then
            on_exit(code, signal)
         end
      end)
   )

   stderr:read_start(function(_, data)
      if data and type(err) ~= 'nil' then
         local str = data:sub(1, -2)
         if err.log then
            log:debug('utils.fn.spawn', 'Command: `' .. command .. '` | StdErr: `' .. str .. '`', true)
         end
         if type(err.fn) == 'function' then
            err(str)
         end
      end
   end)

   stdout:read_start(function(_, data)
      if data and type(out) ~= 'nil' then
         local str = data:sub(1, -2)
         if out.log then
            log:debug('utils.fn.spawn', 'Command: `' .. command .. '` | StdOut: `' .. str .. '`', true)
         end
         if type(out.fn) == 'function' then
            out(str)
         end
      end
   end)
   return 'poop'
end

---Run shell command and return stdout
---@param cmd string
---@param opts? {timeout?:number, cwd?:string, env?:table}
---@return boolean, string[]
M.exec = function(cmd, opts)
   opts = opts or {}
   ---@type string[]
   local lines
   local job = fn.jobstart(cmd, {
      cwd = opts.cwd,
      pty = false,
      env = opts.env,
      stdout_buffered = true,
      on_stdout = function(_, lines_)
         lines = lines_
      end,
   })
   local res = fn.jobwait({ job }, opts.timeout or 1000)
   table.remove(lines, #lines)
   return res[1] == 0, lines
end

---Set the tabstop, softtabstop and shiftwidth for buffer or globally
---@param val number
---@param bufnr number|nil
M.tab_opts = function(val, bufnr)
   if type(bufnr) == 'number' then
      vim.bo[bufnr].tabstop = val
      vim.bo[bufnr].softtabstop = val
      vim.bo[bufnr].shiftwidth = val
   else
      vim.opt.tabstop = val
      vim.opt.softtabstop = val
      vim.opt.shiftwidth = val
   end
end

M.get_treesitter_parsers = function()
   local res = {}

   for k, v in pairs(require('nvim-treesitter.parsers').list) do
      local value = string.format(
         [[   {
      "language": "%s",
      "url": "%s",
      "files": %s
   }]],
         k,
         v.install_info.url,
         vim.json.encode(v.install_info.files)
      )
      table.insert(res, value)
   end

   ufs.write_file(
      ufs.path_join(PATH.config, 'parsers.json'),
      '[\n' .. table.concat(res, ',\n') .. '\n]',
      'w+'
   )
end

return M
