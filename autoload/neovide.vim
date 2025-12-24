function! neovide#load() abort
    let s:guifont = "KawaiiMono"
    let s:guifontsize = 18
    
    function! ApplyFont() abort
        execute "set guifont=" .. s:guifont .. ":h" .. s:guifontsize
    endfunction

    function! SetFontSize(size) abort
        let s:guifont = a:size
        call ApplyFont()
    endfunction

    function! SetFont(font) abort
        let s:guifont = a:font
        call ApplyFont()
    endfunction

    function! AdjustFontSize(amount) abort
        let s:guifontsize = s:guifontsize + a:amount
        call ApplyFont()
    endfunction

    command! -nargs=1 Font call SetFont(<args>)
    command! -nargs=1 FontSize call SetFontSize(<args>)
    
    " Add FontSize Scale
    nnoremap <C-+> <cmd>call AdjustFontSize(+1)<cr>

    " Sub FontSize Scale
    nnoremap <C--> <cmd>call AdjustFontSize(-1)<cr>

    call ApplyFont()
endfunction
