" ============================================================================
" Description: Plugin for NERD Tree that highlights open files
" Inspiration: https://github.com/Xuyuanp/nerdtree-git-plugin
" ============================================================================
" Stop processing if already loaded.
if exists('s:loaded')
    finish
endif
let s:loaded = 1

" Setup NERDTree listener callback.
call g:NERDTreePathNotifier.AddListener('init', 'NERDTreeHighlightOpenBuffers')
call g:NERDTreePathNotifier.AddListener('refresh', 'NERDTreeHighlightOpenBuffers')
call g:NERDTreePathNotifier.AddListener('refreshFlags', 'NERDTreeHighlightOpenBuffers')

function! NERDTreeHighlightOpenBuffers(event)
    let l:path = a:event.subject
    let l:flag = buflisted(expand(l:path.str())) ? s:open_buffer_glyph : ""
    call l:path.flagSet.clearFlags('highlight_open')
    if l:flag !=# ''
        call l:path.flagSet.addFlag('highlight_open', l:flag)
    endif
endfunction

" Autocmds to trigger NERDTree flag refreshes
augroup NERDTreeHighlightOpenBuffersPlugin
    autocmd CursorHold,BufEnter * silent! call s:RefreshFlags()
    autocmd BufDelete,BufWipeout * silent! set updatetime=10
    autocmd BufWritePost,BufReadPost  * silent! set updatetime& | call s:RefreshFlags()
augroup END
function! s:RefreshFlags()
    if g:NERDTree.IsOpen() && !exists('s:stop_recursion')
        let s:stop_recursion = 1
        let l:winnr = winnr()
        let l:altwinnr = winnr('#')

        call g:NERDTree.CursorToTreeWin()
        call b:NERDTree.root.refreshFlags()
        call NERDTreeRender()

        execute l:altwinnr . 'wincmd w'
        execute l:winnr . 'wincmd w'
    endif
    unlet! s:stop_recursion
endfunction

" Setup the syntax highlighting
" The open_buffer_glyph is used just to find the line in NERDTree for syntax
" highlighting. The line containing the glyph is highlighted (Special), and
" then the flag itself is concealed.
let s:open_buffer_glyph='○'
augroup AddHighlighting
    autocmd FileType nerdtree call s:AddHighlighting()
augroup END
function! s:AddHighlighting()
    execute 'syntax match NERDTreeOpenBuffer #\[.\{-}' . s:open_buffer_glyph . '.\{-}\].\+$# containedin=NERDTreeFile,NERDTreeLinkFile,NERDTreeExecFile,NERDTreeRO'
    highlight default link NERDTreeOpenBuffer Constant

    execute 'syntax match NERDTreeOpenBufferFlag #\[.\{-}' . s:open_buffer_glyph . '.\{-}\].# conceal contains=NERDTreeNodeDelimiters containedin=NERDTreeOpenBuffer'
    setlocal conceallevel=3
    setlocal concealcursor=nvic
endfunction
