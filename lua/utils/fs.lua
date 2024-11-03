local M = {}
local fn, uv = vim.fn, (vim.version().minor >= 10 and vim.uv or vim.loop)

--- File mode constants for `libuv`'s unix fs operations
M.FILE_MODES = {
   o777 = tonumber('100777', 8), -- -rwxrwxrwx
   o755 = tonumber('100755', 8), -- -rwxr-xr-x
   o700 = tonumber('100700', 8), -- -rwx------
   o644 = tonumber('100644', 8), -- -rw-r--r--
   o600 = tonumber('100600', 8), -- -rw-------
}
M.FILE_MODES.default = M.FILE_MODES.o644 -- -rw-r--r--

--- Directory mode constants for `libuv`'s unix fs operations
M.DIR_MODES = {
   o777 = tonumber('40777', 8), -- drwxrwxrwx
   o755 = tonumber('40755', 8), -- drwxr-xr-x
   o700 = tonumber('40700', 8), -- drwx------
   o644 = tonumber('40644', 8), -- drw-r--r--
   o600 = tonumber('40600', 8), -- drw-------
}
M.DIR_MODES.default = M.DIR_MODES.o755 -- drwxr-xr-x

---The file system path separator for the current platform.
M.path_separator = '/'
if HOST.is_win then
   M.path_separator = '\\'
end

---check if path points to a directory
---@param path string
---@return boolean
M.is_dir = function(path)
   -- return fn.isdirectory(path) == 1
   local stat = uv.fs_stat(path)
   return stat and stat.type == 'directory' or false
end

---check path points to a file
---@param path string
---@return boolean
M.is_file = function(path)
   -- return fn.filereadable(path) == 1
   local stat = uv.fs_stat(path)
   return stat and stat.type == 'file' or false
end

---check if file/directory is a symlink
---@param path string
---@return boolean
M.is_link = function(path)
   return fn.isdirectory(path) == 2
end

---make a new directory
---@param path string new directory path
---@param mode number|nil directory permission (default 16877, equivalent of 755/drwxr-xr-x)
M.mkdir = function(path, mode)
   mode = mode or M.DIR_MODES.default
   uv.fs_mkdir(path, mode)
end

---make a new directory and all its parents
---@param path string new directory path
---@param mode number|nil directory permission (default 16877, equivalent of 755/drwxr-xr-x)
M.mkdirp = function(path, mode)
   mode = mode or M.DIR_MODES.default

   local parts = M.split(path, M.path_separator)
   local paths = {}

   for i, part in ipairs(parts) do
      paths[i] = M.path_join((paths[i - 1] or ''), part)
   end

   for _, p in ipairs(paths) do
      if M.is_dir(p) then
         goto continue
      end
      assert(not M.is_file(p), 'Cannot create directory: ' .. p .. ' is a file')
      M.mkdir(p, mode)
      ::continue::
   end
end

---list all files in a directory recursively
---@param path string source path
---@param paths string[]|nil list of paths
---@return string[]|nil list of paths
M.scandir = function(path, paths)
   local stat = uv.fs_stat(path)
   paths = paths or {}

   if not stat then
      return nil
   end

   if stat.type == 'file' then
      paths[#paths + 1] = path
   elseif stat.type == 'directory' then
      local handle = assert(uv.fs_scandir(path))

      while true do
         local name = uv.fs_scandir_next(handle)
         if not name then
            break
         end
         local new_path = M.path_join(path, name)
         M.scandir(new_path, paths)
      end
   end
   return paths
end

---Write data to a file
---@param path string can be full or relative to `cwd`
---@param txt string|table text to be written, uses `vim.inspect` internally for tables
---@param flag string used to determine access mode, common flags: "w" for `overwrite` or "a" for `append`
---@param mode? number directory permission (default 33188, equivalent of 644/-rw-r--r--)
---@param offset? number specific number of bytes from the beginning of the file where the data should be written, defaults is `-1` which appends to current file offset
function M.write_file(path, txt, flag, mode, offset)
   mode = mode or M.FILE_MODES.default
   offset = offset == nil and -1 or offset

   local data = type(txt) == 'string' and txt or vim.inspect(txt)

   uv.fs_open(path, flag, mode, function(open_err, fd)
      assert(not open_err, open_err)
      uv.fs_write(fd, data, offset, function(write_err)
         assert(not write_err, write_err)
         uv.fs_close(fd, function(close_err)
            assert(not close_err, close_err)
         end)
      end)
   end)
end

---Write data to a file
---@param path string can be full or relative to `cwd`
---@param mode? number directory permission (default 33188, equivalent of 644/-rw-r--r--)
---@param offset number? specific number of bytes from the beginning of the file where the data should be read, default is `0` which will not change current file offset
---@return string|nil
M.read_file = function(path, mode, offset)
   mode = mode or M.FILE_MODES.default
   offset = offset == nil and 0 or offset

   local fd = assert(uv.fs_open(path, 'r', mode))
   local stat = assert(uv.fs_fstat(fd))
   local data = assert(uv.fs_read(fd, stat.size, offset))
   assert(uv.fs_close(fd))

   if type(data) == 'string' then
      return data
   else
      return nil
   end
end

---Delete a file
---@param path string file path
M.unlink_file = function(path)
   uv.fs_unlink(path, function(err)
      assert(not err, err)
   end)
end

---Copy a file or directory
---@param src string source path
---@param dest string destination path
M.copy = function(src, dest)
   local src_stat = assert(uv.fs_stat(src))
   local src_parts = M.split(src, M.path_separator)

   local dest_stat = uv.fs_stat(dest)

   if src_stat.type == 'file' then
      if dest_stat and dest_stat.type == 'directory' then
         dest = M.path_join(dest, src_parts[#src_parts])
      end
      uv.fs_copyfile(src, dest, function(err)
         assert(not err, err)
      end)
      return
   elseif src_stat.type == 'directory' then
      if dest_stat then
         assert(dest_stat.type ~= 'file', 'Destination is a file')
      else
         M.mkdir(dest, src_stat.mode)
      end

      local handle = assert(uv.fs_scandir(src))

      while true do
         local name = uv.fs_scandir_next(handle)
         if not name then
            break
         end
         local new_src = M.path_join(src, name)
         local new_dest = M.path_join(dest, name)
         M.copy(new_src, new_dest)
      end
   end
end

---Split string into a table of strings using a separator.
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.split = function(inputString, sep)
   local fields = {}

   local pattern = string.format('([^%s]+)', sep)
   local _ = string.gsub(inputString, pattern, function(c)
      fields[#fields + 1] = c
   end)

   return fields
end

---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
M.path_join = function(...)
   local args = { ... }
   if #args == 0 then
      return ''
   end

   local all_parts = {}
   if type(args[1]) == 'string' and args[1]:sub(1, 1) == M.path_separator then
      all_parts[1] = ''
   end

   for _, arg in ipairs(args) do
      if arg == '' and #all_parts == 0 and not HOST.is_win then
         all_parts = { '' }
      else
         local arg_parts = M.split(arg, M.path_separator)
         vim.list_extend(all_parts, arg_parts, 1, #arg_parts)
      end
   end
   return table.concat(all_parts, M.path_separator)
end

return M
