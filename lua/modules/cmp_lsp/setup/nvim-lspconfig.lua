local cmd = require('core.mapper').cmd
local icons = require('modules.ui.icons').diagnostics
local M = {}

M.init = function()
   -- vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
   --    config = config or {}
   --    config.focus_id = ctx.method
   --    config.border = 'rounded'
   --    if not (result and result.contents) then
   --       return
   --    end
   --    log:info('lspconfig', result.content)
   --    local markdown_lines = function(contents)
   --       local s = vim.lsp.util.convert_input_to_markdown_lines(contents, {})
   --       return vim.lsp.util.trim_empty_lines(s)
   --    end
   --    return vim.lsp.util.open_floating_preview(markdown_lines(result.contents), 'markdown', config)
   -- end

   vim.lsp.handlers['textDocument/signatureHelp'] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

   -- --  setup diagnostics signs
   local custom_diagnostics_signs = {
      { name = 'DiagnosticSignError', text = icons.Error },
      { name = 'DiagnosticSignWarn', text = icons.Warning },
      { name = 'DiagnosticSignHint', text = icons.Hint },
      { name = 'DiagnosticSignInfo', text = icons.Info },
   }
   for _, sign in ipairs(custom_diagnostics_signs) do
      vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
   end

   vim.diagnostic.config({
      virtual_text = true, -- show virtual text
      signs = { active = custom_diagnostics_signs }, -- show signs
      update_in_insert = true,
      underline = true,
      severity_sort = true,
      float = {
         focusable = true,
         style = 'minimal',
         border = 'rounded',
         source = true,
         header = ' ' .. vim.fn.expand('%:t'),
         prefix = function(_diagnostic, idx, total)
            -- log:debug('diagnostics', _diagnostic)
            if idx < total then
               return '┣━━', 'Comment'
            end
            return '┗━━', 'Comment'
         end,
      },
   })
end

M.config = function()
   local opts = require('modules.cmp_lsp.lsp.servers')
   local lspconfig = require('lspconfig')
   local mason_lsp = require('mason-lspconfig')

   for _, server in ipairs(mason_lsp.get_installed_servers()) do
      -- using rust-tools.nvim and typescrip.nvim for better lsp config
      if server == 'rust_analyzer' or server == 'ts_ls' then
         goto continue
      end

      if opts.custom[server] ~= nil then
         lspconfig[server].setup(opts.custom[server])
      else
         lspconfig[server].setup(opts.default)
      end

      ::continue::
   end
end

-- stylua: ignore
M.keys = {
   { '<leader>lc', require('utils.lsp').server_capabilities,                               desc = '[utils] Get Capabilities' },
   { '<leader>ld', vim.diagnostic.open_float,                                              desc = '[builtin] Line Diagnostics' },
   { '<leader>lf', function() vim.lsp.buf.format({ async = true, timeout_ms = 1000 }) end, desc = '[builtin] Format File',     mode = { 'n' } },
   {
      '<leader>lf',
      function()
         vim.lsp.buf.format({
            async = true,
            timeout_ms = 1000,
            range = {
               ['start'] = vim.api.nvim_buf_get_mark(0, '<'),
               ['end'] = vim.api.nvim_buf_get_mark(0, '>')
            }
         })
      end,
      desc = '[builtin] Format File',
      mode = { 'v' }
   },
   { '<leader>li',  cmd('LspInfo'),       desc = '[lspconfig] LSP Info' },
   { '<leader>lr',  vim.lsp.buf.rename,   desc = '[builtin] Rename' },
   { '<leader>lar', vim.lsp.codelens.run, desc = '[builtin] Run CodeLens Action' },
}

return M
