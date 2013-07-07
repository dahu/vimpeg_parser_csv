" Vim global plugin for CSV files (alpha, demo)
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	A demonstration of the VimPEG PEG parser generator library
" Last Change:	2013-05-07
" License:	Vim License (see :help license)
" Location:	plugin/vimpeg_parser_csv.vim
" Website:	https://github.com/dahu/vimpeg_parser_csv

let g:vimpeg_parser_csv_version = '0.1'


" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Options: {{{1
if !exists('g:vimpeg_parser_csv_statusline')
  let g:vimpeg_parser_csv_statusline = 1
endif

let g:vimpeg_parser_csv_separator = get(g:, 'vimpeg_parser_csv_separator', ',')

" Public Interface: {{{1
function! CSV_Column()
  let col = col('.') - 2
  if col == -1
    return 1
  endif
  let col = col < 0 ? 0 : col
  if col == 0
    return 1
  endif
  let data = getline('.')[0:col]
  if data =~ '^\s*$'
    return 1
  endif
  " balance dqstrings if cursor is inside one
  if len(substitute(data, '[^"]', '', 'g')) % 2 == 1
    let data .= '"'
  endif
  let recs = g:csv#parser.match(data)
  return recs['is_matched'] ? len(recs['value'][0]) : 1
endfunction

" Example of showing the current CSV column in the status-line {{{2
if g:vimpeg_parser_csv_statusline != 0
  if &statusline != ''
    let &statusline .= '[col %{CSV_Column()}]'
  endif
endif
"}}}

function! CSV_Parse(fline, lline)
  let lines = getline(a:fline, a:lline)
  return g:csv#parser.match(join(lines, "\n"))['value']
endfunction

function! CSV_Print(records, separator)
  for rec in a:records
    call append(line('.')-1, join(rec, a:separator))
  endfor
endfunction

function! CSV_Separator(sep)
  let g:vimpeg_parser_csv_separator = a:sep
  call csv#generate_parser()
endfunction

call csv#generate_parser()


" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
