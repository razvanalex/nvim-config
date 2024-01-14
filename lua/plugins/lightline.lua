vim.opt.laststatus = 2
vim.opt.showmode = false

vim.g.lightline = {
	colorscheme = "powerline",
	active = {
		left = {
			{ "mymode", "paste" },
			{ "fugitive", "gitstatus", "readonly", "filename", "modified" },
		},
	},
	component_function = {
		mymode = "MyMode",
		readonly = "LightlineReadonly",
		fugitive = "LightlineFugitive",
		filetype = "MyFiletype",
		fileformat = "MyFileformat",
		gitstatus = "GitStatus",
	},
	component = {
		lineinfo = " %3l:%-2v",
	},
	separator = { left = "\u{e0b0}", right = "\u{e0b2}" },
	subseparator = { left = "\u{e0b1}", right = "\u{e0b3}" },
}

vim.cmd([[
function! MyMode()
    let _mode = lightline#mode()
    let mode_map = {
        \ 'NORMAL': 'N',
        \ 'INSERT': 'I',
        \ 'REPLACE': 'R',
        \ 'VISUAL': 'V',
        \ 'V-LINE': 'VL',
        \ 'V-BLOCK': 'VB',
        \ 'COMMAND': 'C',
        \ 'SELECT': 'S',
        \ 'S-LINE': 'SL',
        \ 'S-BLOCK': 'SB',
        \ 'TERMINAL': 'T',
    \ }
    return winwidth(0) > 80 ? _mode : mode_map[_mode]
endfunction

function! LightlineFilename()
    let filename = expand('%:t{strlen(&filetype)?&filetype:"no ft"}')
        return filename
    return '[No Name]'
endfunction

function! LightlineReadonly()
    return &readonly ? '' : ''
endfunction

function! LightlineFugitive()
    if exists('*fugitive#head')
        let branch = fugitive#head()
        return winwidth(0) > 60 ? (branch !=# '' ? ' '.branch : '') : ''
    endif
    return ''
endfunction

function! MyFiletype()
  return winwidth(0) > 80 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! MyFileformat()
  return winwidth(0) > 80 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! GitStatus()
    if exists('*fugitive#head') && fugitive#head() != ''
        let [a,m,r] = GitGutterGetHunkSummary()
        return winwidth(0) > 100 ? printf('+%d ~%d -%d', a, m, r) : ''
    endif
    return ''
endfunction
]])
