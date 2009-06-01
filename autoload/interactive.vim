"=============================================================================
" FILE: interactive.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 31 May 2009
" Usage: Just source this file.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 1.11, for Vim 7.0
"-----------------------------------------------------------------------------
" ChangeLog: "{{{
"   1.11:
"     - Improved autocmd.
"   1.10:
"     - Use vimshell.
"   1.01:
"     - Compatible Windows and Linux.
"   1.00:
"     - Initial version.
" }}}
"-----------------------------------------------------------------------------
" TODO: "{{{
"     - Nothing.
""}}}
" Bugs"{{{
"     - Nothing.
""}}}
"=============================================================================

function! interactive#run(args)"{{{
    " Interactive execute command.
    if !g:VimShell_EnableInteractive
        " Error.
        echohl WarningMsg | echo printf('Must use vimproc plugin.') | echohl None
        return
    endif

    " Exit previous command.
    call s:on_exit()

    let l:proc = proc#import()

    try
        if has('win32') || has('win64')
            let l:sub = l:proc.popen2(a:args)
        else
            let l:sub = l:proc.ptyopen(a:args)
        endif
    catch
        echohl WarningMsg | echo printf('File: "%s" is not found.', a:args[0]) | echohl None

        return
    endtry

    " Set variables.
    let b:proc = l:proc
    let b:sub = l:sub

    augroup interactive
        autocmd CursorHold <buffer>     call vimshell#utils#process#execute_out()
        autocmd BufDelete <buffer>      call s:on_exit()
    augroup END

    nnoremap <buffer><silent><C-c>       :<C-u>call <sid>on_exit()<CR>
    inoremap <buffer><silent><C-c>       <ESC>:<C-u>call <sid>on_exit()<CR>
    nnoremap <buffer><silent><CR>       :<C-u>call vimshell#utils#process#execute_out()<CR>

    call vimshell#utils#process#execute_out()
endfunction"}}}

function! s:on_exit()
    augroup interactive
        autocmd! * <buffer>
    augroup END

    call vimshell#utils#process#exit()
endfunction

" vim: foldmethod=marker