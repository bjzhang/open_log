set breakpoint pending on

set logging on

break libxl_osevent_occurred_fd
commands
silent
shell date +%H%M%S_%N
printf "libxl_osevent_occurred_fd\n"
where 3
cont
end

break libxl__ao_complete_check_progress_reports
commands
silent
shell date +%H%M%S_%N
printf "libxl__ao_complete_check_progress_reports\n"
where 3
cont
end

break libxlEventHandler
commands
silent
shell date +%H%M%S_%N
printf "libxlEventHandler\n"
where 3
cont
end

#in libxl lib
break libxl__event_occurred
commands
silent
shell date +%H%M%S_%N
printf "libxl__event_occurred\n"
where 3
cont
end

cont

