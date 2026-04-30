set nocompatible          " Use VIM settings rather than Vi settings; this *must* be first in .vimrc "

"_________________________________________________________________________"
" GENERAL SETTINGS "
""
syntax on				" Enable syntax highlighting "
set hlsearch			" Highlight all search results "
set showmatch			" Highlight matching parentheses "
set autoindent			" Copy indent from the current line when starting a new line "
set smartindent
set backspace=2			" Allow backspacing over everything in insert mode "
set history=100			" Keep 100 lines of command line history "
set incsearch			" While typing a search command, show matches incrementally instead of waiting for you to press enter "
"set number				" Line numbers at the side "
set shiftwidth=4		" Pressing >> or << in normal mode indents by 4 characters "
set tabstop=4			" A tab character indents to the 4th (or 8th, 12th, etc.) column "
set encoding=utf8		" Non-ascii characters are encoded with UTF-8 by default "
set noexpandtab			" Pressing the tab key creates a tab character, not spaces "
set textwidth=0			" No forced wrapping in any file type (unless overridden) "
set showcmd				" Show length of visual selection (docs recommended keeping this off when working over slow connections) "
"set completeopt=menuone,noinsert	" Make autocomplete faster ""
set splitright			" Create vertical splits to the right "
set splitbelow			" Create horizontal splits below "
"set nowrap
set noshowmode
" Apply theme settings only for script files (Perl, shell, Tcl, etc.) "
"augroup script_specific_theme
"    autocmd!
"    autocmd FileType perl,sh,bash,tcl,python colorscheme desert     " Set your theme here "
"augroup END

"_________________________________________________________________________"
" Status Bar "
""
set statusline=      				" Clear status line when vimrc is reloaded "
set statusline+=\ %t\ %M\ %Y\ %R 	" Status line left side "
set statusline+=%=					" Use a divider to separate the left side from the right side "
set statusline+=\ %l\ :\ %L\ col:\ %c\ %p%%	" Status line right side "
set laststatus=2					" Show the status on the second to last line "

call plug#begin('~/.vim/plugged')

Plug 'bluz71/vim-nightfly-colors'
Plug 'itchyny/lightline.vim'
Plug 'sainnhe/sonokai'

call plug#end()
""let g:airline_theme = 'material'
""colorscheme material
