local M = {}

M.config = function()
   local null_ls = require('null-ls')

   local h = require('null-ls.helpers')
   local methods = require('null-ls.methods')

   local DIAGNOSTICS = methods.internal.DIAGNOSTICS
   local FORMATTING = methods.internal.FORMATTING

   -- ref: https://github.com/nvimtools/none-ls.nvim/blob/b4bd764cd1705086de4bd89f7ccf9d9ed0401259/lua/null-ls/builtins/diagnostics/luacheck.lua
   local luacheck = h.make_builtin({
      name = 'luacheck',
      meta = {
         url = 'https://github.com/lunarmodules/luacheck',
         description = 'A tool for linting and static analysis of Lua code.',
      },
      method = DIAGNOSTICS,
      filetypes = { 'lua' },
      generator_opts = {
         command = 'luacheck',
         to_stdin = true,
         from_stderr = true,
         args = {
            '--formatter',
            'plain',
            '--codes',
            '--ranges',
            '--filename',
            '$FILENAME',
            '-',
         },
         format = 'line',
         on_output = h.diagnostics.from_pattern(
            [[:(%d+):(%d+)-(%d+): %((%a)(%d+)%) (.*)]],
            { 'row', 'col', 'end_col', 'severity', 'code', 'message' },
            {
               severities = {
                  E = h.diagnostics.severities['error'],
                  W = h.diagnostics.severities['warning'],
               },
               offsets = { end_col = 1 },
            }
         ),
      },
      factory = h.generator_factory,
   })

   -- ref: https://github.com/nvimtools/none-ls.nvim/blob/b4bd764cd1705086de4bd89f7ccf9d9ed0401259/lua/null-ls/builtins/formatting/rustfmt.lua
   local rustfmt = h.make_builtin({
      name = 'rustfmt',
      meta = {
         url = 'https://github.com/rust-lang/rustfmt',
         description = 'A tool for formatting rust code according to style guidelines.',
         notes = {
            '`--edition` defaults to `2015`. To set a different edition, use `extra_args`.',
            'See [the wiki](https://github.com/nvimtools/none-ls.nvim/wiki/Source-specific-Configuration#rustfmt) for other workarounds.',
         },
      },
      method = FORMATTING,
      filetypes = { 'rust' },
      generator_opts = {
         command = 'rustfmt',
         args = { '--emit=stdout' },
         to_stdin = true,
      },
      factory = h.formatter_factory,
   })

   null_ls.setup({
      debug = false,
      sources = {
         -- null_ls.builtins.formatting.prettier,
         null_ls.builtins.formatting.biome,
         null_ls.builtins.formatting.shfmt,
         -- null_ls.builtins.formatting.black.with({ extra_args = { '--fast' } }),
         -- null_ls.builtins.formatting.autopep8,
         -- null_ls.builtins.formatting.yapf,
         null_ls.builtins.formatting.stylua,
         -- null_ls.builtins.diagnostics.selene,
         -- null_ls.builtins.formatting.google_java_format,
         -- null_ls.builtins.formatting.blade_formatter,
         null_ls.builtins.formatting.sql_formatter,
         null_ls.builtins.formatting.csharpier,
         -- null_ls.builtins.formatting.clang_format,
         -- null_ls.builtins.formatting.cmake_format,
         -- null_ls.builtins.formatting.rustfmt, -- deprecated
         -- null_ls.builtins.formatting.taplo, -- deprecated
         -- null_ls.builtins.diagnostics.flake8,
         luacheck,
         rustfmt,
         -- require('typescript.extensions.null-ls.code-actions'),
      },
   })
end

return M
