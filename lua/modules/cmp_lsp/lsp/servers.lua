local M = {}

M.default = {
   capabilities = require('modules.cmp_lsp.lsp.setup').capabilities,
   on_attach = require('modules.cmp_lsp.lsp.setup').on_attach,
}

M.custom = {
   cssls = {
      capabilities = M.default.capabilities,
      on_attach = require('modules.cmp_lsp.lsp.servers.cssls').on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.cssls').settings,
   },
   emmet_ls = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      -- cmd = require('modules.cmp_lsp.lsp.servers.emmet_ls').cmd,
      init_options = require('modules.cmp_lsp.lsp.servers.emmet_ls').init_options,
      filetypes = require('modules.cmp_lsp.lsp.servers.emmet_ls').filetypes,
   },
   eslint = {
      capabilities = M.default.capabilities,
      on_attach = require('modules.cmp_lsp.lsp.servers.eslint').on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.eslint').settings,
   },
   jsonls = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.jsonls').settings,
      setup = require('modules.cmp_lsp.lsp.servers.jsonls').setup,
   },
   powershell_es = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      cmd = require('modules.cmp_lsp.lsp.servers.powershell_es').cmd,
      bundle_path = require('modules.cmp_lsp.lsp.servers.powershell_es').bundle_path,
   },
   pyright = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.pyright').settings,
   },
   lua_ls = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.lua_ls').settings,
   },
   omnisharp = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      handlers = require('modules.cmp_lsp.lsp.servers.omnisharp').handlers,
   },
   tailwindcss = {
      capabilities = require('modules.cmp_lsp.lsp.servers.tailwindcss').capabilities,
      init_options = require('modules.cmp_lsp.lsp.servers.tailwindcss').init_options,
      on_attach = require('modules.cmp_lsp.lsp.servers.tailwindcss').on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.tailwindcss').settings,
   },
   vuels = {
      filetypes = require('modules.cmp_lsp.lsp.servers.vuels').filetypes,
      on_attach = M.default.on_attach,
      init_options = require('modules.cmp_lsp.lsp.servers.vuels').init_options,
   },
   yamlls = {
      capabilities = M.default.capabilities,
      on_attach = M.default.on_attach,
      settings = require('modules.cmp_lsp.lsp.servers.yamlls').settings,
   },
}

return M
