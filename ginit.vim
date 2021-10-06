"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The following code come from:
" https://www.vim.org/scripts/script.php?script_id=4723
" Distributed under Vim's |license|; see |fontdetect.txt| for details.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Detect installed fonts.

" Query Windows registry to return list of all installed font families.
function! s:_listFontFamiliesUsingWindowsRegistry()
    if !executable('reg')
        return []
    endif
    let regOutput = system('reg query "HKLM\SOFTWARE\Microsoft' .
                \ '\Windows NT\CurrentVersion\Fonts"')

    " Remove registry key at start of output.
    let regOutput = substitute(regOutput,
            \ '.\{-}HKEY_LOCAL_MACHINE.\{-}\n',
            \ '', '')

    " Remove blank lines.
    let regOutput = substitute(regOutput, '\n\n\+', '\n', 'g')

    " Extract font family from each line.  Lines have one of the following
    " formats; all begin with leading spaces and can have spaces in the
    " font family portion:
    "   Font family REG_SZ FontFilename
    "   Font family (TrueType) REG_SZ FontFilename
    "   Font family 1,2,3 (TrueType) REG_SZ FontFilename
    " Throw away everything before and after the font family.
    " Assume that any '(' is not part of the family name.
    " Assume digits followed by comma indicates point size.
    let regOutput = substitute(regOutput,
            \ ' *\(.\{-}\)\ *' .
            \ '\((\|\d\+,\|REG_SZ\)' .
            \ '.\{-}\n',
            \ '\1\n', 'g')

    return split(regOutput, '\n')
endfunction

" Double any quotes in string, then wrap with quotes for eval().
function! s:_quote(string)
    return "'" . substitute(a:string, "'", "''", 'g') . "'"
endfunction

if has('pythonx')
    let s:fontdetect_python = 'pythonx'
    let s:fontdetect_pyevalFunction = 'pyxeval'
elseif has('python3')
    let s:fontdetect_python = 'python3'
    let s:fontdetect_pyevalFunction = 'py3eval'
elseif has('python')
    let s:fontdetect_python = 'python'
    let s:fontdetect_pyevalFunction = 'pyeval'
else
    let s:fontdetect_python = ''
    let s:fontdetect_pyevalFunction = ''
endif

if s:fontdetect_python != ''

" Evaluate pythonSource using the detected version of Python.
function! s:_pyeval(pythonSource)
    let quotedSource = s:_quote(a:pythonSource)
    return eval(s:fontdetect_pyevalFunction . '(' . quotedSource . ')')
endfunction

function s:_setupPythonFunctions()
    " Python function for detecting installed font families using Cocoa.
    execute s:fontdetect_python . ' << endpython'
def fontdetect_listFontFamiliesUsingCocoa():
    try:
        import Cocoa
    except (ImportError, AttributeError):
        return []
    manager = Cocoa.NSFontManager.sharedFontManager()
    fontFamilies = list(manager.availableFontFamilies())
    return fontFamilies
endpython
endfunction

call s:_setupPythonFunctions()
endif

" Use Cocoa font manager to return list of all installed font families.
function! s:_listFontFamiliesUsingCocoa()
    if s:fontdetect_python != ''
        return s:_pyeval('fontdetect_listFontFamiliesUsingCocoa()')
    else
        return []
    endif
endfunction

" Use fontconfig's ``fc-list`` to return list of all installed font families.
function! s:_listFontFamiliesUsingFontconfig()
    if !executable('fc-list')
        return []
    endif
    let fcOutput = system("fc-list --format '%{family}\n'")
    return split(fcOutput, '\n')
endfunction

function! s:_fontDict()
    if exists('g:fontdetect#_cachedFontDict')
        return g:fontdetect#_cachedFontDict
    endif
    if has('win32')
        let families = s:_listFontFamiliesUsingWindowsRegistry()
    elseif has('macunix')
        let families = s:_listFontFamiliesUsingCocoa()
        if len(families) == 0
            " Try falling back on Fontconfig.
            let families = s:_listFontFamiliesUsingFontconfig()
        endif
    elseif executable('fc-list')
        let families = s:_listFontFamiliesUsingFontconfig()
    else
        let families = []
    endif
    if len(families) == 0
        echomsg 'No way to detect fonts'
    endif
    let g:fontdetect#_cachedFontDict = {}
    for fontFamily in families
        let g:fontdetect#_cachedFontDict[fontFamily] = 1
    endfor
    return g:fontdetect#_cachedFontDict
endfunction

" Public functions.

function! s:hasFontFamily(fontFamily)
    return has_key(s:_fontDict(), a:fontFamily)
endfunction

function! s:firstFontFamily(fontFamilies)
    for fontFamily in a:fontFamilies
        if s:hasFontFamily(fontFamily)
            return fontFamily
        endif
    endfor
    return ''
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Find available patched font
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:gui_font_list = [
            \"UbuntuMono NF",
            \"DejaVu Sans Mono Nerd Font Complete Mono Windows Compatible",
            \]

for font in s:gui_font_list
    if s:hasFontFamily(font)
        execute 'GuiFont' font . ':h12'
        break
    endif
endfor
