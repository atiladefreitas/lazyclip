if exists('g:loaded_lazyclip') || &cp
  finish
endif
let g:loaded_lazyclip = 1

command! LazyClip lua require('lazyclip.ui').open_window()

if !exists('g:lazyclip_disable_default_keymap')
  nnoremap <silent> <leader>Cw :LazyClip<CR>
endif
