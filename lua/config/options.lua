local ufn = require('utils.fn')


-------------
-- General --
-------------
vim.opt.laststatus = 3               -- always show status line and only on the last window
vim.opt.fileformats = 'unix,mac,dos' -- use unix EOL format
vim.opt.title = true
vim.opt.showmode = false             -- don't show the current mode
vim.opt.clipboard = 'unnamed'        -- allow neovim to access system clipboard
vim.opt.cursorline = true            -- highlight the current line
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.virtualedit = 'block'
vim.opt.encoding = 'utf-8'
vim.opt.viewoptions = 'folds,cursor,curdir,slash,unix'
vim.opt.wildignore =
'.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**'
vim.opt.runtimepath:append(PATH.data .. '/ts-parsers')
vim.opt.spell = true
vim.opt.spelllang = { 'en_gb' }


------------------
-- Line Numbers --
------------------
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.ruler = true
-- vim.opt.statuscolumn = '%{%v:lua.require("modules.ui.statuscolumn").build_stc()%}'


-----------------
-- Indentation --
-----------------
vim.opt.autoindent = true
vim.opt.expandtab = true   -- convert tabs to spaces
vim.opt.shiftwidth = 3     -- number of spaces inserted for indentation
vim.opt.tabstop = 3        -- number of spaces '\t' is worth
vim.opt.softtabstop = 3    -- number of spaces tab/backspace key press is worth
vim.opt.showtabline = 0    -- always show tabline
vim.opt.smartindent = true -- indent next line based on code style/synctax and indet on current line
vim.opt.smarttab = true
vim.opt.shiftround = true


----------------------
-- Sessions/History --
----------------------
vim.opt.sessionoptions = 'curdir,help,tabpages,winsize'
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.directory = PATH.cache .. '/swap/'
vim.opt.undodir = PATH.cache .. '/undo/'
vim.opt.backupdir = PATH.cache .. '/backup/'
vim.opt.viewdir = PATH.cache .. '/view/'
vim.opt.spellfile = PATH.cache .. '/spell/en.uft-8.add'
vim.opt.history = 2000
vim.opt.shada = "!,'300,<50,@100,s10,h"
vim.opt.backupskip = '/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim'


------------
-- Timing --
------------
vim.opt.timeoutlen = 500  -- time to wait for a mapped sequence to complete.
vim.opt.ttimeoutlen = 10  -- time to wait for key code sequence to complete
vim.opt.updatetime = 250  -- write to swap file if nothing is typed. Aslo time for CursorHold
vim.opt.redrawtime = 1500 -- time to redraw the display


----------------
-- Completion --
----------------
vim.opt.complete = '.,w,b,u,k'
vim.opt.completeopt = { 'menuone', 'noselect' } -- mostly just for cmp


------------
-- Search --
------------
vim.opt.ignorecase = true                                     -- ignore case when searching
if ufn.executable('rg') then
   vim.opt.grepprg = 'rg --vimgrep --no-heading --smart-case' -- command to when running search
   vim.opt.grepformat = '%f:%l:%c:%m'                         -- scanf-like string used format ':grep' command output
end


---------------
-- Behaviors --
---------------
vim.opt.breakat = [[\ \	;:,!?/.+-]]       -- characters that might cause a linebreak if linebreak is on
vim.opt.whichwrap:append('h,l,<,>,[,],~') -- allow keys to move cursor left/right to move to previous line
vim.opt.scroll = 19                       -- number lines scrolled when using <C-u> or <C-d>
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.switchbuf = 'useopen'
vim.opt.diffopt = 'filler,iwhite,internal,algorithm:patience'
vim.opt.jumpoptions = 'stack'
vim.opt.shortmess:append('Ic')
vim.opt.iskeyword:append('-')
vim.opt.smartcase = true
vim.opt.formatoptions = '1jcroql'
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.foldcolumn = '1'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "indent"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- handled by nvim-ufo
vim.opt.foldenable = true
vim.opt.equalalways = false
vim.opt.display = 'lastline'


----------------
-- Appearance --
----------------
if HOST.is_win then
   vim.opt.guifont = { 'JetBrainsMono Nerd Font', ':h9' }
elseif HOST.is_mac then
   vim.opt.guifont = { 'JetBrainsMono Nerd Font', ':h12' }
else
   vim.opt.guifont = { 'JetBrainsMono Nerd Font', ':h9' }
end
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.winwidth = 30
vim.opt.winminwidth = 10
vim.opt.pumheight = 10
vim.opt.helpheight = 20
vim.opt.previewheight = 12
vim.opt.showcmd = false
vim.opt.signcolumn = 'yes' -- always show the sign column, otherwise it would shift the text each time
vim.opt.conceallevel = 0   -- so that `` is visible in mardkown files
vim.opt.fillchars = {
   eob = ' ',
   fold = ' ',
   foldopen = '',
   foldclose = '',
   foldsep = ' ', -- or '│' to use bar for show fold area
}
vim.opt.guicursor =
    'n-v-c:block-blinkwait175-blinkon175-blinkoff175,' ..
    'i-ci-ve:ver25-blinkwait175-blinkon175-blinkoff175,' ..
    'r-cr-o:hor20-Cursor,' .. 'sm:block-blinkwait175-blinkon175-blinkoff175'
vim.opt.cmdwinheight = 5
-- vim.opt.showbreak = '↳ '
vim.opt.listchars = 'tab:»·,nbsp:+,trail:·,extends:→,precedes:←'
vim.opt.pumblend = 10
vim.opt.winblend = 10


-----------
-- Shell --
-----------
if HOST.is_win then
   -- ref: https://github.com/akinsho/toggleterm.nvim/wiki/Tips-and-Tricks#windows
   local powershell_options = {
      shell = ufn.executable('pwsh') and 'pwsh' or 'powershell',
      shellcmdflag =
      '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
      shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait',
      shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode',
      shellquote = '',
      shellxquote = '',
   }

   for option, value in pairs(powershell_options) do
      vim.opt[option] = value
   end
elseif HOST.is_mac or HOST.is_linux then
   vim.opt.shell = 'fish'
end


----------------
-- File Types --
----------------
vim.filetype.add({
   filename = {
      ['.swcrc'] = 'json',
      ['.luacheckrc'] = 'text',
   }
})
