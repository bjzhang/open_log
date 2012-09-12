set breakpoint pending on

set logging on

break libxlClose
commands
silent
printf "libxlClose\n"
where
cont
end

cont
