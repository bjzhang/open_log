set breakpoint pending on

set logging on

#function in libvirt
break evhook_fd_register
commands
silent
printf "evhook_fd_register\n"
where 3
cont
end

break evhook_fd_deregister
commands
silent
printf "evhook_fd_deregister\n"
where 3
cont
end

#function in xenlight 
break libxl_osevent_occurred_timeout
commands
silent
printf "libxl_osevent_occurred_timeout\n"
p *(libxl__ev_time*)for_libxl
cont
end

break libxl__ev_time_register_rel
commands
silent
printf "libxl__ev_time_register_rel: ev_time=%p register ms=%d\n", ev, milliseconds
cont
end

break libxl__ev_time_modify_rel
commands
silent
printf "libxl__ev_time_modify_rel\n"
cont
end

break time_insert_finite
commands
silent
printf "time_insert_finite\n"
cont
end

break time_register_finite
commands
silent
printf "time_register_finite\n"
cont
end

break libxl__ev_time_modify_abs
commands
silent
printf "libxl__ev_time_modify_abs\n"
cont
end

#break virEventPollAddHandle
#commands
#cont
#end
#
#break virEventPollDispatchHandles
#commands
#cont
#end
#

break libxl__ev_fd_register
commands
#silent
printf "libxl__ev_fd_register\n"
where 3
cont
end

break libxl__ev_fd_deregister
commands
#silent
printf "libxl__ev_fd_deregister: fd<%d>\n", ev->fd
where 3
cont
end


cont

