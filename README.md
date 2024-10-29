### Dependencies

**Common**

-  rust toolchain (cargo, rustc, ...)
-  git
-  nodejs
-  ripgrep
-  sed
-  fd
-  ls_emmet
-  go
-  tree-sitter-cli (preferably not as npm package)
-  jq

**Unix**

-  curl/wget
-  unzip
-  tar
-  gzip

**Windows**

-  pwsh
-  tar
-  7zip/peazip/archiver/winzip/WinRaR

### FIX:

-  [x] Tab key not working as intended
-  [x] `tabstop`, `softtabstop`, `shiftwidth` not being set properly
-  [x] MardownPreview not working in MacOS

### TODO:

-  [x] Implement global `buf_cache`
-  [ ] Create wrapper for `nvim-treesitter` commands to interop with `ts-parsers`
-  [ ] ~~Create wrapper for `lazy.nvim` commands~~
-  [x] Bootstrap
   -  [x] Add function to create git-hooks
   -  [x] Add function to download pre-compiled treesitter parsers
-  [x] LSP
   -  [x] Show line diagnostics key-mapping
   -  [x] Group line diagnostics virtual text
   -  [x] Migrate from `typescript.nvim` and `tsserver` to `ts_ls` 
   -  [x] Fix navic not attaching with `cssls`
-  [ ] Configure
   -  [ ] nvim-dap
-  [ ] Add
   -  [ ] nvim-dap-ui
   -  [ ] nvim-dap-virtual-text
   -  [ ] neotest
   -  [x] yanky.nvim
   -  [x] git-worktree.nvim
   -  [ ] nvim-regexplainer
   -  [x] dial.nvim
   -  [ ] ~~gitlinker.nvim~~
   -  [ ] overseer.nvim
   -  [ ] neogen
   -  [ ] ssr.nvim
   -  [ ] trailblazer.nvim?
   -  [x] harpoon
   -  [ ] vim-be-good
   -  [ ] surround.vim
   -  [ ] refactoring.nvim
   -  [x] nvim-ufo
   -  [x] zen-mode.nvim
   -  [x] codesnap.nvim
   -  [ ] nvim-html-css
   -  [ ] johmsalas/text-case.nvim

### Preview Config

Preview config using Docker

```sh
# start/build the container
docker compose up -d custom

# launch in to shell within container
docker compose exec custom bash
```
