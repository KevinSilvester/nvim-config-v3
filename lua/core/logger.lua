local ufs = require('utils.fs')

---@class Core.Logger
---@field _logfile string
---@field _silent boolean
local Logger = {}
Logger.__index = Logger

---Initialize Logger
---@private
function Logger:init()
   local logger = setmetatable({
      _logfile = ufs.path_join(PATH.data, 'my-config.log'),
      _silent = false,
   }, self)

   return logger
end

---Start logger (ONCE OFF CALL)
---@param logfile string? logfile path
---@param silent boolean? notify log output (default is `false`)
function Logger:start(logfile, silent)
   if type(logfile) == 'string' then
      self._logfile = logfile
   end

   if type(silent) == 'boolean' then
      self._silent = silent
   end

   _G.log = self
end

---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:trace(origin, message, silent)
   self:__log('TRACE', origin, message, silent)
end

---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:debug(origin, message, silent)
   self:__log('DEBUG', origin, message, silent)
end

---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:info(origin, message, silent)
   self:__log('INFO', origin, message, silent)
end

---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:warn(origin, message, silent)
   self:__log('WARN', origin, message, silent)
end

---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:error(origin, message, silent)
   self:__log('ERROR', origin, message, silent)
end

---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:off(origin, message, silent)
   self:__log('OFF', origin, message, silent)
end

---Log to logfile
---@private
---@param level 'TRACE'|'DEBUG'|'INFO'|'WARN'|'ERROR'|'OFF' log level
---@param origin string origin of logged message
---@param message any message to be logged
---@param silent? boolean notify log output (default is `false`)
function Logger:__log(level, origin, message, silent)
   if type(message) ~= 'string' then
      message = vim.inspect(message)
   end

   vim.schedule(function()
      xpcall(function()
         -- stylua: ignore
         ufs.write_file(self._logfile,
            '[' .. os.date('%X %a %d/%m/%Y') .. '] - [' .. level .. '] - - [' .. origin .. '] - ' .. message .. '\n', 'a'
         )
      end, function()
         vim.notify('Failed writing to logfile', vim.log.levels.ERROR, { title = '[ERROR] core.logger' })
      end)
   end)

   -- luacheck: ignore
   local silent_log = false

   if type(silent) == 'boolean' then
      silent_log = silent
   else
      silent_log = self._silent
   end

   if not silent_log then
      vim.notify(message, vim.log.levels[level], { title = '[' .. level .. '] ' .. origin })
   end
end

---Dump logfile to floating window
---@param lines string[]|nil possible lines to print
function Logger:dump(lines)
   local popup_ok, Popup = pcall(require, 'nui.popup')

   if not popup_ok then
      self:error('core.logger', 'Failed to load plugin `nui`')
      return
   end

   local component
   lines = lines or vim.split(ufs.read_file(self._logfile) or '', '\n', {})

   component = Popup({
      enter = true,
      focusable = true,
      border = { style = 'rounded' },
      relative = 'editor',
      position = '50%',
      size = { width = '60%', height = '60%' },
      modifiable = true,
      buf_options = {
         readonly = false,
         filetype = 'log',
         buftype = 'nofile',
         bufhidden = 'wipe',
      },
   })

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

      vim.api.nvim_buf_set_lines(component.bufnr, 0, 1, false, lines)
      vim.api.nvim_set_option_value('modifiable', false, { buf = component.bufnr })
      vim.cmd('set number')
      vim.cmd(component.bufnr .. 'b +$')
   end)
end

---Clear the log file
---@arg force? boolean force clear the log file without prompt
function Logger:clear(force)
   if force then
      ufs.write_file(self._logfile, '', 'w')
      return
   end

   vim.ui.select(vim.tbl_keys({ NO = 'NO', YES = 'YES' }), {
      prompt = 'Confirm to clear log file?',
      format_item = function(item)
         return item
      end,
   }, function(choice)
      if not choice then
         return
      end
      if choice == 'YES' then
         ufs.write_file(self._logfile, '', 'w')
      end
   end)
end

local logger_ = Logger:init()
return logger_
