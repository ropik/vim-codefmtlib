" Copyright 2014 Google Inc. All rights reserved.
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

""
" @section Introduction, intro
" @library
" This library is the interface between the |codefmt| plugin and other plugins
" that register formatters for codefmt. It offers no useful functionality by
" itself.


if !exists('s:formatters')
  let s:formatters = []
endif
if !exists('s:default_formatters')
  let s:default_formatters = []
endif


""
" @dict Formatter
" Interface for applying formatting to lines of code.
" Defines these fields:
"   * name (string): The formatter name that will be exposed to users.
"   * setup_instructions (string, optional): A string explaining to users how to
"     make the plugin available if not already available.
" and these functions:
"   * IsAvailable() -> boolean: Whether the formatter is fully functional with
"     all dependencies available. Returns 0 only if setup_instructions have not
"     been followed.
"   * AppliesToBuffer() -> boolean: Whether the current buffer is of a type
"     normally formatted by this formatter. Normally based on 'filetype', but
"     could depend on buffer name or other properties.
" and should implement at least one of the following functions:
"   * Format(): Formats the current buffer directly.
"   * FormatRange({startline}, {endline}): Formats the current buffer, focusing
"     on the range of lines from {startline} to {endline}.
"   * FormatRanges({ranges}): Formats the current buffer, focusing on the given
"     ranges of lines. Each range should be a 2-item list of
"     [startline,endline].
" Formatters should implement the most specific format method that is supported.

""
" Ensures that {formatter} is a valid formatter, and then prepares it for use by
" codefmt.  See @dict(Formatter) for the API {formatter} must implement.
" @throws WrongType if {formatter} is not a dict.
" @throws BadValue if {formatter} is missing required fields.
" Returns the fully prepared formatter.
function! s:EnsureFormatter(formatter) abort
  call maktaba#ensure#IsDict(a:formatter)
  let l:required_fields = ['name', 'IsAvailable', 'AppliesToBuffer']
  " Throw BadValue if any required fields are missing.
  let l:missing_fields =
      \ filter(copy(l:required_fields), '!has_key(a:formatter, v:val)')
  if !empty(l:missing_fields)
    throw maktaba#error#BadValue('a:formatter is missing fields: ' .
        \ join(l:missing_fields, ', '))
  endif

  " Throw BadValue if the wrong number of format functions are provided.
  let l:available_format_functions = ['Format', 'FormatRange', 'FormatRanges']
  let l:format_functions = filter(copy(l:available_format_functions),
        \ 'has_key(a:formatter, v:val)')
  if empty(l:format_functions)
    throw maktaba#error#BadValue('Formatter ' . a:formatter.name .
          \ ' has no format functions.  It must have at least one of ' .
          \ join(l:available_format_functions, ', '))
  endif

  " TODO(dbarnett): Check types.

endfunction

""
" Registers {formatter} as a supported formatter. See @dict(Formatter) for the
" API {formatter} must implement.
" @throws WrongType if {formatter} is not a dict.
" @throws BadValue if {formatter} is missing required fields.
function! codefmtlib#AddFormatter(formatter) abort
  call s:EnsureFormatter(a:formatter)
  let l:formatter = deepcopy(a:formatter)
  lockvar! l:formatter
  call add(s:formatters, l:formatter)
endfunction

""
" Registers {formatter} as a default formatter. Default formatters are serve as
" fallbacks if no customer formatter has been registered. See @dict(Formatter)
" for the API {formatter} must implement.
" @throws WrongType if {formatter} is not a dict.
" @throws BadValue if {formatter} is missing required fields.
function! codefmtlib#AddDefaultFormatter(formatter) abort
  call s:EnsureFormatter(a:formatter)
  let l:formatter = deepcopy(a:formatter)
  lockvar! l:formatter
  call add(s:default_formatters, l:formatter)
endfunction

""
" Returns a list of all registered formatters in order of their priority.
function! codefmtlib#GetFormatters() abort
  return s:formatters + s:default_formatters
endfunction
