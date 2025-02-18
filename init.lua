-- load core
require('core.lua_globals')
require('core.logger'):start()
require('core.bootstrap'):start()
require('core.cache'):start()
require('core.lazy'):start()

-- load config
require('config.globals')
require('config.options')
require('config.autocmds')
require('config.cmds')
require('config.keymaps')

require('modules.ui.colorscheme').setup('catppuccin')
