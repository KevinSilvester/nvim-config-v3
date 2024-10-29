local m = require('core.mapper')

local M = {}

---Setup LSP keymaps
---@private
---@param bufnr number The buffer number
M.set_lsp_keymaps = function(bufnr)
   -- stylua: ignore
   m.buf_nmap(bufnr, {
      -- {
      --    "K",
      --    function()
      --       local winid = require('ufo').peekFoldedLinesUnderCursor()
      --       if not winid then
      --          vim.lsp.buf.hover()
      --       end
      --    end,
      --    m.opts(m.noremap, m.silent, '[ufo/builtin] Hover doc')
      -- },
      -- { "D",  function() vim.lsp.buf.type_definition() end, m.opts(m.noremap, m.silent, '[builtin] Type Definition') },
      { "gD", function() vim.lsp.buf.declaration() end,  m.opts(m.noremap, m.silent, '[builtin] Goto Declarations') },
      { "gd", function() vim.lsp.buf.definition() end,   m.opts(m.noremap, m.silent, '[builtin] Goto Definitions') },
      { "gq", function() vim.diagnostic.setqflist() end, m.opts(m.noremap, m.silent, '[builtin] Show QuickFix') },
      { "[d", m.cmd("Lspsaga diagnostic_jump_prev"),     m.opts(m.noremap, m.silent, '[lspsaga] Goto Prev Diagnostics') },
      { "]d", m.cmd("Lspsaga diagnostic_jump_next"),     m.opts(m.noremap, m.silent, '[lspsaga] Goto Next Diagnostics') },
      {
         "[e",
         function() require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
         m.opts(m.noremap, m.silent, '[lspsaga] Goto Prev Error')
      },
      {
         "]e",
         function() require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
         m.opts(m.noremap, m.silent, '[lspsaga] Goto Next Error')
      }
   })
end

local capabilities_extension = {
   textDocument = {
      foldingRange = {
         dynamicRegistration = false,
         lineFoldingOnly = true,
      },
   },
}

---Enable completions from lsp
M.capabilities = vim.tbl_deep_extend(
   'force',
   vim.lsp.protocol.make_client_capabilities(),
   require('cmp_nvim_lsp').default_capabilities(),
   require('lsp-file-operations').default_capabilities(),
   capabilities_extension
)

---After attaching to a buffer, set keymaps, attach nvim-navic and vim-illuminate
---@param client table
---@param bufnr number
M.on_attach = function(client, bufnr)
   M.set_lsp_keymaps(bufnr)
   require('lsp-inlayhints').on_attach(client, bufnr, false)
   if client.server_capabilities['documentSymbolProvider'] then
      require('nvim-navic').attach(client, bufnr)
   end
   vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })

   local format_disable = {
      'lua_ls',
      'rust_analyzer',
      'marksman',
      'ts_ls',
      'jsonls',
      'cssls',
      'html',
   }

   for _, server in pairs(format_disable) do
      if client.name == server then
         client.server_capabilities.document_formatting = false
      end
   end
end

return M
