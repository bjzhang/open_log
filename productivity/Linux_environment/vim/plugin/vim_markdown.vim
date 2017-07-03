
"insert - with number of last line
:map <C-\>2 :LogAssistantInsertMinusSign<CR>
command! -nargs=0 -bar LogAssistantInsertMinusSign call s:LogAssistant_insertMinusSign()

"insert - with number of last line
:map <C-\>3 :LogAssistantInsertEqualSign<CR>

"FIXME: 对中文字符宽度计算错误
:map <C-\>4 :LogAssistantFormatTable<CR>
command! -nargs=0 -bar LogAssistantFormatTable call s:LogAssistant_formatTable()

function! s:LogAssistant_insertMinusSign()
    let loc = line('.') - 1
    let len = strdisplaywidth(getline(loc))
    exe ":normal a" . repeat('-', len)
endfunction

command! -nargs=0 -bar LogAssistantInsertEqualSign call s:LogAssistant_insertEqualSign()
function! s:LogAssistant_insertEqualSign()
    let loc = line('.') - 1
    let len = strdisplaywidth(getline(loc))
    exe ":normal a" . repeat('=', len)
endfunction

function! s:LogAssistant_formatTable()
python << endpython
import vim
import re

(row, col) = vim.current.window.cursor
#buffer start from 0
table_header = vim.current.buffer[row - 1]
#print "table header is ", table_header
table_header_list = table_header.split('|')

row = row + 1

while len(vim.current.buffer[row - 1]):
    line = vim.current.buffer[row - 1]
#    print "<", row, "> ", line
    line_item_list = line.split(',')
    new_line = ""
    index = 0
    for ti in range(len(table_header_list)):
        table_item = table_header_list[ti]
#        print ti, table_item

        if index < len(line_item_list):
            line_item = line_item_list[index]
        else:
            break
#            line_item = ""

        line_item_len = len(line_item)

#        print line_item, line_item_len

        width = len(table_item) - line_item_len
        width_before = (width + 1) / 2
        width_after = width / 2
        new_line = new_line + " " * width_before + line_item
        if index < len(line_item_list) - 1 and ti < len(table_header_list) - 1:
            new_line = new_line + " " * width_after + "|"

        index = index + 1

    #print "result :<", new_line, ">\n"
#    new_line = re.sub("\|[ \|]*$", "|", new_line)
    #print "after strip: result :<", new_line, ">\n"
    vim.current.buffer[row - 1] = new_line

    if row < len(vim.current.buffer):
        vim.current.window.cursor = (row, col)
        row = row + 1
    else:
        break

vim.current.window.cursor = (row, col)
endpython
endfunction
