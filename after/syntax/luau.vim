syntax region complexString
    \ start=+`+
    \ end=+`+
    \ skip="\\`"
    \ contains=complex
    \ keepend

syntax region complex 
    \ start=+{+
    \ end=+}+
    \ contained
    \ containedin=complexString
    \ contains=ALL
    \ keepend

highlight link complexString String
