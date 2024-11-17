local M = {}

M.opts = {
   tools = {
      inlay_hints = {
         auto = true,
         only_current_line = false,
         show_parameter_hints = true,
         parameter_hints_prefix = '<- ',
         other_hints_prefix = '=> ',
         max_len_align = false, -- whether to align to the lenght of the longest line in the file
         max_len_align_padding = 1, -- padding from the left if max_len_align is true
         right_align = false,
         right_align_padding = 7,
         highlight = 'Comment',
      },
      hover_actions = {
         auto_focus = false,
         border = {
            { '╭', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '╮', 'FloatBorder' },
            { '│', 'FloatBorder' },
            { '╯', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '╰', 'FloatBorder' },
            { '│', 'FloatBorder' },
         },
      },
   },
   dap = {
      adapter = {
         type = 'executable',
         command = 'lldb-vscode',
         name = 'rt_lldb',
      },
   },
}

M.config = function(_, opts)
   opts.tools.executor = require('rust-tools.executors').toggleterm
   opts.tools.on_initialized = function()
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'CursorHold', 'InsertLeave' }, {
         pattern = { '*.rs' },
         callback = function()
            vim.lsp.codelens.refresh()
         end,
      })
   end
   opts.server = {
      cmd = { 'rust-analyzer' },
      on_attach = require('modules.cmp_lsp.lsp.setup').on_attach,
      capabilities = require('modules.cmp_lsp.lsp.setup').capabilities,
      standalone = false,
      settings = {
         ['rust-analyzer'] = {
            lens = { enable = true },
            procMacro = { enable = true },
            diagnostics = { disabled = { 'unresolved-proc-macro' } },
            checkOnSave = { command = 'clippy' },
            -- diagnostics = { enable = false },
            -- checkOnSave = { enable = false },
         },
      },
   }

   -- log:debug('rust-tools config: ', opts)
   require('rust-tools').setup(opts)
end

return M
