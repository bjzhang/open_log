set breakpoint pending on

set logging on

break libxl_osevent_occurred_timeout
commands
silent
printf "libxl_osevent_occurred_timeout\n"
end
cont

