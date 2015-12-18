" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"if has("autocmd")
"  filetype plugin indent on
"endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)
set mouse=

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

"My 
set autoindent
set encoding=utf8
set shiftwidth=4
set tabstop=4
set smartindent
set nocompatible
set encoding=utf8

"set list
set complete=.,k            " Autocomplete search in current  only AND dictionary( Ctrl+N ) in current file
set ic                      " Ignore case when search
function! Tab_Or_Complete() " Autocomplete works with TAB when inserting a word
  if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
    return "\<C-N>"
  else
    return "\<Tab>"
  endif
endfunction

:inoremap <Tab> <C-R>=Tab_Or_Complete()<CR>
"set dict=/usr/share/dict/words
silent !file %

retab
set tabstop=4 shiftwidth=4 expandtab


set t_ti= t_te=
set autoindent
set encoding=utf8
set shiftwidth=4
set tabstop=4
set smartindent
set nocompatible
set encoding=utf8
set bg=light
set ruler
"set t_ti= t_te= "dont clear screen after q
"set list
set complete=.,k            " Autocomplete search in current  only AND dictionary( Ctrl+N ) in current file
"set confirm
set ic                      " Ignore case when search
"set backupdir=/home/user/tmp/backup_vim/
"set dir=/home/user/tmp/
"set clipboard=unnamed
"set runtimepath+=/home/user/conf/vim_plugins
set laststatus=2
set autochdir
set hlsearch
let g:yankring_enabled = 1
let g:yankring_share_between_instances = 1

highlight Error ctermbg=darkred guibg=black

autocmd FileType python,sh,bash,zsh,ruby,perl,muttrc let StartComment="#" | let EndComment=""
autocmd FileType php,cpp,javascript let StartComment="//" | let EndComment=""
command! -range=% CAtoUTF8 <line1>,<line2>call Ca_to_Utf8() " When someone wont use utf8
command! CPtoUTF8 call Cp_to_Utf8()


au BufEnter     *.pl,*.pm call PerlOpenFix()
au BufEnter     *.pl6,*.p6 setf perl6
au BufEnter     *.kv setf yaml
au BufEnter     *.kv :colorscheme elflord

"au BufEnter     *.pl,*.pm command! -range=% CPtoUTF8 <line1>,<line2>call Cp_to_Utf8()
au BufEnter     *.php*    command! Check !php -l %
au BufEnter     *.pl,*.pcgi compiler perl
au BufEnter     *.pl,*.pcgi let g:perl_compiler_force_warnings = 0

"au BufWritePost *.pl,*.pm !perl -I`cat /root/demayl/libs` -c %
"au VimLeave     *.pl,*.pm !perl -I`cat /root/demayl/libs` -c %
"au CursorHold  *.pl !perl -I`cat /root/demayl/libs` -c % && echo "Kafeee"
"au BufEnter    *.pl silent! %s/    /\t/g " convert space to TAB for indent

"Remove backup file on exit
"au VimLeave     *.pl,*.pm silent! execute "!rm /root/demayl/tmp/backup_vim/" . expand('%:t') . '~ 2>/dev/null'

" To write compressed text
augroup gzip
    autocmd!
    autocmd BufReadPre,FileReadPre     *.gz set bin
    autocmd BufReadPost,FileReadPost   *.gz '[,']!gunzip
    autocmd BufReadPost,FileReadPost   *.gz set nobin
    autocmd BufReadPost,FileReadPost   *.gz execute ":doautocmd BufReadPost " . expand("%:r")

    autocmd BufWritePost,FileWritePost *.gz !mv <afile> <afile>:r
    autocmd BufWritePost,FileWritePost *.gz !gzip <afile>:r

    autocmd FileAppendPre              *.gz !gunzip <afile>
    autocmd FileAppendPre              *.gz !mv <afile>:r <afile>
    autocmd FileAppendPost             *.gz !mv <afile> <afile>:r
    autocmd FileAppendPost             *.gz !gzip <afile>:r
augroup END

function! CommentLines()
    try
        execute ":s@^".g:StartComment." @\@g"
        execute ":s@ ".g:EndComment."$@@g"
    catch
        execute ":s@^@".g:StartComment." @g"
        execute ":s@$@ ".g:EndComment."@g"
    endtry
endfunction

" Mark visual block & press c + o to comment/uncomment lines
vmap co :call CommentLines()<CR>
au BufRead,BufNewFile *.sh,*.pl,*.tcl,*.p6,*.pl6,*.pm let StartComment="#" | let EndComment=""
au BufRead vimrc,.vimrc let StartComment="\"" | let EndComment=""


function! PerlOpenFix()

    set backup

    if filereadable( '/root/demayl/conf/perl_functions.txt' )
        set dict=/root/demayl/conf/perl_functions.txt
    endif

    " Load custom perl configuration
    if filereadable( '/root/demayl/conf/perl.vim' )
        setf perl2
        so /root/demayl/conf/perl.vim
    endif
    if filereadable( '/root/demayl/libs' )
        command! Check !perl -I`cat /root/demayl/libs` -c %
    endif
    command! FixTabs %s/    /\t/g
    call matchadd("Error","FUCK")
    match Error "return undef"
    match Error "\(sub\s\+\w\+\s*\)\@<=(.\+)\(\s*{\)\@="


endfunction

function! Cp_to_Utf8()
  let file = expand("%")
  if input("That will overwrite current file ? [Yn] \n", "y" ) == "y"
    exe "!iconv -f cp1251 -t utf8 -o " . file . " " . file
    e
  endif
endfunction

function! Ca_to_Utf8()
  let current_line  = line("v")
  let l:line_data   = getline( current_line )
"  if strlen( matchstr( line_data, '[\x7f-\xff]' ) )
  if strlen( matchstr( line_data, '[\xc0-\xdf\xe0-\xff]' ) ) " range only for cyrillic alpha
      let l:output  = iconv( iconv( line_data, 'utf8','latin1'), 'cp1251','utf8')
      silent! call setline( current_line, output );
      echo "Replace line " . current_line
  else
"     echo "Skip"
  endif
endfunction

