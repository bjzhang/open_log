set breakpoint pending on

set logging on

break xl.c:245
commands
print "set msg level as DEBUG"
set minmsglevel=XTL_DEBUG
print minmsglevel
cont
end

break bootloader_gotptys

