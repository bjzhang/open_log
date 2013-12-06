set breakpoint pending on

set logging on

#break libxl_osevent_occurred_fd
#commands
#silent
#shell date +%H%M%S_%N
#printf "libxl_osevent_occurred_fd\n"
#where 3
#cont
#end

break libxl__ao_complete_check_progress_reports
commands
silent
shell date +%H%M%S_%N
printf "libxl__ao_complete_check_progress_reports\n"
where 3
cont
end

break libxl/libxl_driver.c:521
commands
silent
shell date +%H%M%S_%N
printf "libxlEventHandler: priv: %x, event: %x\n", priv, event
where 3
cont
end

break libxl/libxl_driver.c:538
commands
silent
shell date +%H%M%S_%N
printf "libxlEventHandler: priv: %lx, event: %lx\n", priv, cp
where 3
cont
end

break libxl/libxl_driver.c:451
commands
silent
shell date +%H%M%S_%N
printf "libxlEventHandlerThread: priv: %lx event: %lx\n", priv, event
#where 3
cont
end

break libxlDomainObjPrivateInitCtx
commands
silent
shell date +%H%M%S_%N
printf "libxlDomainObjPrivateInitCtx\n"
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

break childproc_reaped
commands
silent
shell date +%H%M%S_%N
printf "childproc_reaped: %d\n", pid
where 3
cont
end

cont

