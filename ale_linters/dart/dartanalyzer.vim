" Author: w0rp <devw0rp@gmail.com>
" Description: Check Dart files with dartanalyzer

call ale#Set('dart_dartanalyzer_executable', 'dartanalyzer')

function! ale_linters#dart#dartanalyzer#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'dart_dartanalyzer_executable')
endfunction

function! ale_linters#dart#dartanalyzer#GetCommand(buffer) abort
    let l:executable = ale_linters#dart#dartanalyzer#GetExecutable(a:buffer)
    let l:path = ale#path#FindNearestFile(a:buffer, '.packages')

    return ale#Escape(l:executable)
    \   . (!empty(l:path) ? ' --packages ' . ale#Escape(l:path) : '')
    \   . ' %t'
endfunction

function! ale_linters#dart#dartanalyzer#Handle(buffer, lines) abort
    let l:pattern = '\v^  ([a-z]+) . (.+) at (.+):(\d+):(\d+) . (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'type': l:match[1] ==# 'error' ? 'E' : 'W',
        \   'text': l:match[6] . ': ' . l:match[2],
        \   'lnum': str2nr(l:match[4]),
        \   'col': str2nr(l:match[5]),
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('dart', {
\   'name': 'dartanalyzer',
\   'executable_callback': 'ale_linters#dart#dartanalyzer#GetExecutable',
\   'command_callback': 'ale_linters#dart#dartanalyzer#GetCommand',
\   'callback': 'ale_linters#dart#dartanalyzer#Handle',
\})
