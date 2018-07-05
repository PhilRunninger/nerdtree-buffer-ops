" ============================================================================
" File:        bwipeout.vim
" Description: plugin for NERD Tree that provides a buffer wipeout command
" Notes:       The logic in NERDTreeBufWipeout is a modified version of that found here:
"              http://vim.wikia.com/wiki/Deleting_a_buffer_without_closing_the_window
" Maintainer:  Phil Runninger <prunninger at virtualhold dot com>
" ============================================================================
if exists("g:loaded_nerdtree_bwipeout")
    finish
endif
let g:loaded_nerdtree_bwipeout = 1

call NERDTreeAddKeyMap({
            \ 'key': 'w',
            \ 'callback': 'NERDTreeBufWipeout',
            \ 'quickhelpText': 'Wipeout file''s buffer',
            \ 'override': 0,
            \ 'scope': 'FileNode'})

function! NERDTreeBufWipeout(fileNode)
    let bufferNumber = bufnr(a:fileNode.path.str())
    if bufferNumber < 0 || !buflisted(bufferNumber)
        call nerdtree#echo(a:fileNode.path.displayString(). " is not open in any buffer.")
        return
    endif

    " Numbers of windows that view target buffer which we will wipeout.
    let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == bufferNumber')
    let wcurrent = winnr()

    " For each window the buffer is in, switch buffers.
    for w in wnums
        execute w.'wincmd w'
        let prevbuf = bufnr('#')
        if prevbuf > 0 && buflisted(prevbuf)
            buffer #
        else
            let availableBuffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != bufferNumber && bufwinnr(v:val) < 0')
            let bjump = (availableBuffers + [-1])[0]
            if bjump > 0
                execute 'buffer '.bjump
            else
                execute 'enew!'
            endif
        endif
    endfor

    execute 'confirm bwipeout'.' '.bufferNumber
    execute wcurrent.'wincmd w'
    call nerdtree#echo("Buffer ". bufferNumber ." [". a:fileNode.path.displayString() ."] was wiped out.")
endfunction
